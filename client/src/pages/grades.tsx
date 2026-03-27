import { useQuery, useQueryClient } from "@tanstack/react-query";
import { Card, CardContent } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useMemo, useEffect, useCallback, useState } from "react";
import { usePersistedState } from "@/lib/persisted-state";
import type { Student, Course, Enrollment, Subject, PaceCourse, UserProfile } from "@shared/schema";
import { Pencil, Undo2, Redo2 } from "lucide-react";
import { StudentSearch } from "@/components/student-search";
import { apiRequest } from "@/lib/queryClient";
import { useToast } from "@/hooks/use-toast";

function formatGrade(grade: number | null): string {
  if (grade === null || grade === undefined) return "—";
  if (Number.isInteger(grade)) return `${grade}%`;
  return `${parseFloat(grade.toFixed(1))}%`;
}

function formatDate(dateStr: string | null): string {
  if (!dateStr) return "—";
  const parts = dateStr.split("-");
  if (parts.length !== 3) return dateStr;
  return `${parts[2]}/${parts[1]}/${parts[0].slice(2)}`;
}

type PendingChange = {
  grade: number | null;
  dateEnded: string | null;
};

type GradeEdit = {
  enrollmentId: number;
  prev: PendingChange;
  next: PendingChange;
};

type DialogState = {
  open: boolean;
  enrollmentId: number | null;
  paceNum: number | null;
  courseLabel: string;
  grade: string;
  dateEnded: string;
  isNew: boolean;
  courseId: number | null;
};

