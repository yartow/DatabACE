import { useQuery } from "@tanstack/react-query";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Skeleton } from "@/components/ui/skeleton";
import { useState } from "react";
import type { Student, Subject, Term, Grade } from "@shared/schema";
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend, LineChart, Line } from "recharts";

export default function SPCPage() {
  const [selectedStudent, setSelectedStudent] = useState<string>("");
  const [selectedTerm, setSelectedTerm] = useState<string>("");

  const { data: students, isLoading: studentsLoading } = useQuery<Student[]>({ queryKey: ["/api/students"] });
  const { data: subjects } = useQuery<Subject[]>({ queryKey: ["/api/subjects"] });
  const { data: terms } = useQuery<Term[]>({ queryKey: ["/api/terms"] });
  const { data: allGrades } = useQuery<Grade[]>({ queryKey: ["/api/grades"] });

  const student = students?.find(s => s.id === parseInt(selectedStudent));
  const studentGrades = allGrades?.filter(g => g.studentId === parseInt(selectedStudent)) || [];
  const filteredGrades = selectedTerm
    ? studentGrades.filter(g => g.termId === parseInt(selectedTerm))
    : studentGrades;

  const subjectMap = new Map(subjects?.map(s => [s.id, s]) || []);
  const termMap = new Map(terms?.map(t => [t.id, t]) || []);

  const chartData = subjects?.map(sub => {
    const entry: any = { subject: sub.code };
    terms?.forEach(term => {
      const grade = studentGrades.find(g => g.subjectId === sub.id && g.termId === term.id);
      entry[term.name] = grade?.score || 0;
    });
    return entry;
  }) || [];

  const progressData = terms?.map(term => {
    const termGrades = studentGrades.filter(g => g.termId === term.id);
    const avg = termGrades.length > 0
      ? Math.round(termGrades.reduce((sum, g) => sum + g.score, 0) / termGrades.length)
      : 0;
    return { term: term.name, average: avg };
  }) || [];

  const overallAvg = filteredGrades.length > 0
    ? Math.round(filteredGrades.reduce((sum, g) => sum + g.score, 0) / filteredGrades.length)
    : 0;

  const getScoreColor = (score: number) => {
    if (score >= 80) return "text-emerald-600 dark:text-emerald-400";
    if (score >= 60) return "text-amber-600 dark:text-amber-400";
    return "text-red-600 dark:text-red-400";
  };

  const getScoreBg = (score: number) => {
    if (score >= 80) return "bg-emerald-500/20";
    if (score >= 60) return "bg-amber-500/20";
    return "bg-red-500/20";
  };

  return (
    <div className="p-6 max-w-6xl mx-auto space-y-6">
      <div>
        <h1 className="text-2xl font-serif font-bold tracking-tight" data-testid="text-page-title">Student Progress Chart</h1>
        <p className="text-muted-foreground mt-1">Track academic performance across subjects and terms.</p>
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
              <SelectValue placeholder="All terms" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Terms</SelectItem>
              {terms?.map(t => (
                <SelectItem key={t.id} value={t.id.toString()}>
                  {t.name} ({t.year})
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      </div>

      {!selectedStudent ? (
        <Card>
          <CardContent className="py-16 text-center">
            <p className="text-muted-foreground">Select a student to view their progress chart.</p>
          </CardContent>
        </Card>
      ) : studentsLoading ? (
        <div className="space-y-4">
          <Skeleton className="h-64" />
          <Skeleton className="h-48" />
        </div>
      ) : (
        <>
          <div className="grid sm:grid-cols-3 gap-4">
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground">Overall Average</CardTitle>
              </CardHeader>
              <CardContent>
                <p className={`text-3xl font-bold ${getScoreColor(overallAvg)}`} data-testid="text-overall-avg">{overallAvg}%</p>
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground">Subjects</CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-3xl font-bold" data-testid="text-subject-count">{subjects?.length || 0}</p>
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground">Student</CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-lg font-semibold" data-testid="text-selected-student">{student?.firstName} {student?.lastName}</p>
                <p className="text-sm text-muted-foreground">{student?.classGroup}</p>
              </CardContent>
            </Card>
          </div>

          <div className="grid lg:grid-cols-2 gap-6">
            <Card>
              <CardHeader>
                <CardTitle className="text-base">Scores by Subject</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="h-72">
                  <ResponsiveContainer width="100%" height="100%">
                    <BarChart data={chartData} margin={{ top: 5, right: 10, left: -10, bottom: 5 }}>
                      <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
                      <XAxis dataKey="subject" tick={{ fontSize: 12 }} stroke="hsl(var(--muted-foreground))" />
                      <YAxis domain={[0, 100]} tick={{ fontSize: 12 }} stroke="hsl(var(--muted-foreground))" />
                      <Tooltip
                        contentStyle={{
                          backgroundColor: "hsl(var(--card))",
                          border: "1px solid hsl(var(--border))",
                          borderRadius: "6px",
                          fontSize: "12px",
                        }}
                      />
                      <Legend wrapperStyle={{ fontSize: "12px" }} />
                      {terms?.map((term, i) => (
                        <Bar key={term.id} dataKey={term.name} fill={`hsl(var(--chart-${(i % 5) + 1}))`} radius={[2, 2, 0, 0]} />
                      ))}
                    </BarChart>
                  </ResponsiveContainer>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="text-base">Average Progress Over Terms</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="h-72">
                  <ResponsiveContainer width="100%" height="100%">
                    <LineChart data={progressData} margin={{ top: 5, right: 10, left: -10, bottom: 5 }}>
                      <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
                      <XAxis dataKey="term" tick={{ fontSize: 12 }} stroke="hsl(var(--muted-foreground))" />
                      <YAxis domain={[0, 100]} tick={{ fontSize: 12 }} stroke="hsl(var(--muted-foreground))" />
                      <Tooltip
                        contentStyle={{
                          backgroundColor: "hsl(var(--card))",
                          border: "1px solid hsl(var(--border))",
                          borderRadius: "6px",
                          fontSize: "12px",
                        }}
                      />
                      <Line type="monotone" dataKey="average" stroke="hsl(var(--primary))" strokeWidth={2} dot={{ r: 4 }} />
                    </LineChart>
                  </ResponsiveContainer>
                </div>
              </CardContent>
            </Card>
          </div>

          <Card>
            <CardHeader>
              <CardTitle className="text-base">Detailed Scores</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="overflow-x-auto">
                <table className="w-full text-sm" data-testid="table-grades">
                  <thead>
                    <tr className="border-b">
                      <th className="text-left py-3 px-2 font-medium text-muted-foreground">Subject</th>
                      {selectedTerm && selectedTerm !== "all"
                        ? <th className="text-center py-3 px-2 font-medium text-muted-foreground">Score</th>
                        : terms?.map(t => (
                          <th key={t.id} className="text-center py-3 px-2 font-medium text-muted-foreground">{t.name}</th>
                        ))}
                      <th className="text-center py-3 px-2 font-medium text-muted-foreground">Average</th>
                    </tr>
                  </thead>
                  <tbody>
                    {subjects?.map(sub => {
                      const subGrades = studentGrades.filter(g => g.subjectId === sub.id);
                      const avg = subGrades.length > 0
                        ? Math.round(subGrades.reduce((s, g) => s + g.score, 0) / subGrades.length)
                        : 0;
                      return (
                        <tr key={sub.id} className="border-b last:border-0">
                          <td className="py-3 px-2 font-medium">{sub.name}</td>
                          {selectedTerm && selectedTerm !== "all"
                            ? (() => {
                                const grade = subGrades.find(g => g.termId === parseInt(selectedTerm));
                                return (
                                  <td className="text-center py-3 px-2">
                                    {grade ? (
                                      <span className={`inline-flex items-center justify-center w-12 h-7 rounded-md text-sm font-medium ${getScoreBg(grade.score)} ${getScoreColor(grade.score)}`}>
                                        {grade.score}
                                      </span>
                                    ) : <span className="text-muted-foreground">—</span>}
                                  </td>
                                );
                              })()
                            : terms?.map(t => {
                                const grade = subGrades.find(g => g.termId === t.id);
                                return (
                                  <td key={t.id} className="text-center py-3 px-2">
                                    {grade ? (
                                      <span className={`inline-flex items-center justify-center w-12 h-7 rounded-md text-sm font-medium ${getScoreBg(grade.score)} ${getScoreColor(grade.score)}`}>
                                        {grade.score}
                                      </span>
                                    ) : <span className="text-muted-foreground">—</span>}
                                  </td>
                                );
                              })}
                          <td className="text-center py-3 px-2">
                            <span className={`font-semibold ${getScoreColor(avg)}`}>{avg}%</span>
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            </CardContent>
          </Card>
        </>
      )}
    </div>
  );
}
