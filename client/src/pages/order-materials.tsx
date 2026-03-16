import { useState, useMemo } from "react";
import { useQuery } from "@tanstack/react-query";
import { Printer, ShoppingCart } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import { Label } from "@/components/ui/label";
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
import { Skeleton } from "@/components/ui/skeleton";
import type { OrderMaterialRow } from "../../../server/storage";

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

type GroupedRow = {
  paceId: number | null;
  paceNumber: number | null;
  courseId: number;
  courseName: string | null;
  enrollmentNumber: string | null;
  quantity: number;
  toOrder: number;
  fromInventory: number;
};

export default function OrderMaterialsPage() {
  const [term, setTerm] = useState<string>("5");
  const [yearTerm, setYearTerm] = useState<string>(getCurrentYearTerm());
  const [hideStudents, setHideStudents] = useState(false);

  const queryKey = ["/api/order-materials", term, yearTerm];
  const { data: rows = [], isLoading } = useQuery<OrderMaterialRow[]>({
    queryKey,
    queryFn: () =>
      fetch(`/api/order-materials?term=${term}&yearTerm=${encodeURIComponent(yearTerm)}`)
        .then((r) => r.json()),
    enabled: !!term,
  });

  const grouped = useMemo<GroupedRow[]>(() => {
    const map = new Map<string, GroupedRow>();
    for (const r of rows) {
      const key = r.paceId != null ? `p_${r.paceId}` : `e_${r.enrollmentId}`;
      const existing = map.get(key);
      if (existing) {
        existing.quantity += r.quantity;
        existing.toOrder += r.toOrder;
        existing.fromInventory += r.fromInventory;
      } else {
        map.set(key, {
          paceId: r.paceId,
          paceNumber: r.paceNumber,
          courseId: r.courseId,
          courseName: r.courseName,
          enrollmentNumber: r.enrollmentNumber,
          quantity: r.quantity,
          toOrder: r.toOrder,
          fromInventory: r.fromInventory,
        });
      }
    }
    return Array.from(map.values()).sort((a, b) => {
      const pn = (a.paceNumber ?? 0) - (b.paceNumber ?? 0);
      if (pn !== 0) return pn;
      return (a.courseName ?? "").localeCompare(b.courseName ?? "");
    });
  }, [rows]);

  const totalToOrder = grouped.reduce((s, r) => s + r.toOrder, 0);
  const totalFromInv = grouped.reduce((s, r) => s + r.fromInventory, 0);

  function handlePrint() {
    window.print();
  }

  return (
    <div className="p-6 space-y-4 print:p-2">
      {/* Header */}
      <div className="flex items-center justify-between print:hidden">
        <div className="flex items-center gap-2">
          <ShoppingCart className="w-5 h-5 text-primary" />
          <h1 className="text-xl font-semibold">Order Materials</h1>
        </div>
        <Button variant="outline" size="sm" onClick={handlePrint} data-testid="button-print">
          <Printer className="w-4 h-4 mr-1" />
          Print
        </Button>
      </div>

      {/* Filters */}
      <div className="flex flex-wrap items-end gap-4 print:hidden">
        <div className="space-y-1">
          <Label htmlFor="select-year-term">Year–Term</Label>
          <Select value={yearTerm} onValueChange={setYearTerm}>
            <SelectTrigger id="select-year-term" className="w-32" data-testid="select-year-term">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              {YEAR_TERM_OPTIONS.map((yt) => (
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
              {[1, 2, 3, 4, 5].map((t) => (
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

      {/* Print header (only shown on print) */}
      <div className="hidden print:block mb-4">
        <h1 className="text-lg font-bold">Order Materials — {yearTerm} T{term}</h1>
        <p className="text-sm text-muted-foreground">ICS De Ceder – Boskoop</p>
      </div>

      {/* Table */}
      {isLoading ? (
        <div className="space-y-2">
          {Array.from({ length: 6 }).map((_, i) => (
            <Skeleton key={i} className="h-8 w-full" />
          ))}
        </div>
      ) : rows.length === 0 ? (
        <p className="text-muted-foreground text-sm py-8 text-center">
          No enrollments found for {yearTerm} T{term}.
        </p>
      ) : hideStudents ? (
        /* ---- Grouped view ---- */
        <div className="rounded-md border overflow-x-auto">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-16">ID</TableHead>
                <TableHead>Course</TableHead>
                <TableHead className="w-24">PACE #</TableHead>
                <TableHead className="w-20 text-right">Qty</TableHead>
                <TableHead className="w-24 text-right">To order</TableHead>
                <TableHead className="w-28 text-right">From Inventory</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {grouped.map((r, idx) => (
                <TableRow key={idx} data-testid={`row-order-grouped-${idx}`}>
                  <TableCell className="font-mono text-xs text-muted-foreground">
                    {r.paceId ?? "—"}
                  </TableCell>
                  <TableCell>{r.courseName ?? "—"}</TableCell>
                  <TableCell className="font-mono">
                    {r.paceNumber ?? r.enrollmentNumber ?? "—"}
                  </TableCell>
                  <TableCell className="text-right">{r.quantity}</TableCell>
                  <TableCell className="text-right font-medium">{r.toOrder}</TableCell>
                  <TableCell className="text-right text-muted-foreground">
                    {r.fromInventory !== 0 ? r.fromInventory : "—"}
                  </TableCell>
                </TableRow>
              ))}
              {/* Totals row */}
              <TableRow className="font-semibold bg-muted/50">
                <TableCell colSpan={3} className="text-right pr-4">Total</TableCell>
                <TableCell className="text-right">{grouped.reduce((s, r) => s + r.quantity, 0)}</TableCell>
                <TableCell className="text-right">{totalToOrder}</TableCell>
                <TableCell className="text-right text-muted-foreground">
                  {totalFromInv !== 0 ? totalFromInv : "—"}
                </TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </div>
      ) : (
        /* ---- Per-student view ---- */
        <div className="rounded-md border overflow-x-auto">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-16">ID</TableHead>
                <TableHead>Course</TableHead>
                <TableHead className="w-24">PACE #</TableHead>
                <TableHead className="w-20 text-right">Qty</TableHead>
                <TableHead>Student</TableHead>
                <TableHead className="w-24 text-right">To order</TableHead>
                <TableHead className="w-28 text-right">From Inventory</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {rows.map((r) => (
                <TableRow key={r.enrollmentId} data-testid={`row-order-${r.enrollmentId}`}>
                  <TableCell className="font-mono text-xs text-muted-foreground">
                    {r.paceId ?? "—"}
                  </TableCell>
                  <TableCell>{r.courseName ?? "—"}</TableCell>
                  <TableCell className="font-mono">
                    {r.paceNumber ?? r.enrollmentNumber ?? "—"}
                  </TableCell>
                  <TableCell className="text-right">{r.quantity}</TableCell>
                  <TableCell>
                    {r.studentSurname}, {r.studentCallName}
                  </TableCell>
                  <TableCell className="text-right font-medium">{r.toOrder}</TableCell>
                  <TableCell className="text-right text-muted-foreground">
                    {r.fromInventory !== 0 ? r.fromInventory : "—"}
                  </TableCell>
                </TableRow>
              ))}
              {/* Totals row */}
              <TableRow className="font-semibold bg-muted/50">
                <TableCell colSpan={4} className="text-right pr-4">Total</TableCell>
                <TableCell />
                <TableCell className="text-right">{rows.reduce((s, r) => s + r.toOrder, 0)}</TableCell>
                <TableCell className="text-right text-muted-foreground">
                  {rows.reduce((s, r) => s + r.fromInventory, 0) !== 0
                    ? rows.reduce((s, r) => s + r.fromInventory, 0)
                    : "—"}
                </TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </div>
      )}
    </div>
  );
}
