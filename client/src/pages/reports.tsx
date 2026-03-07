import { useQuery } from "@tanstack/react-query";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { Separator } from "@/components/ui/separator";
import { useState, useMemo } from "react";
import type { Student, Course, DateEntry, PaceCourse } from "@shared/schema";
import { GraduationCap, Calendar } from "lucide-react";

export default function ReportsPage() {
  const [selectedStudent, setSelectedStudent] = useState<string>("");
  const [selectedTerm, setSelectedTerm] = useState<string>("");

  const { data: students } = useQuery<Student[]>({ queryKey: ["/api/students"] });
  const { data: courses } = useQuery<Course[]>({ queryKey: ["/api/courses"] });
  const { data: dates } = useQuery<DateEntry[]>({ queryKey: ["/api/dates"] });
  const { data: paceCourses } = useQuery<PaceCourse[]>({ queryKey: ["/api/pace-courses"] });

  const student = students?.find(s => s.id === parseInt(selectedStudent));

  const uniqueTerms = useMemo(() => {
    if (!dates) return [];
    const terms = [...new Set(dates.filter(d => d.term != null).map(d => d.term!))];
    return terms.sort((a, b) => a - b);
  }, [dates]);

  const termDates = useMemo(() => {
    if (!dates || !selectedTerm) return [];
    return dates.filter(d => d.term === parseInt(selectedTerm));
  }, [dates, selectedTerm]);

  const termInfo = useMemo(() => {
    if (termDates.length === 0) return null;
    const schoolDays = termDates.filter(d => !d.dayOff);
    const holidays = termDates.filter(d => d.holiday && !d.weekend);
    const weekends = termDates.filter(d => d.weekend);
    const weeks = [...new Set(termDates.map(d => d.termWeek).filter(w => w != null))];
    return {
      totalDays: termDates.length,
      schoolDays: schoolDays.length,
      holidays: holidays.length,
      weekends: weekends.length,
      weeks: weeks.length,
    };
  }, [termDates]);

  const subjectGroups = useMemo(() => {
    if (!courses || !paceCourses) return [];
    const groups = [...new Set(courses.filter(c => c.subjectGroup).map(c => c.subjectGroup!))];
    return groups.map(group => {
      const groupCourses = courses.filter(c => c.subjectGroup === group);
      const totalPaces = groupCourses.reduce((sum, c) => {
        return sum + paceCourses.filter(pc => pc.courseId === c.id).length;
      }, 0);
      const activePaces = groupCourses.reduce((sum, c) => {
        return sum + paceCourses.filter(pc => pc.courseId === c.id && pc.active === 1).length;
      }, 0);
      return { group, courses: groupCourses.length, totalPaces, activePaces };
    });
  }, [courses, paceCourses]);

  return (
    <div className="p-6 max-w-4xl mx-auto space-y-6">
      <div>
        <h1 className="text-2xl font-serif font-bold tracking-tight" data-testid="text-page-title">Term Reports</h1>
        <p className="text-muted-foreground mt-1">View term schedules and course progress reports.</p>
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
                  {s.callName} {s.surname}
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
              {uniqueTerms.map(t => (
                <SelectItem key={t} value={t.toString()}>Term {t}</SelectItem>
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
        <div className="space-y-6" id="report-container">
          <Card>
            <CardContent className="p-8">
              <div className="text-center space-y-2 mb-8">
                <div className="flex justify-center mb-4">
                  <GraduationCap className="w-8 h-8 text-primary" />
                </div>
                <h2 className="text-xl font-serif font-bold" data-testid="text-report-title">
                  Term {selectedTerm} Report
                </h2>
                <p className="text-muted-foreground text-sm">School Year Overview</p>
              </div>

              <Separator className="my-6" />

              <div className="grid sm:grid-cols-2 gap-6 mb-8">
                <div className="space-y-3">
                  <div className="flex items-center gap-2 text-sm">
                    <span className="text-muted-foreground w-24">Student:</span>
                    <span className="font-medium" data-testid="text-report-student">
                      {student?.firstNames || student?.callName} {student?.surname}
                    </span>
                  </div>
                  <div className="flex items-center gap-2 text-sm">
                    <span className="text-muted-foreground w-24">Call Name:</span>
                    <span className="font-medium">{student?.callName}</span>
                  </div>
                </div>
                <div className="space-y-3">
                  {termInfo && (
                    <>
                      <div className="flex items-center gap-2 text-sm">
                        <Calendar className="w-4 h-4 text-muted-foreground" />
                        <span className="text-muted-foreground">School Days:</span>
                        <span className="font-medium">{termInfo.schoolDays}</span>
                      </div>
                      <div className="flex items-center gap-2 text-sm">
                        <Calendar className="w-4 h-4 text-muted-foreground" />
                        <span className="text-muted-foreground">Term Weeks:</span>
                        <span className="font-medium">{termInfo.weeks}</span>
                      </div>
                    </>
                  )}
                </div>
              </div>

              <h3 className="font-semibold mb-4">Course Progress by Subject Group</h3>
              <div className="overflow-x-auto">
                <table className="w-full text-sm" data-testid="table-report">
                  <thead>
                    <tr className="border-b bg-muted/30">
                      <th className="text-left py-3 px-4 font-semibold">Subject Group</th>
                      <th className="text-center py-3 px-4 font-semibold">Courses</th>
                      <th className="text-center py-3 px-4 font-semibold">Total PACEs</th>
                      <th className="text-center py-3 px-4 font-semibold">Active PACEs</th>
                    </tr>
                  </thead>
                  <tbody>
                    {subjectGroups.map(sg => (
                      <tr key={sg.group} className="border-b last:border-0">
                        <td className="py-3 px-4 font-medium">{sg.group}</td>
                        <td className="text-center py-3 px-4">{sg.courses}</td>
                        <td className="text-center py-3 px-4">{sg.totalPaces}</td>
                        <td className="text-center py-3 px-4">
                          <Badge variant={sg.activePaces > 0 ? "default" : "secondary"}>
                            {sg.activePaces}
                          </Badge>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                  <tfoot>
                    <tr className="bg-muted/30 font-semibold">
                      <td className="py-3 px-4">Total</td>
                      <td className="text-center py-3 px-4">{subjectGroups.reduce((s, g) => s + g.courses, 0)}</td>
                      <td className="text-center py-3 px-4">{subjectGroups.reduce((s, g) => s + g.totalPaces, 0)}</td>
                      <td className="text-center py-3 px-4">{subjectGroups.reduce((s, g) => s + g.activePaces, 0)}</td>
                    </tr>
                  </tfoot>
                </table>
              </div>
            </CardContent>
          </Card>
        </div>
      )}
    </div>
  );
}
