import { useState, useMemo, useCallback } from "react";
import { useQuery, useMutation } from "@tanstack/react-query";
import { Printer, ShoppingCart, Plus, Save, FolderOpen, PackageCheck, ArrowLeft, Search } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import { Label } from "@/components/ui/label";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import { Skeleton } from "@/components/ui/skeleton";
import { useToast } from "@/hooks/use-toast";
import { apiRequest, queryClient } from "@/lib/queryClient";
import type { OrderMaterialRow, OrderListItemRich, OrderList, Student, Pace, PaceCourse, Course } from "@shared/schema";

const YEAR_TERM_OPTIONS = Array.from({ length: 12 }, (_, i) => {
  const y = 22 + i;
  return `${y}\u2013${String(y + 1).slice(-2)}`;
});

function getCurrentYearTerm(): string {
  const now = new Date();
  const y = now.getFullYear() % 100;
  const month = now.getMonth() + 1;
  const base = month >= 8 ? y : y - 1;
  return `${base}\u2013${String(base + 1).slice(-2)}`;
}

type LocalRow = {
  key: string;
  enrollmentId: number | null;
  paceId: number | null;
  paceNumber: number | null;
  courseId: number | null;
  courseName: string | null;
  enrollmentNumber: string | null;
  studentId: number;
  studentCallName: string | null;
  studentSurname: string | null;
  quantity: number;
  initiallyToOrder: number;
  fromInventory: number;
  finalToOrder: number;
};

type GroupedRow = {
  paceId: number | null;
  paceNumber: number | null;
  courseId: number | null;
  courseName: string | null;
  enrollmentNumber: string | null;
  quantity: number;
  initiallyToOrder: number;
  fromInventory: number;
  finalToOrder: number;
};