export default function GradesPage() {
  const [selectedStudentId, setSelectedStudentId] = usePersistedState<string>("shared.selectedStudentId", "");
  const { toast } = useToast();
  const queryClient = useQueryClient();

  const { data: students, isLoading: studentsLoading } = useQuery<Student[]>({ queryKey: ["/api/students"] });
  const { data: courses } = useQuery<Course[]>({ queryKey: ["/api/courses"] });
  const { data: subjects } = useQuery<Subject[]>({ queryKey: ["/api/subjects"] });
  const { data: paceCourses } = useQuery<PaceCourse[]>({ queryKey: ["/api/pace-courses"] });

  const selectedStudent = useMemo(() => {
    if (!selectedStudentId || !students) return null;
    return students.find(s => s.id === parseInt(selectedStudentId)) || null;
  }, [selectedStudentId, students]);

  const { data: enrollments } = useQuery<Enrollment[]>({
    queryKey: ["/api/enrollments", selectedStudentId],
    queryFn: async () => {
      const res = await fetch(`/api/enrollments?studentId=${selectedStudentId}`, { credentials: "include" });
      if (!res.ok) throw new Error("Failed");
      return res.json();
    },
    enabled: !!selectedStudentId,
  });

  const [editMode, setEditMode] = useState(false);
  const [pendingChanges, setPendingChanges] = useState<Map<number, PendingChange>>(new Map());
  const [undoStack, setUndoStack] = useState<GradeEdit[]>([]);
  const [redoStack, setRedoStack] = useState<GradeEdit[]>([]);
  const [showSaveConfirm, setShowSaveConfirm] = useState(false);
  const [saving, setSaving] = useState(false);

  const [dialog, setDialog] = useState<DialogState>({
    open: false,
    enrollmentId: null,
    paceNum: null,
    courseLabel: "",
    grade: "",
    dateEnded: "",
    isNew: false,
    courseId: null,
  });

  const subjectMap = useMemo(() => {
    const map = new Map<number, Subject>();
    subjects?.forEach(s => map.set(s.id, s));
    return map;
  }, [subjects]);

  const courseMap = useMemo(() => {
    const map = new Map<number, Course>();
    courses?.forEach(c => map.set(c.id, c));
    return map;
  }, [courses]);

  const paceNumbersByCourse = useMemo(() => {
    const map = new Map<number, number[]>();
    paceCourses?.forEach(pc => {
      if (pc.number !== null && pc.number !== undefined) {
        const num = typeof pc.number === "string" ? parseInt(pc.number, 10) : pc.number;
        if (!isNaN(num)) {
          const existing = map.get(pc.courseId) || [];
          if (!existing.includes(num)) existing.push(num);
          map.set(pc.courseId, existing);
        }
      }
    });
    map.forEach((nums, key) => map.set(key, nums.sort((a, b) => a - b)));
    return map;
  }, [paceCourses]);

  const courseGroups = useMemo(() => {
    if (!enrollments || !courses) return [];
    const grouped = new Map<number, Enrollment[]>();
    enrollments.forEach(e => {
      const list = grouped.get(e.courseId) || [];
      list.push(e);
      grouped.set(e.courseId, list);
    });

    const result: {
      course: Course;
      subject: Subject | undefined;
      paceNumbers: number[];
      enrollmentsByNumber: Map<number, Enrollment>;
    }[] = [];

    grouped.forEach((enrs, courseId) => {
      const course = courseMap.get(courseId);
      if (!course) return;
      const subject = course.subjectId ? subjectMap.get(course.subjectId) : undefined;
      const paceNumbers = paceNumbersByCourse.get(courseId) || [];
      const enrollmentsByNumber = new Map<number, Enrollment>();
      enrs.forEach(e => {
        const num = typeof e.number === "string" ? parseInt(e.number, 10) : e.number;
        if (!isNaN(num)) enrollmentsByNumber.set(num, e);
      });
      result.push({ course, subject, paceNumbers, enrollmentsByNumber });
    });

    result.sort((a, b) => {
      const sA = a.course.subjectId ?? 999;
      const sB = b.course.subjectId ?? 999;
      if (sA !== sB) return sA - sB;
      return (a.course.level ?? 0) - (b.course.level ?? 0);
    });
    return result;
  }, [enrollments, courses, courseMap, subjectMap, paceNumbersByCourse]);

  // Reset edit state when student changes
  useEffect(() => {
    setEditMode(false);
    setPendingChanges(new Map());
    setUndoStack([]);
    setRedoStack([]);
  }, [selectedStudentId]);

  const getEffectiveGrade = useCallback((enrollment: Enrollment): number | null => {
    const pending = pendingChanges.get(enrollment.id);
    if (pending !== undefined) return pending.grade;
    return enrollment.grade ?? null;
  }, [pendingChanges]);

  const getEffectiveDateEnded = useCallback((enrollment: Enrollment): string | null => {
    const pending = pendingChanges.get(enrollment.id);
    if (pending !== undefined) return pending.dateEnded;
    return enrollment.dateEnded ?? null;
  }, [pendingChanges]);

  const hasPendingChange = useCallback((enrollment: Enrollment): boolean => {
    const pending = pendingChanges.get(enrollment.id);
    if (!pending) return false;
    return pending.grade !== (enrollment.grade ?? null) ||
           pending.dateEnded !== (enrollment.dateEnded ?? null);
  }, [pendingChanges]);

  const applyEdit = useCallback((edit: GradeEdit) => {
    setPendingChanges(prev => {
      const next = new Map(prev);
      next.set(edit.enrollmentId, edit.next);
      return next;
    });
  }, []);

  const openDialog = useCallback((enrollment: Enrollment, paceNum: number, courseLabel: string) => {
    if (!editMode) return;
    const currentGrade = pendingChanges.get(enrollment.id)?.grade ?? enrollment.grade ?? null;
    const currentDate = pendingChanges.get(enrollment.id)?.dateEnded ?? enrollment.dateEnded ?? null;
    setDialog({
      open: true,
      enrollmentId: enrollment.id,
      paceNum,
      courseLabel,
      grade: currentGrade !== null ? String(currentGrade) : "",
      dateEnded: currentDate ?? "",
      isNew: false,
      courseId: null,
    });
  }, [editMode, pendingChanges]);

  const openNewDialog = useCallback((courseId: number, paceNum: number, courseLabel: string) => {
    if (!editMode) return;
    setDialog({
      open: true,
      enrollmentId: null,
      paceNum,
      courseLabel,
      grade: "",
      dateEnded: "",
      isNew: true,
      courseId,
    });
  }, [editMode]);

  const commitEdit = useCallback(async () => {
    if (dialog.isNew) {
      if (!dialog.courseId || !selectedStudent || dialog.paceNum === null) return;
      try {
        const rawGrade = dialog.grade.trim() === "" ? null : parseFloat(dialog.grade.replace("%", ""));
        const res = await apiRequest("POST", "/api/enrollments/course", {
          studentId: selectedStudent.id,
          courseId: dialog.courseId,
          selectedPaces: [{ number: String(dialog.paceNum), isRepeat: false }],
        });
        const created: Enrollment[] = await res.json();
        const newEnrollment = created[0];
        if (newEnrollment && (rawGrade !== null || dialog.dateEnded)) {
          await apiRequest("PATCH", `/api/enrollments/${newEnrollment.id}`, {
            grade: rawGrade === null || isNaN(rawGrade) ? null : rawGrade,
            dateEnded: dialog.dateEnded || null,
          });
        }
        await queryClient.invalidateQueries({ queryKey: ["/api/enrollments", selectedStudentId] });
      } catch (err: any) {
        toast({ title: "Failed to create enrollment", description: err.message, variant: "destructive" });
      }
      setDialog(d => ({ ...d, open: false }));
      return;
    }

    if (dialog.enrollmentId === null || !enrollments) return;
    const enrollment = enrollments.find(e => e.id === dialog.enrollmentId);
    if (!enrollment) return;

    const prevPending = pendingChanges.get(dialog.enrollmentId);
    const prev: PendingChange = prevPending ?? {
      grade: enrollment.grade ?? null,
      dateEnded: enrollment.dateEnded ?? null,
    };

    const rawGrade = dialog.grade.trim() === "" ? null : parseFloat(dialog.grade.replace("%", ""));
    const next: PendingChange = {
      grade: rawGrade === null || isNaN(rawGrade) ? null : rawGrade,
      dateEnded: dialog.dateEnded || null,
    };

    const edit: GradeEdit = { enrollmentId: dialog.enrollmentId, prev, next };
    applyEdit(edit);
    setUndoStack(s => [...s, edit]);
    setRedoStack([]);
    setDialog(d => ({ ...d, open: false }));
  }, [dialog, pendingChanges, enrollments, applyEdit, selectedStudent, selectedStudentId, queryClient, toast]);

  const undo = useCallback(() => {
    if (undoStack.length === 0) return;
    const edit = undoStack[undoStack.length - 1];
    setUndoStack(s => s.slice(0, -1));
    setRedoStack(s => [...s, edit]);
    setPendingChanges(prev => {
      const next = new Map(prev);
      next.set(edit.enrollmentId, edit.prev);
      return next;
    });
  }, [undoStack]);

  const redo = useCallback(() => {
    if (redoStack.length === 0) return;
    const edit = redoStack[redoStack.length - 1];
    setRedoStack(s => s.slice(0, -1));
    setUndoStack(s => [...s, edit]);
    applyEdit(edit);
  }, [redoStack, applyEdit]);

  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if (!editMode) return;
      const mod = e.ctrlKey || e.metaKey;
      if (mod && e.shiftKey && e.key.toLowerCase() === "z") {
        e.preventDefault();
        redo();
      } else if (mod && e.key.toLowerCase() === "z") {
        e.preventDefault();
        undo();
      }
    };
    window.addEventListener("keydown", handler);
    return () => window.removeEventListener("keydown", handler);
  }, [editMode, undo, redo]);

  const handleEditToggle = () => {
    if (!editMode) {
      setEditMode(true);
    } else {
      setShowSaveConfirm(true);
    }
  };

  const saveChanges = async () => {
    setSaving(true);
    try {
      const entries = Array.from(pendingChanges.entries()).filter(([id]) => {
        const enrollment = enrollments?.find(e => e.id === id);
        if (!enrollment) return false;
        const p = pendingChanges.get(id)!;
        return p.grade !== (enrollment.grade ?? null) || p.dateEnded !== (enrollment.dateEnded ?? null);
      });
      await Promise.all(
        entries.map(([id, change]) =>
          apiRequest("PATCH", `/api/enrollments/${id}`, {
            grade: change.grade,
            dateEnded: change.dateEnded,
          })
        )
      );
      await queryClient.invalidateQueries({ queryKey: ["/api/enrollments", selectedStudentId] });
      setPendingChanges(new Map());
      setUndoStack([]);
      setRedoStack([]);
      setEditMode(false);
      toast({ title: "Grades saved" });
    } catch (err: any) {
      toast({ title: "Save failed", description: err.message, variant: "destructive" });
    } finally {
      setSaving(false);
    }
  };

  const changedCount = useMemo(() => {
    if (!enrollments) return 0;
    return Array.from(pendingChanges.entries()).filter(([id]) => {
      const e = enrollments.find(en => en.id === id);
      if (!e) return false;
      const p = pendingChanges.get(id)!;
      return p.grade !== (e.grade ?? null) || p.dateEnded !== (e.dateEnded ?? null);
    }).length;
  }, [pendingChanges, enrollments]);

  if (studentsLoading) {
    return (
      <div className="p-6 max-w-7xl mx-auto space-y-4">
        <Skeleton className="h-8 w-48" />
        <Skeleton className="h-12 w-64" />
        <Skeleton className="h-96 w-full" />
      </div>
    );
  }

  return (
    <div className="p-6 max-w-7xl mx-auto space-y-6">
      <div className="flex items-start justify-between gap-4">
        <div>
          <h1 className="text-2xl font-serif font-bold tracking-tight">Grades</h1>
          <p className="text-muted-foreground mt-1">Enter and review PACE grades per student.</p>
        </div>
        {selectedStudent && (
          <div className="flex items-center gap-2 pt-1">
            {editMode && (
              <>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={undo}
                  disabled={undoStack.length === 0}
                  title="Undo (Ctrl+Z)"
                >
                  <Undo2 className="w-4 h-4" />
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={redo}
                  disabled={redoStack.length === 0}
                  title="Redo (Ctrl+Shift+Z)"
                >
                  <Redo2 className="w-4 h-4" />
                </Button>
              </>
            )}
            <Button
              variant={editMode ? "default" : "outline"}
              size="sm"
              onClick={handleEditToggle}
            >
              <Pencil className="w-4 h-4 mr-1.5" />
              {editMode ? "Done Editing" : "Edit"}
            </Button>
          </div>
        )}
      </div>

      <div className="space-y-1.5">
        <label className="text-sm font-medium">Select Student</label>
        <StudentSearch
          onSelect={(s) => setSelectedStudentId(String(s.id))}
          selectedStudent={selectedStudent}
          className="max-w-md"
        />
      </div>

      {selectedStudent && !enrollments && (
        <div className="space-y-3">
          <Skeleton className="h-32 w-full" />
          <Skeleton className="h-32 w-full" />
        </div>
      )}

      {selectedStudent && enrollments && courseGroups.length === 0 && (
        <Card>
          <CardContent className="py-12 text-center text-muted-foreground">
            No enrollments found for {selectedStudent.callName}. Add enrollments on the Enrollments page first.
          </CardContent>
        </Card>
      )}

      {selectedStudent && courseGroups.length > 0 && (
        <div className="space-y-4">
          {courseGroups.map(({ course, subject, paceNumbers, enrollmentsByNumber }) => {
            const colorCode = subject?.colorCode || "#808080";

            return (
              <Card key={course.id} className="overflow-hidden">
                <div className="h-1.5" style={{ backgroundColor: colorCode }} />
                <CardContent className="p-4">
                  <div className="flex flex-wrap items-baseline gap-x-4 gap-y-1 mb-3">
                    <span className="font-semibold text-sm">
                      {course.aceAlias || course.icceAlias || `Course ${course.id}`}
                    </span>
                    <span className="text-xs text-muted-foreground">
                      ICCE: {course.icceAlias || "—"}
                    </span>
                    <span className="text-xs text-muted-foreground">
                      Cert: {course.certificateName || "—"}
                    </span>
                    <span
                      className="text-xs font-medium px-2 py-0.5 rounded-full"
                      style={{
                        backgroundColor: colorCode + "20",
                        color: colorCode === "#FFFFFF" ? "#666" : colorCode,
                        border: colorCode === "#FFFFFF" ? "1px solid #ddd" : "none",
                      }}
                    >
                      {subject?.subject || "Unknown"}
                    </span>
                  </div>

                  <div className="overflow-x-auto">
                    <table className="text-xs border-collapse">
                      <thead>
                        <tr>
                          <th className="text-left pr-3 py-1 font-medium text-muted-foreground whitespace-nowrap min-w-[60px]">
                            PACE #
                          </th>
                          {paceNumbers.map(num => (
                            <th
                              key={num}
                              className="text-center px-1 py-1 font-mono font-normal text-muted-foreground min-w-[52px]"
                            >
                              {num}
                            </th>
                          ))}
                        </tr>
                      </thead>
                      <tbody>
                        <tr>
                          <td className="pr-3 py-1.5 font-medium text-muted-foreground whitespace-nowrap">
                            Grade
                          </td>
                          {paceNumbers.map(num => {
                            const enrollment = enrollmentsByNumber.get(num);
                            const grade = enrollment ? getEffectiveGrade(enrollment) : null;
                            const changed = enrollment ? hasPendingChange(enrollment) : false;

                            return (
                              <td
                                key={num}
                                className={[
                                  "text-center px-1 py-1.5 font-mono rounded transition-colors",
                                  editMode ? "cursor-pointer hover:bg-accent/60" : "",
                                  grade !== null
                                    ? "text-foreground font-medium"
                                    : "text-muted-foreground/30",
                                  changed ? "bg-amber-50 dark:bg-amber-950/30" : "",
                                ].join(" ")}
                                onClick={() => {
                                  const label = course.aceAlias || course.icceAlias || `Course ${course.id}`;
                                  if (enrollment) {
                                    openDialog(enrollment, num, label);
                                  } else {
                                    openNewDialog(course.id, num, label);
                                  }
                                }}
                              >
                                {formatGrade(grade)}
                              </td>
                            );
                          })}
                        </tr>
                        <tr>
                          <td className="pr-3 py-1 font-medium text-muted-foreground whitespace-nowrap">
                            Date
                          </td>
                          {paceNumbers.map(num => {
                            const enrollment = enrollmentsByNumber.get(num);
                            const dateEnded = enrollment ? getEffectiveDateEnded(enrollment) : null;
                            const changed = enrollment ? hasPendingChange(enrollment) : false;

                            return (
                              <td
                                key={num}
                                className={[
                                  "text-center px-1 py-1 text-muted-foreground rounded transition-colors",
                                  editMode ? "cursor-pointer hover:bg-accent/60" : "",
                                  changed ? "bg-amber-50 dark:bg-amber-950/30" : "",
                                ].join(" ")}
                                onClick={() => {
                                  const label = course.aceAlias || course.icceAlias || `Course ${course.id}`;
                                  if (enrollment) {
                                    openDialog(enrollment, num, label);
                                  } else {
                                    openNewDialog(course.id, num, label);
                                  }
                                }}
                              >
                                {formatDate(dateEnded)}
                              </td>
                            );
                          })}
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </CardContent>
              </Card>
            );
          })}
        </div>
      )}

      {/* Grade edit dialog */}
      <Dialog open={dialog.open} onOpenChange={(open) => setDialog(d => ({ ...d, open }))}>
        <DialogContent className="sm:max-w-xs">
          <DialogHeader>
            <DialogTitle>
              {dialog.courseLabel} — PACE {dialog.paceNum}
              {dialog.isNew && <span className="text-muted-foreground font-normal text-sm ml-2">(new)</span>}
            </DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-2">
            <div className="space-y-1.5">
              <Label htmlFor="grade-input">Grade (%)</Label>
              <Input
                id="grade-input"
                type="number"
                min={0}
                max={100}
                step={0.1}
                placeholder="e.g. 87"
                value={dialog.grade}
                onChange={e => setDialog(d => ({ ...d, grade: e.target.value }))}
                onKeyDown={e => e.key === "Enter" && commitEdit()}
                autoFocus
              />
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="date-input">Date</Label>
              <Input
                id="date-input"
                type="date"
                value={dialog.dateEnded}
                onChange={e => setDialog(d => ({ ...d, dateEnded: e.target.value }))}
                onKeyDown={e => e.key === "Enter" && commitEdit()}
              />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setDialog(d => ({ ...d, open: false }))}>
              Cancel
            </Button>
            <Button onClick={commitEdit}>OK</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Save confirmation dialog */}
      <AlertDialog open={showSaveConfirm} onOpenChange={setShowSaveConfirm}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Save all edits?</AlertDialogTitle>
            <AlertDialogDescription>
              {changedCount === 0
                ? "No changes were made."
                : `You have changes for ${changedCount} PACE${changedCount !== 1 ? "s" : ""}. Save them now?`}
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel onClick={() => setShowSaveConfirm(false)}>
              Cancel
            </AlertDialogCancel>
            <AlertDialogAction
              onClick={async () => {
                setShowSaveConfirm(false);
                if (changedCount > 0) {
                  await saveChanges();
                } else {
                  setPendingChanges(new Map());
                  setUndoStack([]);
                  setRedoStack([]);
                  setEditMode(false);
                }
              }}
              disabled={saving}
            >
              {saving ? "Saving…" : "OK"}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
