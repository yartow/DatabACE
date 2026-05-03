import { useQuery } from "@tanstack/react-query";
import { Card, CardContent, CardHeader } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { Badge } from "@/components/ui/badge";
import { useAuth } from "@/hooks/use-auth";
import { usePersistedState } from "@/lib/persisted-state";
import { HelpTip } from "@/components/help-tip";
import type { Student, Enrollment, Course, Subject } from "@shared/schema";
import { BarChart3, FileText, TrendingUp, BookOpen, CheckCircle2, Clock } from "lucide-react";
import { Link } from "wouter";
import cederLogoPath from "@assets/cederlogo_basic_v2017_1_1773068129584.png";

function formatGrade(grade: number | null): string {
  if (grade === null || grade === undefined) return "—";
  if (Number.isInteger(grade)) return `${grade}%`;
  return `${parseFloat(grade.toFixed(1))}%`;
}

function gradeColor(grade: number): string {
  if (grade >= 90) return "text-green-600";
  if (grade >= 80) return "text-green-500";
  if (grade >= 70) return "text-amber-500";
  return "text-red-600";
}

function StudentCard({ student }: { student: Student }) {
  const [, setSelectedStudentId] = usePersistedState<string>("shared.selectedStudentId", "");

  const { data: enrollments } = useQuery<Enrollment[]>({
    queryKey: ["/api/enrollments", String(student.id)],
    queryFn: async () => {
      const res = await fetch(`/api/enrollments?studentId=${student.id}`, { credentials: "include" });
      if (!res.ok) throw new Error("Failed");
      return res.json();
    },
  });

  const { data: courses } = useQuery<Course[]>({ queryKey: ["/api/courses"] });
  const { data: subjects } = useQuery<Subject[]>({ queryKey: ["/api/subjects"] });

  const courseMap = new Map(courses?.map(c => [c.id, c]) ?? []);
  const subjectMap = new Map(subjects?.map(s => [s.id, s]) ?? []);

  const completed = (enrollments ?? []).filter(e => e.dateEnded && e.grade !== null);
  const inProgress = (enrollments ?? []).filter(e => !e.dateEnded);

  const avgGrade =
    completed.length > 0
      ? completed.reduce((s, e) => s + (e.grade ?? 0), 0) / completed.length
      : null;

  const recentResults = [...completed]
    .sort((a, b) => (b.dateEnded ?? "").localeCompare(a.dateEnded ?? ""))
    .slice(0, 6);

  const navigateToStudent = () => setSelectedStudentId(String(student.id));

  return (
    <Card className="overflow-hidden shadow-sm">
      <div className="h-1.5 bg-primary" />
      <CardHeader className="pb-3">
        <div className="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-3">
          <div>
            <h2 className="text-xl font-serif font-bold tracking-tight">
              {student.callName} {student.surname}
            </h2>
            <div className="flex items-center gap-2 mt-1">
              {student.group && (
                <span className="text-sm text-muted-foreground">Group {student.group}</span>
              )}
              {student.alias && (
                <Badge variant="secondary" className="text-xs">{student.alias}</Badge>
              )}
            </div>
          </div>
          <div className="flex gap-2 flex-shrink-0">
            <Link href="/spc" onClick={navigateToStudent}>
              <Button size="sm" variant="outline" className="gap-1.5">
                <BarChart3 className="w-4 h-4" />
                Progress chart
              </Button>
            </Link>
            <Link href="/reports" onClick={navigateToStudent}>
              <Button size="sm" variant="outline" className="gap-1.5">
                <FileText className="w-4 h-4" />
                Term report
              </Button>
            </Link>
          </div>
        </div>
      </CardHeader>

      <CardContent className="space-y-5">
        {/* Summary stats */}
        <div className="grid grid-cols-3 gap-3">
          <div className="flex flex-col items-center justify-center p-3 rounded-lg bg-muted/50 text-center">
            <Clock className="w-5 h-5 text-muted-foreground mb-1" />
            <span className="text-2xl font-bold leading-none">
              {enrollments ? inProgress.length : <span className="text-muted-foreground">—</span>}
            </span>
            <span className="text-xs text-muted-foreground mt-1 leading-tight">In progress</span>
          </div>
          <div className="flex flex-col items-center justify-center p-3 rounded-lg bg-muted/50 text-center">
            <CheckCircle2 className="w-5 h-5 text-muted-foreground mb-1" />
            <span className="text-2xl font-bold leading-none">
              {enrollments ? completed.length : <span className="text-muted-foreground">—</span>}
            </span>
            <span className="text-xs text-muted-foreground mt-1 leading-tight">Completed</span>
          </div>
          <div className="flex flex-col items-center justify-center p-3 rounded-lg bg-muted/50 text-center">
            <TrendingUp className="w-5 h-5 text-muted-foreground mb-1" />
            <span className={`text-2xl font-bold leading-none ${avgGrade !== null ? gradeColor(avgGrade) : "text-muted-foreground"}`}>
              {avgGrade !== null ? formatGrade(avgGrade) : "—"}
            </span>
            <span className="text-xs text-muted-foreground mt-1 leading-tight">Average grade</span>
          </div>
        </div>

        {/* Recent results */}
        {!enrollments && (
          <div className="space-y-2 pt-1">
            <Skeleton className="h-4 w-full" />
            <Skeleton className="h-4 w-5/6" />
            <Skeleton className="h-4 w-4/6" />
          </div>
        )}

        {enrollments && recentResults.length > 0 && (
          <div>
            <div className="flex items-center gap-1.5 mb-3">
              <span className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                Recent results
              </span>
              <HelpTip
                content="These are your child's most recently completed PACE booklets, sorted from newest to oldest. A PACE is one workbook in a course."
                side="right"
              />
            </div>
            <div className="divide-y divide-border rounded-md border overflow-hidden">
              {recentResults.map((e) => {
                const course = courseMap.get(e.courseId);
                const subject = course?.subjectId ? subjectMap.get(course.subjectId) : null;
                const name = course?.aceAlias || course?.icceAlias || `Course ${e.courseId}`;
                const threshold = course?.passThreshold ? course.passThreshold * 100 : 80;
                const passed = (e.grade ?? 0) >= threshold;
                return (
                  <div key={e.id} className="flex items-center justify-between px-3 py-2.5 bg-background gap-3">
                    <div className="min-w-0">
                      <span className="text-sm font-medium truncate block">{name}</span>
                      <span className="text-xs text-muted-foreground">
                        PACE #{e.number}
                        {subject && ` · ${subject.subject}`}
                      </span>
                    </div>
                    <div className="flex items-center gap-2 flex-shrink-0">
                      <span className={`text-sm font-semibold tabular-nums ${gradeColor(e.grade ?? 0)}`}>
                        {formatGrade(e.grade)}
                      </span>
                      <Badge
                        variant={passed ? "default" : "destructive"}
                        className="text-xs px-1.5 py-0"
                      >
                        {passed ? "Pass" : "Fail"}
                      </Badge>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        )}

        {enrollments && recentResults.length === 0 && (
          <p className="text-sm text-muted-foreground py-3 text-center">
            No completed course results yet.
          </p>
        )}
      </CardContent>
    </Card>
  );
}

export default function ParentHomePage() {
  const { user } = useAuth();
  const { data: students, isLoading } = useQuery<Student[]>({ queryKey: ["/api/students"] });

  const now = new Date();
  const yearStart = now.getMonth() >= 7 ? now.getFullYear() : now.getFullYear() - 1;
  const academicYear = `${yearStart}–${String(yearStart + 1).slice(2)}`;

  return (
    <div className="min-h-full flex flex-col bg-background">
      {/* Formal school header */}
      <div className="border-b bg-card shadow-sm">
        <div className="max-w-3xl mx-auto px-4 sm:px-6 py-5">
          <div className="flex flex-col sm:flex-row sm:items-center gap-4">
            <img src={cederLogoPath} alt="de Ceder" className="h-10 w-auto object-contain" />
            <div className="sm:border-l sm:pl-4 sm:ml-1">
              <h1 className="text-lg font-serif font-bold tracking-tight leading-tight">
                Parent Portal
              </h1>
              <p className="text-xs text-muted-foreground mt-0.5">
                Academic year {academicYear}
                {user?.firstName && ` · Welcome, ${user.firstName}`}
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 max-w-3xl mx-auto w-full px-4 sm:px-6 py-6 space-y-5">
        <div className="flex items-center gap-1.5">
          <h2 className="text-base font-semibold">Academic overview</h2>
          <HelpTip
            content={
              <div className="space-y-1.5">
                <p>This page shows the academic progress for each of your children at de Ceder.</p>
                <p>Each card shows recent PACE results, a grade average, and links to the full Progress Chart and Term Report.</p>
              </div>
            }
            side="right"
          />
        </div>

        {isLoading && (
          <div className="space-y-4">
            <Skeleton className="h-56 w-full rounded-lg" />
            <Skeleton className="h-56 w-full rounded-lg" />
          </div>
        )}

        {students?.map((s) => <StudentCard key={s.id} student={s} />)}

        {!isLoading && students?.length === 0 && (
          <Card>
            <CardContent className="py-14 text-center">
              <BookOpen className="w-8 h-8 text-muted-foreground mx-auto mb-3" />
              <p className="text-sm text-muted-foreground">
                No students found for your family account.
                <br />
                Please contact the school administration if this is unexpected.
              </p>
            </CardContent>
          </Card>
        )}
      </div>

      <footer className="border-t">
        <div className="max-w-3xl mx-auto px-4 sm:px-6 py-3 text-xs text-muted-foreground">
          Internationale christelijke school de Ceder · Ceder School Management System
        </div>
      </footer>
    </div>
  );
}
