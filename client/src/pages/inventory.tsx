import { useQuery } from "@tanstack/react-query";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { Label } from "@/components/ui/label";
import { useState, useMemo, useRef } from "react";
import { usePersistedState } from "@/lib/persisted-state";
import type { Course, UserProfile } from "@shared/schema";
import { ChevronDown, ChevronRight, Download, Upload, Package, AlertTriangle } from "lucide-react";
import { useToast } from "@/hooks/use-toast";
import { queryClient } from "@/lib/queryClient";

const INVENTORY_STUDENT_IDS = [9996, 9997, 9998, 9999];
const INVENTORY_NAMES: Record<number, string> = {
  9996: "Inventory Kindergarten",
  9997: "Inventory ABCs",
  9998: "Inventory Juniors",
  9999: "Inventory Seniors",
};

type InventoryRow = {
  inventoryId: number;
  paceVersionId: number;
  yearRevised: number | null;
  type: "PACE" | "Score Key" | "Material" | null;
  edition: number | null;
  paceId: number;
  paceNumber: number | null;
  courseId: number | null;
  courseName: string | null;
  studentId: number;
  studentSurname: string;
  studentCallName: string;
  numberInPossession: number | null;
};

type GroupedRow = {
  paceVersionId: number;
  paceId: number;
  paceNumber: number | null;
  courseId: number | null;
  courseName: string | null;
  yearRevised: number | null;
  type: "PACE" | "Score Key" | "Material" | null;
  edition: number | null;
  total: number;
  entries: InventoryRow[];
};

type ImportResult = {
  sessionId: string; newCount: number; conflictCount: number; skippedIdentical: number;
  errors: string[]; conflicts: { index: number; excelRow: any; dbRow: any }[];
};

