import { useQuery, useMutation } from "@tanstack/react-query";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { Calendar } from "@/components/ui/calendar";
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import { useToast } from "@/hooks/use-toast";
import { useState, useMemo, useRef, useEffect, useCallback } from "react";
import { usePersistedState } from "@/lib/persisted-state";
import type { Student, Course, Enrollment, SupplementaryActivity, Pace, PaceCourse, Subject } from "@shared/schema";
import { apiRequest, queryClient } from "@/lib/queryClient";
import { Label } from "@/components/ui/label";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { StudentSearch } from "@/components/student-search";
import { Checkbox } from "@/components/ui/checkbox";
import { CalendarIcon, Pencil, Plus, ChevronDown, ChevronRight, Trash2, Upload, Download, AlertCircle, CheckCircle2, Music, Filter, ChevronsDown, ChevronsUp } from "lucide-react";
import { format, parse } from "date-fns";
import { cn } from "@/lib/utils";

const SUPP_ACTIVITIES = ["Music", "Physical Education", "Project", "Other"];
const COL_COUNT = 7;

function computeYearTermFromDate(dateStr: string): string | null {
  if (!dateStr) return null;
  try {
    const d = parse(dateStr, "yyyy-MM-dd", new Date());
    if (isNaN(d.getTime())) return null;
    const month = d.getMonth();
    const year = d.getFullYear();
    const startYear = month >= 7 ? year : year - 1;
    const endYear = startYear + 1;
    const s = String(startYear).slice(-2);
    const e = String(endYear).slice(-2);
    return `${s}\u2013${e}`;
  } catch {
    return null;
  }
}

function getCurrentYearTerm(): string {
  const now = new Date();
  const month = now.getMonth();
  const year = now.getFullYear();
  const startYear = month >= 7 ? year : year - 1;
  const endYear = startYear + 1;
  const s = String(startYear).slice(-2);
  const e = String(endYear).slice(-2);
  return `${s}\u2013${e}`;
}

function getEffectivePassThreshold(course: Course, isDyslexic: boolean, subjectById: Map<number, Subject>): number {
  const threshold = course.passThreshold ?? 80;
  if (isDyslexic && course.subjectId) {
    const subj = subjectById.get(course.subjectId);
    if (subj?.subject?.toLowerCase().includes("word building")) return 80;
  }
  return threshold;
}

