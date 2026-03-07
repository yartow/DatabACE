import { useQuery, useMutation } from "@tanstack/react-query";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { Calendar } from "@/components/ui/calendar";
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu";
import { Textarea } from "@/components/ui/textarea";
import { useToast } from "@/hooks/use-toast";
import { useState, useMemo, useRef, useEffect, useCallback } from "react";
import type { Student, Course, Enrollment } from "@shared/schema";
import { apiRequest, queryClient } from "@/lib/queryClient";
import { CalendarIcon, Pencil, Plus, CheckCircle2, XCircle } from "lucide-react";
import { format, parse } from "date-fns";

function StudentSearch({ onSelect }: { onSelect: (student: Student) => void }) {
  const [query, setQuery] = useState("");
  const [open, setOpen] = useState(false);
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

  return (
    <div className="relative" ref={containerRef}>
      <Input
        ref={inputRef}
        placeholder="Type student name to search..."
        value={query}
        onChange={e => {
          setQuery(e.target.value);
          setOpen(e.target.value.length >= 1);
        }}
        onFocus={() => { if (query.length >= 1) setOpen(true); }}
        className="w-full max-w-md"
        data-testid="input-student-search"
      />
      {open && suggestions.length > 0 && (
        <div className="absolute z-50 top-full left-0 mt-1 w-full max-w-md bg-popover border rounded-md shadow-lg" data-testid="dropdown-student-suggestions">
          {suggestions.map(s => (
            <button
              key={s.id}
              className="w-full text-left px-4 py-2.5 hover:bg-accent text-sm flex items-center justify-between gap-2 first:rounded-t-md last:rounded-b-md"
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

  return (
    <div className="relative flex-1 min-w-0" ref={containerRef}>
      <Input
        placeholder="Type course name..."
        value={query}
        onChange={e => {
          setQuery(e.target.value);
          setOpen(e.target.value.length >= 2);
        }}
        onFocus={() => { if (query.length >= 2) setOpen(true); }}
        className="w-full"
        data-testid="input-course-search"
      />
      {open && suggestions.length > 0 && (
        <div className="absolute z-50 top-full left-0 mt-1 w-full bg-popover border rounded-md shadow-lg max-h-60 overflow-auto" data-testid="dropdown-course-suggestions">
          {suggestions.map(c => (
            <button
              key={c.id}
              className="w-full text-left px-4 py-2.5 hover:bg-accent text-sm flex items-center justify-between gap-2 first:rounded-t-md last:rounded-b-md"
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

interface EnrollmentRowProps {
  enrollment: Enrollment;
  courseName: string;
  onUpdate: (id: number, data: any) => void;
  isPending: boolean;
}

function EnrollmentRow({ enrollment, courseName, onUpdate, isPending }: EnrollmentRowProps) {
  const [editing, setEditing] = useState(false);
  const [grade, setGrade] = useState(enrollment.grade?.toString() || "");
  const [remarks, setRemarks] = useState(enrollment.remarks || "");
  const [dateStarted, setDateStarted] = useState(enrollment.dateStarted);
  const [dateEnded, setDateEnded] = useState(enrollment.dateEnded);

  const handleSave = useCallback(() => {
    onUpdate(enrollment.id, {
      dateStarted,
      dateEnded: dateEnded || null,
      grade: grade ? parseFloat(grade) : null,
      remarks: remarks || null,
    });
    setEditing(false);
  }, [enrollment.id, dateStarted, dateEnded, grade, remarks, onUpdate]);

  const handleCoursePassed = useCallback(() => {
    const today = format(new Date(), "yyyy-MM-dd");
    onUpdate(enrollment.id, {
      dateEnded: enrollment.dateEnded || today,
      grade: enrollment.grade,
      remarks: enrollment.remarks,
    });
  }, [enrollment, onUpdate]);

  const handleEndEnrollment = useCallback(() => {
    const today = format(new Date(), "yyyy-MM-dd");
    onUpdate(enrollment.id, {
      dateEnded: today,
      grade: enrollment.grade,
      remarks: enrollment.remarks,
    });
  }, [enrollment, onUpdate]);

  if (editing) {
    return (
      <tr className="border-b bg-muted/20">
        <td className="py-3 px-3 font-medium text-sm">{courseName}</td>
        <td className="py-3 px-2">
          <DatePicker value={dateStarted} onChange={(v) => v && setDateStarted(v)} placeholder="Date started" />
        </td>
        <td className="py-3 px-2">
          <DatePicker value={dateEnded} onChange={(v) => setDateEnded(v)} placeholder="Date ended" />
        </td>
        <td className="py-3 px-2">
          <Input
            type="number"
            step="0.1"
            min="0"
            max="100"
            value={grade}
            onChange={e => setGrade(e.target.value)}
            className="w-[80px] h-9 text-xs"
            placeholder="Grade"
            data-testid="input-grade-edit"
          />
        </td>
        <td className="py-3 px-2">
          <Textarea
            value={remarks}
            onChange={e => setRemarks(e.target.value.slice(0, 1000))}
            maxLength={1000}
            className="text-xs min-h-[36px] h-9 resize-none"
            placeholder="Remarks..."
            data-testid="input-remarks-edit"
          />
        </td>
        <td className="py-3 px-2 text-right">
          <div className="flex items-center gap-1 justify-end">
            <Button size="sm" variant="default" onClick={handleSave} disabled={isPending} className="h-8 text-xs" data-testid="button-save-enrollment">
              Save
            </Button>
            <Button size="sm" variant="ghost" onClick={() => setEditing(false)} className="h-8 text-xs" data-testid="button-cancel-edit">
              Cancel
            </Button>
          </div>
        </td>
      </tr>
    );
  }

  return (
    <tr className="border-b last:border-0" data-testid={`row-enrollment-${enrollment.id}`}>
      <td className="py-3 px-3 font-medium text-sm">{courseName}</td>
      <td className="py-3 px-2 text-sm text-muted-foreground">
        {enrollment.dateStarted ? format(parse(enrollment.dateStarted, "yyyy-MM-dd", new Date()), "dd MMM yyyy") : "—"}
      </td>
      <td className="py-3 px-2 text-sm text-muted-foreground">
        {enrollment.dateEnded ? format(parse(enrollment.dateEnded, "yyyy-MM-dd", new Date()), "dd MMM yyyy") : "—"}
      </td>
      <td className="py-3 px-2 text-sm text-center">
        {enrollment.grade != null ? enrollment.grade : "—"}
      </td>
      <td className="py-3 px-2 text-xs text-muted-foreground max-w-[200px] truncate">
        {enrollment.remarks || "—"}
      </td>
      <td className="py-3 px-2 text-right">
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button size="icon" variant="ghost" className="h-8 w-8" data-testid={`button-edit-enrollment-${enrollment.id}`}>
              <Pencil className="h-3.5 w-3.5" />
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            <DropdownMenuItem onClick={() => setEditing(true)} data-testid="menu-edit">
              <Pencil className="h-3.5 w-3.5 mr-2" />
              Edit enrollment
            </DropdownMenuItem>
            <DropdownMenuItem onClick={handleCoursePassed} data-testid="menu-course-passed">
              <CheckCircle2 className="h-3.5 w-3.5 mr-2 text-emerald-500" />
              Course passed
            </DropdownMenuItem>
            <DropdownMenuItem onClick={handleEndEnrollment} data-testid="menu-end-enrollment">
              <XCircle className="h-3.5 w-3.5 mr-2 text-red-500" />
              End enrollment
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </td>
    </tr>
  );
}

function NewEnrollmentRow({ studentId, existingCourseIds, onCreated }: { studentId: number; existingCourseIds: number[]; onCreated: () => void }) {
  const { toast } = useToast();
  const [selectedCourse, setSelectedCourse] = useState<Course | null>(null);
  const [dateStarted, setDateStarted] = useState<string>(format(new Date(), "yyyy-MM-dd"));
  const [dateEnded, setDateEnded] = useState<string | null>(null);
  const [grade, setGrade] = useState("");
  const [remarks, setRemarks] = useState("");

  const createMutation = useMutation({
    mutationFn: async () => {
      if (!selectedCourse) throw new Error("Select a course");
      await apiRequest("POST", "/api/enrollments", {
        studentId,
        courseId: selectedCourse.id,
        dateStarted,
        dateEnded: dateEnded || null,
        grade: grade ? parseFloat(grade) : null,
        remarks: remarks || null,
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/enrollments", studentId.toString()] });
      toast({ title: "Enrollment created" });
      setSelectedCourse(null);
      setDateStarted(format(new Date(), "yyyy-MM-dd"));
      setDateEnded(null);
      setGrade("");
      setRemarks("");
      onCreated();
    },
    onError: (err: Error) => toast({ title: "Failed to create enrollment", description: err.message, variant: "destructive" }),
  });

  return (
    <tr className="border-b bg-accent/30" data-testid="row-new-enrollment">
      <td className="py-3 px-3">
        {selectedCourse ? (
          <div className="flex items-center gap-2">
            <span className="text-sm font-medium">{selectedCourse.course || selectedCourse.aceAlias}</span>
            <Button size="sm" variant="ghost" className="h-6 text-xs" onClick={() => setSelectedCourse(null)}>Change</Button>
          </div>
        ) : (
          <CourseSearch onSelect={setSelectedCourse} exclude={existingCourseIds} />
        )}
      </td>
      <td className="py-3 px-2">
        <DatePicker value={dateStarted} onChange={(v) => v && setDateStarted(v)} placeholder="Date started" />
      </td>
      <td className="py-3 px-2">
        <DatePicker value={dateEnded} onChange={(v) => setDateEnded(v)} placeholder="Date ended" />
      </td>
      <td className="py-3 px-2">
        <Input
          type="number"
          step="0.1"
          min="0"
          max="100"
          value={grade}
          onChange={e => setGrade(e.target.value)}
          className="w-[80px] h-9 text-xs"
          placeholder="Grade"
          data-testid="input-grade-new"
        />
      </td>
      <td className="py-3 px-2">
        <Textarea
          value={remarks}
          onChange={e => setRemarks(e.target.value.slice(0, 1000))}
          maxLength={1000}
          className="text-xs min-h-[36px] h-9 resize-none"
          placeholder="Remarks (max 1000 chars)..."
          data-testid="input-remarks-new"
        />
      </td>
      <td className="py-3 px-2 text-right">
        <Button
          size="sm"
          onClick={() => createMutation.mutate()}
          disabled={!selectedCourse || !dateStarted || createMutation.isPending}
          className="h-8 text-xs"
          data-testid="button-save-new-enrollment"
        >
          {createMutation.isPending ? "Saving..." : "Save"}
        </Button>
      </td>
    </tr>
  );
}

export default function EnrollmentsPage() {
  const { toast } = useToast();
  const [selectedStudent, setSelectedStudent] = useState<Student | null>(null);
  const [showNewRow, setShowNewRow] = useState(false);

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

  const courseMap = useMemo(() => {
    return new Map(courses?.map(c => [c.id, c]) || []);
  }, [courses]);

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

  const handleUpdate = useCallback((id: number, data: any) => {
    updateMutation.mutate({ id, data });
  }, [updateMutation]);

  const existingCourseIds = useMemo(() => {
    return enrollments?.map(e => e.courseId) || [];
  }, [enrollments]);

  return (
    <div className="p-6 max-w-6xl mx-auto space-y-6">
      <div>
        <h1 className="text-2xl font-serif font-bold tracking-tight" data-testid="text-page-title">Enrollments</h1>
        <p className="text-muted-foreground mt-1">Manage student course enrollments. Search for a student to view and edit their enrollments.</p>
      </div>

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
              {enrollments && <span className="text-muted-foreground font-normal ml-2">({enrollments.length})</span>}
            </CardTitle>
          </CardHeader>
          <CardContent className="p-0">
            <div className="overflow-x-auto">
              <table className="w-full text-sm" data-testid="table-enrollments">
                <thead>
                  <tr className="border-b bg-muted/30">
                    <th className="text-left py-3 px-3 font-medium text-muted-foreground min-w-[200px]">Course</th>
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
                  ) : enrollments && enrollments.length > 0 ? (
                    enrollments.map(enrollment => {
                      const course = courseMap.get(enrollment.courseId);
                      const courseName = course?.course || course?.aceAlias || `Course #${enrollment.courseId}`;
                      return (
                        <EnrollmentRow
                          key={enrollment.id}
                          enrollment={enrollment}
                          courseName={courseName}
                          onUpdate={handleUpdate}
                          isPending={updateMutation.isPending}
                        />
                      );
                    })
                  ) : !showNewRow ? (
                    <tr>
                      <td colSpan={6} className="text-center py-8 text-muted-foreground">
                        No enrollments yet. Click "Add new enrollment" to get started.
                      </td>
                    </tr>
                  ) : null}
                  {showNewRow && (
                    <NewEnrollmentRow
                      studentId={selectedStudent.id}
                      existingCourseIds={existingCourseIds}
                      onCreated={() => setShowNewRow(false)}
                    />
                  )}
                </tbody>
              </table>
            </div>
            <div className="p-4 border-t">
              <Button
                variant="outline"
                onClick={() => setShowNewRow(true)}
                disabled={showNewRow}
                data-testid="button-add-enrollment"
              >
                <Plus className="h-4 w-4 mr-2" />
                Add new enrollment
              </Button>
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}