function ImportConflictDialog({ result, onResolve, onClose }: { result: ImportResult; onResolve: (sessionId: string, choices: string[], overrideAll?: boolean) => void; onClose: () => void }) {
  const [choices, setChoices] = useState<Record<number, "excel" | "skip">>(
    Object.fromEntries(result.conflicts.map((_, i) => [i, "skip"]))
  );
  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent className="max-w-3xl max-h-[80vh] overflow-y-auto">
        <DialogHeader><DialogTitle>Import Conflicts – Inventory</DialogTitle></DialogHeader>
        <div className="space-y-3 text-sm">
          <p className="text-muted-foreground">{result.newCount} new · {result.conflictCount} conflicts · {result.skippedIdentical} identical (skipped)</p>
          {result.errors.length > 0 && (
            <div className="p-3 bg-destructive/10 rounded text-destructive text-xs space-y-1">
              {result.errors.slice(0, 5).map((e, i) => <p key={i}>{e}</p>)}
              {result.errors.length > 5 && <p>…and {result.errors.length - 5} more</p>}
            </div>
          )}
          {result.conflicts.length > 0 && (
            <div className="space-y-2">
              <div className="flex gap-2">
                <Button size="sm" variant="outline" onClick={() => setChoices(Object.fromEntries(result.conflicts.map((_, i) => [i, "excel"])))}>Select All: Use Excel</Button>
                <Button size="sm" variant="outline" onClick={() => setChoices(Object.fromEntries(result.conflicts.map((_, i) => [i, "skip"])))}>Select All: Skip</Button>
              </div>
              {result.conflicts.map(c => (
                <Card key={c.index} className="text-xs">
                  <CardContent className="pt-3 pb-2 flex items-center justify-between gap-4">
                    <div>
                      <p className="font-medium">PaceVersion {c.excelRow.paceVersionsId} / Student {c.excelRow.studentId}</p>
                      <p>Current: <strong>{c.dbRow.numberInPossession}</strong> → Excel: <strong className="text-primary">{c.excelRow.numberInPossession}</strong></p>
                    </div>
                    <div className="flex gap-1 shrink-0">
                      <Button size="sm" variant={choices[c.index] === "excel" ? "default" : "outline"} className="h-7 text-xs" onClick={() => setChoices(p => ({ ...p, [c.index]: "excel" }))}>Use Excel</Button>
                      <Button size="sm" variant={choices[c.index] === "skip" ? "secondary" : "outline"} className="h-7 text-xs" onClick={() => setChoices(p => ({ ...p, [c.index]: "skip" }))}>Skip</Button>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          )}
        </div>
        <DialogFooter className="gap-2">
          <Button variant="outline" onClick={onClose}>Cancel</Button>
          <Button variant="outline" onClick={() => onResolve(result.sessionId, [], true)}>Override All</Button>
          <Button onClick={() => onResolve(result.sessionId, result.conflicts.map((_, i) => choices[i] || "skip"))}>Apply Selections</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

export default function InventoryPage() {
  const { toast } = useToast();
  const fileRef = useRef<HTMLInputElement>(null);

  const [showInventoryOnly, setShowInventoryOnly] = usePersistedState<boolean>("inventory.showInventoryOnly", false);
  const [typeFilter, setTypeFilter] = usePersistedState<string>("inventory.typeFilter", "all");
  const [courseFilter, setCourseFilter] = usePersistedState<string>("inventory.courseFilter", "all");
  const [paceNumberSearch, setPaceNumberSearch] = usePersistedState<string>("inventory.paceNumberSearch", "");
  const [expandedRows, setExpandedRows] = useState<Set<number>>(new Set());
  const [importResult, setImportResult] = useState<ImportResult | null>(null);

  const { data: inventoryRows, isLoading } = useQuery<InventoryRow[]>({ queryKey: ["/api/inventory"] });
  const { data: courses } = useQuery<Course[]>({ queryKey: ["/api/courses"] });
  const { data: profile } = useQuery<UserProfile>({ queryKey: ["/api/profile"] });

  const isTeacher = profile?.role === "teacher";

  const courseMap = useMemo(() => new Map(courses?.map(c => [c.id, c]) || []), [courses]);
  const uniqueCourseIds = useMemo(() => {
    if (!inventoryRows) return [];
    return [...new Set(inventoryRows.filter(r => r.courseId != null).map(r => r.courseId!))];
  }, [inventoryRows]);

  const filteredRows = useMemo(() => {
    if (!inventoryRows) return [];
    let rows = inventoryRows;
    if (showInventoryOnly) rows = rows.filter(r => INVENTORY_STUDENT_IDS.includes(r.studentId));
    if (typeFilter !== "all") rows = rows.filter(r => r.type === typeFilter);
    if (courseFilter !== "all") rows = rows.filter(r => r.courseId === parseInt(courseFilter));
    if (paceNumberSearch) rows = rows.filter(r => String(r.paceNumber || "").includes(paceNumberSearch));
    return rows;
  }, [inventoryRows, showInventoryOnly, typeFilter, courseFilter, paceNumberSearch]);

  const grouped = useMemo<GroupedRow[]>(() => {
    const map = new Map<number, GroupedRow>();
    for (const row of filteredRows) {
      const key = row.paceVersionId;
      if (!map.has(key)) {
        map.set(key, {
          paceVersionId: row.paceVersionId, paceId: row.paceId, paceNumber: row.paceNumber,
          courseId: row.courseId, courseName: row.courseName, yearRevised: row.yearRevised,
          type: row.type, edition: row.edition, total: 0, entries: [],
        });
      }
      const g = map.get(key)!;
      g.total += row.numberInPossession || 0;
      g.entries.push(row);
    }
    return [...map.values()].sort((a, b) => (a.paceNumber || 0) - (b.paceNumber || 0));
  }, [filteredRows]);

  const totalItems = useMemo(() => grouped.reduce((s, g) => s + g.total, 0), [grouped]);

  const toggleRow = (id: number) => {
    setExpandedRows(prev => {
      const next = new Set(prev);
      next.has(id) ? next.delete(id) : next.add(id);
      return next;
    });
  };

  const typeLabel = (t: string | null) => {
    if (t === "PACE") return <Badge className="text-xs bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200 border-blue-300">PACE</Badge>;
    if (t === "Score Key") return <Badge className="text-xs bg-amber-100 text-amber-800 dark:bg-amber-900 dark:text-amber-200 border-amber-300">Score Key</Badge>;
    if (t === "Material") return <Badge className="text-xs bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200 border-green-300">Material</Badge>;
    return <Badge variant="outline" className="text-xs">—</Badge>;
  };

  const studentName = (row: InventoryRow) => {
    if (INVENTORY_STUDENT_IDS.includes(row.studentId)) return INVENTORY_NAMES[row.studentId] || `#${row.studentId}`;
    return `${row.studentCallName} ${row.studentSurname}`.trim() || `#${row.studentId}`;
  };

  const handleImportUpload = async (file: File) => {
    const formData = new FormData();
    formData.append("file", file);
    try {
      const res = await fetch("/api/inventory/import", { method: "POST", body: formData, credentials: "include" });
      const data = await res.json();
      if (!res.ok) { toast({ title: "Import failed", description: data.message, variant: "destructive" }); return; }
      if (data.conflictCount === 0 && data.newCount > 0) {
        await fetch("/api/inventory/import/resolve", { method: "POST", headers: { "Content-Type": "application/json" }, credentials: "include", body: JSON.stringify({ sessionId: data.sessionId, choices: [], overrideAll: false }) });
        queryClient.invalidateQueries({ queryKey: ["/api/inventory"] });
        toast({ title: "Import complete", description: `${data.newCount} inserted, ${data.skippedIdentical} skipped` });
      } else if (data.conflictCount > 0 || data.newCount > 0) {
        setImportResult(data);
      } else {
        toast({ title: "Nothing to import", description: `${data.skippedIdentical} identical rows skipped` });
      }
    } catch (e: any) { toast({ title: "Upload failed", description: e.message, variant: "destructive" }); }
  };

  const handleResolve = async (sessionId: string, choices: string[], overrideAll = false) => {
    try {
      const res = await fetch("/api/inventory/import/resolve", { method: "POST", headers: { "Content-Type": "application/json" }, credentials: "include", body: JSON.stringify({ sessionId, choices, overrideAll }) });
      const data = await res.json();
      if (!res.ok) { toast({ title: "Failed", description: data.message, variant: "destructive" }); return; }
      queryClient.invalidateQueries({ queryKey: ["/api/inventory"] });
      toast({ title: "Import applied", description: `${data.inserted} inserted, ${data.updated} updated, ${data.skipped} skipped` });
      setImportResult(null);
    } catch (e: any) { toast({ title: "Failed", description: e.message, variant: "destructive" }); }
  };

  return (
    <div className="p-6 max-w-6xl mx-auto space-y-6">
      <div className="flex items-start justify-between gap-4">
        <div>
          <h1 className="text-2xl font-serif font-bold tracking-tight" data-testid="text-page-title">Inventory</h1>
          <p className="text-muted-foreground mt-1">Track how many of each PACE version are in stock and with whom.</p>
        </div>
        {isTeacher && (
          <div className="flex items-center gap-2 shrink-0">
            <Button variant="outline" size="sm" onClick={() => window.open("/api/inventory/template", "_blank")} data-testid="button-download-inv-template">
              <Download className="h-4 w-4 mr-1" /> Template
            </Button>
            <Button variant="outline" size="sm" onClick={() => fileRef.current?.click()} data-testid="button-import-inventory">
              <Upload className="h-4 w-4 mr-1" /> Import
            </Button>
            <input ref={fileRef} type="file" accept=".xlsx,.xls" className="hidden" onChange={e => { const f = e.target.files?.[0]; if (f) handleImportUpload(f); e.target.value = ""; }} />
          </div>
        )}
      </div>

      <div className="grid sm:grid-cols-3 gap-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between gap-1 space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Unique PACE Versions</CardTitle>
            <Package className="w-4 h-4 text-chart-1" />
          </CardHeader>
          <CardContent><p className="text-2xl font-bold" data-testid="text-inv-versions">{grouped.length}</p></CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between gap-1 space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Total Items in Stock</CardTitle>
            <Package className="w-4 h-4 text-chart-2" />
          </CardHeader>
          <CardContent><p className="text-2xl font-bold" data-testid="text-inv-total">{totalItems}</p></CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between gap-1 space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Inventory Locations</CardTitle>
            <Package className="w-4 h-4 text-chart-3" />
          </CardHeader>
          <CardContent><p className="text-2xl font-bold">4</p></CardContent>
        </Card>
      </div>

      <div className="flex flex-wrap items-end gap-4">
        <div className="flex items-center gap-2">
          <Checkbox
            id="inv-only"
            checked={showInventoryOnly}
            onCheckedChange={v => setShowInventoryOnly(!!v)}
            data-testid="checkbox-inventory-only"
          />
          <label htmlFor="inv-only" className="text-sm font-medium cursor-pointer select-none">Show only PACEs in inventory locations</label>
        </div>
        <div className="space-y-1.5">
          <label className="text-sm font-medium">Type</label>
          <Select value={typeFilter} onValueChange={setTypeFilter}>
            <SelectTrigger className="w-[160px]" data-testid="select-type-filter"><SelectValue /></SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Types</SelectItem>
              <SelectItem value="PACE">PACE</SelectItem>
              <SelectItem value="Score Key">Score Key</SelectItem>
              <SelectItem value="Material">Material</SelectItem>
            </SelectContent>
          </Select>
        </div>
        <div className="space-y-1.5">
          <label className="text-sm font-medium">Course</label>
          <Select value={courseFilter} onValueChange={setCourseFilter}>
            <SelectTrigger className="w-[220px]" data-testid="select-course-filter"><SelectValue /></SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Courses</SelectItem>
              {uniqueCourseIds.map(cid => {
                const c = courseMap.get(cid);
                return <SelectItem key={cid} value={cid.toString()}>{c?.icceAlias || c?.aceAlias || `#${cid}`}</SelectItem>;
              })}
            </SelectContent>
          </Select>
        </div>
        <div className="space-y-1.5">
          <label className="text-sm font-medium">PACE number</label>
          <Input
            value={paceNumberSearch}
            onChange={e => setPaceNumberSearch(e.target.value)}
            placeholder="Search…"
            className="w-[140px]"
            data-testid="input-pace-number-filter"
          />
        </div>
      </div>

      <Card>
        <CardHeader>
          <CardTitle className="text-base">PACE Versions ({grouped.length})</CardTitle>
        </CardHeader>
        <CardContent className="p-0">
          {isLoading ? (
            <div className="py-12 text-center text-muted-foreground text-sm">Loading inventory…</div>
          ) : grouped.length === 0 ? (
            <div className="py-12 text-center text-muted-foreground text-sm">No inventory records found.</div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-sm" data-testid="table-inventory">
                <thead>
                  <tr className="border-b bg-muted/30">
                    <th className="w-8" />
                    <th className="text-left py-3 px-3 font-medium text-muted-foreground">PACE #</th>
                    <th className="text-left py-3 px-3 font-medium text-muted-foreground">Course</th>
                    <th className="text-center py-3 px-3 font-medium text-muted-foreground">Type</th>
                    <th className="text-center py-3 px-3 font-medium text-muted-foreground">Year Revised</th>
                    <th className="text-center py-3 px-3 font-medium text-muted-foreground">Edition</th>
                    <th className="text-center py-3 px-3 font-medium text-muted-foreground">Total in Stock</th>
                  </tr>
                </thead>
                <tbody>
                  {grouped.map(g => {
                    const expanded = expandedRows.has(g.paceVersionId);
                    return [
                      <tr
                        key={g.paceVersionId}
                        className="border-b hover:bg-muted/20 cursor-pointer"
                        onClick={() => toggleRow(g.paceVersionId)}
                        data-testid={`row-inv-${g.paceVersionId}`}
                      >
                        <td className="py-3 px-2 text-center text-muted-foreground">
                          {expanded ? <ChevronDown className="h-4 w-4 mx-auto" /> : <ChevronRight className="h-4 w-4 mx-auto" />}
                        </td>
                        <td className="py-3 px-3 font-mono font-medium">{g.paceNumber ?? "—"}</td>
                        <td className="py-3 px-3">{g.courseName || "—"}</td>
                        <td className="py-3 px-3 text-center">{typeLabel(g.type)}</td>
                        <td className="py-3 px-3 text-center text-muted-foreground">{g.yearRevised ?? "—"}</td>
                        <td className="py-3 px-3 text-center text-muted-foreground">{g.edition ?? "—"}</td>
                        <td className="py-3 px-3 text-center font-semibold">{g.total}</td>
                      </tr>,
                      expanded && (
                        <tr key={`${g.paceVersionId}-details`}>
                          <td colSpan={7} className="pb-2 pt-0 px-4 bg-muted/10">
                            <table className="w-full text-xs mt-1">
                              <thead>
                                <tr className="text-muted-foreground">
                                  <th className="text-left py-1 px-2">Student / Location</th>
                                  <th className="text-center py-1 px-2">In possession</th>
                                </tr>
                              </thead>
                              <tbody>
                                {g.entries.map(e => (
                                  <tr key={e.inventoryId} className="border-t border-muted" data-testid={`row-inv-entry-${e.inventoryId}`}>
                                    <td className="py-1.5 px-2">
                                      <span className={INVENTORY_STUDENT_IDS.includes(e.studentId) ? "font-medium text-primary" : ""}>
                                        {studentName(e)}
                                      </span>
                                    </td>
                                    <td className="py-1.5 px-2 text-center font-semibold">{e.numberInPossession ?? 0}</td>
                                  </tr>
                                ))}
                              </tbody>
                            </table>
                          </td>
                        </tr>
                      ),
                    ];
                  })}
                </tbody>
              </table>
            </div>
          )}
        </CardContent>
      </Card>

      {importResult && (
        <ImportConflictDialog result={importResult} onResolve={handleResolve} onClose={() => setImportResult(null)} />
      )}
    </div>
  );
}