function CourseSearch({ onSelect, exclude }: { onSelect: (course: Course) => void; exclude: number[] }) {
  const [query, setQuery] = useState("");
  const [open, setOpen] = useState(false);
  const [highlightIndex, setHighlightIndex] = useState(-1);
  const containerRef = useRef<HTMLDivElement>(null);

  const { data: courses } = useQuery<Course[]>({ queryKey: ["/api/courses"] });

  const suggestions = useMemo(() => {
    if (!courses || query.length < 2) return [];
    const q = query.toLowerCase();
    const excludeSet = new Set(exclude);
    return courses.filter(c =>
      !excludeSet.has(c.id) && (
        (c.aceAlias?.toLowerCase().includes(q)) ||
        (c.icceAlias?.toLowerCase().includes(q)) ||
        (c.certificateName?.toLowerCase().includes(q))
      )
    ).slice(0, 8);
  }, [courses, query, exclude]);

  useEffect(() => {
    function handleClickOutside(e: MouseEvent) {
      if (containerRef.current && !containerRef.current.contains(e.target as Node)) setOpen(false);
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  function handleKeyDown(e: React.KeyboardEvent) {
    if (!open) return;
    if (e.key === "Escape") { e.preventDefault(); setOpen(false); setHighlightIndex(-1); return; }
    if (suggestions.length === 0) return;
    if (e.key === "ArrowDown") { e.preventDefault(); setHighlightIndex(prev => (prev + 1) % suggestions.length); }
    else if (e.key === "ArrowUp") { e.preventDefault(); setHighlightIndex(prev => (prev - 1 + suggestions.length) % suggestions.length); }
    else if (e.key === "Enter" && highlightIndex >= 0 && highlightIndex < suggestions.length) {
      e.preventDefault();
      onSelect(suggestions[highlightIndex]);
      setQuery(""); setOpen(false); setHighlightIndex(-1);
    }
  }

  return (
    <div className="relative flex-1 min-w-0" ref={containerRef}>
      <Input
        placeholder="Type course name..."
        value={query}
        onChange={e => { setQuery(e.target.value); setOpen(e.target.value.length >= 2); setHighlightIndex(-1); }}
        onFocus={() => { if (query.length >= 2) setOpen(true); }}
        onKeyDown={handleKeyDown}
        className="w-full"
        data-testid="input-course-search"
      />
      {open && suggestions.length > 0 && (
        <div className="absolute z-50 top-full left-0 mt-1 w-full bg-popover border rounded-md shadow-lg overflow-hidden max-h-64 overflow-y-auto">
          {suggestions.map((c, i) => (
            <button
              key={c.id}
              type="button"
              className={cn("w-full text-left px-3 py-2 text-sm hover:bg-accent", i === highlightIndex && "bg-accent")}
              onMouseDown={e => { e.preventDefault(); onSelect(c); setQuery(""); setOpen(false); setHighlightIndex(-1); }}
              data-testid={`suggestion-course-${c.id}`}
            >
              <span className="font-medium">{c.icceAlias || c.aceAlias}</span>
              {c.certificateName && <span className="text-muted-foreground ml-2 text-xs">{c.certificateName}</span>}
            </button>
          ))}
        </div>
      )}
      {open && query.length >= 2 && suggestions.length === 0 && (
        <div className="absolute z-50 top-full left-0 mt-1 w-full bg-popover border rounded-md shadow-lg p-3 text-sm text-muted-foreground">
          No courses found matching "{query}"
        </div>
      )}
    </div>
  );
}

function DatePicker({ value, onChange, placeholder }: { value: string | null | undefined; onChange: (val: string | null) => void; placeholder: string }) {
  const [open, setOpen] = useState(false);
  const date = value ? parse(value, "yyyy-MM-dd", new Date()) : undefined;
  return (
    <Popover open={open} onOpenChange={setOpen}>
      <PopoverTrigger asChild>
        <Button variant="outline" className="w-[140px] justify-start text-left font-normal text-xs h-9" data-testid={`button-date-${placeholder.toLowerCase().replace(/\s/g, "-")}`}>
          <CalendarIcon className="mr-1.5 h-3.5 w-3.5 text-muted-foreground" />
          {value ? format(parse(value, "yyyy-MM-dd", new Date()), "dd MMM yyyy") : <span className="text-muted-foreground">{placeholder}</span>}
        </Button>
      </PopoverTrigger>
      <PopoverContent className="w-auto p-0" align="start">
        <Calendar
          mode="single"
          selected={date}
          onSelect={(d) => { onChange(d ? format(d, "yyyy-MM-dd") : null); setOpen(false); }}
          initialFocus
        />
      </PopoverContent>
    </Popover>
  );
}

function formatDate(dateStr: string | null | undefined): string {
  if (!dateStr) return "—";
  try {
    return format(parse(dateStr, "yyyy-MM-dd", new Date()), "dd MMM yyyy");
  } catch {
    return dateStr;
  }
}

interface CourseGroup {
  courseId: number;
  courseName: string;
  enrollments: Enrollment[];
  minDateStarted: string | null;
  maxDateEnded: string | null;
}

function groupEnrollmentsByCourse(enrollmentList: Enrollment[], courseMap: Map<number, Course>): CourseGroup[] {
  const groups = new Map<number, Enrollment[]>();
  for (const e of enrollmentList) {
    const arr = groups.get(e.courseId) || [];
    arr.push(e);
    groups.set(e.courseId, arr);
  }
  return Array.from(groups.entries()).map(([courseId, rows]) => {
    const course = courseMap.get(courseId);
    const courseName = course?.icceAlias || course?.aceAlias || `Course #${courseId}`;
    const sortedRows = rows.sort((a, b) => {
      const numA = typeof a.number === "string" ? parseInt(a.number, 10) : a.number;
      const numB = typeof b.number === "string" ? parseInt(b.number, 10) : b.number;
      if (!isNaN(numA) && !isNaN(numB)) return numA - numB;
      return String(a.number).localeCompare(String(b.number));
    });
    const dates = sortedRows.map(r => r.dateStarted).filter(Boolean) as string[];
    const minDateStarted = dates.length > 0 ? [...dates].sort()[0] : null;
    const endDates = sortedRows.map(r => r.dateEnded).filter((d): d is string => !!d);
    const maxDateEnded = endDates.length > 0 ? [...endDates].sort().reverse()[0] : null;
    return { courseId, courseName, enrollments: sortedRows, minDateStarted, maxDateEnded };
  });
}

const YEAR_TERM_OPTIONS = Array.from({ length: 12 }, (_, i) => {
  const y = 22 + i;
  return `${String(y).padStart(2, "0")}–${String(y + 1).padStart(2, "0")}`;
});

function NumberRow({
  enrollment,
  onUpdate,
  onDelete,
  isPending,
  starValue,
  passThreshold,
}: {
  enrollment: Enrollment;
  onUpdate: (id: number, data: any) => void;
  onDelete: (id: number) => void;
  isPending: boolean;
  starValue: number;
  passThreshold: number;
}) {
  const [editing, setEditing] = useState(false);
  const [dateStarted, setDateStarted] = useState(enrollment.dateStarted);
  const [dateEnded, setDateEnded] = useState(enrollment.dateEnded);
  const [grade, setGrade] = useState(enrollment.grade?.toString() || "");
  const [remarks, setRemarks] = useState(enrollment.remarks || "");
  const [isRepeat, setIsRepeat] = useState(enrollment.isRepeat);
  const [editTerm, setEditTerm] = useState<string>(enrollment.term?.toString() || "");
  const [editYearTerm, setEditYearTerm] = useState<string>(enrollment.yearTerm || "");

  const handleSave = useCallback(() => {
    onUpdate(enrollment.id, {
      dateStarted,
      dateEnded: dateEnded || null,
      grade: grade ? parseFloat(grade) : null,
      remarks: remarks || null,
      isRepeat,
      term: editTerm ? parseInt(editTerm) : null,
      yearTerm: editYearTerm || null,
    });
    setEditing(false);
  }, [enrollment.id, dateStarted, dateEnded, grade, remarks, isRepeat, editTerm, editYearTerm, onUpdate]);

  const isFailed = enrollment.grade != null && enrollment.grade < passThreshold;
  const isPassed = enrollment.grade != null && enrollment.grade >= passThreshold;

  if (editing) {
    return (
      <>
        <tr className="border-b bg-muted/20" data-testid={`row-number-edit-${enrollment.id}`}>
          <td className="py-2 pl-10 pr-2 text-sm text-muted-foreground font-mono">{enrollment.number}</td>
          <td className="py-2 px-2">
            <DatePicker value={dateStarted} onChange={(v) => v && setDateStarted(v)} placeholder="Date started" />
          </td>
          <td className="py-2 px-2">
            <DatePicker value={dateEnded} onChange={(v) => setDateEnded(v)} placeholder="Date ended" />
          </td>
          <td className="py-2 px-2 text-center text-amber-500 text-xs">{"★".repeat(Math.max(1, starValue))}</td>
          <td className="py-2 px-2">
            <Input
              type="number" step="0.1" min="0" max="100"
              value={grade}
              onChange={e => setGrade(e.target.value)}
              className="w-[80px] h-8 text-xs"
              placeholder="Grade"
              data-testid="input-grade-edit"
            />
          </td>
          <td className="py-2 px-2">
            <Textarea
              value={remarks}
              onChange={e => setRemarks(e.target.value.slice(0, 1000))}
              maxLength={1000}
              className="text-xs min-h-[32px] h-8 resize-none"
              placeholder="Remarks..."
              data-testid="input-remarks-edit"
            />
          </td>
          <td className="py-2 px-2 text-right">
            <div className="flex items-center gap-1 justify-end flex-wrap">
              <label className="flex items-center gap-1 text-xs text-muted-foreground cursor-pointer mr-1">
                <Checkbox checked={isRepeat} onCheckedChange={(v) => setIsRepeat(!!v)} data-testid="checkbox-is-repeat" />
                Repeat
              </label>
              <Button size="sm" variant="default" onClick={handleSave} disabled={isPending} className="h-7 text-xs" data-testid="button-save-number">
                Save
              </Button>
              <Button size="sm" variant="ghost" onClick={() => setEditing(false)} className="h-7 text-xs">
                Cancel
              </Button>
              <Button
                size="sm" variant="ghost"
                onClick={() => { if (confirm("Delete this PACE enrollment?")) { onDelete(enrollment.id); setEditing(false); } }}
                disabled={isPending}
                className="h-7 text-xs text-destructive hover:text-destructive"
                data-testid={`button-delete-number-${enrollment.id}`}
              >
                <Trash2 className="h-3 w-3" />
              </Button>
            </div>
          </td>
        </tr>
        <tr className="bg-muted/20 border-b">
          <td className="pl-10 pb-2 pr-2" />
          <td colSpan={3} className="pb-2 px-2">
            <div className="flex items-center gap-2">
              <span className="text-xs text-muted-foreground whitespace-nowrap">Term:</span>
              <Select value={editTerm} onValueChange={setEditTerm} data-testid="select-term-edit">
                <SelectTrigger className="h-7 text-xs w-[80px]">
                  <SelectValue placeholder="—" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="">—</SelectItem>
                  {[1, 2, 3, 4, 5].map(t => (
                    <SelectItem key={t} value={String(t)}>T{t}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
              <span className="text-xs text-muted-foreground whitespace-nowrap ml-2">Year–Term:</span>
              <Select value={editYearTerm} onValueChange={setEditYearTerm} data-testid="select-yearterm-edit">
                <SelectTrigger className="h-7 text-xs w-[100px]">
                  <SelectValue placeholder="—" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="">—</SelectItem>
                  {YEAR_TERM_OPTIONS.map(yt => (
                    <SelectItem key={yt} value={yt}>{yt}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </td>
          <td colSpan={3} className="pb-2 px-2">
            <p className="text-[10px] text-muted-foreground/60 italic">
              Term and Year–Term are normally auto-computed from the end date. Edit manually only to correct errors.
            </p>
          </td>
        </tr>
      </>
    );
  }

  return (
    <tr className="border-b last:border-0 hover:bg-muted/10" data-testid={`row-number-${enrollment.id}`}>
      <td className="py-2 pl-10 pr-2 text-sm text-muted-foreground font-mono">
        {enrollment.number}
        {enrollment.term != null && (
          <span className="ml-1.5 text-[10px] bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300 rounded px-1 font-sans">
            T{enrollment.term}
          </span>
        )}
      </td>
      <td className="py-2 px-2 text-sm text-muted-foreground">{formatDate(enrollment.dateStarted)}</td>
      <td className="py-2 px-2 text-sm text-muted-foreground">{formatDate(enrollment.dateEnded)}</td>
      <td className="py-2 px-2 text-center text-amber-500 text-xs">{"★".repeat(Math.max(1, starValue))}</td>
      <td className="py-2 px-2 text-sm text-center">
        {enrollment.grade != null ? (
          <span className={cn(isFailed && "text-red-600 italic font-normal")}>
            {enrollment.grade}
            {isPassed && enrollment.isRepeat && <sup className="text-[9px] ml-0.5">*</sup>}
          </span>
        ) : "—"}
      </td>
      <td className="py-2 px-2 text-xs text-muted-foreground max-w-[160px] truncate">{enrollment.remarks || "—"}</td>
      <td className="py-2 px-2 text-right">
        <Button size="icon" variant="ghost" className="h-7 w-7" onClick={() => setEditing(true)} data-testid={`button-edit-number-${enrollment.id}`}>
          <Pencil className="h-3 w-3" />
        </Button>
      </td>
    </tr>
  );
}

function AddPacesContent({
  studentId,
  courseId,
  paceStarMap,
  alreadyEnrolledNumbers,
  onCreated,
  onCancel,
  defaultTerm,
}: {
  studentId: number;
  courseId: number;
  paceStarMap: Map<string, number>;
  alreadyEnrolledNumbers: Set<string>;
  onCreated: () => void;
  onCancel: () => void;
  defaultTerm?: string;
}) {
  const { toast } = useToast();
  const [selectedTerm, setSelectedTerm] = useState<string>(defaultTerm ?? "");
  const [selectedPaces, setSelectedPaces] = useState<Set<string>>(new Set());
  const [repeatPaces, setRepeatPaces] = useState<Set<string>>(new Set());

  const allPaceNumbers = useMemo(() =>
    Array.from(paceStarMap.keys()).sort((a, b) => {
      const na = parseInt(a, 10), nb = parseInt(b, 10);
      if (!isNaN(na) && !isNaN(nb)) return na - nb;
      return a.localeCompare(b);
    }), [paceStarMap]);

  const unenrolledNumbers = useMemo(() => allPaceNumbers.filter(n => !alreadyEnrolledNumbers.has(n)), [allPaceNumbers, alreadyEnrolledNumbers]);
  const allSelected = unenrolledNumbers.length > 0 && unenrolledNumbers.every(n => selectedPaces.has(n));

  function toggleSelectAll(checked: boolean) {
    setSelectedPaces(prev => {
      const next = new Set(prev);
      if (checked) unenrolledNumbers.forEach(n => next.add(n));
      else unenrolledNumbers.forEach(n => next.delete(n));
      return next;
    });
  }

  function togglePace(n: string, checked: boolean) {
    setSelectedPaces(prev => {
      const next = new Set(prev);
      if (checked) next.add(n);
      else {
        next.delete(n);
        setRepeatPaces(p => { const r = new Set(p); r.delete(n); return r; });
      }
      return next;
    });
  }

  const createMutation = useMutation({
    mutationFn: async () => {
      if (selectedPaces.size === 0) throw new Error("Select at least one PACE");
      const pacesToEnroll = Array.from(selectedPaces).map(n => ({ number: n, isRepeat: repeatPaces.has(n) }));
      await apiRequest("POST", "/api/enrollments/course", {
        studentId,
        courseId,
        term: selectedTerm ? parseInt(selectedTerm) : null,
        paces: pacesToEnroll,
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/enrollments", studentId.toString()] });
      toast({ title: `${selectedPaces.size} PACE${selectedPaces.size !== 1 ? "s" : ""} enrolled` });
      onCreated();
    },
    onError: (err: Error) => toast({ title: "Failed to enroll", description: err.message, variant: "destructive" }),
  });

  if (allPaceNumbers.length === 0) {
    return (
      <div className="text-xs text-muted-foreground italic py-2">
        No PACE numbers configured for this course.
        <Button size="sm" variant="ghost" onClick={onCancel} className="ml-2 h-6 text-xs">Close</Button>
      </div>
    );
  }

  return (
    <div className="space-y-3 max-w-2xl" data-testid="add-paces-content">
      <div className="flex items-center gap-3 flex-wrap">
        <span className="text-sm font-medium">Enroll student for term:</span>
        <Select value={selectedTerm} onValueChange={setSelectedTerm}>
          <SelectTrigger className="w-[100px] h-8 text-xs" data-testid="select-enrollment-term">
            <SelectValue placeholder="Select..." />
          </SelectTrigger>
          <SelectContent>
            {[1, 2, 3, 4, 5].map(t => <SelectItem key={t} value={String(t)}>T{t}</SelectItem>)}
          </SelectContent>
        </Select>
        {!selectedTerm && <span className="text-xs text-muted-foreground">(optional)</span>}
      </div>

      <div className="space-y-2">
        {unenrolledNumbers.length > 0 && (
          <label className="flex items-center gap-2 text-xs font-medium cursor-pointer select-none" data-testid="label-select-all-paces">
            <Checkbox checked={allSelected} onCheckedChange={toggleSelectAll} data-testid="checkbox-select-all-paces" />
            Select all unenrolled ({unenrolledNumbers.length})
          </label>
        )}
        {unenrolledNumbers.length === 0 && allPaceNumbers.length > 0 && (
          <p className="text-xs text-muted-foreground">All PACEs for this course are already enrolled. You can still re-enroll as a Repeat PACE.</p>
        )}
        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-1 max-h-52 overflow-y-auto pr-1">
          {allPaceNumbers.map(n => {
            const isEnrolled = alreadyEnrolledNumbers.has(n);
            const isChecked = selectedPaces.has(n);
            const star = paceStarMap.get(n) ?? 1;
            return (
              <div key={n} className={cn("flex items-center gap-1.5 text-xs rounded px-2 py-1.5 border", isEnrolled ? "bg-muted/40 border-muted" : "border-transparent hover:bg-accent/30")}>
                <Checkbox checked={isChecked} onCheckedChange={(checked) => togglePace(n, !!checked)} data-testid={`checkbox-pace-${n}`} />
                <span className={cn("font-mono", isEnrolled && "text-muted-foreground")}>{n}</span>
                <span className="text-amber-500 text-[10px]">{"★".repeat(Math.max(1, star))}</span>
                {isEnrolled && <span className="text-[10px] text-muted-foreground ml-auto">✓</span>}
                {isChecked && (
                  <label className="flex items-center gap-0.5 cursor-pointer ml-auto" title="Mark as Repeat PACE">
                    <Checkbox
                      checked={repeatPaces.has(n)}
                      onCheckedChange={(checked) => {
                        setRepeatPaces(prev => { const next = new Set(prev); if (checked) next.add(n); else next.delete(n); return next; });
                      }}
                      className="h-3 w-3"
                      data-testid={`checkbox-repeat-${n}`}
                    />
                    <span className="text-[10px] text-muted-foreground">R</span>
                  </label>
                )}
              </div>
            );
          })}
        </div>
      </div>

      <div className="flex items-center gap-2 pt-1">
        <Button
          size="sm"
          onClick={() => createMutation.mutate()}
          disabled={selectedPaces.size === 0 || createMutation.isPending}
          className="h-7 text-xs"
          data-testid="button-enroll-paces"
        >
          {createMutation.isPending ? "Enrolling..." : `Enroll ${selectedPaces.size || ""} PACE${selectedPaces.size !== 1 ? "s" : ""}`}
        </Button>
        <Button size="sm" variant="ghost" onClick={onCancel} className="h-7 text-xs" data-testid="button-cancel-enroll-paces">
          Cancel
        </Button>
      </div>
    </div>
  );
}

function AddPacesForCourseForm(props: Parameters<typeof AddPacesContent>[0]) {
  return (
    <tr data-testid="row-add-paces-form">
      <td colSpan={COL_COUNT} className="py-3 px-6 bg-accent/20 border-b">
        <AddPacesContent {...props} />
      </td>
    </tr>
  );
}

function CourseGroupRow({
  group,
  courseMap,
  course,
  onUpdate,
  onDelete,
  onDeleteCourse,
  isPending,
  paceStarMap,
  passThreshold,
  enrolledNumbers,
  studentId,
  forceExpand,
  defaultTerm,
}: {
  group: CourseGroup;
  courseMap: Map<number, Course>;
  course: Course | undefined;
  onUpdate: (id: number, data: any) => void;
  onDelete: (id: number) => void;
  onDeleteCourse: (studentId: number, courseId: number) => void;
  isPending: boolean;
  paceStarMap: Map<string, number>;
  passThreshold: number;
  enrolledNumbers: Set<string>;
  studentId: number;
  forceExpand: boolean;
  defaultTerm?: string;
}) {
  const [expanded, setExpanded] = useState(false);
  const [showAddPaces, setShowAddPaces] = useState(false);

  useEffect(() => { setExpanded(forceExpand); }, [forceExpand]);

  const failedCount = group.enrollments.filter(e => e.grade != null && e.grade < passThreshold).length;

  return (
    <>
      <tr
        className="border-b bg-muted/5 cursor-pointer hover:bg-muted/20 select-none"
        onClick={() => setExpanded(!expanded)}
        data-testid={`row-course-group-${group.courseId}`}
      >
        <td className="py-3 px-3 font-medium text-sm">
          <div className="flex items-center gap-2">
            {expanded ? <ChevronDown className="h-4 w-4 text-muted-foreground shrink-0" /> : <ChevronRight className="h-4 w-4 text-muted-foreground shrink-0" />}
            <span>{group.courseName}</span>
            <span className="text-xs text-muted-foreground font-normal">({group.enrollments.length})</span>
            {failedCount > 0 && <span className="text-xs text-red-500 font-normal">{failedCount} failed</span>}
          </div>
        </td>
        <td className="py-3 px-2 text-sm text-muted-foreground">{formatDate(group.minDateStarted)}</td>
        <td className="py-3 px-2 text-sm text-muted-foreground">{formatDate(group.maxDateEnded)}</td>
        <td className="py-3 px-2"></td>
        <td className="py-3 px-2"></td>
        <td className="py-3 px-2"></td>
        <td className="py-3 px-2 text-right" onClick={e => e.stopPropagation()}>
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button size="icon" variant="ghost" className="h-8 w-8" data-testid={`button-actions-course-${group.courseId}`}>
                <Pencil className="h-3.5 w-3.5" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuItem onClick={() => { setExpanded(true); setShowAddPaces(true); }} data-testid="menu-add-paces">
                <Plus className="h-3.5 w-3.5 mr-2" />
                Add enrollment
              </DropdownMenuItem>
              <DropdownMenuItem onClick={() => setExpanded(true)} data-testid="menu-expand">
                <ChevronDown className="h-3.5 w-3.5 mr-2" />
                Expand numbers
              </DropdownMenuItem>
              <DropdownMenuItem
                onClick={() => onDeleteCourse(studentId, group.courseId)}
                className="text-red-600"
                data-testid="menu-delete-course"
              >
                <Trash2 className="h-3.5 w-3.5 mr-2" />
                Remove course enrollment
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </td>
      </tr>
      {expanded && group.enrollments.map(enrollment => (
        <NumberRow
          key={enrollment.id}
          enrollment={enrollment}
          onUpdate={onUpdate}
          onDelete={onDelete}
          isPending={isPending}
          starValue={paceStarMap.get(enrollment.number) ?? 1}
          passThreshold={passThreshold}
        />
      ))}
      {expanded && showAddPaces && (
        <AddPacesForCourseForm
          studentId={studentId}
          courseId={group.courseId}
          paceStarMap={paceStarMap}
          alreadyEnrolledNumbers={enrolledNumbers}
          onCreated={() => setShowAddPaces(false)}
          onCancel={() => setShowAddPaces(false)}
          defaultTerm={defaultTerm}
        />
      )}
      {expanded && !showAddPaces && (
        <tr className="border-b">
          <td colSpan={7} className="py-1 px-2 text-right">
            <Button size="sm" variant="ghost" className="h-6 text-xs" onClick={() => setShowAddPaces(true)} data-testid={`button-add-paces-${group.courseId}`}>
              <Plus className="h-3 w-3 mr-1" />
              Add enrollment
            </Button>
          </td>
        </tr>
      )}
    </>
  );
}

function NewEnrollmentForm({
  studentId,
  allEnrollments,
  paceStarMapByCourse,
  onCreated,
  onCancel,
}: {
  studentId: number;
  allEnrollments: Enrollment[];
  paceStarMapByCourse: Map<number, Map<string, number>>;
  onCreated: () => void;
  onCancel: () => void;
}) {
  const [selectedCourse, setSelectedCourse] = useState<Course | null>(null);

  const existingCourseIds = useMemo(() => {
    const ids = new Set<number>();
    allEnrollments.forEach(e => ids.add(e.courseId));
    return Array.from(ids);
  }, [allEnrollments]);

  const alreadyEnrolledNumbers = useMemo(() => {
    if (!selectedCourse) return new Set<string>();
    return new Set(allEnrollments.filter(e => e.courseId === selectedCourse.id).map(e => e.number));
  }, [allEnrollments, selectedCourse]);

  if (!selectedCourse) {
    return (
      <div className="border rounded-lg bg-accent/30 p-4 space-y-3" data-testid="form-new-enrollment">
        <p className="text-sm font-medium">Select a course to enroll in:</p>
        <CourseSearch onSelect={setSelectedCourse} exclude={existingCourseIds} />
        <Button size="sm" variant="ghost" onClick={onCancel} className="h-8 text-xs" data-testid="button-cancel-new-enrollment">
          Cancel
        </Button>
      </div>
    );
  }

  const paceStarMap = paceStarMapByCourse.get(selectedCourse.id) || new Map<string, number>();

  return (
    <div className="border rounded-lg bg-accent/30 p-4 space-y-3" data-testid="form-new-enrollment-paces">
      <div className="flex items-center gap-2">
        <span className="text-sm font-semibold">{selectedCourse.icceAlias || selectedCourse.aceAlias}</span>
        <Button size="sm" variant="ghost" className="h-6 text-xs" onClick={() => setSelectedCourse(null)}>Change</Button>
      </div>
      <AddPacesContent
        studentId={studentId}
        courseId={selectedCourse.id}
        paceStarMap={paceStarMap}
        alreadyEnrolledNumbers={alreadyEnrolledNumbers}
        onCreated={onCreated}
        onCancel={onCancel}
      />
    </div>
  );
}

function SuppActivityRow({ sa, onDelete, studentId }: { sa: SupplementaryActivity; onDelete: () => void; studentId: number }) {
  const { toast } = useToast();
  const [editing, setEditing] = useState(false);
  const [term, setTerm] = useState(sa.term?.toString() || "");
  const [grade, setGrade] = useState(sa.grade || "");

  const updateMutation = useMutation({
    mutationFn: async () => {
      await apiRequest("PATCH", `/api/supplementary-activities/${sa.id}`, {
        term: term ? parseInt(term) : null,
        grade: grade || null,
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/supplementary-activities", studentId.toString()] });
      toast({ title: "Activity updated" });
      setEditing(false);
    },
    onError: (err: Error) => toast({ title: "Failed to update", description: err.message, variant: "destructive" }),
  });

  if (editing) {
    return (
      <tr className="border-b bg-muted/20" data-testid={`row-supp-edit-${sa.id}`}>
        <td className="py-2 px-4 text-sm">{sa.activity}</td>
        <td className="py-2 px-4">
          <Select value={term} onValueChange={setTerm}>
            <SelectTrigger className="w-[80px] h-8 text-xs" data-testid="select-supp-term-edit"><SelectValue placeholder="Term" /></SelectTrigger>
            <SelectContent>{[1, 2, 3, 4, 5].map(t => <SelectItem key={t} value={String(t)}>T{t}</SelectItem>)}</SelectContent>
          </Select>
        </td>
        <td className="py-2 px-4">
          <Input value={grade} onChange={e => setGrade(e.target.value.slice(0, 4))} maxLength={4} className="w-[80px] h-8 text-xs" data-testid="input-supp-grade-edit" />
        </td>
        <td className="py-2 px-4 text-right">
          <div className="flex gap-1 justify-end">
            <Button size="sm" onClick={() => updateMutation.mutate()} disabled={updateMutation.isPending} className="h-7 text-xs" data-testid="button-save-supp">Save</Button>
            <Button size="sm" variant="ghost" onClick={() => setEditing(false)} className="h-7 text-xs">Cancel</Button>
          </div>
        </td>
      </tr>
    );
  }

  return (
    <tr className="border-b last:border-0 hover:bg-muted/10" data-testid={`row-supp-${sa.id}`}>
      <td className="py-2 px-4 text-sm">{sa.activity}</td>
      <td className="py-2 px-4 text-sm text-muted-foreground">{sa.term ? `T${sa.term}` : "—"}</td>
      <td className="py-2 px-4 text-sm">{sa.grade || "—"}</td>
      <td className="py-2 px-4 text-right">
        <div className="flex gap-1 justify-end">
          <Button size="icon" variant="ghost" className="h-7 w-7" onClick={() => setEditing(true)} data-testid={`button-edit-supp-${sa.id}`}>
            <Pencil className="h-3 w-3" />
          </Button>
          <Button size="icon" variant="ghost" className="h-7 w-7 text-destructive hover:text-destructive" onClick={onDelete} data-testid={`button-delete-supp-${sa.id}`}>
            <Trash2 className="h-3 w-3" />
          </Button>
        </div>
      </td>
    </tr>
  );
}

function NewSuppActivityForm({ studentId, onCreated, onCancel }: { studentId: number; onCreated: () => void; onCancel: () => void }) {
  const { toast } = useToast();
  const [selectedActivity, setSelectedActivity] = useState("");
  const [customActivity, setCustomActivity] = useState("");
  const [term, setTerm] = useState("");
  const [grade, setGrade] = useState("");
  const [yearTerm] = useState(() => getCurrentYearTerm());

  const createMutation = useMutation({
    mutationFn: async () => {
      const activityName = selectedActivity === "Other" ? customActivity : selectedActivity;
      if (!activityName) throw new Error("Activity name is required");
      await apiRequest("POST", "/api/supplementary-activities", {
        studentId,
        activity: activityName,
        yearTerm,
        term: term ? parseInt(term) : null,
        grade: grade || null,
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/supplementary-activities", studentId.toString()] });
      toast({ title: "Supplementary activity added" });
      setSelectedActivity(""); setCustomActivity(""); setTerm(""); setGrade("");
      onCreated();
    },
    onError: (err: Error) => toast({ title: "Failed to create enrollment", description: err.message, variant: "destructive" }),
  });

  const activityName = selectedActivity === "Other" ? customActivity : selectedActivity;

  return (
    <div className="border rounded-lg bg-accent/30 p-4 space-y-4" data-testid="form-new-supp-activity">
      <div className="space-y-2">
        <Label>Activity</Label>
        <Select value={selectedActivity} onValueChange={v => { setSelectedActivity(v); if (v !== "Other") setCustomActivity(""); }}>
          <SelectTrigger data-testid="select-supp-activity"><SelectValue placeholder="Select activity..." /></SelectTrigger>
          <SelectContent>{SUPP_ACTIVITIES.map(a => <SelectItem key={a} value={a}>{a}</SelectItem>)}</SelectContent>
        </Select>
      </div>
      {selectedActivity === "Other" && (
        <div className="space-y-2">
          <Label>Activity Name</Label>
          <Input value={customActivity} onChange={e => setCustomActivity(e.target.value)} placeholder="Enter activity name..." data-testid="input-custom-activity" />
        </div>
      )}
      <div className="flex gap-4">
        <div className="space-y-2">
          <Label>Term (optional)</Label>
          <Select value={term} onValueChange={setTerm}>
            <SelectTrigger className="w-[100px]" data-testid="select-new-supp-term"><SelectValue placeholder="Term" /></SelectTrigger>
            <SelectContent>{[1, 2, 3, 4, 5].map(t => <SelectItem key={t} value={String(t)}>T{t}</SelectItem>)}</SelectContent>
          </Select>
        </div>
        <div className="space-y-2">
          <Label>Grade (optional)</Label>
          <Input value={grade} onChange={e => setGrade(e.target.value.slice(0, 4))} maxLength={4} className="w-[100px]" placeholder="e.g. A" data-testid="input-new-supp-grade" />
        </div>
      </div>
      <div className="flex items-center gap-2">
        <Button size="sm" onClick={() => createMutation.mutate()} disabled={!activityName || createMutation.isPending} className="h-8 text-xs" data-testid="button-save-supp-activity">
          {createMutation.isPending ? "Creating..." : "Create enrollment"}
        </Button>
        <Button size="sm" variant="ghost" onClick={onCancel} className="h-8 text-xs" data-testid="button-cancel-supp-activity">Cancel</Button>
      </div>
    </div>
  );
}

type ConflictRow = {
  rowIndex: number;
  excelRow: { studentId: number; courseId: number; number: string; dateStarted: string | null; dateEnded: string | null; grade: number | null; remarks: string | null };
  dbRow: { id: number; studentId: number; courseId: number; number: string; dateStarted: string | null; dateEnded: string | null; grade: number | null; remarks: string | null };
};

function ImportDialog({ open, onOpenChange }: { open: boolean; onOpenChange: (v: boolean) => void }) {
  const { toast } = useToast();
  const [file, setFile] = useState<File | null>(null);
  const [importing, setImporting] = useState(false);
  const [resolving, setResolving] = useState(false);
  const [result, setResult] = useState<{ imported: number; skipped: number; updated?: number; errors?: string[] } | null>(null);
  const [conflicts, setConflicts] = useState<ConflictRow[] | null>(null);
  const [conflictChoices, setConflictChoices] = useState<Map<number, "db" | "excel">>(new Map());
  const [sessionId, setSessionId] = useState<string | null>(null);
  const [newRowCount, setNewRowCount] = useState(0);
  const [skippedIdentical, setSkippedIdentical] = useState(0);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const { data: allStudents } = useQuery<Student[]>({ queryKey: ["/api/students"] });
  const { data: allCourses } = useQuery<Course[]>({ queryKey: ["/api/courses"] });

  const studentMap = useMemo(() => {
    const m = new Map<number, Student>();
    allStudents?.forEach(s => m.set(s.id, s));
    return m;
  }, [allStudents]);

  const courseMap = useMemo(() => {
    const m = new Map<number, Course>();
    allCourses?.forEach(c => m.set(c.id, c));
    return m;
  }, [allCourses]);

  function handleDownloadTemplate() {
    window.open("/api/enrollments/template", "_blank");
  }

  async function handleImport() {
    if (!file) return;
    setImporting(true);
    setResult(null);
    setConflicts(null);
    setSessionId(null);
    try {
      const formData = new FormData();
      formData.append("file", file);
      const res = await fetch("/api/enrollments/import", { method: "POST", body: formData, credentials: "include" });
      const data = await res.json();
      if (!res.ok) throw new Error(data.message || "Import failed");
      if (data.conflicts && data.conflicts.length > 0) {
        setConflicts(data.conflicts);
        setSessionId(data.sessionId);
        setNewRowCount(data.newRowCount || 0);
        setSkippedIdentical(data.skippedIdentical || 0);
        const initialChoices = new Map<number, "db" | "excel">();
        data.conflicts.forEach((_: ConflictRow, i: number) => initialChoices.set(i, "db"));
        setConflictChoices(initialChoices);
      } else {
        setResult(data);
        queryClient.invalidateQueries({ queryKey: ["/api/enrollments"] });
      }
    } catch (err: any) {
      toast({ title: "Import failed", description: err.message, variant: "destructive" });
    } finally {
      setImporting(false);
    }
  }

  async function handleResolve() {
    if (!sessionId || !conflicts) return;
    setResolving(true);
    try {
      const choices: ("db" | "excel")[] = conflicts.map((_, i) => conflictChoices.get(i) ?? "db");
      const res = await fetch("/api/enrollments/import/resolve", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        credentials: "include",
        body: JSON.stringify({ sessionId, choices }),
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.message || "Resolve failed");
      setResult(data);
      setConflicts(null);
      setSessionId(null);
      queryClient.invalidateQueries({ queryKey: ["/api/enrollments"] });
    } catch (err: any) {
      toast({ title: "Resolve failed", description: err.message, variant: "destructive" });
    } finally {
      setResolving(false);
    }
  }

  function handleClose() {
    setFile(null); setResult(null); setConflicts(null); setSessionId(null);
    setConflictChoices(new Map()); setNewRowCount(0); setSkippedIdentical(0);
    onOpenChange(false);
  }

  return (
    <Dialog open={open} onOpenChange={handleClose}>
      <DialogContent className="max-w-2xl max-h-[80vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>Import Enrollments</DialogTitle>
        </DialogHeader>
        <div className="space-y-4">
          <div className="flex gap-2">
            <Button variant="outline" size="sm" onClick={handleDownloadTemplate} data-testid="button-download-template">
              <Download className="h-3.5 w-3.5 mr-2" />
              Download Template
            </Button>
          </div>

          {!result && !conflicts && (
            <div className="space-y-3">
              <div
                className="border-2 border-dashed rounded-lg p-6 text-center cursor-pointer hover:bg-accent/30"
                onClick={() => fileInputRef.current?.click()}
                data-testid="dropzone-import"
              >
                <Upload className="h-8 w-8 mx-auto text-muted-foreground mb-2" />
                <p className="text-sm text-muted-foreground">{file ? file.name : "Click to select Excel file (.xlsx)"}</p>
              </div>
              <input ref={fileInputRef} type="file" accept=".xlsx" className="hidden" onChange={e => setFile(e.target.files?.[0] || null)} data-testid="input-import-file" />
              <Button onClick={handleImport} disabled={!file || importing} className="w-full" data-testid="button-import-submit">
                {importing ? "Importing..." : "Import"}
              </Button>
            </div>
          )}

          {conflicts && (
            <div className="space-y-3">
              <div className="flex gap-4 text-sm">
                <span className="text-green-600"><CheckCircle2 className="h-4 w-4 inline mr-1" />{newRowCount} new</span>
                <span className="text-muted-foreground">{skippedIdentical} identical (skipped)</span>
                <span className="text-amber-600"><AlertCircle className="h-4 w-4 inline mr-1" />{conflicts.length} conflicts</span>
              </div>
              <p className="text-sm font-medium">Choose which version to keep for each conflict:</p>
              <div className="space-y-2 max-h-60 overflow-y-auto">
                {conflicts.map((c, i) => {
                  const student = studentMap.get(c.dbRow.studentId);
                  const course = courseMap.get(c.dbRow.courseId);
                  const choice = conflictChoices.get(i) ?? "db";
                  return (
                    <div key={i} className="border rounded-lg p-3 space-y-2" data-testid={`conflict-row-${i}`}>
                      <p className="text-xs font-medium text-muted-foreground">
                        {student ? `${student.callName} ${student.surname}` : `Student #${c.dbRow.studentId}`} — {course?.icceAlias || course?.aceAlias || `Course #${c.dbRow.courseId}`} — PACE {c.dbRow.number}
                      </p>
                      <div className="grid grid-cols-2 gap-2">
                        <button
                          type="button"
                          className={cn("text-left border rounded p-2 text-xs", choice === "db" ? "border-primary bg-primary/10" : "hover:bg-accent")}
                          onClick={() => setConflictChoices(prev => { const n = new Map(prev); n.set(i, "db"); return n; })}
                          data-testid={`conflict-choose-db-${i}`}
                        >
                          <p className="font-medium mb-1">Keep database</p>
                          <p>Grade: {c.dbRow.grade ?? "—"}</p>
                          <p>Started: {c.dbRow.dateStarted || "—"}</p>
                          <p>Ended: {c.dbRow.dateEnded || "—"}</p>
                        </button>
                        <button
                          type="button"
                          className={cn("text-left border rounded p-2 text-xs", choice === "excel" ? "border-primary bg-primary/10" : "hover:bg-accent")}
                          onClick={() => setConflictChoices(prev => { const n = new Map(prev); n.set(i, "excel"); return n; })}
                          data-testid={`conflict-choose-excel-${i}`}
                        >
                          <p className="font-medium mb-1">Use Excel</p>
                          <p>Grade: {c.excelRow.grade ?? "—"}</p>
                          <p>Started: {c.excelRow.dateStarted || "—"}</p>
                          <p>Ended: {c.excelRow.dateEnded || "—"}</p>
                        </button>
                      </div>
                    </div>
                  );
                })}
              </div>
              <Button onClick={handleResolve} disabled={resolving} className="w-full" data-testid="button-resolve-conflicts">
                {resolving ? "Applying..." : "Apply choices"}
              </Button>
            </div>
          )}

          {result && (
            <div className="space-y-2">
              <div className="flex gap-4 text-sm">
                <span className="text-green-600"><CheckCircle2 className="h-4 w-4 inline mr-1" />{result.imported} imported</span>
                {result.updated != null && <span className="text-blue-600">{result.updated} updated</span>}
                <span className="text-muted-foreground">{result.skipped} skipped</span>
              </div>
              {result.errors && result.errors.length > 0 && (
                <div className="text-xs text-red-600 space-y-1">
                  <p className="font-medium">Errors:</p>
                  <ul className="list-disc list-inside">{result.errors.slice(0, 10).map((e, i) => <li key={i}>{e}</li>)}</ul>
                </div>
              )}
              <Button onClick={handleClose} className="w-full" data-testid="button-import-done">Done</Button>
            </div>
          )}
        </div>
      </DialogContent>
    </Dialog>
  );
}

export default function EnrollmentsPage() {
  const { toast } = useToast();
  const [selectedStudentId, setSelectedStudentId] = usePersistedState<string>("shared.selectedStudentId", "");
  const [showNewRow, setShowNewRow] = useState(false);
  const [showNewSuppRow, setShowNewSuppRow] = useState(false);
  const [showImport, setShowImport] = useState(false);
  const [selectedYearTerms, setSelectedYearTerms] = usePersistedState<Set<string>>("enrollments.selectedYearTerms", new Set([getCurrentYearTerm()]));
  const [yearTermFilterOpen, setYearTermFilterOpen] = useState(false);
  const [termFilter, setTermFilter] = usePersistedState<string>("enrollments.termFilter", "all");
  const [expandAll, setExpandAll] = useState(false);

  const { data: students } = useQuery<Student[]>({ queryKey: ["/api/students"] });
  const selectedStudent = useMemo(() => {
    if (!selectedStudentId || !students) return null;
    return students.find(s => s.id === parseInt(selectedStudentId)) || null;
  }, [selectedStudentId, students]);

  const { data: enrollments, isLoading: enrollmentsLoading } = useQuery<Enrollment[]>({
    queryKey: ["/api/enrollments", selectedStudentId],
    queryFn: async () => {
      const res = await fetch(`/api/enrollments?studentId=${selectedStudentId}`, { credentials: "include" });
      if (!res.ok) throw new Error("Failed to fetch enrollments");
      return res.json();
    },
    enabled: !!selectedStudentId,
  });

  const { data: courses } = useQuery<Course[]>({ queryKey: ["/api/courses"] });
  const { data: paces } = useQuery<Pace[]>({ queryKey: ["/api/paces"] });
  const { data: paceCourses } = useQuery<PaceCourse[]>({ queryKey: ["/api/pace-courses"] });
  const { data: subjects } = useQuery<Subject[]>({ queryKey: ["/api/subjects"] });
  const { data: termWeeks } = useQuery<{ yearTerm: string; term: number; weeks: number }[]>({ queryKey: ["/api/dates/term-weeks"] });

  const { data: suppActivities } = useQuery<SupplementaryActivity[]>({
    queryKey: ["/api/supplementary-activities", selectedStudentId],
    queryFn: async () => {
      const res = await fetch(`/api/supplementary-activities?studentId=${selectedStudentId}`, { credentials: "include" });
      if (!res.ok) throw new Error("Failed to fetch supplementary activities");
      return res.json();
    },
    enabled: !!selectedStudentId,
  });

  const courseMap = useMemo(() => new Map((courses || []).map(c => [c.id, c])), [courses]);
  const subjectById = useMemo(() => new Map((subjects || []).map(s => [s.id, s])), [subjects]);
  const paceById = useMemo(() => new Map((paces || []).map(p => [p.id, p])), [paces]);

  const paceStarMapByCourse = useMemo(() => {
    const m = new Map<number, Map<string, number>>();
    for (const pc of paceCourses || []) {
      if (pc.number == null) continue;
      const pace = paceById.get(pc.paceId);
      const star = pace?.starValue ?? 1;
      let cm = m.get(pc.courseId);
      if (!cm) { cm = new Map(); m.set(pc.courseId, cm); }
      cm.set(pc.number, star);
    }
    return m;
  }, [paceCourses, paceById]);

  const enrolledByCourseFull = useMemo(() => {
    const m = new Map<number, Set<string>>();
    for (const e of enrollments || []) {
      let s = m.get(e.courseId);
      if (!s) { s = new Set(); m.set(e.courseId, s); }
      s.add(e.number);
    }
    return m;
  }, [enrollments]);

  const availableYearTerms = useMemo(() => {
    if (!enrollments) return [];
    const ytSet = new Set<string>();
    for (const e of enrollments) {
      const yt = e.yearTerm ?? (e.dateStarted ? computeYearTermFromDate(e.dateStarted) : null);
      if (yt) ytSet.add(yt);
    }
    return Array.from(ytSet).sort();
  }, [enrollments]);

  const filteredEnrollments = useMemo(() => {
    if (!enrollments) return [];
    let result = enrollments;
    if (selectedYearTerms.size > 0) {
      result = result.filter(e => {
        // Always show enrollments with no date information at all (not yet started)
        if (!e.yearTerm && !e.dateStarted && !e.dateEnded) return true;
        const yt = e.yearTerm ?? (e.dateStarted ? computeYearTermFromDate(e.dateStarted) : null);
        return yt ? selectedYearTerms.has(yt) : false;
      });
    }
    if (termFilter !== "all") {
      const tf = parseInt(termFilter);
      // Use loose equality (==) to handle any integer/string type variance from the DB
      result = result.filter(e => e.term == tf || e.term == null);
    }
    return result;
  }, [enrollments, selectedYearTerms, termFilter]);

  const courseGroups = useMemo(() => groupEnrollmentsByCourse(filteredEnrollments, courseMap), [filteredEnrollments, courseMap]);

  const honorRoll = useMemo(() => {
    if (!selectedStudent || termFilter === "all" || !termWeeks) return null;
    const tf = parseInt(termFilter);

    // Pick the best year-term: prefer the one from the active year-term filter,
    // else use the most recent complete school year (>= 4 terms) that has this term.
    let yearTermToUse: string | null = null;
    if (selectedYearTerms.size === 1) {
      yearTermToUse = [...selectedYearTerms][0];
    } else {
      const termCountByYearTerm = new Map<string, number>();
      for (const tw of termWeeks) {
        termCountByYearTerm.set(tw.yearTerm, (termCountByYearTerm.get(tw.yearTerm) ?? 0) + 1);
      }
      const candidates = termWeeks
        .filter(tw => tw.term === tf && (termCountByYearTerm.get(tw.yearTerm) ?? 0) >= 4)
        .map(tw => tw.yearTerm)
        .sort();
      yearTermToUse = candidates.at(-1) ?? null;
    }
    if (!yearTermToUse) return null;
    const termData = termWeeks.find(tw => tw.yearTerm === yearTermToUse && tw.term === tf);
    if (!termData) return null;
    const z = termData.weeks;
    const x = z * 2 - 1;
    let sumGradeWeight = 0, sumWeight = 0, totalStars = 0;
    for (const e of filteredEnrollments) {
      if (e.term !== tf) continue; // only count PACEs explicitly tagged to this term
      const course = courseMap.get(e.courseId);
      if (!course) continue;
      const threshold = getEffectivePassThreshold(course, selectedStudent.isDyslexic, subjectById);
      const star = paceStarMapByCourse.get(e.courseId)?.get(e.number) ?? 1;
      if (e.grade != null && e.grade >= threshold) {
        totalStars += star;
        sumGradeWeight += e.grade * star;
        sumWeight += star;
      }
    }
    const y = totalStars;
    const w = sumWeight > 0 ? sumGradeWeight / sumWeight : null;
    let score: string | null = null;
    if (y >= x && w != null) {
      if (w >= 98) score = "A*";
      else if (w >= 96) score = "A";
      else if (w >= 92) score = "B";
    }
    return { x, y, w, z, score };
  }, [selectedStudent, termFilter, termWeeks, selectedYearTerms, filteredEnrollments, courseMap, subjectById, paceStarMapByCourse]);

  const deleteSuppMutation = useMutation({
    mutationFn: async (id: number) => { await apiRequest("DELETE", `/api/supplementary-activities/${id}`); },
    onSuccess: () => {
      if (selectedStudentId) queryClient.invalidateQueries({ queryKey: ["/api/supplementary-activities", selectedStudentId] });
      toast({ title: "Supplementary activity removed" });
    },
    onError: (err: Error) => toast({ title: "Failed to delete", description: err.message, variant: "destructive" }),
  });

  const updateMutation = useMutation({
    mutationFn: async ({ id, data }: { id: number; data: any }) => {
      await apiRequest("PATCH", `/api/enrollments/${id}`, data);
    },
    onSuccess: () => {
      if (selectedStudentId) queryClient.invalidateQueries({ queryKey: ["/api/enrollments", selectedStudentId] });
      toast({ title: "Enrollment updated" });
    },
    onError: (err: Error) => toast({ title: "Failed to update", description: err.message, variant: "destructive" }),
  });

  const deleteEnrollmentMutation = useMutation({
    mutationFn: async (id: number) => { await apiRequest("DELETE", `/api/enrollments/${id}`); },
    onSuccess: () => {
      if (selectedStudentId) queryClient.invalidateQueries({ queryKey: ["/api/enrollments", selectedStudentId] });
      toast({ title: "PACE enrollment removed" });
    },
    onError: (err: Error) => toast({ title: "Failed to delete", description: err.message, variant: "destructive" }),
  });

  const deleteCourseEnrollmentMutation = useMutation({
    mutationFn: async ({ studentId, courseId }: { studentId: number; courseId: number }) => {
      await apiRequest("DELETE", `/api/enrollments/course/${studentId}/${courseId}`);
    },
    onSuccess: () => {
      if (selectedStudentId) queryClient.invalidateQueries({ queryKey: ["/api/enrollments", selectedStudentId] });
      toast({ title: "Course enrollment removed" });
    },
    onError: (err: Error) => toast({ title: "Failed to delete", description: err.message, variant: "destructive" }),
  });

  const handleUpdate = useCallback((id: number, data: any) => { updateMutation.mutate({ id, data }); }, [updateMutation]);
  const handleDelete = useCallback((id: number) => { deleteEnrollmentMutation.mutate(id); }, [deleteEnrollmentMutation]);
  const handleDeleteCourse = useCallback((studentId: number, courseId: number) => {
    deleteCourseEnrollmentMutation.mutate({ studentId, courseId });
  }, [deleteCourseEnrollmentMutation]);

  return (
    <div className="p-6 space-y-6 max-w-6xl mx-auto">
      <div className="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-4">
        <div className="min-w-0">
          <h1 className="text-2xl font-bold" data-testid="heading-enrollments">Enrollments</h1>
          <p className="text-muted-foreground text-sm mt-1">Manage student PACE enrollments and grades</p>
        </div>
        <div className="flex flex-wrap items-center gap-2 sm:justify-end sm:shrink-0">
          <Button variant="outline" size="sm" onClick={() => setShowImport(true)} data-testid="button-import-enrollments">
            <Upload className="h-4 w-4 mr-2" />
            Import
          </Button>
          <Button variant="outline" size="sm" onClick={() => window.open("/api/enrollments/export", "_blank")} data-testid="button-export-enrollments">
            <Download className="h-4 w-4 mr-2" />
            Export
          </Button>
        </div>
      </div>

      <ImportDialog open={showImport} onOpenChange={setShowImport} />

      <Card>
        <CardHeader>
          <CardTitle className="text-base">Select Student</CardTitle>
        </CardHeader>
        <CardContent>
          <StudentSearch onSelect={(s) => { setSelectedStudentId(String(s.id)); setShowNewRow(false); }} selectedStudent={selectedStudent} className="max-w-md" />
          {selectedStudent && (
            <div className="mt-3 flex items-center gap-2">
              <span className="text-sm text-muted-foreground">Selected:</span>
              <span className="text-sm font-semibold" data-testid="text-selected-student">
                {selectedStudent.callName} {selectedStudent.surname}
              </span>
              {selectedStudent.firstNames && (
                <span className="text-xs text-muted-foreground">({selectedStudent.firstNames})</span>
              )}
              {selectedStudent.isDyslexic && (
                <span className="text-xs bg-purple-100 dark:bg-purple-900/30 text-purple-700 dark:text-purple-300 px-1.5 py-0.5 rounded">Dyslexic</span>
              )}
            </div>
          )}
        </CardContent>
      </Card>

      {selectedStudent && honorRoll && (
        <div
          className={cn(
            "rounded-lg border px-4 py-3 text-sm",
            honorRoll.score
              ? "bg-green-50 dark:bg-green-950/30 border-green-300 dark:border-green-700"
              : "bg-muted/30"
          )}
          data-testid="banner-honor-roll"
        >
          <div className="flex flex-wrap items-baseline gap-x-6 gap-y-1">
            <span className="text-sm font-medium">
              <span className="font-bold">{honorRoll.x}</span> stars needed for honor roll —{" "}
              student has{" "}
              <span className={cn("font-bold", honorRoll.y >= honorRoll.x ? "text-green-600 dark:text-green-400" : "")}>
                {honorRoll.y}
              </span> stars this term
            </span>
            {honorRoll.w != null && (
              <span className="text-sm font-semibold" data-testid="text-weighted-avg">
                Weighted average: <span className={cn(honorRoll.score ? "text-green-700 dark:text-green-300" : "")}>{honorRoll.w.toFixed(1)}%</span>
              </span>
            )}
          </div>
          {honorRoll.score && (
            <p className="mt-1 font-semibold text-green-700 dark:text-green-300" data-testid="text-honor-roll-achieved">
              The student has passed{" "}
              {honorRoll.score === "A*" ? <span>A<sup>*</sup></span> : honorRoll.score}{" "}
              Honor Roll
            </p>
          )}
        </div>
      )}

      {selectedStudent && (
        <Card>
          <CardHeader className="flex flex-row items-center justify-between gap-4 flex-wrap">
            <CardTitle className="text-base">
              Course Enrollments
              {courseGroups.length > 0 && <span className="text-muted-foreground font-normal ml-2">({courseGroups.length} courses)</span>}
            </CardTitle>
            <div className="flex items-center gap-2 flex-wrap">
              {courseGroups.length > 0 && (
                <Button
                  variant="outline" size="sm" className="h-8 text-xs gap-1.5"
                  onClick={() => setExpandAll(v => !v)}
                  data-testid="button-expand-all"
                >
                  {expandAll ? <ChevronsUp className="h-3.5 w-3.5" /> : <ChevronsDown className="h-3.5 w-3.5" />}
                  {expandAll ? "Collapse all" : "Expand all"}
                </Button>
              )}
              <div className="flex items-center gap-1.5">
                <span className="text-xs text-muted-foreground">Term:</span>
                <Select value={termFilter} onValueChange={setTermFilter}>
                  <SelectTrigger className="h-8 w-[90px] text-xs" data-testid="select-term-filter">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">All</SelectItem>
                    {[1, 2, 3, 4, 5].map(t => <SelectItem key={t} value={String(t)}>T{t}</SelectItem>)}
                  </SelectContent>
                </Select>
              </div>
              {availableYearTerms.length > 0 && (
                <Popover open={yearTermFilterOpen} onOpenChange={setYearTermFilterOpen}>
                  <PopoverTrigger asChild>
                    <Button variant="outline" size="sm" className="h-8 text-xs gap-1.5" data-testid="button-yearterm-filter">
                      <Filter className="h-3.5 w-3.5" />
                      Year-Term
                      {selectedYearTerms.size > 0 && (
                        <span className="ml-1 rounded-full bg-primary text-primary-foreground px-1.5 text-[10px] font-semibold">{selectedYearTerms.size}</span>
                      )}
                    </Button>
                  </PopoverTrigger>
                  <PopoverContent className="w-48 p-2" align="end">
                    <div className="space-y-1">
                      <p className="text-xs font-medium text-muted-foreground px-2 pb-1">Filter by year-term</p>
                      {availableYearTerms.map(yt => (
                        <label key={yt} className="flex items-center gap-2 px-2 py-1.5 rounded hover:bg-accent cursor-pointer text-sm" data-testid={`checkbox-yearterm-${yt}`}>
                          <Checkbox
                            checked={selectedYearTerms.has(yt)}
                            onCheckedChange={(checked) => {
                              setSelectedYearTerms(prev => {
                                const next = new Set(prev);
                                if (checked) next.add(yt); else next.delete(yt);
                                return next;
                              });
                            }}
                          />
                          {yt}
                        </label>
                      ))}
                      <div className="border-t pt-1 mt-1 flex gap-1">
                        <Button variant="ghost" size="sm" className="h-7 text-xs flex-1" onClick={() => setSelectedYearTerms(new Set(availableYearTerms))} data-testid="button-yearterm-select-all">Select All</Button>
                        <Button variant="ghost" size="sm" className="h-7 text-xs flex-1" onClick={() => setSelectedYearTerms(new Set())} data-testid="button-yearterm-clear">Clear</Button>
                      </div>
                    </div>
                  </PopoverContent>
                </Popover>
              )}
            </div>
          </CardHeader>
          <CardContent className="p-0">
            <div className="overflow-x-auto">
              <table className="w-full text-sm" data-testid="table-enrollments">
                <thead>
                  <tr className="border-b bg-muted/30">
                    <th className="text-left py-3 px-3 font-medium text-muted-foreground min-w-[200px]">Course / PACE#</th>
                    <th className="text-left py-3 px-2 font-medium text-muted-foreground">Date Started</th>
                    <th className="text-left py-3 px-2 font-medium text-muted-foreground">Date Ended</th>
                    <th className="text-center py-3 px-2 font-medium text-muted-foreground text-amber-600">★</th>
                    <th className="text-center py-3 px-2 font-medium text-muted-foreground">Grade</th>
                    <th className="text-left py-3 px-2 font-medium text-muted-foreground">Remarks</th>
                    <th className="text-right py-3 px-2 font-medium text-muted-foreground w-[100px]"></th>
                  </tr>
                </thead>
                <tbody>
                  {enrollmentsLoading ? (
                    <tr>
                      <td colSpan={COL_COUNT} className="text-center py-8 text-muted-foreground">Loading enrollments...</td>
                    </tr>
                  ) : courseGroups.length > 0 ? (
                    courseGroups.map(group => {
                      const course = courseMap.get(group.courseId);
                      const passThreshold = course ? getEffectivePassThreshold(course, selectedStudent.isDyslexic, subjectById) : 80;
                      const paceStarMap = paceStarMapByCourse.get(group.courseId) || new Map<string, number>();
                      const enrolledNums = enrolledByCourseFull.get(group.courseId) || new Set<string>();
                      return (
                        <CourseGroupRow
                          key={group.courseId}
                          group={group}
                          courseMap={courseMap}
                          course={course}
                          onUpdate={handleUpdate}
                          onDelete={handleDelete}
                          onDeleteCourse={handleDeleteCourse}
                          isPending={updateMutation.isPending || deleteEnrollmentMutation.isPending}
                          paceStarMap={paceStarMap}
                          passThreshold={passThreshold}
                          enrolledNumbers={enrolledNums}
                          studentId={selectedStudent.id}
                          forceExpand={expandAll}
                          defaultTerm={termFilter !== "all" ? termFilter : undefined}
                        />
                      );
                    })
                  ) : !showNewRow ? (
                    <tr>
                      <td colSpan={COL_COUNT} className="text-center py-8 text-muted-foreground">
                        No enrollments found. Click "Add enrollment for course" to get started.
                      </td>
                    </tr>
                  ) : null}
                </tbody>
              </table>
            </div>
            <div className="p-4 border-t space-y-4">
              {showNewRow ? (
                <NewEnrollmentForm
                  studentId={selectedStudent.id}
                  allEnrollments={enrollments || []}
                  paceStarMapByCourse={paceStarMapByCourse}
                  onCreated={() => setShowNewRow(false)}
                  onCancel={() => setShowNewRow(false)}
                />
              ) : (
                <Button variant="outline" onClick={() => setShowNewRow(true)} data-testid="button-add-enrollment">
                  <Plus className="h-4 w-4 mr-2" />
                  Add enrollment for course
                </Button>
              )}
            </div>

            {suppActivities && suppActivities.length > 0 && (
              <div className="border-t">
                <div className="px-4 py-3">
                  <h3 className="text-sm font-medium text-muted-foreground">Supplementary Activities</h3>
                </div>
                <table className="w-full text-sm" data-testid="table-supp-activities">
                  <thead>
                    <tr className="border-b bg-muted/30">
                      <th className="text-left py-2 px-4 font-medium text-muted-foreground">Activity</th>
                      <th className="text-left py-2 px-4 font-medium text-muted-foreground">Term</th>
                      <th className="text-left py-2 px-4 font-medium text-muted-foreground">Grade</th>
                      <th className="text-right py-2 px-4 font-medium text-muted-foreground w-[100px]"></th>
                    </tr>
                  </thead>
                  <tbody>
                    {suppActivities.map(sa => (
                      <SuppActivityRow
                        key={sa.id}
                        sa={sa}
                        onDelete={() => deleteSuppMutation.mutate(sa.id)}
                        studentId={selectedStudent.id}
                      />
                    ))}
                  </tbody>
                </table>
              </div>
            )}

            <div className="p-4 border-t">
              {showNewSuppRow ? (
                <NewSuppActivityForm
                  studentId={selectedStudent.id}
                  onCreated={() => setShowNewSuppRow(false)}
                  onCancel={() => setShowNewSuppRow(false)}
                />
              ) : (
                <Button variant="outline" onClick={() => setShowNewSuppRow(true)} data-testid="button-add-supp-activity">
                  <Music className="h-4 w-4 mr-2" />
                  Add enrollment for supplementary activity
                </Button>
              )}
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}
