import { useQuery } from "@tanstack/react-query";
import { Card, CardContent } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Skeleton } from "@/components/ui/skeleton";
import { useState, useMemo, useEffect } from "react";
import type { Student, Course, Enrollment, Subject, DateEntry, PaceCourse, UserProfile } from "@shared/schema";
import { Star } from "lucide-react";

function formatGrade(grade: number | null): string {
  if (grade === null || grade === undefined) return "";
  if (Number.isInteger(grade)) return `${grade}%`;
  return `${parseFloat(grade.toFixed(1))}%`;
}

function isPassed(grade: number | null, course: Course, isDyslexic: boolean): boolean {
  if (grade === null || grade === undefined) return false;
  const isWordBuilding = course.subjectTemp?.toLowerCase() === "word building";
  if (isWordBuilding) {
    return isDyslexic ? grade >= 80 : grade >= 90;
  }
  return grade >= (course.passThreshold ? course.passThreshold * 100 : 80);
}

function excelDateToKey(excelDate: number): string {
  const msPerDay = 86400000;
  const excelEpochMs = Date.UTC(1899, 11, 30);
  const utcMs = excelEpochMs + excelDate * msPerDay;
  const d = new Date(utcMs);
  return `${d.getUTCFullYear()}-${String(d.getUTCMonth() + 1).padStart(2, "0")}-${String(d.getUTCDate()).padStart(2, "0")}`;
}

function getTermLabel(dateStarted: string | null, datesMap: Map<string, DateEntry>): string {
  if (!dateStarted) return "";
  const dateEntry = datesMap.get(dateStarted);
  if (!dateEntry) return "";
  const yearTerm = dateEntry.yearTerm;
  const term = dateEntry.term;
  if (!yearTerm || !term) return "";
  return `${yearTerm}.T${term}`;
}