export default function OrderMaterialsPage() {
  const { toast } = useToast();

  const [term, setTerm] = useState<string>("5");
  const [yearTerm, setYearTerm] = useState<string>(getCurrentYearTerm());
  const [hideStudents, setHideStudents] = useState(false);
  const [manualRows, setManualRows] = useState<LocalRow[]>([]);

  const [savedListId, setSavedListId] = useState<number | null>(null);
  const [openListDialogOpen, setOpenListDialogOpen] = useState(false);
  const [addOrderDialogOpen, setAddOrderDialogOpen] = useState(false);

  const [addPaceSearch, setAddPaceSearch] = useState("");
  const [addSelectedPaceId, setAddSelectedPaceId] = useState<number | null>(null);
  const [addSelectedStudentId, setAddSelectedStudentId] = useState<string>("");
  const [addQuantity, setAddQuantity] = useState("1");

  const { data: apiRows = [], isLoading: apiLoading } = useQuery<OrderMaterialRow[]>({
    queryKey: ["/api/order-materials", term, yearTerm],
    queryFn: () =>
      fetch(`/api/order-materials?term=${term}&yearTerm=${encodeURIComponent(yearTerm)}`)
        .then((r) => r.json()),
    enabled: !!term && savedListId === null,
  });

  const { data: savedListData, isLoading: savedLoading } = useQuery<{ list: OrderList; items: OrderListItemRich[] }>({
    queryKey: ["/api/order-lists", savedListId],
    queryFn: () => fetch(`/api/order-lists/${savedListId}`).then(r => r.json()),
    enabled: savedListId !== null,
  });

  const { data: allOrderLists = [] } = useQuery<OrderList[]>({
    queryKey: ["/api/order-lists"],
  });

  const { data: allStudents = [] } = useQuery<Student[]>({ queryKey: ["/api/students"] });
  const { data: allPaces = [] } = useQuery<Pace[]>({ queryKey: ["/api/paces"] });
  const { data: allPaceCourses = [] } = useQuery<PaceCourse[]>({ queryKey: ["/api/pace-courses"] });
  const { data: allCourses = [] } = useQuery<Course[]>({ queryKey: ["/api/courses"] });

  const realStudents = useMemo(() =>
    allStudents.filter(s => s.id < 9996).sort((a, b) => a.surname.localeCompare(b.surname)),
    [allStudents]
  );

  const localRows = useMemo<LocalRow[]>(() => {
    if (savedListId !== null) return [];
    const fromApi: LocalRow[] = apiRows.map(r => ({
      key: `api_${r.enrollmentId}`,
      enrollmentId: r.enrollmentId,
      paceId: r.paceId,
      paceNumber: r.paceNumber,
      courseId: r.courseId,
      courseName: r.courseName,
      enrollmentNumber: r.enrollmentNumber,
      studentId: r.studentId,
      studentCallName: r.studentCallName,
      studentSurname: r.studentSurname,
      quantity: r.quantity,
      initiallyToOrder: r.quantity,
      fromInventory: r.fromInventory,
      finalToOrder: r.toOrder,
    }));
    return [...fromApi, ...manualRows];
  }, [apiRows, manualRows, savedListId]);

  const grouped = useMemo<GroupedRow[]>(() => {
    const source = savedListId !== null ? (savedListData?.items ?? []).map(it => ({
      paceId: it.paceId,
      paceNumber: it.paceNumber,
      courseId: it.courseId,
      courseName: it.courseName,
      enrollmentNumber: it.enrollmentNumber,
      quantity: it.quantity ?? 1,
      initiallyToOrder: it.initiallyToOrder ?? 1,
      fromInventory: it.fromInventory ?? 0,
      finalToOrder: it.finalToOrder ?? 0,
    })) : localRows;

    const map = new Map<string, GroupedRow>();
    for (const r of source) {
      const key = r.paceId != null ? `p_${r.paceId}` : `c_${r.courseId}_${r.enrollmentNumber}`;
      const existing = map.get(key);
      if (existing) {
        existing.quantity += r.quantity;
        existing.initiallyToOrder += r.initiallyToOrder;
        existing.fromInventory += r.fromInventory;
        existing.finalToOrder += r.finalToOrder;
      } else {
        map.set(key, { ...r });
      }
    }
    return Array.from(map.values()).sort((a, b) => {
      const pn = (a.paceNumber ?? 0) - (b.paceNumber ?? 0);
      if (pn !== 0) return pn;
      return (a.courseName ?? "").localeCompare(b.courseName ?? "");
    });
  }, [localRows, savedListId, savedListData]);

  const saveMutation = useMutation({
    mutationFn: async () => {
      const now = new Date();
      const pad = (n: number) => String(n).padStart(2, "0");
      const name = `Order list ${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())} ${pad(now.getHours())}:${pad(now.getMinutes())}`;
      return apiRequest("POST", "/api/order-lists", {
        name,
        term: parseInt(term),
        yearTerm,
        items: localRows.map(r => ({
          paceId: r.paceId,
          courseId: r.courseId,
          enrollmentNumber: r.enrollmentNumber,
          studentId: r.studentId,
          enrollmentId: r.enrollmentId,
          quantity: r.quantity,
          initiallyToOrder: r.initiallyToOrder,
          fromInventory: r.fromInventory,
          finalToOrder: r.finalToOrder,
        })),
      });
    },
    onSuccess: async (res) => {
      const list = await res.json();
      queryClient.invalidateQueries({ queryKey: ["/api/order-lists"] });
      toast({ title: "Saved", description: `Order list "${list.name}" saved successfully.` });
    },
    onError: () => toast({ title: "Error", description: "Failed to save order list.", variant: "destructive" }),
  });

  const deliveryMutation = useMutation({
    mutationFn: async () => {
      const res = await apiRequest("POST", `/api/order-lists/${savedListId}/process-delivery`);
      return res.json();
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ["/api/order-lists", savedListId] });
      queryClient.invalidateQueries({ queryKey: ["/api/inventory"] });
      toast({ title: "Delivery processed", description: `${data.processed} item(s) added to inventory.` });
    },
    onError: () => toast({ title: "Error", description: "Failed to process delivery.", variant: "destructive" }),
  });

  const toggleDelivered = useCallback(async (itemId: number, delivered: boolean) => {
    if (savedListId === null) return;
    await apiRequest("PATCH", `/api/order-lists/${savedListId}/items/${itemId}`, { delivered });
    queryClient.invalidateQueries({ queryKey: ["/api/order-lists", savedListId] });
  }, [savedListId]);

  function handleAddOrder() {
    if (!addSelectedPaceId || !addSelectedStudentId) return;
    const pace = allPaces.find(p => p.id === addSelectedPaceId);
    const student = allStudents.find(s => s.id === parseInt(addSelectedStudentId));
    if (!pace || !student) return;

    const pc = allPaceCourses.find(pc => pc.paceId === pace.id);
    const course = pc ? allCourses.find(c => c.id === pc.courseId) : null;
    const qty = Math.max(1, parseInt(addQuantity) || 1);

    const row: LocalRow = {
      key: `manual_${Date.now()}_${Math.random()}`,
      enrollmentId: null,
      paceId: pace.id,
      paceNumber: pace.number,
      courseId: course?.id ?? null,
      courseName: course?.icceAlias ?? null,
      enrollmentNumber: pc?.number ?? null,
      studentId: student.id,
      studentCallName: student.callName,
      studentSurname: student.surname,
      quantity: qty,
      initiallyToOrder: qty,
      fromInventory: 0,
      finalToOrder: qty,
    };

    setManualRows(prev => [...prev, row]);
    setAddOrderDialogOpen(false);
    setAddPaceSearch("");
    setAddSelectedPaceId(null);
    setAddSelectedStudentId("");
    setAddQuantity("1");
  }

  const filteredPaces = useMemo(() => {
    if (!addPaceSearch) return [];
    const q = addPaceSearch.toLowerCase();
    return allPaces
      .filter(p => {
        if (String(p.number ?? "").includes(q)) return true;
        const pc = allPaceCourses.find(pc => pc.paceId === p.id);
        if (pc) {
          const c = allCourses.find(c => c.id === pc.courseId);
          if (c?.icceAlias?.toLowerCase().includes(q)) return true;
        }
        return false;
      })
      .slice(0, 20);
  }, [addPaceSearch, allPaces, allPaceCourses, allCourses]);

  const isInSavedMode = savedListId !== null;
  const effectiveHideStudents = isInSavedMode ? false : hideStudents;
  const isLoading = isInSavedMode ? savedLoading : apiLoading;
  const displayRows = isInSavedMode ? (savedListData?.items ?? []) : localRows;
  const isEmpty = displayRows.length === 0 && !isLoading;

  const totals = useMemo(() => {
    if (effectiveHideStudents) {
      return {
        qty: grouped.reduce((s, r) => s + r.quantity, 0),
        init: grouped.reduce((s, r) => s + r.initiallyToOrder, 0),
        inv: grouped.reduce((s, r) => s + r.fromInventory, 0),
        final: grouped.reduce((s, r) => s + r.finalToOrder, 0),
      };
    }
    if (savedListId !== null) {
      const items = savedListData?.items ?? [];
      return {
        qty: items.reduce((s, r) => s + (r.quantity ?? 1), 0),
        init: items.reduce((s, r) => s + (r.initiallyToOrder ?? 1), 0),
        inv: items.reduce((s, r) => s + (r.fromInventory ?? 0), 0),
        final: items.reduce((s, r) => s + (r.finalToOrder ?? 0), 0),
      };
    }
    return {
      qty: localRows.reduce((s, r) => s + r.quantity, 0),
      init: localRows.reduce((s, r) => s + r.initiallyToOrder, 0),
      inv: localRows.reduce((s, r) => s + r.fromInventory, 0),
      final: localRows.reduce((s, r) => s + r.finalToOrder, 0),
    };
  }, [effectiveHideStudents, grouped, localRows, savedListId, savedListData]);

  return (
    <div className="p-6 space-y-4 print:p-2">
      <div className="flex items-center justify-between print:hidden">
        <div className="flex items-center gap-2">
          <ShoppingCart className="w-5 h-5 text-primary" />
          <h1 className="text-xl font-semibold" data-testid="text-order-title">
            {savedListId !== null && savedListData ? savedListData.list.name : "Order Materials"}
          </h1>
        </div>
        <div className="flex items-center gap-2">
          <Button variant="outline" size="sm" onClick={() => window.print()} data-testid="button-print">
            <Printer className="w-4 h-4 mr-1" /> Print
          </Button>
        </div>
      </div>

      {savedListId !== null ? (
        <div className="flex items-center gap-2 print:hidden">
          <Button variant="ghost" size="sm" onClick={() => { setSavedListId(null); setManualRows([]); }} data-testid="button-back-to-draft">
            <ArrowLeft className="w-4 h-4 mr-1" /> Back to new order
          </Button>
          <div className="flex-1" />
          <Button
            size="sm"
            onClick={() => deliveryMutation.mutate()}
            disabled={deliveryMutation.isPending}
            data-testid="button-process-delivery"
          >
            <PackageCheck className="w-4 h-4 mr-1" />
            {deliveryMutation.isPending ? "Processing…" : "Process delivery"}
          </Button>
        </div>
      ) : (
        <>
          <div className="flex flex-wrap items-end gap-4 print:hidden">
            <div className="space-y-1">
              <Label htmlFor="select-year-term">Year–Term</Label>
              <Select value={yearTerm} onValueChange={setYearTerm}>
                <SelectTrigger id="select-year-term" className="w-32" data-testid="select-year-term">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {YEAR_TERM_OPTIONS.map(yt => (
                    <SelectItem key={yt} value={yt}>{yt}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-1">
              <Label htmlFor="select-term">Term</Label>
              <Select value={term} onValueChange={setTerm}>
                <SelectTrigger id="select-term" className="w-28" data-testid="select-term">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {[1, 2, 3, 4, 5].map(t => (
                    <SelectItem key={t} value={String(t)}>T{t}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="flex items-center gap-2 pb-0.5">
              <Checkbox
                id="hide-students"
                checked={hideStudents}
                onCheckedChange={(v) => setHideStudents(Boolean(v))}
                data-testid="checkbox-hide-students"
              />
              <Label htmlFor="hide-students" className="cursor-pointer">Hide students</Label>
            </div>
          </div>

          <div className="flex flex-wrap items-center gap-2 print:hidden">
            <Button variant="outline" size="sm" onClick={() => setAddOrderDialogOpen(true)} data-testid="button-add-order">
              <Plus className="w-4 h-4 mr-1" /> Add order
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={() => saveMutation.mutate()}
              disabled={saveMutation.isPending || localRows.length === 0}
              data-testid="button-save-order"
            >
              <Save className="w-4 h-4 mr-1" />
              {saveMutation.isPending ? "Saving…" : "Save order list"}
            </Button>
            <Button variant="outline" size="sm" onClick={() => setOpenListDialogOpen(true)} data-testid="button-open-order">
              <FolderOpen className="w-4 h-4 mr-1" /> Open order list
            </Button>
          </div>
        </>
      )}

      <div className="hidden print:block mb-4">
        <h1 className="text-lg font-bold">
          {savedListId !== null && savedListData
            ? savedListData.list.name
            : `Order Materials — ${yearTerm} T${term}`}
        </h1>
        <p className="text-sm text-muted-foreground">ICS De Ceder – Boskoop</p>
      </div>

      {isLoading ? (
        <div className="space-y-2">
          {Array.from({ length: 6 }).map((_, i) => <Skeleton key={i} className="h-8 w-full" />)}
        </div>
      ) : isEmpty ? (
        <p className="text-muted-foreground text-sm py-8 text-center" data-testid="text-empty">
          {savedListId !== null ? "This order list is empty." : `No enrollments found for ${yearTerm} T${term}.`}
        </p>
      ) : effectiveHideStudents ? (
        <div className="rounded-md border overflow-x-auto">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-16">ID</TableHead>
                <TableHead>Course</TableHead>
                <TableHead className="w-24">PACE #</TableHead>
                <TableHead className="w-20 text-right">Qty</TableHead>
                <TableHead className="w-28 text-right">Initially to order</TableHead>
                <TableHead className="w-28 text-right">From Inventory</TableHead>
                <TableHead className="w-28 text-right">Final to order</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {grouped.map((r, idx) => (
                <TableRow key={idx} data-testid={`row-order-grouped-${idx}`}>
                  <TableCell className="font-mono text-xs text-muted-foreground">{r.paceId ?? "—"}</TableCell>
                  <TableCell>{r.courseName ?? "—"}</TableCell>
                  <TableCell className="font-mono">{r.paceNumber ?? r.enrollmentNumber ?? "—"}</TableCell>
                  <TableCell className="text-right">{r.quantity}</TableCell>
                  <TableCell className="text-right">{r.initiallyToOrder}</TableCell>
                  <TableCell className="text-right text-muted-foreground">{r.fromInventory !== 0 ? r.fromInventory : "—"}</TableCell>
                  <TableCell className="text-right font-medium">{r.finalToOrder}</TableCell>
                </TableRow>
              ))}
              <TableRow className="font-semibold bg-muted/50">
                <TableCell colSpan={3} className="text-right pr-4">Total</TableCell>
                <TableCell className="text-right">{totals.qty}</TableCell>
                <TableCell className="text-right">{totals.init}</TableCell>
                <TableCell className="text-right text-muted-foreground">{totals.inv !== 0 ? totals.inv : "—"}</TableCell>
                <TableCell className="text-right">{totals.final}</TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </div>
      ) : savedListId !== null ? (
        <div className="rounded-md border overflow-x-auto">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-16">ID</TableHead>
                <TableHead>Course</TableHead>
                <TableHead className="w-24">PACE #</TableHead>
                <TableHead className="w-20 text-right">Qty</TableHead>
                <TableHead className="w-28 text-right">Initially to order</TableHead>
                <TableHead className="w-28 text-right">From Inventory</TableHead>
                <TableHead className="w-28 text-right">Final to order</TableHead>
                <TableHead className="w-24 text-center">Delivered</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {(savedListData?.items ?? []).map(r => (
                <TableRow key={r.id} data-testid={`row-order-saved-${r.id}`}>
                  <TableCell className="font-mono text-xs text-muted-foreground">{r.paceId ?? "—"}</TableCell>
                  <TableCell>{r.courseName ?? "—"}</TableCell>
                  <TableCell className="font-mono">{r.paceNumber ?? r.enrollmentNumber ?? "—"}</TableCell>
                  <TableCell className="text-right">{r.quantity ?? 1}</TableCell>
                  <TableCell className="text-right">{r.initiallyToOrder ?? 1}</TableCell>
                  <TableCell className="text-right text-muted-foreground">{(r.fromInventory ?? 0) !== 0 ? r.fromInventory : "—"}</TableCell>
                  <TableCell className="text-right font-medium">{r.finalToOrder ?? 0}</TableCell>
                  <TableCell className="text-center">
                    <Checkbox
                      checked={!!r.delivered}
                      onCheckedChange={(v) => toggleDelivered(r.id, Boolean(v))}
                      data-testid={`checkbox-delivered-${r.id}`}
                    />
                  </TableCell>
                </TableRow>
              ))}
              <TableRow className="font-semibold bg-muted/50">
                <TableCell colSpan={3} className="text-right pr-4">Total</TableCell>
                <TableCell className="text-right">{totals.qty}</TableCell>
                <TableCell className="text-right">{totals.init}</TableCell>
                <TableCell className="text-right text-muted-foreground">{totals.inv !== 0 ? totals.inv : "—"}</TableCell>
                <TableCell className="text-right">{totals.final}</TableCell>
                <TableCell />
              </TableRow>
            </TableBody>
          </Table>
        </div>
      ) : (
        <div className="rounded-md border overflow-x-auto">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-16">ID</TableHead>
                <TableHead>Course</TableHead>
                <TableHead className="w-24">PACE #</TableHead>
                <TableHead className="w-20 text-right">Qty</TableHead>
                <TableHead>Student</TableHead>
                <TableHead className="w-28 text-right">Initially to order</TableHead>
                <TableHead className="w-28 text-right">From Inventory</TableHead>
                <TableHead className="w-28 text-right">Final to order</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {localRows.map(r => (
                <TableRow key={r.key} data-testid={`row-order-${r.key}`}>
                  <TableCell className="font-mono text-xs text-muted-foreground">{r.paceId ?? "—"}</TableCell>
                  <TableCell>{r.courseName ?? "—"}</TableCell>
                  <TableCell className="font-mono">{r.paceNumber ?? r.enrollmentNumber ?? "—"}</TableCell>
                  <TableCell className="text-right">{r.quantity}</TableCell>
                  <TableCell>{r.studentSurname}, {r.studentCallName}</TableCell>
                  <TableCell className="text-right">{r.initiallyToOrder}</TableCell>
                  <TableCell className="text-right text-muted-foreground">{r.fromInventory !== 0 ? r.fromInventory : "—"}</TableCell>
                  <TableCell className="text-right font-medium">{r.finalToOrder}</TableCell>
                </TableRow>
              ))}
              <TableRow className="font-semibold bg-muted/50">
                <TableCell colSpan={3} className="text-right pr-4">Total</TableCell>
                <TableCell className="text-right">{totals.qty}</TableCell>
                <TableCell />
                <TableCell className="text-right">{totals.init}</TableCell>
                <TableCell className="text-right text-muted-foreground">{totals.inv !== 0 ? totals.inv : "—"}</TableCell>
                <TableCell className="text-right">{totals.final}</TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </div>
      )}

      <Dialog open={addOrderDialogOpen} onOpenChange={setAddOrderDialogOpen}>
        <DialogContent className="max-w-lg">
          <DialogHeader>
            <DialogTitle>Add order item</DialogTitle>
          </DialogHeader>
          <div className="space-y-4">
            <div className="space-y-1">
              <Label>Search PACE (by number or course name)</Label>
              <div className="relative">
                <Search className="absolute left-2 top-2.5 w-4 h-4 text-muted-foreground" />
                <Input
                  value={addPaceSearch}
                  onChange={e => { setAddPaceSearch(e.target.value); setAddSelectedPaceId(null); }}
                  placeholder="Type to search…"
                  className="pl-8"
                  data-testid="input-pace-search"
                />
              </div>
              {addPaceSearch && filteredPaces.length > 0 && !addSelectedPaceId && (
                <div className="border rounded-md max-h-48 overflow-y-auto mt-1">
                  {filteredPaces.map(p => {
                    const pc = allPaceCourses.find(pc => pc.paceId === p.id);
                    const c = pc ? allCourses.find(c => c.id === pc.courseId) : null;
                    return (
                      <button
                        key={p.id}
                        className="w-full text-left px-3 py-1.5 hover:bg-accent text-sm"
                        onClick={() => { setAddSelectedPaceId(p.id); setAddPaceSearch(`${p.number} — ${c?.icceAlias ?? "Unknown"}`); }}
                        data-testid={`pace-option-${p.id}`}
                      >
                        <span className="font-mono">{p.number}</span>{" "}
                        <span className="text-muted-foreground">— {c?.icceAlias ?? "No course linked"}</span>
                      </button>
                    );
                  })}
                </div>
              )}
              {addSelectedPaceId && (
                <p className="text-xs text-green-600">PACE selected (ID: {addSelectedPaceId})</p>
              )}
            </div>
            <div className="space-y-1">
              <Label>Student</Label>
              <Select value={addSelectedStudentId} onValueChange={setAddSelectedStudentId}>
                <SelectTrigger data-testid="select-add-student">
                  <SelectValue placeholder="Select student" />
                </SelectTrigger>
                <SelectContent>
                  {realStudents.map(s => (
                    <SelectItem key={s.id} value={String(s.id)}>{s.surname}, {s.callName}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-1">
              <Label>Quantity</Label>
              <Input
                type="number"
                min="1"
                value={addQuantity}
                onChange={e => setAddQuantity(e.target.value)}
                className="w-24"
                data-testid="input-add-quantity"
              />
            </div>
          </div>
          <DialogFooter>
            <Button variant="ghost" onClick={() => setAddOrderDialogOpen(false)}>Cancel</Button>
            <Button onClick={handleAddOrder} disabled={!addSelectedPaceId || !addSelectedStudentId} data-testid="button-confirm-add">
              Add
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={openListDialogOpen} onOpenChange={setOpenListDialogOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>Open order list</DialogTitle>
          </DialogHeader>
          {allOrderLists.length === 0 ? (
            <p className="text-sm text-muted-foreground py-4 text-center">No saved order lists yet.</p>
          ) : (
            <div className="border rounded-md max-h-72 overflow-y-auto">
              {allOrderLists.map(ol => (
                <button
                  key={ol.id}
                  className="w-full text-left px-3 py-2 hover:bg-accent border-b last:border-b-0 flex justify-between items-center"
                  onClick={() => { setSavedListId(ol.id); setOpenListDialogOpen(false); }}
                  data-testid={`order-list-${ol.id}`}
                >
                  <span className="text-sm font-medium">{ol.name}</span>
                  <span className="text-xs text-muted-foreground">
                    {ol.createdAt ? new Date(ol.createdAt).toLocaleDateString() : ""}
                  </span>
                </button>
              ))}
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}
