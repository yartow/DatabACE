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
import type { Student, Course, Enrollment, SupplementaryActivity } from "@shared/schema";
import { apiRequest, queryClient } from "@/lib/queryClient";
import { Label } from "@/components/ui/label";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Checkbox } from "@/components/ui/checkbox";
import { CalendarIcon, Pencil, Plus, ChevronDown, ChevronRight, Trash2, Upload, Download, AlertCircle, CheckCircle2, Music, Filter } from "lucide-react";
import { format, parse } from "date-fns";

const SUPP_ACTIVITIES = ["Music", "Physical Education", "Project", "Other"];

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

function StudentSearch({ onSelect }: { onSelect: (student: Student) => void }) {
  const [query, setQuery] = useState("");
  const [open, setOpen] = useState(false);
  const [highlightIndex, setHighlightIndex] = useState(-1);
  const inputRef = useRef<HTMLInputElement>(null);
  const containerRef = useRef<HTMLDivElement>(null);

  const { data: students } = useQuery<Student[]>({ queryKey: ["/api/students"] });

  const suggestions = useMemo(() => {
    if (!students || query.length < 1) return [];
    const q = query.toLowerCase();
    return students.filter(s =>
      s.callName.toLowerCase().includes(q) ||
      s.surname.toLowerCase().includes(q) ||
      s.alias.toLowerCase().includes(q) ||
      (s.firstNames?.toLowerCase().includes(q))
    ).slice(0, 8);
  }, [students, query]);

  useEffect(() => {
    function handleClickOutside(e: MouseEvent) {
      if (containerRef.current && !containerRef.current.contains(e.target as Node)) {
        setOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  function handleKeyDown(e: React.KeyboardEvent) {
    if (!open) return;
    if (e.key === "Escape") {
      e.preventDefault();
      setOpen(false);
      setHighlightIndex(-1);
      return;
    }
    if (suggestions.length === 0) return;
    if (e.key === "ArrowDown") {
      e.preventDefault();
      setHighlightIndex(prev => (prev + 1) % suggestions.length);
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      setHighlightIndex(prev => (prev - 1 + suggestions.length) % suggestions.length);
    } else if (e.key === "Enter" && highlightIndex >= 0 && highlightIndex < suggestions.length) {
      e.preventDefault();
      const s = suggestions[highlightIndex];
      onSelect(s);
      setQuery(`${s.callName} ${s.surname}`);
      setOpen(false);
      setHighlightIndex(-1);
    }
  }

  return (
    <div className="relative" ref={containerRef}>
      <Input
        ref={inputRef}
        placeholder="Type student name to search..."
        value={query}
        onChange={e => {
          setQuery(e.target.value);
          setOpen(e.target.value.length >= 1);
          setHighlightIndex(-1);
        }}
        onFocus={() => { if (query.length >= 1) setOpen(true); }}
        onKeyDown={handleKeyDown}
        className="w-full max-w-md"
        data-testid="input-student-search"
      />
      {open && suggestions.length > 0 && (
        <div className="absolute z-50 top-full left-0 mt-1 w-full max-w-md bg-popover border rounded-md shadow-lg" data-testid="dropdown-student-suggestions">
          {suggestions.map((s, i) => (
            <button
              key={s.id}
              className={`w-full text-left px-4 py-2.5 hover:bg-accent text-sm flex items-center justify-between gap-2 first:rounded-t-md last:rounded-b-md ${highlightIndex === i ? "bg-accent" : ""}`}
              onClick={() => {
                onSelect(s);
                setQuery(`${s.callName} ${s.surname}`);
                setOpen(false);
              }}
              data-testid={`suggestion-student-${s.id}`}
            >
              <span className="font-medium">{s.callName} {s.surname}</span>
              <span className="text-xs text-muted-foreground">{s.alias}</span>
            </button>
          ))}
        </div>
      )}
      {open && query.length >= 1 && suggestions.length === 0 && (
        <div className="absolute z-50 top-full left-0 mt-1 w-full max-w-md bg-popover border rounded-md shadow-lg p-3 text-sm text-muted-foreground">
          No students found matching "{query}"
        </div>
      )}
    </div>
  );
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
        (c.course?.toLowerCase().includes(q)) ||
        (c.aceAlias?.toLowerCase().includes(q)) ||
        (c.icceAlias?.toLowerCase().includes(q)) ||
        (c.certificateName?.toLowerCase().includes(q)) ||
        (c.subjectTemp?.toLowerCase().includes(q)) ||
        (c.subjectAbb?.toLowerCase().includes(q))
      )
    ).slice(0, 8);
  }, [courses, query, exclude]);

  useEffect(() => {
    function handleClickOutside(e: MouseEvent) {
      if (containerRef.current && !containerRef.current.contains(e.target as Node)) {
        setOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  function handleKeyDown(e: React.KeyboardEvent) {
    if (!open) return;
    if (e.key === "Escape") {
      e.preventDefault();
      setOpen(false);
      setHighlightIndex(-1);
      return;
    }
    if (suggestions.length === 0) return;
    if (e.key === "ArrowDown") {
      e.preventDefault();
      setHighlightIndex(prev => (prev + 1) % suggestions.length);
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      setHighlightIndex(prev => (prev - 1 + suggestions.length) % suggestions.length);
    } else if (e.key === "Enter" && highlightIndex >= 0 && highlightIndex < suggestions.length) {
      e.preventDefault();
      onSelect(suggestions[highlightIndex]);
      setQuery("");
      setOpen(false);
      setHighlightIndex(-1);
    }
  }

  return (
    <div className="relative flex-1 min-w-0" ref={containerRef}>
      <Input
        placeholder="Type course name..."
        value={query}
        onChange={e => {
          setQuery(e.target.value);
          setOpen(e.target.value.length >= 2);
          setHighlightIndex(-1);
        }}
        onFocus={() => { if (query.length >= 2) setOpen(true); }}
        onKeyDown={handleKeyDown}
        className="w-full"
        data-testid="input-course-search"
      />
      {open && suggestions.length > 0 && (
        <div className="absolute z-50 top-full left-0 mt-1 w-full bg-popover border rounded-md shadow-lg max-h-60 overflow-auto" data-testid="dropdown-course-suggestions">
          {suggestions.map((c, i) => (
            <button
              key={c.id}
              className={`w-full text-left px-4 py-2.5 hover:bg-accent text-sm flex items-center justify-between gap-2 first:rounded-t-md last:rounded-b-md ${highlightIndex === i ? "bg-accent" : ""}`}
              onClick={() => {
                onSelect(c);
                setQuery("");
                setOpen(false);
              }}
              data-testid={`suggestion-course-${c.id}`}
            >
              <span className="font-medium truncate">{c.course || c.aceAlias || `Course ${c.id}`}</span>
              <span className="text-xs text-muted-foreground shrink-0">{c.subjectAbb} L{c.level}</span>
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
        <Button
          variant="outline"
          className="w-[140px] justify-start text-left font-normal text-xs h-9"
          data-testid={`button-date-${placeholder.toLowerCase().replace(/\s/g, "-")}`}
        >
          <CalendarIcon className="mr-1.5 h-3.5 w-3.5 text-muted-foreground" />
          {value ? format(parse(value, "yyyy-MM-dd", new Date()), "dd MMM yyyy") : <span className="text-muted-foreground">{placeholder}</span>}
        </Button>
      </PopoverTrigger>
      <PopoverContent className="w-auto p-0" align="start">
        <Calendar
          mode="single"
          selected={date}
          onSelect={(d) => {
            onChange(d ? format(d, "yyyy-MM-dd") : null);
            setOpen(false);
          }}
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
  minDateStarted: string;
  maxDateEnded: string | null;
  avgGrade: number | null;
}

function groupEnrollmentsByCourse(enrollments: Enrollment[], courseMap: Map<number, Course>): CourseGroup[] {
  const groups = new Map<number, Enrollment[]>();
  for (const e of enrollments) {
    const arr = groups.get(e.courseId) || [];
    arr.push(e);
    groups.set(e.courseId, arr);
  }

  return Array.from(groups.entries()).map(([courseId, rows]) => {
    const course = courseMap.get(courseId);
    const courseName = course?.course || course?.aceAlias || `Course #${courseId}`;
    const sortedRows = rows.sort((a, b) => a.number - b.number);

    const dates = sortedRows.map(r => r.dateStarted).filter(Boolean);
    const minDateStarted = dates.length > 0 ? dates.sort()[0] : "";

    const endDates = sortedRows.map(r => r.dateEnded).filter((d): d is string => !!d);
    const maxDateEnded = endDates.length > 0 ? endDates.sort().reverse()[0] : null;

    const grades = sortedRows.map(r => r.grade).filter((g): g is number => g !== null);
    const avgGrade = grades.length > 0 ? grades.reduce((s, g) => s + g, 0) / grades.length : null;

    return {
      courseId,
      courseName,
      enrollments: sortedRows,
      minDateStarted,
      maxDateEnded,
      avgGrade,
    };
  });
}

function NumberRow({ enrollment, onUpdate, isPending }: { enrollment: Enrollment; onUpdate: (id: number, data: any) => void; isPending: boolean }) {
  const [editing, setEditing] = useState(false);
  const [dateStarted, setDateStarted] = useState(enrollment.dateStarted);
  const [dateEnded, setDateEnded] = useState(enrollment.dateEnded);
  const [grade, setGrade] = useState(enrollment.grade?.toString() || "");
  const [remarks, setRemarks] = useState(enrollment.remarks || "");

  const handleSave = useCallback(() => {
    onUpdate(enrollment.id, {
      dateStarted,
      dateEnded: dateEnded || null,
      grade: grade ? parseFloat(grade) : null,
      remarks: remarks || null,
    });
    setEditing(false);
  }, [enrollment.id, dateStarted, dateEnded, grade, remarks, onUpdate]);

  if (editing) {
    return (
      <tr className="border-b bg-muted/20" data-testid={`row-number-edit-${enrollment.id}`}>
        <td className="py-2 pl-10 pr-2 text-sm text-muted-foreground">{enrollment.number}</td>
        <td className="py-2 px-2">
          <DatePicker value={dateStarted} onChange={(v) => v && setDateStarted(v)} placeholder="Date started" />
        </td>
        <td className="py-2 px-2">
          <DatePicker value={dateEnded} onChange={(v) => setDateEnded(v)} placeholder="Date ended" />
        </td>
        <td className="py-2 px-2">
          <Input
            type="number"
            step="0.1"
            min="0"
            max="100"
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
          <div className="flex items-center gap-1 justify-end">
            <Button size="sm" variant="default" onClick={handleSave} disabled={isPending} className="h-7 text-xs" data-testid="button-save-number">
              Save
            </Button>
            <Button size="sm" variant="ghost" onClick={() => setEditing(false)} className="h-7 text-xs">
              Cancel
            </Button>
          </div>
        </td>
      </tr>
    );
  }

  return (
    <tr className="border-b last:border-0 hover:bg-muted/10" data-testid={`row-number-${enrollment.id}`}>
      <td className="py-2 pl-10 pr-2 text-sm text-muted-foreground">{enrollment.number}</td>
      <td className="py-2 px-2 text-sm text-muted-foreground">{formatDate(enrollment.dateStarted)}</td>
      <td className="py-2 px-2 text-sm text-muted-foreground">{formatDate(enrollment.dateEnded)}</td>
      <td className="py-2 px-2 text-sm text-center">{enrollment.grade != null ? enrollment.grade : "—"}</td>
      <td className="py-2 px-2 text-xs text-muted-foreground max-w-[200px] truncate">{enrollment.remarks || "—"}</td>
      <td className="py-2 px-2 text-right">
        <Button size="icon" variant="ghost" className="h-7 w-7" onClick={() => setEditing(true)} data-testid={`button-edit-number-${enrollment.id}`}>
          <Pencil className="h-3 w-3" />
        </Button>
      </td>
    </tr>
  );
}

function CourseGroupRow({ group, courseMap, onUpdate, onDeleteCourse, isPending }: {
  group: CourseGroup;
  courseMap: Map<number, Course>;
  onUpdate: (id: number, data: any) => void;
  onDeleteCourse: (studentId: number, courseId: number) => void;
  isPending: boolean;
}) {
  const [expanded, setExpanded] = useState(false);
  const studentId = group.enrollments[0]?.studentId;

  return (
    <>
      <tr
        className="border-b bg-muted/5 cursor-pointer hover:bg-muted/20"
        onClick={() => setExpanded(!expanded)}
        data-testid={`row-course-group-${group.courseId}`}
      >
        <td className="py-3 px-3 font-medium text-sm">
          <div className="flex items-center gap-2">
            {expanded ? <ChevronDown className="h-4 w-4 text-muted-foreground shrink-0" /> : <ChevronRight className="h-4 w-4 text-muted-foreground shrink-0" />}
            <span>{group.courseName}</span>
            <span className="text-xs text-muted-foreground font-normal">({group.enrollments.length} numbers)</span>
          </div>
        </td>
        <td className="py-3 px-2 text-sm text-muted-foreground">{formatDate(group.minDateStarted)}</td>
        <td className="py-3 px-2 text-sm text-muted-foreground">{formatDate(group.maxDateEnded)}</td>
        <td className="py-3 px-2 text-sm text-center">{group.avgGrade != null ? group.avgGrade.toFixed(1) : "—"}</td>
        <td className="py-3 px-2"></td>
        <td className="py-3 px-2 text-right" onClick={e => e.stopPropagation()}>
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button size="icon" variant="ghost" className="h-8 w-8" data-testid={`button-actions-course-${group.courseId}`}>
                <Pencil className="h-3.5 w-3.5" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
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
          isPending={isPending}
        />
      ))}
    </>
  );
}

function NewEnrollmentForm({ studentId, existingCourseIds, onCreated, onCancel }: { studentId: number; existingCourseIds: number[]; onCreated: () => void; onCancel: () => void }) {
  const { toast } = useToast();
  const [selectedCourse, setSelectedCourse] = useState<Course | null>(null);
  const [dateStarted, setDateStarted] = useState<string>("");

  const createMutation = useMutation({
    mutationFn: async () => {
      if (!selectedCourse) throw new Error("Select a course");
      await apiRequest("POST", "/api/enrollments/course", {
        studentId,
        courseId: selectedCourse.id,
        dateStarted: dateStarted || null,
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/enrollments", studentId.toString()] });
      toast({ title: "Course enrollment created" });
      setSelectedCourse(null);
      setDateStarted("");
      onCreated();
    },
    onError: (err: Error) => toast({ title: "Failed to create enrollment", description: err.message, variant: "destructive" }),
  });

  return (
    <div className="border rounded-lg bg-accent/30 p-4 space-y-4" data-testid="form-new-enrollment">
      <div className="space-y-2">
        <label className="text-sm font-medium">Course</label>
        {selectedCourse ? (
          <div className="flex items-center gap-2">
            <span className="text-sm font-medium">{selectedCourse.course || selectedCourse.aceAlias}</span>
            <Button size="sm" variant="ghost" className="h-6 text-xs" onClick={() => setSelectedCourse(null)}>Change</Button>
          </div>
        ) : (
          <CourseSearch onSelect={setSelectedCourse} exclude={existingCourseIds} />
        )}
      </div>
      <div className="flex flex-wrap items-end gap-4">
        <div className="space-y-2">
          <label className="text-sm font-medium">Date Started</label>
          <DatePicker value={dateStarted} onChange={(v) => v && setDateStarted(v)} placeholder="Date started" />
        </div>
      </div>
      <p className="text-xs text-muted-foreground">
        All PACE numbers for this course will be enrolled automatically. Start date is optional. You can edit individual numbers after creation.
      </p>
      <div className="flex items-center gap-2">
        <Button
          size="sm"
          onClick={() => createMutation.mutate()}
          disabled={!selectedCourse || createMutation.isPending}
          className="h-8 text-xs"
          data-testid="button-save-new-enrollment"
        >
          {createMutation.isPending ? "Creating..." : "Create enrollment"}
        </Button>
        <Button size="sm" variant="ghost" onClick={onCancel} className="h-8 text-xs" data-testid="button-cancel-new-enrollment">
          Cancel
        </Button>
      </div>
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
        <td className="py-2 px-4 font-medium">{sa.activity}</td>
        <td className="py-2 px-4">
          <Select value={term} onValueChange={setTerm}>
            <SelectTrigger className="h-8 w-[80px]" data-testid="select-supp-term"><SelectValue placeholder="Term" /></SelectTrigger>
            <SelectContent>
              {[1,2,3,4,5].map(t => <SelectItem key={t} value={String(t)}>T{t}</SelectItem>)}
            </SelectContent>
          </Select>
        </td>
        <td className="py-2 px-4">
          <Input
            value={grade}
            onChange={e => setGrade(e.target.value.slice(0, 4))}
            maxLength={4}
            className="h-8 w-[70px] text-xs"
            placeholder="Grade"
            data-testid="input-supp-grade"
          />
        </td>
        <td className="py-2 px-4 text-right">
          <div className="flex items-center gap-1 justify-end">
            <Button size="sm" variant="default" onClick={() => updateMutation.mutate()} disabled={updateMutation.isPending} className="h-7 text-xs" data-testid="button-save-supp">Save</Button>
            <Button size="sm" variant="ghost" onClick={() => setEditing(false)} className="h-7 text-xs">Cancel</Button>
          </div>
        </td>
      </tr>
    );
  }

  return (
    <tr className="border-b last:border-0" data-testid={`row-supp-${sa.id}`}>
      <td className="py-2 px-4 font-medium">{sa.activity}</td>
      <td className="py-2 px-4 text-muted-foreground">{sa.term ? `T${sa.term}` : "—"}</td>
      <td className="py-2 px-4 text-muted-foreground">{sa.grade || "—"}</td>
      <td className="py-2 px-4 text-right">
        <div className="flex items-center gap-1 justify-end">
          <Button size="icon" variant="ghost" className="h-7 w-7" onClick={() => setEditing(true)} data-testid={`button-edit-supp-${sa.id}`}>
            <Pencil className="h-3 w-3" />
          </Button>
          <Button size="icon" variant="ghost" className="h-7 w-7 text-destructive" onClick={onDelete} data-testid={`button-delete-supp-${sa.id}`}>
            <Trash2 className="h-3 w-3" />
          </Button>
        </div>
      </td>
    </tr>
  );
}

function NewSuppActivityForm({ studentId, onCreated, onCancel }: { studentId: number; onCreated: () => void; onCancel: () => void }) {
  const { toast } = useToast();
  const [selectedActivity, setSelectedActivity] = useState<string>("");
  const [customActivity, setCustomActivity] = useState("");
  const [term, setTerm] = useState("");
  const [grade, setGrade] = useState("");

  const createMutation = useMutation({
    mutationFn: async () => {
      const activity = selectedActivity === "Other" ? customActivity : selectedActivity;
      if (!activity) throw new Error("Select an activity");
      await apiRequest("POST", "/api/supplementary-activities", {
        studentId,
        activity,
        term: term ? parseInt(term) : null,
        grade: grade || null,
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/supplementary-activities", studentId.toString()] });
      toast({ title: "Supplementary activity enrollment created" });
      setSelectedActivity("");
      setCustomActivity("");
      setTerm("");
      setGrade("");
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
          <SelectContent>
            {SUPP_ACTIVITIES.map(a => <SelectItem key={a} value={a}>{a}</SelectItem>)}
          </SelectContent>
        </Select>
      </div>
      {selectedActivity === "Other" && (
        <div className="space-y-2">
          <Label>Activity Name</Label>
          <Input
            value={customActivity}
            onChange={e => setCustomActivity(e.target.value)}
            placeholder="Enter activity name..."
            data-testid="input-custom-activity"
          />
        </div>
      )}
      <div className="flex gap-4">
        <div className="space-y-2">
          <Label>Term (optional)</Label>
          <Select value={term} onValueChange={setTerm}>
            <SelectTrigger className="w-[100px]" data-testid="select-new-supp-term"><SelectValue placeholder="Term" /></SelectTrigger>
            <SelectContent>
              {[1,2,3,4,5].map(t => <SelectItem key={t} value={String(t)}>T{t}</SelectItem>)}
            </SelectContent>
          </Select>
        </div>
        <div className="space-y-2">
          <Label>Grade (optional)</Label>
          <Input
            value={grade}
            onChange={e => setGrade(e.target.value.slice(0, 4))}
            maxLength={4}
            className="w-[100px]"
            placeholder="e.g. A"
            data-testid="input-new-supp-grade"
          />
        </div>
      </div>
      <div className="flex items-center gap-2">
        <Button
          size="sm"
          onClick={() => createMutation.mutate()}
          disabled={!activityName || createMutation.isPending}
          className="h-8 text-xs"
          data-testid="button-save-supp-activity"
        >
          {createMutation.isPending ? "Creating..." : "Create enrollment"}
        </Button>
        <Button size="sm" variant="ghost" onClick={onCancel} className="h-8 text-xs" data-testid="button-cancel-supp-activity">
          Cancel
        </Button>
      </div>
    </div>
  );
}

function ImportDialog({ open, onOpenChange }: { open: boolean; onOpenChange: (v: boolean) => void }) {
  const { toast } = useToast();
  const [file, setFile] = useState<File | null>(null);
  const [importing, setImporting] = useState(false);
  const [result, setResult] = useState<{ imported: number; skipped: number; errors?: string[] } | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  function handleDownloadTemplate() {
    window.open("/api/enrollments/template", "_blank");
  }

  async function handleImport() {
    if (!file) return;
    setImporting(true);
    setResult(null);
    try {
      const formData = new FormData();
      formData.append("file", file);
      const res = await fetch("/api/enrollments/import", {
        method: "POST",
        body: formData,
        credentials: "include",
      });
      const data = await res.json();
      if (!res.ok) {
        toast({ title: "Import failed", description: data.message, variant: "destructive" });
        if (data.errors) setResult({ imported: 0, skipped: 0, errors: data.errors });
      } else {
        setResult(data);
        queryClient.invalidateQueries({ queryKey: ["/api/enrollments"] });
        toast({ title: `Successfully imported ${data.imported} enrollment(s)` });
      }
    } catch (err: any) {
      toast({ title: "Import error", description: err.message, variant: "destructive" });
    } finally {
      setImporting(false);
    }
  }

  function handleClose(v: boolean) {
    if (!v) {
      setFile(null);
      setResult(null);
    }
    onOpenChange(v);
  }

  return (
    <Dialog open={open} onOpenChange={handleClose}>
      <DialogContent className="max-w-lg">
        <DialogHeader>
          <DialogTitle>Import Enrollments from Excel</DialogTitle>
        </DialogHeader>
        <div className="space-y-4 pt-2">
          <p className="text-sm text-muted-foreground">
            Upload an Excel file (.xlsx) with enrollment data. The file should have columns: studentId, courseId, number, dateStarted, dateEnded, grade, remarks.
          </p>

          <Button variant="outline" onClick={handleDownloadTemplate} className="w-full" data-testid="button-download-template">
            <Download className="w-4 h-4 mr-2" />
            Download Excel Template
          </Button>

          <div className="space-y-2">
            <Label>Select Excel file</Label>
            <Input
              ref={fileInputRef}
              type="file"
              accept=".xlsx,.xls"
              onChange={e => { setFile(e.target.files?.[0] || null); setResult(null); }}
              data-testid="input-import-file"
            />
          </div>

          {result && (
            <div className={`rounded-md p-3 text-sm ${result.imported > 0 ? "bg-emerald-50 dark:bg-emerald-950 border border-emerald-200 dark:border-emerald-800" : "bg-red-50 dark:bg-red-950 border border-red-200 dark:border-red-800"}`}>
              <div className="flex items-center gap-2 mb-1">
                {result.imported > 0 ? (
                  <CheckCircle2 className="w-4 h-4 text-emerald-600" />
                ) : (
                  <AlertCircle className="w-4 h-4 text-red-600" />
                )}
                <span className="font-medium">
                  {result.imported > 0 ? `Imported ${result.imported} row(s)` : "No rows imported"}
                </span>
              </div>
              {result.skipped > 0 && (
                <p className="text-muted-foreground ml-6">{result.skipped} row(s) skipped due to errors</p>
              )}
              {result.errors && result.errors.length > 0 && (
                <ul className="mt-2 ml-6 space-y-1 text-xs text-red-700 dark:text-red-300 max-h-32 overflow-y-auto">
                  {result.errors.map((err, i) => <li key={i}>{err}</li>)}
                </ul>
              )}
            </div>
          )}

          <Button
            onClick={handleImport}
            disabled={!file || importing}
            className="w-full"
            data-testid="button-import-submit"
          >
            {importing ? "Importing..." : "Import"}
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  );
}

export default function EnrollmentsPage() {
  const { toast } = useToast();
  const [selectedStudent, setSelectedStudent] = useState<Student | null>(null);
  const [showNewRow, setShowNewRow] = useState(false);
  const [showNewSuppRow, setShowNewSuppRow] = useState(false);
  const [showImport, setShowImport] = useState(false);
  const [selectedYearTerms, setSelectedYearTerms] = useState<Set<string>>(new Set([getCurrentYearTerm()]));
  const [yearTermFilterOpen, setYearTermFilterOpen] = useState(false);

  const { data: enrollments, isLoading: enrollmentsLoading } = useQuery<Enrollment[]>({
    queryKey: ["/api/enrollments", selectedStudent?.id?.toString() || ""],
    queryFn: async () => {
      const res = await fetch(`/api/enrollments?studentId=${selectedStudent!.id}`, { credentials: "include" });
      if (!res.ok) throw new Error("Failed to fetch enrollments");
      return res.json();
    },
    enabled: !!selectedStudent,
  });

  const { data: courses } = useQuery<Course[]>({ queryKey: ["/api/courses"] });

  const { data: suppActivities } = useQuery<SupplementaryActivity[]>({
    queryKey: ["/api/supplementary-activities", selectedStudent?.id?.toString() || ""],
    queryFn: async () => {
      const res = await fetch(`/api/supplementary-activities?studentId=${selectedStudent!.id}`, { credentials: "include" });
      if (!res.ok) throw new Error("Failed to fetch supplementary activities");
      return res.json();
    },
    enabled: !!selectedStudent,
  });

  const deleteSuppMutation = useMutation({
    mutationFn: async (id: number) => { await apiRequest("DELETE", `/api/supplementary-activities/${id}`); },
    onSuccess: () => {
      if (selectedStudent) {
        queryClient.invalidateQueries({ queryKey: ["/api/supplementary-activities", selectedStudent.id.toString()] });
      }
      toast({ title: "Supplementary activity removed" });
    },
    onError: (err: Error) => toast({ title: "Failed to delete", description: err.message, variant: "destructive" }),
  });

  const courseMap = useMemo(() => {
    return new Map(courses?.map(c => [c.id, c]) || []);
  }, [courses]);

  const availableYearTerms = useMemo(() => {
    if (!enrollments) return [];
    const ytSet = new Set<string>();
    for (const e of enrollments) {
      if (e.dateStarted) {
        const yt = computeYearTermFromDate(e.dateStarted);
        if (yt) ytSet.add(yt);
      }
    }
    return Array.from(ytSet).sort();
  }, [enrollments]);

  const filteredEnrollments = useMemo(() => {
    if (!enrollments || selectedYearTerms.size === 0) return enrollments || [];
    return enrollments.filter(e => {
      if (!e.dateStarted) return false;
      const yt = computeYearTermFromDate(e.dateStarted);
      return yt ? selectedYearTerms.has(yt) : false;
    });
  }, [enrollments, selectedYearTerms]);

  const courseGroups = useMemo(() => {
    if (!filteredEnrollments) return [];
    return groupEnrollmentsByCourse(filteredEnrollments, courseMap);
  }, [filteredEnrollments, courseMap]);

  const updateMutation = useMutation({
    mutationFn: async ({ id, data }: { id: number; data: any }) => {
      await apiRequest("PATCH", `/api/enrollments/${id}`, data);
    },
    onSuccess: () => {
      if (selectedStudent) {
        queryClient.invalidateQueries({ queryKey: ["/api/enrollments", selectedStudent.id.toString()] });
      }
      toast({ title: "Enrollment updated" });
    },
    onError: (err: Error) => toast({ title: "Failed to update", description: err.message, variant: "destructive" }),
  });

  const deleteCourseEnrollmentMutation = useMutation({
    mutationFn: async ({ studentId, courseId }: { studentId: number; courseId: number }) => {
      await apiRequest("DELETE", `/api/enrollments/course/${studentId}/${courseId}`);
    },
    onSuccess: () => {
      if (selectedStudent) {
        queryClient.invalidateQueries({ queryKey: ["/api/enrollments", selectedStudent.id.toString()] });
      }
      toast({ title: "Course enrollment removed" });
    },
    onError: (err: Error) => toast({ title: "Failed to delete", description: err.message, variant: "destructive" }),
  });

  const handleUpdate = useCallback((id: number, data: any) => {
    updateMutation.mutate({ id, data });
  }, [updateMutation]);

  const handleDeleteCourse = useCallback((studentId: number, courseId: number) => {
    deleteCourseEnrollmentMutation.mutate({ studentId, courseId });
  }, [deleteCourseEnrollmentMutation]);

  const existingCourseIds = useMemo(() => {
    return courseGroups.map(g => g.courseId);
  }, [courseGroups]);

  return (
    <div className="p-6 max-w-6xl mx-auto space-y-6">
      <div className="flex items-start justify-between gap-4 flex-wrap">
        <div>
          <h1 className="text-2xl font-serif font-bold tracking-tight" data-testid="text-page-title">Enrollments</h1>
          <p className="text-muted-foreground mt-1">Manage student course enrollments. Search for a student to view and edit their enrollments.</p>
        </div>
        <div className="flex items-center gap-2">
          <Button variant="outline" onClick={() => window.open("/api/enrollments/template", "_blank")} data-testid="button-download-template-header">
            <Download className="w-4 h-4 mr-2" />
            Download Template
          </Button>
          <Button onClick={() => setShowImport(true)} data-testid="button-import-header">
            <Upload className="w-4 h-4 mr-2" />
            Import
          </Button>
        </div>
      </div>

      <ImportDialog open={showImport} onOpenChange={setShowImport} />

      <Card>
        <CardHeader>
          <CardTitle className="text-base">Select Student</CardTitle>
        </CardHeader>
        <CardContent>
          <StudentSearch onSelect={(s) => { setSelectedStudent(s); setShowNewRow(false); }} />
          {selectedStudent && (
            <div className="mt-3 flex items-center gap-2">
              <span className="text-sm text-muted-foreground">Selected:</span>
              <span className="text-sm font-semibold" data-testid="text-selected-student">
                {selectedStudent.callName} {selectedStudent.surname}
              </span>
              {selectedStudent.firstNames && (
                <span className="text-xs text-muted-foreground">({selectedStudent.firstNames})</span>
              )}
            </div>
          )}
        </CardContent>
      </Card>

      {selectedStudent && (
        <Card>
          <CardHeader className="flex flex-row items-center justify-between gap-4">
            <CardTitle className="text-base">
              Course Enrollments
              {courseGroups.length > 0 && <span className="text-muted-foreground font-normal ml-2">({courseGroups.length} courses)</span>}
            </CardTitle>
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
                              if (checked) next.add(yt);
                              else next.delete(yt);
                              return next;
                            });
                          }}
                        />
                        {yt}
                      </label>
                    ))}
                    <div className="border-t pt-1 mt-1 flex gap-1">
                      <Button
                        variant="ghost"
                        size="sm"
                        className="h-7 text-xs flex-1"
                        onClick={() => setSelectedYearTerms(new Set(availableYearTerms))}
                        data-testid="button-yearterm-select-all"
                      >
                        Select All
                      </Button>
                      <Button
                        variant="ghost"
                        size="sm"
                        className="h-7 text-xs flex-1"
                        onClick={() => setSelectedYearTerms(new Set())}
                        data-testid="button-yearterm-clear"
                      >
                        Clear
                      </Button>
                    </div>
                  </div>
                </PopoverContent>
              </Popover>
            )}
          </CardHeader>
          <CardContent className="p-0">
            <div className="overflow-x-auto">
              <table className="w-full text-sm" data-testid="table-enrollments">
                <thead>
                  <tr className="border-b bg-muted/30">
                    <th className="text-left py-3 px-3 font-medium text-muted-foreground min-w-[200px]">Course / Number</th>
                    <th className="text-left py-3 px-2 font-medium text-muted-foreground">Date Started</th>
                    <th className="text-left py-3 px-2 font-medium text-muted-foreground">Date Ended</th>
                    <th className="text-center py-3 px-2 font-medium text-muted-foreground">Grade</th>
                    <th className="text-left py-3 px-2 font-medium text-muted-foreground">Remarks</th>
                    <th className="text-right py-3 px-2 font-medium text-muted-foreground w-[80px]"></th>
                  </tr>
                </thead>
                <tbody>
                  {enrollmentsLoading ? (
                    <tr>
                      <td colSpan={6} className="text-center py-8 text-muted-foreground">Loading enrollments...</td>
                    </tr>
                  ) : courseGroups.length > 0 ? (
                    courseGroups.map(group => (
                      <CourseGroupRow
                        key={group.courseId}
                        group={group}
                        courseMap={courseMap}
                        onUpdate={handleUpdate}
                        onDeleteCourse={handleDeleteCourse}
                        isPending={updateMutation.isPending}
                      />
                    ))
                  ) : !showNewRow ? (
                    <tr>
                      <td colSpan={6} className="text-center py-8 text-muted-foreground">
                        No enrollments yet. Click "Add enrollment for course" to get started.
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
                  existingCourseIds={existingCourseIds}
                  onCreated={() => setShowNewRow(false)}
                  onCancel={() => setShowNewRow(false)}
                />
              ) : (
                <Button
                  variant="outline"
                  onClick={() => setShowNewRow(true)}
                  data-testid="button-add-enrollment"
                >
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
                <Button
                  variant="outline"
                  onClick={() => setShowNewSuppRow(true)}
                  data-testid="button-add-supp-activity"
                >
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