export default function SPCPage() {
  const [selectedStudentId, setSelectedStudentId] = useState<string>("");

  const { data: profile } = useQuery<UserProfile>({ queryKey: ["/api/profile"] });
  const { data: students, isLoading: studentsLoading } = useQuery<Student[]>({ queryKey: ["/api/students"] });
  const { data: courses } = useQuery<Course[]>({ queryKey: ["/api/courses"] });
  const { data: subjects } = useQuery<Subject[]>({ queryKey: ["/api/subjects"] });
  const { data: allDates } = useQuery<DateEntry[]>({ queryKey: ["/api/dates"] });
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

  const datesMap = useMemo(() => {
    const map = new Map<string, DateEntry>();
    allDates?.forEach(d => {
      if (d.date !== null && d.date !== undefined) {
        map.set(excelDateToKey(d.date), d);
      }
    });
    return map;
  }, [allDates]);

  const paceNumbersByCourse = useMemo(() => {
    const map = new Map<number, number[]>();
    paceCourses?.forEach(pc => {
      if (pc.number !== null && pc.number !== undefined) {
        const num = typeof pc.number === "string" ? parseInt(pc.number, 10) : pc.number;
        if (!isNaN(num)) {
          const existing = map.get(pc.courseId) || [];
          if (!existing.includes(num)) {
            existing.push(num);
          }
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

  const sortedStudents = useMemo(() => {
    if (!students) return [];
    return [...students].sort((a, b) => {
      if (profile?.role === "parent") {
        if (a.dateOfBirth && b.dateOfBirth) return a.dateOfBirth.localeCompare(b.dateOfBirth);
        if (a.dateOfBirth) return -1;
        if (b.dateOfBirth) return 1;
        return a.callName.localeCompare(b.callName);
      }
      if (a.active !== b.active) return a.active ? -1 : 1;
      return a.callName.localeCompare(b.callName);
    });
  }, [students, profile]);

  useEffect(() => {
    if (!selectedStudentId && sortedStudents.length > 0 && profile?.role === "parent") {
      setSelectedStudentId(String(sortedStudents[0].id));
    }
  }, [sortedStudents, selectedStudentId, profile]);

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
      <div>
        <h1 className="text-2xl font-serif font-bold tracking-tight" data-testid="text-page-title">Student Progress Chart</h1>
        <p className="text-muted-foreground mt-1">View per-student PACE progress with grades and terms.</p>
      </div>

      <div className="space-y-1.5">
        <label className="text-sm font-medium">Select Student</label>
        <Select value={selectedStudentId} onValueChange={setSelectedStudentId}>
          <SelectTrigger className="w-[280px]" data-testid="select-student">
            <SelectValue placeholder="Choose a student..." />
          </SelectTrigger>
          <SelectContent>
            {sortedStudents.map(s => (
              <SelectItem key={s.id} value={String(s.id)} data-testid={`option-student-${s.id}`}>
                {s.callName} {s.surname}{!s.active ? " (inactive)" : ""}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
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
        <div className="space-y-4" data-testid="spc-grid">
          {courseGroups.map(({ course, subject, paceNumbers, enrollmentsByNumber }) => {
            const colorCode = subject?.colorCode || "#808080";
            const isDyslexic = selectedStudent.isDyslexic;

            return (
              <Card key={course.id} className="overflow-hidden" data-testid={`spc-course-${course.id}`}>
                <div
                  className="h-1.5"
                  style={{ backgroundColor: colorCode }}
                />
                <CardContent className="p-4">
                  <div className="flex flex-wrap items-baseline gap-x-4 gap-y-1 mb-3">
                    <span className="font-semibold text-sm" data-testid={`text-ace-name-${course.id}`}>
                      {course.aceAlias || course.course || `Course ${course.id}`}
                    </span>
                    <span className="text-xs text-muted-foreground" data-testid={`text-icce-name-${course.id}`}>
                      ICCE: {course.icceAlias || "—"}
                    </span>
                    <span className="text-xs text-muted-foreground" data-testid={`text-cert-name-${course.id}`}>
                      Cert: {course.certificateName || "—"}
                    </span>
                    <span
                      className="text-xs font-medium px-2 py-0.5 rounded-full"
                      style={{
                        backgroundColor: colorCode + "20",
                        color: colorCode === "#FFFFFF" ? "#666" : colorCode,
                        border: colorCode === "#FFFFFF" ? "1px solid #ddd" : "none",
                      }}
                      data-testid={`badge-subject-${course.id}`}
                    >
                      {subject?.subject || course.subjectTemp || "Unknown"}
                    </span>
                  </div>

                  <div className="overflow-x-auto">
                    <table className="text-xs border-collapse" data-testid={`table-spc-${course.id}`}>
                      <thead>
                        <tr>
                          <th className="text-left pr-3 py-1 font-medium text-muted-foreground whitespace-nowrap min-w-[60px]">PACE #</th>
                          {paceNumbers.map(num => (
                            <th key={num} className="text-center px-1 py-1 font-mono font-normal text-muted-foreground min-w-[36px]">
                              {num}
                            </th>
                          ))}
                        </tr>
                      </thead>
                      <tbody>
                        <tr>
                          <td className="pr-3 py-1.5 font-medium text-muted-foreground whitespace-nowrap">Stars</td>
                          {paceNumbers.map(num => {
                            const enrollment = enrollmentsByNumber.get(num);
                            const grade = enrollment?.grade ?? null;
                            const passed = isPassed(grade, course, isDyslexic);

                            return (
                              <td key={num} className="text-center px-1 py-1.5" data-testid={`star-${course.id}-${num}`}>
                                <Star
                                  className="w-5 h-5 mx-auto"
                                  fill={passed ? colorCode : "none"}
                                  stroke={passed ? colorCode : "hsl(var(--muted-foreground) / 0.3)"}
                                  strokeWidth={1.5}
                                />
                              </td>
                            );
                          })}
                        </tr>
                        <tr>
                          <td className="pr-3 py-1 font-medium text-muted-foreground whitespace-nowrap">Grade</td>
                          {paceNumbers.map(num => {
                            const enrollment = enrollmentsByNumber.get(num);
                            const grade = enrollment?.grade ?? null;
                            const passed = isPassed(grade, course, isDyslexic);

                            return (
                              <td
                                key={num}
                                className={`text-center px-1 py-1 font-mono ${
                                  grade !== null
                                    ? passed
                                      ? "text-foreground font-medium"
                                      : "text-destructive font-medium"
                                    : "text-muted-foreground/30"
                                }`}
                                data-testid={`grade-${course.id}-${num}`}
                              >
                                {grade !== null ? formatGrade(grade) : "—"}
                              </td>
                            );
                          })}
                        </tr>
                        <tr>
                          <td className="pr-3 py-1 font-medium text-muted-foreground whitespace-nowrap">Term</td>
                          {paceNumbers.map(num => {
                            const enrollment = enrollmentsByNumber.get(num);
                            const label = getTermLabel(enrollment?.dateStarted ?? null, datesMap);

                            return (
                              <td
                                key={num}
                                className="text-center px-1 py-1 text-muted-foreground"
                                data-testid={`term-${course.id}-${num}`}
                              >
                                {label || "—"}
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
    </div>
  );
}
