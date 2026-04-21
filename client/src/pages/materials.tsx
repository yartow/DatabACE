import { useQuery, useMutation } from "@tanstack/react-query";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu";
import { Switch } from "@/components/ui/switch";
import { useState, useMemo, useRef, Fragment } from "react";
import { usePersistedState } from "@/lib/persisted-state";
import type { Course, Pace, PaceCourse, Subject, SubjectGroup, UserProfile } from "@shared/schema";
import { BookOpen, Package, Link2, Pencil, Check, X, Plus, Upload, Download, ChevronDown, ChevronUp, ChevronsUpDown, ArrowUp, ArrowDown, AlertTriangle, Loader2, Trash2 } from "lucide-react";
import { Command, CommandEmpty, CommandGroup, CommandInput, CommandItem, CommandList } from "@/components/ui/command";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { apiRequest, queryClient } from "@/lib/queryClient";
import { useToast } from "@/hooks/use-toast";

const COURSE_TYPES = ["Core", "CourseWork", "Further Credit Option"] as const;

function AddPacesDialog({ course, onClose, onSaved }: { course: Course; onClose: () => void; onSaved: () => void }) {
  const { toast } = useToast();
  const { data: paceCourses } = useQuery<PaceCourse[]>({ queryKey: ["/api/pace-courses"] });
  const existing = paceCourses?.filter(pc => pc.courseId === course.id) || [];
  const [paceCount, setPaceCount] = useState("");
  const [paceEntries, setPaceEntries] = useState<{ number: string }[]>([]);
  const [deletingId, setDeletingId] = useState<number | null>(null);

  const handlePaceCountChange = (val: string) => {
    setPaceCount(val);
    const n = parseInt(val);
    if (!isNaN(n) && n >= 0 && n <= 50) {
      setPaceEntries(prev => {
        const arr = [...prev];
        while (arr.length < n) arr.push({ number: "" });
        return arr.slice(0, n);
      });
    }
  };

  const addMutation = useMutation({
    mutationFn: async () => {
      const valid = paceEntries.filter(e => e.number.trim() !== "");
      await apiRequest("POST", `/api/courses/${course.id}/paces`, {
        paceData: valid.map(e => ({ number: e.number })),
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/pace-courses"] });
      queryClient.invalidateQueries({ queryKey: ["/api/paces"] });
      toast({ title: "PACEs added" });
      setPaceCount("");
      setPaceEntries([]);
    },
    onError: (err: Error) => toast({ title: "Failed", description: err.message, variant: "destructive" }),
  });

  const deleteMutation = useMutation({
    mutationFn: async (pcId: number) => {
      setDeletingId(pcId);
      await apiRequest("DELETE", `/api/pace-courses/${pcId}`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/pace-courses"] });
      queryClient.invalidateQueries({ queryKey: ["/api/paces"] });
      toast({ title: "PACE removed" });
    },
    onError: (err: Error) => toast({ title: "Failed", description: err.message, variant: "destructive" }),
    onSettled: () => setDeletingId(null),
  });

  const isBusy = addMutation.isPending || deleteMutation.isPending;

  const scrollIntoView = (e: React.FocusEvent<HTMLInputElement>) => {
    setTimeout(() => e.target.scrollIntoView({ behavior: "smooth", block: "nearest" }), 150);
  };

  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent className="max-w-xl max-h-[80dvh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>Add/Edit PACEs — {course.icceAlias || course.aceAlias || `Course ${course.id}`}</DialogTitle>
        </DialogHeader>
        {existing.length > 0 && (
          <div className="space-y-1">
            <p className="text-sm font-medium text-muted-foreground">Existing PACEs ({existing.length})</p>
            <div className="rounded border divide-y text-xs">
              {existing.map(pc => (
                <div key={pc.id} className="flex items-center justify-between px-3 py-1.5">
                  <span className="font-mono">PACE #{pc.number}</span>
                  <div className="flex items-center gap-3">
                    <Button
                      size="icon"
                      variant="ghost"
                      className="h-6 w-6 text-destructive hover:text-destructive"
                      disabled={isBusy}
                      onClick={() => deleteMutation.mutate(pc.id)}
                      data-testid={`button-delete-pace-${pc.id}`}
                    >
                      {deletingId === pc.id ? <Loader2 className="h-3 w-3 animate-spin" /> : <Trash2 className="h-3 w-3" />}
                    </Button>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}
        <div className="space-y-4 pt-2 border-t">
          <div className="space-y-1.5">
            <Label>Number of new PACEs to add</Label>
            <Input type="number" min="0" max="50" value={paceCount} onChange={e => handlePaceCountChange(e.target.value)} onFocus={scrollIntoView} placeholder="e.g. 3" className="w-32" disabled={isBusy} data-testid="input-add-pace-count" />
          </div>
          {paceEntries.length > 0 && (
            <div className="space-y-2">
              <Label>PACE numbers</Label>
              <div className="grid grid-cols-3 gap-2">
                {paceEntries.map((entry, i) => (
                  <div key={i} className="space-y-1">
                    <label className="text-xs text-muted-foreground">#{i + 1}</label>
                    <Input
                      type="text"
                      value={entry.number}
                      onChange={e => setPaceEntries(prev => { const arr = [...prev]; arr[i] = { number: e.target.value }; return arr; })}
                      onFocus={scrollIntoView}
                      placeholder="bijv. 1001 of 1–2"
                      className="text-center"
                      disabled={isBusy}
                      data-testid={`input-add-pace-number-${i}`}
                    />
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={onClose} disabled={isBusy}>Close</Button>
          {paceEntries.length > 0 && (
            <Button onClick={() => addMutation.mutate()} disabled={isBusy} data-testid="button-save-paces">
              {addMutation.isPending ? <><Loader2 className="h-4 w-4 animate-spin mr-2" />Adding…</> : "Add PACEs"}
            </Button>
          )}
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

function EditableCourseRow({ c, subjectMap, subjectGroupMap, starValue, colSpan, onCancel, onSaved }: { c: Course; subjectMap: Map<number, Subject>; subjectGroupMap: Map<number, SubjectGroup>; starValue?: number; colSpan: number; onCancel: () => void; onSaved: () => void }) {
  const { toast } = useToast();
  const [icceAlias, setIcceAlias] = useState(c.icceAlias || "");
  const [icceId, setIcceId] = useState(c.icceId || "");
  const [aceAlias, setAceAlias] = useState(c.aceAlias || "");
  const [certificateName, setCertificateName] = useState(c.certificateName || "");
  const [level, setLevel] = useState(c.level?.toString() || "");
  const [passThreshold, setPassThreshold] = useState(c.passThreshold != null ? Math.round(c.passThreshold * 100).toString() : "");
  const [courseType, setCourseType] = useState(c.courseType || "");
  const [remarks, setRemarks] = useState(c.remarks || "");
  const [credits, setCredits] = useState(c.credits?.toString() || "");
  const [active, setActive] = useState((c.active ?? 1) === 1);
  const [showPacesDialog, setShowPacesDialog] = useState(false);

  const mutation = useMutation({
    mutationFn: async () => {
      await apiRequest("PATCH", `/api/courses/${c.id}`, {
        icceAlias: icceAlias || null,
        icceId: icceId ? icceId.slice(0, 10) : null,
        aceAlias: aceAlias || null,
        certificateName: certificateName || null,
        level: level ? parseInt(level) : null,
        passThreshold: passThreshold ? parseFloat(passThreshold) / 100 : null,
        credits: credits ? parseFloat(credits) : null,
        courseType: courseType || null,
        remarks: remarks || null,
        active: active ? 1 : 0,
      });
      await queryClient.invalidateQueries({ queryKey: ["/api/courses"] });
    },
    onSuccess: () => {
      toast({ title: "Course updated" });
      onSaved();
    },
    onError: (err: Error) => toast({ title: "Failed", description: err.message, variant: "destructive" }),
  });

  const subj = c.subjectId ? subjectMap.get(c.subjectId) : null;
  const grp = c.subjectGroupId ? subjectGroupMap.get(c.subjectGroupId) : null;

  return (
    <>
      <tr className="border-b border-b-0 bg-muted/20" data-testid={`row-course-edit-${c.id}`}>
        <td className="py-2 px-2">
          <Input value={icceAlias} onChange={e => setIcceAlias(e.target.value)} className="h-7 text-xs" disabled={mutation.isPending} data-testid="input-edit-course-name" />
        </td>
        <td className="text-center py-2 px-2">
          <Badge variant="secondary">{subj?.subject || "—"}</Badge>
        </td>
        <td className="text-center py-2 px-2 text-muted-foreground text-xs">{grp?.subjectGroup || "—"}</td>
        <td className="text-center py-2 px-2">
          <Input value={level} onChange={e => setLevel(e.target.value)} className="h-7 w-16 text-xs text-center mx-auto" disabled={mutation.isPending} data-testid="input-edit-course-level" />
        </td>
        <td className="text-center py-2 px-2">
          <Input value={credits} onChange={e => setCredits(e.target.value)} className="h-7 w-16 text-xs text-center mx-auto" disabled={mutation.isPending} data-testid="input-edit-course-credits" placeholder="0" />
        </td>
        <td className="text-center py-2 px-2">
          <Select value={courseType || "none"} onValueChange={v => setCourseType(v === "none" ? "" : v)} disabled={mutation.isPending}>
            <SelectTrigger className="h-7 text-xs mx-auto" data-testid="select-edit-course-type"><SelectValue placeholder="— type —" /></SelectTrigger>
            <SelectContent>
              <SelectItem value="none">— none —</SelectItem>
              {COURSE_TYPES.map(t => <SelectItem key={t} value={t}>{t}</SelectItem>)}
            </SelectContent>
          </Select>
        </td>
        <td className="text-center py-2 px-2 text-amber-600 dark:text-amber-400 font-medium text-xs">
          {starValue != null && starValue > 0 ? `★ ${starValue}` : "—"}
        </td>
        <td className="text-center py-2 px-2">
          <Switch checked={active} onCheckedChange={setActive} disabled={mutation.isPending} data-testid="switch-edit-course-active" />
        </td>
        <td className="text-center py-2 px-2">
          <Input value={passThreshold} onChange={e => setPassThreshold(e.target.value)} className="h-7 w-16 text-xs text-center mx-auto" disabled={mutation.isPending} data-testid="input-edit-course-pass" />
        </td>
        <td className="py-2 px-2">
          <Input value={remarks} onChange={e => setRemarks(e.target.value)} className="h-7 text-xs" maxLength={3000} disabled={mutation.isPending} data-testid="input-edit-course-remarks" />
        </td>
        <td className="text-center py-2 px-2">
          <div className="flex items-center gap-1 justify-center">
            <Button size="sm" variant="outline" className="h-6 text-xs px-2" onClick={() => setShowPacesDialog(true)} disabled={mutation.isPending} data-testid={`button-add-edit-paces-${c.id}`}>
              Add/Edit PACEs
            </Button>
            <Button size="icon" variant="ghost" className="h-6 w-6" onClick={() => mutation.mutate()} disabled={mutation.isPending} data-testid="button-save-course">
              {mutation.isPending ? <Loader2 className="h-3 w-3 animate-spin" /> : <Check className="h-3 w-3 text-emerald-600" />}
            </Button>
            <Button size="icon" variant="ghost" className="h-6 w-6" onClick={onCancel} disabled={mutation.isPending} data-testid="button-cancel-course">
              <X className="h-3 w-3" />
            </Button>
          </div>
        </td>
      </tr>
      <tr className="border-b bg-muted/30" data-testid={`row-course-edit-extra-${c.id}`}>
        <td colSpan={colSpan} className="py-2 px-3">
          <div className="flex flex-wrap gap-4 items-center text-xs">
            <span className="text-muted-foreground font-medium">ID: <span className="text-foreground font-mono">{c.id}</span></span>
            <div className="flex items-center gap-1.5">
              <label className="text-muted-foreground font-medium whitespace-nowrap">ICCE ID</label>
              <Input value={icceId} onChange={e => setIcceId(e.target.value)} className="h-6 text-xs w-24" maxLength={10} disabled={mutation.isPending} data-testid="input-edit-course-icceid" />
            </div>
            <div className="flex items-center gap-1.5">
              <label className="text-muted-foreground font-medium whitespace-nowrap">ACE Alias</label>
              <Input value={aceAlias} onChange={e => setAceAlias(e.target.value)} className="h-6 text-xs w-48" disabled={mutation.isPending} data-testid="input-edit-course-ace" />
            </div>
            <div className="flex items-center gap-1.5">
              <label className="text-muted-foreground font-medium whitespace-nowrap">Certificate Name</label>
              <Input value={certificateName} onChange={e => setCertificateName(e.target.value)} className="h-6 text-xs w-48" disabled={mutation.isPending} data-testid="input-edit-course-cert" />
            </div>
          </div>
        </td>
      </tr>
      {showPacesDialog && (
        <AddPacesDialog
          course={c}
          onClose={() => setShowPacesDialog(false)}
          onSaved={() => setShowPacesDialog(false)}
        />
      )}
    </>
  );
}

function EditablePcRow({ pc, courseMap, paceMap, onCancel, onSaved }: { pc: PaceCourse; courseMap: Map<number, Course>; paceMap: Map<number, Pace>; onCancel: () => void; onSaved: () => void }) {
  const { toast } = useToast();
  const [pcNumber, setPcNumber] = useState(pc.number || "");
  const [starValue, setStarValue] = useState<string>((paceMap.get(pc.paceId)?.starValue ?? 1).toString());

  const course = courseMap.get(pc.courseId);
  const courseName = course?.aceAlias || course?.icceAlias || `#${pc.courseId}`;

  const saveMutation = useMutation({
    mutationFn: async () => {
      await apiRequest("PATCH", `/api/pace-courses/${pc.id}`, {
        number: pcNumber || null,
      });
      const sv = parseInt(starValue);
      if (!isNaN(sv) && sv > 0) {
        await apiRequest("PATCH", `/api/paces/${pc.paceId}`, { starValue: sv });
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/pace-courses"] });
      queryClient.invalidateQueries({ queryKey: ["/api/paces"] });
      toast({ title: "PACE updated" });
      onSaved();
    },
    onError: (err: Error) => toast({ title: "Failed", description: err.message, variant: "destructive" }),
  });

  const deleteMutation = useMutation({
    mutationFn: async () => {
      await apiRequest("DELETE", `/api/pace-courses/${pc.id}`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/pace-courses"] });
      queryClient.invalidateQueries({ queryKey: ["/api/paces"] });
      toast({ title: "PACE-Course deleted" });
      onSaved();
    },
    onError: (err: Error) => toast({ title: "Failed", description: err.message, variant: "destructive" }),
  });

  const isBusy = saveMutation.isPending || deleteMutation.isPending;

  return (
    <tr className="border-b bg-muted/20" data-testid={`row-pc-edit-${pc.id}`}>
      <td className="py-2 px-2 text-muted-foreground font-mono text-xs">{pc.id}</td>
      <td className="py-2 px-2 font-medium text-xs">{courseName}</td>
      <td className="text-center py-2 px-2 font-mono text-xs">
        <Input value={pcNumber} onChange={e => setPcNumber(e.target.value)} className="h-7 w-24 text-xs text-center mx-auto font-mono" disabled={isBusy} data-testid="input-edit-pc-number" />
      </td>
      <td className="text-center py-2 px-2">
        <Input
          type="number" min="1" max="10" step="1"
          value={starValue}
          onChange={e => setStarValue(e.target.value)}
          className="h-7 w-16 text-xs text-center mx-auto"
          disabled={isBusy}
          data-testid="input-edit-pc-star"
        />
      </td>
      <td className="text-center py-2 px-2">
        <div className="flex items-center gap-1 justify-center">
          <Button size="icon" variant="ghost" className="h-6 w-6" onClick={() => saveMutation.mutate()} disabled={isBusy} data-testid="button-save-pc">
            {saveMutation.isPending ? <Loader2 className="h-3 w-3 animate-spin" /> : <Check className="h-3 w-3 text-emerald-600" />}
          </Button>
          <Button size="icon" variant="ghost" className="h-6 w-6 text-destructive hover:text-destructive" onClick={() => deleteMutation.mutate()} disabled={isBusy} data-testid={`button-delete-pc-${pc.id}`}>
            {deleteMutation.isPending ? <Loader2 className="h-3 w-3 animate-spin" /> : <Trash2 className="h-3 w-3" />}
          </Button>
          <Button size="icon" variant="ghost" className="h-6 w-6" onClick={onCancel} disabled={isBusy} data-testid="button-cancel-pc">
            <X className="h-3 w-3" />
          </Button>
        </div>
      </td>
    </tr>
  );
}

type ImportResult = { sessionId: string; newCount: number; conflictCount: number; skippedIdentical: number; errors: string[]; conflicts: { index: number; excelRow: any; dbRow: any }[] };

function ImportConflictDialog({ result, onResolve, onClose, importType }: { result: ImportResult; onResolve: (sessionId: string, choices: string[], overrideAll?: boolean) => void; onClose: () => void; importType: string }) {
  const [choices, setChoices] = useState<Record<number, "excel" | "skip">>(
    Object.fromEntries(result.conflicts.map((c, i) => [i, "skip"]))
  );

  const entityLabel = importType === "pace-courses" ? "PaceCourse" : "Course";
  const idKey = importType === "pace-courses" ? "id" : "id";

  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent className="max-w-4xl max-h-[80vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>Import Conflicts – {entityLabel}s</DialogTitle>
        </DialogHeader>
        <div className="space-y-3 text-sm">
          <p className="text-muted-foreground">
            {result.newCount} new · {result.conflictCount} conflicts · {result.skippedIdentical} identical (skipped)
          </p>
          {result.errors.length > 0 && (
            <div className="p-3 bg-destructive/10 rounded text-destructive text-xs space-y-1">
              {result.errors.slice(0, 5).map((e, i) => <p key={i}>{e}</p>)}
              {result.errors.length > 5 && <p>…and {result.errors.length - 5} more errors</p>}
            </div>
          )}
          {result.conflicts.length > 0 && (
            <div className="space-y-2">
              <div className="flex gap-2">
                <Button size="sm" variant="outline" onClick={() => setChoices(Object.fromEntries(result.conflicts.map((_, i) => [i, "excel"])))}>Select All: Use Excel</Button>
                <Button size="sm" variant="outline" onClick={() => setChoices(Object.fromEntries(result.conflicts.map((_, i) => [i, "skip"])))}>Select All: Skip</Button>
              </div>
              {result.conflicts.map((c) => (
                <Card key={c.index} className="text-xs">
                  <CardContent className="pt-3 pb-2">
                    <div className="flex items-start justify-between gap-4">
                      <div className="space-y-1 flex-1">
                        <p className="font-medium">ID {c.excelRow[idKey]}</p>
                        <div className="grid grid-cols-2 gap-x-4">
                          <div>
                            <p className="text-muted-foreground font-medium mb-1">Current (DB)</p>
                            {Object.keys(c.excelRow).filter(k => k !== "id" && c.excelRow[k] !== c.dbRow[k]).map(k => (
                              <p key={k}><span className="font-mono">{k}</span>: {String(c.dbRow[k] ?? "—")}</p>
                            ))}
                          </div>
                          <div>
                            <p className="text-muted-foreground font-medium mb-1">Excel (new)</p>
                            {Object.keys(c.excelRow).filter(k => k !== "id" && c.excelRow[k] !== c.dbRow[k]).map(k => (
                              <p key={k} className="text-primary"><span className="font-mono">{k}</span>: {String(c.excelRow[k] ?? "—")}</p>
                            ))}
                          </div>
                        </div>
                      </div>
                      <div className="flex gap-1 shrink-0">
                        <Button size="sm" variant={choices[c.index] === "excel" ? "default" : "outline"} className="h-7 text-xs" onClick={() => setChoices(prev => ({ ...prev, [c.index]: "excel" }))}>Use Excel</Button>
                        <Button size="sm" variant={choices[c.index] === "skip" ? "secondary" : "outline"} className="h-7 text-xs" onClick={() => setChoices(prev => ({ ...prev, [c.index]: "skip" }))}>Skip</Button>
                      </div>
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

export default function MaterialsPage() {
  const [selectedSubjectId, setSelectedSubjectId] = usePersistedState<string>("materials.selectedSubjectId", "all");
  const [levelFilter, setLevelFilter] = usePersistedState<string>("materials.levelFilter", "");
  const [subjectGroupIdFilter, setSubjectGroupIdFilter] = usePersistedState<string>("materials.subjectGroupIdFilter", "all");
  const [search, setSearch] = usePersistedState<string>("materials.search", "");
  const [editingCourseId, setEditingCourseId] = useState<number | null>(null);
  const [expandedCourseIds, setExpandedCourseIds] = useState<Set<number>>(new Set());
  const [editingPcId, setEditingPcId] = useState<number | null>(null);

  const toggleExpand = (id: number) => setExpandedCourseIds(prev => {
    const next = new Set(prev);
    next.has(id) ? next.delete(id) : next.add(id);
    return next;
  });

  const [activeTab, setActiveTab] = usePersistedState<"courses" | "pace-courses">("materials.activeTab", "courses");
  const [pcSearch, setPcSearch] = usePersistedState<string>("materials.pcSearch", "");
  const [pcSelectedCourse, setPcSelectedCourse] = usePersistedState<string>("materials.pcSelectedCourse", "all");
  const [pcComboOpen, setPcComboOpen] = useState(false);
  const [pcSortCol, setPcSortCol] = usePersistedState<"course" | "number" | "star">("materials.pcSortCol", "course");
  const [pcSortDir, setPcSortDir] = usePersistedState<"asc" | "desc">("materials.pcSortDir", "asc");

  const togglePcSort = (col: typeof pcSortCol) => {
    if (pcSortCol === col) setPcSortDir(d => d === "asc" ? "desc" : "asc");
    else { setPcSortCol(col); setPcSortDir("asc"); }
  };

  const handleTabChange = (tab: string) => {
    if (tab === "pace-courses" && activeTab === "courses") {
      if (filteredCourses.length === 1) {
        setPcSelectedCourse(filteredCourses[0].id.toString());
        setPcSearch("");
      } else if (search.trim()) {
        setPcSearch(search.trim());
        setPcSelectedCourse("all");
      }
    }
    setActiveTab(tab as "courses" | "pace-courses");
  };

  const [showAddCourse, setShowAddCourse] = useState(false);
  const [importResult, setImportResult] = useState<ImportResult | null>(null);
  const [importType, setImportType] = useState<"courses" | "pace-courses">("courses");
  const courseFileRef = useRef<HTMLInputElement>(null);
  const { toast } = useToast();

  const { data: courses } = useQuery<Course[]>({ queryKey: ["/api/courses"] });
  const { data: allPaces } = useQuery<Pace[]>({ queryKey: ["/api/paces"] });
  const { data: paceCourses } = useQuery<PaceCourse[]>({ queryKey: ["/api/pace-courses"] });
  const { data: subjects } = useQuery<Subject[]>({ queryKey: ["/api/subjects"] });
  const { data: subjectGroups } = useQuery<SubjectGroup[]>({ queryKey: ["/api/subject-groups"] });
  const { data: profile } = useQuery<UserProfile>({ queryKey: ["/api/profile"] });

  const isTeacher = profile?.role === "teacher";

  const subjectMap = useMemo(() => new Map(subjects?.map(s => [s.id, s]) || []), [subjects]);
  const subjectGroupMap = useMemo(() => new Map(subjectGroups?.map(g => [g.id, g]) || []), [subjectGroups]);

  const uniqueLevels = useMemo(() => {
    if (!courses) return [];
    return [...new Set(courses.filter(c => c.level != null).map(c => c.level!))].sort((a, b) => a - b);
  }, [courses]);

  const filteredCourses = useMemo(() => {
    if (!courses) return [];
    let result = courses;
    if (selectedSubjectId !== "all") result = result.filter(c => c.subjectId === parseInt(selectedSubjectId));
    if (subjectGroupIdFilter !== "all") result = result.filter(c => c.subjectGroupId === parseInt(subjectGroupIdFilter));
    if (search) {
      const q = search.toLowerCase();
      result = result.filter(c =>
        (c.icceAlias || "").toLowerCase().includes(q) ||
        (c.aceAlias || "").toLowerCase().includes(q) ||
        (c.certificateName || "").toLowerCase().includes(q)
      );
    }
    if (levelFilter) result = result.filter(c => c.level?.toString() === levelFilter);
    return [...result].sort((a, b) => {
      const nameA = (a.icceAlias || a.aceAlias || "").toLowerCase();
      const nameB = (b.icceAlias || b.aceAlias || "").toLowerCase();
      return nameA.localeCompare(nameB);
    });
  }, [courses, selectedSubjectId, subjectGroupIdFilter, search, levelFilter]);

  const courseMap = useMemo(() => new Map(courses?.map(c => [c.id, c]) || []), [courses]);
  const paceMap = useMemo(() => new Map(allPaces?.map(p => [p.id, p]) || []), [allPaces]);

  const courseStarValues = useMemo(() => {
    const map = new Map<number, number>();
    paceCourses?.forEach(pc => {
      const sv = paceMap.get(pc.paceId)?.starValue ?? 1;
      map.set(pc.courseId, (map.get(pc.courseId) || 0) + sv);
    });
    return map;
  }, [paceCourses, paceMap]);

  const displayPaceCourses = useMemo(() => {
    if (!paceCourses) return [];
    let filtered = paceCourses;
    if (pcSelectedCourse !== "all") {
      filtered = filtered.filter(pc => pc.courseId === parseInt(pcSelectedCourse));
    }
    if (pcSearch.trim()) {
      const q = pcSearch.trim().toLowerCase();
      filtered = filtered.filter(pc => {
        const course = courseMap.get(pc.courseId);
        const name = (course?.icceAlias || course?.aceAlias || "").toLowerCase();
        return name.includes(q) || (pc.number || "").toLowerCase().includes(q);
      });
    }
    return [...filtered].sort((a, b) => {
      const dir = pcSortDir === "asc" ? 1 : -1;
      const courseA = courseMap.get(a.courseId);
      const courseB = courseMap.get(b.courseId);
      switch (pcSortCol) {
        case "course": {
          const na = (courseA?.aceAlias || courseA?.icceAlias || "").toLowerCase();
          const nb = (courseB?.aceAlias || courseB?.icceAlias || "").toLowerCase();
          return na.localeCompare(nb) * dir;
        }
        case "number": {
          const toNum = (s: string) => { const m = s.match(/\d+/); return m ? parseInt(m[0], 10) : 0; };
          const na = toNum(a.number || "");
          const nb = toNum(b.number || "");
          return na !== nb ? (na - nb) * dir : (a.number || "").localeCompare(b.number || "") * dir;
        }
        case "star": {
          const svA = paceMap.get(a.paceId)?.starValue ?? 1;
          const svB = paceMap.get(b.paceId)?.starValue ?? 1;
          return (svA - svB) * dir;
        }
        default: return 0;
      }
    });
  }, [paceCourses, pcSelectedCourse, pcSearch, pcSortCol, pcSortDir, courseMap, paceMap]);

  const handleImportUpload = async (file: File, type: "courses" | "pace-courses") => {
    setImportType(type);
    const formData = new FormData();
    formData.append("file", file);
    try {
      const res = await fetch(`/api/courses/import?type=${type}`, {
        method: "POST",
        body: formData,
        credentials: "include",
      });
      const data = await res.json();
      if (!res.ok) { toast({ title: "Import failed", description: data.message, variant: "destructive" }); return; }
      if (data.conflictCount === 0 && data.newCount > 0) {
        await fetch("/api/courses/import/resolve", { method: "POST", headers: { "Content-Type": "application/json" }, credentials: "include", body: JSON.stringify({ sessionId: data.sessionId, choices: [], overrideAll: false }) });
        queryClient.invalidateQueries({ queryKey: ["/api/courses"] });
        queryClient.invalidateQueries({ queryKey: ["/api/pace-courses"] });
        toast({ title: "Import complete", description: `${data.newCount} inserted, ${data.skippedIdentical} identical skipped` });
      } else if (data.conflictCount > 0 || data.newCount > 0) {
        setImportResult(data);
      } else {
        toast({ title: "Nothing to import", description: `${data.skippedIdentical} identical rows skipped` });
      }
    } catch (e: any) {
      toast({ title: "Upload failed", description: e.message, variant: "destructive" });
    }
  };

  const handleResolve = async (sessionId: string, choices: string[], overrideAll = false) => {
    try {
      const res = await fetch("/api/courses/import/resolve", { method: "POST", headers: { "Content-Type": "application/json" }, credentials: "include", body: JSON.stringify({ sessionId, choices, overrideAll }) });
      const data = await res.json();
      if (!res.ok) { toast({ title: "Failed", description: data.message, variant: "destructive" }); return; }
      queryClient.invalidateQueries({ queryKey: ["/api/courses"] });
      queryClient.invalidateQueries({ queryKey: ["/api/pace-courses"] });
      toast({ title: "Import applied", description: `${data.inserted} inserted, ${data.updated} updated, ${data.skipped} skipped` });
      setImportResult(null);
    } catch (e: any) {
      toast({ title: "Failed", description: e.message, variant: "destructive" });
    }
  };

  return (
    <div className="p-6 max-w-6xl mx-auto space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-4">
        <div className="min-w-0">
          <h1 className="text-2xl font-serif font-bold tracking-tight" data-testid="text-page-title">Courses & PACEs</h1>
          <p className="text-muted-foreground mt-1">Browse courses, PACEs, and their active status.</p>
        </div>
        {isTeacher && (
          <div className="flex flex-wrap items-center gap-2 sm:justify-end sm:shrink-0">
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="outline" size="sm" data-testid="button-download-template">
                  <Download className="h-4 w-4 mr-1" /> Template <ChevronDown className="h-3 w-3 ml-1" />
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent>
                <DropdownMenuItem onClick={() => window.open("/api/courses/template?type=courses", "_blank")} data-testid="menu-template-courses">Courses template</DropdownMenuItem>
                <DropdownMenuItem onClick={() => window.open("/api/courses/template?type=pace-courses", "_blank")} data-testid="menu-template-pace-courses">PaceCourses template</DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="outline" size="sm" data-testid="button-import">
                  <Upload className="h-4 w-4 mr-1" /> Import <ChevronDown className="h-3 w-3 ml-1" />
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent>
                <DropdownMenuItem onClick={() => { setImportType("courses"); courseFileRef.current && (courseFileRef.current.dataset.type = "courses") && courseFileRef.current.click(); }} data-testid="menu-import-courses">Import Courses</DropdownMenuItem>
                <DropdownMenuItem onClick={() => { setImportType("pace-courses"); courseFileRef.current && (courseFileRef.current.dataset.type = "pace-courses") && courseFileRef.current.click(); }} data-testid="menu-import-pace-courses">Import PaceCourses</DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
            <input ref={courseFileRef} type="file" accept=".xlsx,.xls" className="hidden" onChange={e => { const f = e.target.files?.[0]; if (f) handleImportUpload(f, (courseFileRef.current?.dataset.type as any) || "courses"); e.target.value = ""; }} />
            <Button size="sm" onClick={() => setShowAddCourse(true)} data-testid="button-add-course">
              <Plus className="h-4 w-4 mr-1" /> Add Course
            </Button>
          </div>
        )}
      </div>

      <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between gap-1 space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Total Courses</CardTitle>
            <BookOpen className="w-4 h-4 text-chart-1" />
          </CardHeader>
          <CardContent><p className="text-2xl font-bold" data-testid="text-total-courses">{courses?.length || 0}</p></CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between gap-1 space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Total PACEs</CardTitle>
            <Package className="w-4 h-4 text-chart-2" />
          </CardHeader>
          <CardContent><p className="text-2xl font-bold" data-testid="text-total-paces">{allPaces?.length || 0}</p></CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between gap-1 space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">PACE-Course Links</CardTitle>
            <Link2 className="w-4 h-4 text-chart-3" />
          </CardHeader>
          <CardContent><p className="text-2xl font-bold" data-testid="text-total-pace-courses">{paceCourses?.length || 0}</p></CardContent>
        </Card>
      </div>

      <Tabs value={activeTab} onValueChange={handleTabChange} className="space-y-4">
        <TabsList>
          <TabsTrigger value="courses" data-testid="tab-courses">Courses</TabsTrigger>
          <TabsTrigger value="pace-courses" data-testid="tab-pace-courses">PACE-Course Links</TabsTrigger>
        </TabsList>

        <TabsContent value="courses">
          <Card>
            <CardHeader>
              <div className="flex flex-wrap items-end gap-3">
                <CardTitle className="text-base shrink-0">Courses ({filteredCourses.length})</CardTitle>
                <div className="flex flex-wrap items-end gap-3 ml-auto">
                  <Input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search name, alias…" className="h-8 w-[180px]" data-testid="input-search-courses" />
                  <Select value={selectedSubjectId} onValueChange={v => setSelectedSubjectId(v)}>
                    <SelectTrigger className="h-8 w-[160px]" data-testid="select-subject"><SelectValue placeholder="All subjects" /></SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">All Subjects</SelectItem>
                      {subjects?.map(s => <SelectItem key={s.id} value={s.id.toString()}>{s.subject}</SelectItem>)}
                    </SelectContent>
                  </Select>
                  <Select value={subjectGroupIdFilter} onValueChange={setSubjectGroupIdFilter}>
                    <SelectTrigger className="h-8 w-[150px]" data-testid="select-group"><SelectValue placeholder="All groups" /></SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">All Groups</SelectItem>
                      {subjectGroups?.map(g => <SelectItem key={g.id} value={g.id.toString()}>{g.subjectGroup}</SelectItem>)}
                    </SelectContent>
                  </Select>
                  <Select value={levelFilter || "all"} onValueChange={v => setLevelFilter(v === "all" ? "" : v)}>
                    <SelectTrigger className="h-8 w-[110px]" data-testid="select-level"><SelectValue placeholder="All levels" /></SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">All Levels</SelectItem>
                      {uniqueLevels.map(l => <SelectItem key={l} value={l.toString()}>Level {l}</SelectItem>)}
                    </SelectContent>
                  </Select>
                </div>
              </div>
            </CardHeader>
            <CardContent>
              <div className="overflow-x-auto">
                <table className="w-full text-sm" data-testid="table-courses-list">
                  <thead>
                    <tr className="border-b">
                      <th className="text-left py-3 px-2 font-medium text-muted-foreground">Course</th>
                      <th className="text-center py-3 px-2 font-medium text-muted-foreground">Subject</th>
                      <th className="text-center py-3 px-2 font-medium text-muted-foreground">Group</th>
                      <th className="text-center py-3 px-2 font-medium text-muted-foreground">Level</th>
                      <th className="text-center py-3 px-2 font-medium text-muted-foreground">Credits</th>
                      <th className="text-center py-3 px-2 font-medium text-muted-foreground">Type</th>
                      <th className="text-center py-3 px-2 font-medium text-muted-foreground">★ Stars</th>
                      <th className="text-center py-3 px-2 font-medium text-muted-foreground">Active</th>
                      <th className="text-center py-3 px-2 font-medium text-muted-foreground">Pass %</th>
                      <th className="text-left py-3 px-2 font-medium text-muted-foreground">Remarks</th>
                      <th className="w-[80px]" />
                    </tr>
                  </thead>
                  <tbody>
                    {filteredCourses.map(c => {
                      const colSpan = 11;
                      if (editingCourseId === c.id) {
                        return <EditableCourseRow key={c.id} c={c} subjectMap={subjectMap} subjectGroupMap={subjectGroupMap} starValue={courseStarValues.get(c.id)} colSpan={colSpan} onCancel={() => setEditingCourseId(null)} onSaved={() => setEditingCourseId(null)} />;
                      }
                      const subj = c.subjectId ? subjectMap.get(c.subjectId) : null;
                      const grp = c.subjectGroupId ? subjectGroupMap.get(c.subjectGroupId) : null;
                      const sv = courseStarValues.get(c.id);
                      const isExpanded = expandedCourseIds.has(c.id);
                      const isInactive = (c.active ?? 1) === 0;
                      const hasLongRemarks = (c.remarks?.length ?? 0) > 80;
                      return (
                        <Fragment key={c.id}>
                          <tr className={`border-b ${isInactive ? "opacity-50" : ""} ${isExpanded ? "border-b-0" : ""}`} data-testid={`row-course-${c.id}`}>
                            <td className="py-3 px-2 font-medium">{c.icceAlias || c.aceAlias || `Course ${c.id}`}</td>
                            <td className="text-center py-3 px-2"><Badge variant="secondary">{subj?.subject || "—"}</Badge></td>
                            <td className="text-center py-3 px-2 text-muted-foreground text-xs">{grp?.subjectGroup || "—"}</td>
                            <td className="text-center py-3 px-2">{c.level ?? "—"}</td>
                            <td className="text-center py-3 px-2">{c.credits != null ? c.credits : "—"}</td>
                            <td className="text-center py-3 px-2 text-muted-foreground">{c.courseType || "—"}</td>
                            <td className="text-center py-3 px-2 font-medium text-amber-600 dark:text-amber-400" data-testid={`text-stars-${c.id}`}>
                              {sv != null && sv > 0 ? `★ ${sv}` : "—"}
                            </td>
                            <td className="text-center py-3 px-2">
                              <Badge variant={(c.active ?? 1) === 1 ? "default" : "secondary"}>
                                {(c.active ?? 1) === 1 ? "Active" : "Inactive"}
                              </Badge>
                            </td>
                            <td className="text-center py-3 px-2 text-muted-foreground">{c.passThreshold != null ? `${Math.round(c.passThreshold * 100)}%` : "—"}</td>
                            <td className="py-3 px-2 text-xs text-muted-foreground max-w-[220px]" data-testid={`text-course-remarks-${c.id}`}>
                              {c.remarks ? (
                                <span className="flex items-start gap-1">
                                  <span className="block truncate">{c.remarks.slice(0, 80)}{hasLongRemarks ? "…" : ""}</span>
                                  {hasLongRemarks && (
                                    <button
                                      className="shrink-0 text-primary underline-offset-2 hover:underline text-[10px] leading-relaxed mt-px"
                                      onClick={() => setExpandedCourseIds(prev => { const next = new Set(prev); next.has(c.id) ? next.delete(c.id) : next.add(c.id); return next; })}
                                      data-testid={`button-expand-remarks-${c.id}`}
                                    >
                                      {isExpanded ? "less" : "more"}
                                    </button>
                                  )}
                                </span>
                              ) : "—"}
                            </td>
                            <td className="text-center py-3 px-2">
                              <div className="flex items-center gap-0.5 justify-center">
                                <Button size="icon" variant="ghost" className="h-6 w-6" onClick={() => toggleExpand(c.id)} data-testid={`button-expand-course-${c.id}`} title="Show more">
                                  {isExpanded ? <ChevronUp className="h-3 w-3" /> : <ChevronDown className="h-3 w-3" />}
                                </Button>
                                {isTeacher && (
                                  <Button size="icon" variant="ghost" className="h-6 w-6" onClick={() => { setEditingCourseId(c.id); setExpandedCourseIds(prev => { const next = new Set(prev); next.delete(c.id); return next; }); }} data-testid={`button-edit-course-${c.id}`}>
                                    <Pencil className="h-3 w-3" />
                                  </Button>
                                )}
                              </div>
                            </td>
                          </tr>
                          {isExpanded && (
                            <tr className="border-b bg-muted/10" data-testid={`row-course-details-${c.id}`}>
                              <td colSpan={colSpan} className="py-2 px-4">
                                <div className="flex flex-wrap gap-x-6 gap-y-1 text-xs text-muted-foreground">
                                  <span><span className="font-medium text-foreground">ID:</span> <span className="font-mono">{c.id}</span></span>
                                  {c.icceId && <span><span className="font-medium text-foreground">ICCE ID:</span> <span className="font-mono">{c.icceId}</span></span>}
                                  <span><span className="font-medium text-foreground">ACE Alias:</span> {c.aceAlias || "—"}</span>
                                  <span><span className="font-medium text-foreground">Certificate Name:</span> {c.certificateName || "—"}</span>
                                </div>
                                {c.remarks && (
                                  <div className="mt-2 text-xs text-muted-foreground leading-relaxed" data-testid={`text-remarks-full-${c.id}`}>
                                    <span className="font-medium text-foreground">Remarks: </span>{c.remarks}
                                  </div>
                                )}
                              </td>
                            </tr>
                          )}
                        </Fragment>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="pace-courses">
          <Card>
            <CardHeader>
              <div className="flex flex-wrap items-end gap-3">
                <CardTitle className="text-base shrink-0">PACE-Course Links ({displayPaceCourses.length})</CardTitle>
                <div className="flex flex-wrap items-end gap-3 ml-auto">
                  <Input
                    value={pcSearch}
                    onChange={e => setPcSearch(e.target.value)}
                    placeholder="Search course, code, PACE#…"
                    className="h-8 w-[220px]"
                    data-testid="input-search-pc"
                  />
                  <Popover open={pcComboOpen} onOpenChange={setPcComboOpen}>
                    <PopoverTrigger asChild>
                      <Button variant="outline" role="combobox" aria-expanded={pcComboOpen} className="h-8 w-[230px] justify-between font-normal" data-testid="combobox-course">
                        <span className="truncate">
                          {pcSelectedCourse === "all"
                            ? "All Courses"
                            : (() => { const c = courseMap.get(parseInt(pcSelectedCourse)); return c?.icceAlias || c?.aceAlias || `Course ${pcSelectedCourse}`; })()}
                        </span>
                        <ChevronsUpDown className="ml-2 h-3 w-3 shrink-0 opacity-50" />
                      </Button>
                    </PopoverTrigger>
                    <PopoverContent className="w-[320px] p-0" align="start">
                      <Command>
                        <CommandInput placeholder="Type to search course…" data-testid="input-combobox-course" />
                        <CommandList>
                          <CommandEmpty>No course found.</CommandEmpty>
                          <CommandGroup>
                            <CommandItem value="all" onSelect={() => { setPcSelectedCourse("all"); setPcComboOpen(false); }}>
                              All Courses
                            </CommandItem>
                            {[...(courses || [])].sort((a, b) => (a.icceAlias || a.aceAlias || "").localeCompare(b.icceAlias || b.aceAlias || "")).map(c => (
                              <CommandItem
                                key={c.id}
                                value={`${c.icceAlias || ""} ${c.aceAlias || ""} ${c.id}`}
                                onSelect={() => { setPcSelectedCourse(c.id.toString()); setPcComboOpen(false); }}
                              >
                                {c.icceAlias || c.aceAlias || `Course ${c.id}`}
                              </CommandItem>
                            ))}
                          </CommandGroup>
                        </CommandList>
                      </Command>
                    </PopoverContent>
                  </Popover>
                </div>
              </div>
            </CardHeader>
            <CardContent>
              <div className="overflow-x-auto">
                <table className="w-full text-sm" data-testid="table-pace-courses">
                  <thead>
                    <tr className="border-b">
                      <th className="text-left py-3 px-2 font-medium text-muted-foreground w-[60px]">ID</th>
                      <th className="text-left py-3 px-2 cursor-pointer select-none hover:text-foreground" onClick={() => togglePcSort("course")} data-testid="th-sort-course">
                        <div className="flex items-center gap-1 font-medium text-muted-foreground">
                          ACE Alias
                          {pcSortCol === "course" ? (pcSortDir === "asc" ? <ArrowUp className="h-3 w-3" /> : <ArrowDown className="h-3 w-3" />) : <ChevronsUpDown className="h-3 w-3 opacity-40" />}
                        </div>
                      </th>
                      <th className="text-center py-3 px-2 cursor-pointer select-none hover:text-foreground" onClick={() => togglePcSort("number")} data-testid="th-sort-number">
                        <div className="flex items-center justify-center gap-1 font-medium text-muted-foreground">
                          PACE Number
                          {pcSortCol === "number" ? (pcSortDir === "asc" ? <ArrowUp className="h-3 w-3" /> : <ArrowDown className="h-3 w-3" />) : <ChevronsUpDown className="h-3 w-3 opacity-40" />}
                        </div>
                      </th>
                      <th className="text-center py-3 px-2 cursor-pointer select-none hover:text-foreground" onClick={() => togglePcSort("star")} data-testid="th-sort-star">
                        <div className="flex items-center justify-center gap-1 font-medium text-muted-foreground">
                          Star Value
                          {pcSortCol === "star" ? (pcSortDir === "asc" ? <ArrowUp className="h-3 w-3" /> : <ArrowDown className="h-3 w-3" />) : <ChevronsUpDown className="h-3 w-3 opacity-40" />}
                        </div>
                      </th>
                      {isTeacher && <th className="w-[50px]" />}
                    </tr>
                  </thead>
                  <tbody>
                    {displayPaceCourses.slice(0, 200).map(pc => {
                      if (editingPcId === pc.id) {
                        return <EditablePcRow key={pc.id} pc={pc} courseMap={courseMap} paceMap={paceMap} onCancel={() => setEditingPcId(null)} onSaved={() => setEditingPcId(null)} />;
                      }
                      const course = courseMap.get(pc.courseId);
                      const sv = paceMap.get(pc.paceId)?.starValue ?? 1;
                      return (
                        <tr key={pc.id} className="border-b last:border-0" data-testid={`row-pc-${pc.id}`}>
                          <td className="py-2 px-2 text-muted-foreground font-mono text-xs">{pc.id}</td>
                          <td className="py-2 px-2 font-medium text-xs">{course?.aceAlias || course?.icceAlias || `#${pc.courseId}`}</td>
                          <td className="text-center py-2 px-2 font-mono text-xs">{pc.number ?? "—"}</td>
                          <td className="text-center py-2 px-2 text-xs">
                            <span className="text-amber-500">{"★".repeat(sv)}</span>
                            <span className="text-muted-foreground ml-1">({sv})</span>
                          </td>
                          {isTeacher && (
                            <td className="text-center py-2 px-2">
                              <Button size="icon" variant="ghost" className="h-6 w-6" onClick={() => setEditingPcId(pc.id)} data-testid={`button-edit-pc-${pc.id}`}>
                                <Pencil className="h-3 w-3" />
                              </Button>
                            </td>
                          )}
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
                {displayPaceCourses.length > 200 && (
                  <p className="text-sm text-muted-foreground text-center py-3">Showing 200 of {displayPaceCourses.length}. Use filters to narrow results.</p>
                )}
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>

      {showAddCourse && (
        <AddCourseDialog
          subjects={subjects || []}
          subjectGroups={subjectGroups || []}
          onClose={() => setShowAddCourse(false)}
          onCreated={() => {
            setShowAddCourse(false);
            queryClient.invalidateQueries({ queryKey: ["/api/courses"] });
            queryClient.invalidateQueries({ queryKey: ["/api/paces"] });
            queryClient.invalidateQueries({ queryKey: ["/api/pace-courses"] });
          }}
        />
      )}

      {importResult && (
        <ImportConflictDialog
          result={importResult}
          importType={importType}
          onResolve={handleResolve}
          onClose={() => setImportResult(null)}
        />
      )}
    </div>
  );
}

function AddCourseDialog({ subjects, subjectGroups, onClose, onCreated }: { subjects: Subject[]; subjectGroups: SubjectGroup[]; onClose: () => void; onCreated: () => void }) {
  const { toast } = useToast();
  const [aceAlias, setAceAlias] = useState("");
  const [icceAlias, setIcceAlias] = useState("");
  const [certificateName, setCertificateName] = useState("");
  const [level, setLevel] = useState("");
  const [subjectId, setSubjectId] = useState("");
  const [subjectGroupId, setSubjectGroupId] = useState("");
  const [courseType, setCourseType] = useState("");
  const [passThreshold, setPassThreshold] = useState("");
  const [credits, setCredits] = useState("");
  const [remarks, setRemarks] = useState("");
  const [paceCount, setPaceCount] = useState("");
  const [paceEntries, setPaceEntries] = useState<{ number: string }[]>([]);

  const handlePaceCountChange = (val: string) => {
    setPaceCount(val);
    const n = parseInt(val);
    if (!isNaN(n) && n >= 0 && n <= 50) {
      setPaceEntries(prev => {
        const arr = [...prev];
        while (arr.length < n) arr.push({ number: "" });
        return arr.slice(0, n);
      });
    }
  };

  const mutation = useMutation({
    mutationFn: async () => {
      const valid = paceEntries.filter(e => e.number.trim() !== "");
      await apiRequest("POST", "/api/courses/create-with-paces", {
        aceAlias: aceAlias || null,
        icceAlias: icceAlias || null,
        certificateName: certificateName || null,
        level: level ? parseInt(level) : null,
        subjectId: subjectId ? parseInt(subjectId) : null,
        subjectGroupId: subjectGroupId ? parseInt(subjectGroupId) : null,
        courseType: courseType || null,
        passThreshold: passThreshold ? parseFloat(passThreshold) / 100 : null,
        credits: credits ? parseFloat(credits) : null,
        remarks: remarks || null,
        paceData: valid.map(e => ({ number: e.number })),
      });
    },
    onSuccess: () => { toast({ title: "Course created" }); onCreated(); },
    onError: (err: Error) => toast({ title: "Failed", description: err.message, variant: "destructive" }),
  });

  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent className="max-w-2xl max-h-[85vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>Add New Course</DialogTitle>
        </DialogHeader>
        <div className="grid grid-cols-2 gap-4 py-2">
          <div className="space-y-1.5">
            <Label>ACE alias</Label>
            <Input value={aceAlias} onChange={e => setAceAlias(e.target.value)} placeholder="e.g. Math I" data-testid="input-new-ace-alias" />
          </div>
          <div className="space-y-1.5">
            <Label>ICCE alias</Label>
            <Input value={icceAlias} onChange={e => setIcceAlias(e.target.value)} data-testid="input-new-icce-alias" />
          </div>
          <div className="space-y-1.5">
            <Label>Certificate name</Label>
            <Input value={certificateName} onChange={e => setCertificateName(e.target.value)} data-testid="input-new-cert-name" />
          </div>
          <div className="space-y-1.5">
            <Label>Level</Label>
            <Input type="number" value={level} onChange={e => setLevel(e.target.value)} placeholder="e.g. 3" data-testid="input-new-level" />
          </div>
          <div className="space-y-1.5">
            <Label>Course type</Label>
            <Select value={courseType || "none"} onValueChange={v => setCourseType(v === "none" ? "" : v)}>
              <SelectTrigger data-testid="select-new-course-type"><SelectValue placeholder="— select type —" /></SelectTrigger>
              <SelectContent>
                <SelectItem value="none">— none —</SelectItem>
                {COURSE_TYPES.map(t => <SelectItem key={t} value={t}>{t}</SelectItem>)}
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-1.5">
            <Label>Subject</Label>
            <Select value={subjectId || "none"} onValueChange={v => setSubjectId(v === "none" ? "" : v)}>
              <SelectTrigger data-testid="select-new-subject"><SelectValue placeholder="Select subject" /></SelectTrigger>
              <SelectContent>
                <SelectItem value="none">— none —</SelectItem>
                {subjects.map(s => <SelectItem key={s.id} value={s.id.toString()}>{s.subject}</SelectItem>)}
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-1.5">
            <Label>Subject group</Label>
            <Select value={subjectGroupId || "none"} onValueChange={v => setSubjectGroupId(v === "none" ? "" : v)}>
              <SelectTrigger data-testid="select-new-subject-group"><SelectValue placeholder="Select group" /></SelectTrigger>
              <SelectContent>
                <SelectItem value="none">— none —</SelectItem>
                {subjectGroups.map(g => <SelectItem key={g.id} value={g.id.toString()}>{g.subjectGroup}</SelectItem>)}
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-1.5">
            <Label>Pass threshold</Label>
            <Input type="number" value={passThreshold} onChange={e => setPassThreshold(e.target.value)} placeholder="e.g. 80" data-testid="input-new-pass-threshold" />
          </div>
          <div className="space-y-1.5">
            <Label>Credits</Label>
            <Input type="number" value={credits} onChange={e => setCredits(e.target.value)} placeholder="e.g. 1" data-testid="input-new-credits" />
          </div>
          <div className="col-span-2 space-y-1.5">
            <Label>Remarks</Label>
            <Textarea value={remarks} onChange={e => setRemarks(e.target.value)} maxLength={3000} rows={2} data-testid="input-new-remarks" />
          </div>
          <div className="col-span-2 space-y-1.5 border-t pt-4">
            <Label>Number of PACEs in this course</Label>
            <Input type="number" min="0" max="50" value={paceCount} onChange={e => handlePaceCountChange(e.target.value)} placeholder="e.g. 6" className="w-32" data-testid="input-new-pace-count" />
          </div>
          {paceEntries.length > 0 && (
            <div className="col-span-2 space-y-2">
              <Label>PACE details</Label>
              <div className="grid grid-cols-3 gap-2">
                {paceEntries.map((entry, i) => (
                  <div key={i} className="space-y-1">
                    <label className="text-xs text-muted-foreground">PACE {i + 1}</label>
                    <Input
                      type="text"
                      value={entry.number}
                      onChange={e => setPaceEntries(prev => { const arr = [...prev]; arr[i] = { number: e.target.value }; return arr; })}
                      placeholder={`bijv. 100${i + 1} of 1–2`}
                      className="text-center"
                      data-testid={`input-pace-number-${i}`}
                    />
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={onClose}>Cancel</Button>
          <Button onClick={() => mutation.mutate()} disabled={mutation.isPending} data-testid="button-create-course">
            {mutation.isPending ? "Creating…" : "Create Course"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
