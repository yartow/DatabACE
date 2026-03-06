import { useQuery } from "@tanstack/react-query";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Skeleton } from "@/components/ui/skeleton";
import { Badge } from "@/components/ui/badge";
import { Separator } from "@/components/ui/separator";
import { useState } from "react";
import type { Student, Subject, Term, Grade } from "@shared/schema";
import { GraduationCap, Calendar, Award } from "lucide-react";

export default function ReportsPage() {
  const [selectedStudent, setSelectedStudent] = useState<string>("");
  const [selectedTerm, setSelectedTerm] = useState<string>("");

  const { data: students } = useQuery<Student[]>({ queryKey: ["/api/students"] });
  const { data: subjects } = useQuery<Subject[]>({ queryKey: ["/api/subjects"] });
  const { data: terms } = useQuery<Term[]>({ queryKey: ["/api/terms"] });
  const { data: allGrades } = useQuery<Grade[]>({ queryKey: ["/api/grades"] });

  const student = students?.find(s => s.id === parseInt(selectedStudent));
  const term = terms?.find(t => t.id === parseInt(selectedTerm));

  const reportGrades = allGrades?.filter(
    g => g.studentId === parseInt(selectedStudent) && g.termId === parseInt(selectedTerm)
  ) || [];

  const subjectMap = new Map(subjects?.map(s => [s.id, s]) || []);

  const overallAvg = reportGrades.length > 0
    ? Math.round(reportGrades.reduce((sum, g) => sum + g.score, 0) / reportGrades.length)
    : 0;

  const getGradeLabel = (score: number) => {
    if (score >= 90) return "A+";
    if (score >= 80) return "A";
    if (score >= 70) return "B";
    if (score >= 60) return "C";
    if (score >= 50) return "D";
    return "F";
  };

  const getScoreColor = (score: number) => {
    if (score >= 80) return "text-emerald-600 dark:text-emerald-400";
    if (score >= 60) return "text-amber-600 dark:text-amber-400";
    return "text-red-600 dark:text-red-400";
  };

  const getGradeBadgeVariant = (score: number): "default" | "secondary" | "destructive" => {
    if (score >= 70) return "default";
    if (score >= 50) return "secondary";
    return "destructive";
  };

  return (
    <div className="p-6 max-w-4xl mx-auto space-y-6">
      <div>
        <h1 className="text-2xl font-serif font-bold tracking-tight" data-testid="text-page-title">Term Reports</h1>
        <p className="text-muted-foreground mt-1">View and print student reports for each school term.</p>
      </div>

      <div className="flex flex-wrap items-end gap-4">
        <div className="space-y-1.5">
          <label className="text-sm font-medium">Student</label>
          <Select value={selectedStudent} onValueChange={setSelectedStudent}>
            <SelectTrigger className="w-[220px]" data-testid="select-student">
              <SelectValue placeholder="Select a student" />
            </SelectTrigger>
            <SelectContent>
              {students?.map(s => (
                <SelectItem key={s.id} value={s.id.toString()}>
                  {s.firstName} {s.lastName}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
        <div className="space-y-1.5">
          <label className="text-sm font-medium">Term</label>
          <Select value={selectedTerm} onValueChange={setSelectedTerm}>
            <SelectTrigger className="w-[180px]" data-testid="select-term">
              <SelectValue placeholder="Select a term" />
            </SelectTrigger>
            <SelectContent>
              {terms?.map(t => (
                <SelectItem key={t.id} value={t.id.toString()}>
                  {t.name} ({t.year})
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      </div>

      {!selectedStudent || !selectedTerm ? (
        <Card>
          <CardContent className="py-16 text-center">
            <p className="text-muted-foreground">Select a student and term to view the report.</p>
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-6 print:space-y-4" id="report-container">
          <Card className="print:shadow-none print:border-2">
            <CardContent className="p-8">
              <div className="text-center space-y-2 mb-8">
                <div className="flex items-center justify-center gap-3 mb-4">
                  <GraduationCap className="w-8 h-8 text-primary" />
                </div>
                <h2 className="text-xl font-serif font-bold" data-testid="text-report-title">
                  School Report Card
                </h2>
                <p className="text-muted-foreground text-sm">
                  {term?.name} {term?.year}
                </p>
              </div>

              <Separator className="my-6" />

              <div className="grid sm:grid-cols-2 gap-6 mb-8">
                <div className="space-y-3">
                  <div className="flex items-center gap-2 text-sm">
                    <span className="text-muted-foreground w-24">Student:</span>
                    <span className="font-medium" data-testid="text-report-student">
                      {student?.firstName} {student?.lastName}
                    </span>
                  </div>
                  <div className="flex items-center gap-2 text-sm">
                    <span className="text-muted-foreground w-24">Class:</span>
                    <span className="font-medium">{student?.classGroup || "—"}</span>
                  </div>
                </div>
                <div className="space-y-3">
                  <div className="flex items-center gap-2 text-sm">
                    <Calendar className="w-4 h-4 text-muted-foreground" />
                    <span className="text-muted-foreground">Period:</span>
                    <span className="font-medium">
                      {term?.startDate || "—"} to {term?.endDate || "—"}
                    </span>
                  </div>
                  <div className="flex items-center gap-2 text-sm">
                    <Award className="w-4 h-4 text-muted-foreground" />
                    <span className="text-muted-foreground">Overall:</span>
                    <span className={`font-bold ${getScoreColor(overallAvg)}`}>
                      {overallAvg}% ({getGradeLabel(overallAvg)})
                    </span>
                  </div>
                </div>
              </div>

              <div className="overflow-x-auto">
                <table className="w-full text-sm" data-testid="table-report">
                  <thead>
                    <tr className="border-b bg-muted/30">
                      <th className="text-left py-3 px-4 font-semibold">Subject</th>
                      <th className="text-center py-3 px-4 font-semibold">Score</th>
                      <th className="text-center py-3 px-4 font-semibold">Grade</th>
                      <th className="text-left py-3 px-4 font-semibold">Comment</th>
                    </tr>
                  </thead>
                  <tbody>
                    {reportGrades.length > 0 ? (
                      reportGrades.map(grade => {
                        const subject = subjectMap.get(grade.subjectId);
                        return (
                          <tr key={grade.id} className="border-b last:border-0">
                            <td className="py-3 px-4 font-medium">{subject?.name || "Unknown"}</td>
                            <td className="text-center py-3 px-4">
                              <span className={`font-semibold ${getScoreColor(grade.score)}`}>
                                {grade.score}/{grade.maxScore}
                              </span>
                            </td>
                            <td className="text-center py-3 px-4">
                              <Badge variant={getGradeBadgeVariant(grade.score)}>
                                {getGradeLabel(grade.score)}
                              </Badge>
                            </td>
                            <td className="py-3 px-4 text-muted-foreground">{grade.comment || "—"}</td>
                          </tr>
                        );
                      })
                    ) : (
                      <tr>
                        <td colSpan={4} className="text-center py-8 text-muted-foreground">
                          No grades recorded for this term.
                        </td>
                      </tr>
                    )}
                  </tbody>
                  {reportGrades.length > 0 && (
                    <tfoot>
                      <tr className="bg-muted/30 font-semibold">
                        <td className="py-3 px-4">Overall Average</td>
                        <td className="text-center py-3 px-4">
                          <span className={getScoreColor(overallAvg)}>{overallAvg}%</span>
                        </td>
                        <td className="text-center py-3 px-4">
                          <Badge variant={getGradeBadgeVariant(overallAvg)}>
                            {getGradeLabel(overallAvg)}
                          </Badge>
                        </td>
                        <td className="py-3 px-4"></td>
                      </tr>
                    </tfoot>
                  )}
                </table>
              </div>
            </CardContent>
          </Card>
        </div>
      )}
    </div>
  );
}
