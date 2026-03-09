import { useQuery } from "@tanstack/react-query";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { useState, useMemo } from "react";
import type { Course, PaceCourse } from "@shared/schema";
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from "recharts";

export default function SPCPage() {
  const [selectedSubject, setSelectedSubject] = useState<string>("all");

  const { data: courses } = useQuery<Course[]>({ queryKey: ["/api/courses"] });
  const { data: paceCourses } = useQuery<PaceCourse[]>({ queryKey: ["/api/pace-courses"] });

  const uniqueSubjects = useMemo(() => {
    if (!courses) return [];
    const subjects = [...new Set(courses.filter(c => c.subjectTemp).map(c => c.subjectTemp!))];
    return subjects.sort();
  }, [courses]);

  const filteredCourses = useMemo(() => {
    if (!courses) return [];
    let filtered = courses;
    if (selectedSubject && selectedSubject !== "all") {
      filtered = filtered.filter(c => c.subjectTemp === selectedSubject);
    }
    return filtered;
  }, [courses, selectedSubject]);

  const courseStats = useMemo(() => {
    if (!filteredCourses || !paceCourses) return [];
    return filteredCourses.map(course => {
      const coursePCs = paceCourses.filter(pc => pc.courseId === course.id);
      const activePCs = coursePCs.filter(pc => pc.active === 1);
      const totalPaces = coursePCs.length;
      return {
        courseId: course.id,
        aceAlias: course.aceAlias || course.course || `Course ${course.id}`,
        icceAlias: course.icceAlias || null,
        certificateName: course.certificateName || null,
        subject: course.subjectTemp || "Unknown",
        subjectAbb: course.subjectAbb || "?",
        level: course.level,
        totalPaces,
        activePaces: activePCs.length,
        starValue: course.starValue || 0,
        passThreshold: course.passThreshold,
        paceRange: course.paceNrStart && course.paceNrEnd ? `${course.paceNrStart}-${course.paceNrEnd}` : "—",
      };
    });
  }, [filteredCourses, paceCourses]);

  const chartData = useMemo(() => {
    if (!courses || !paceCourses) return [];
    const subjectGroups = [...new Set(courses.filter(c => c.subjectTemp).map(c => c.subjectTemp!))];
    return subjectGroups.map(subject => {
      const subjectCourses = courses.filter(c => c.subjectTemp === subject);
      const totalPaces = subjectCourses.reduce((sum, c) => {
        return sum + paceCourses.filter(pc => pc.courseId === c.id).length;
      }, 0);
      const activePaces = subjectCourses.reduce((sum, c) => {
        return sum + paceCourses.filter(pc => pc.courseId === c.id && pc.active === 1).length;
      }, 0);
      return { subject, totalPaces, activePaces };
    }).sort((a, b) => b.totalPaces - a.totalPaces);
  }, [courses, paceCourses]);

  return (
    <div className="p-6 max-w-6xl mx-auto space-y-6">
      <div>
        <h1 className="text-2xl font-serif font-bold tracking-tight" data-testid="text-page-title">Student Progress Chart</h1>
        <p className="text-muted-foreground mt-1">Track PACE completion and course progress across subjects.</p>
      </div>

      <div className="flex flex-wrap items-end gap-4">
        <div className="space-y-1.5">
          <label className="text-sm font-medium">Subject</label>
          <Select value={selectedSubject} onValueChange={setSelectedSubject}>
            <SelectTrigger className="w-[180px]" data-testid="select-subject">
              <SelectValue placeholder="All subjects" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Subjects</SelectItem>
              {uniqueSubjects.map(s => (
                <SelectItem key={s} value={s}>{s}</SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      </div>

      <div className="grid sm:grid-cols-3 gap-4">
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Total Courses</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-3xl font-bold" data-testid="text-total-courses">{filteredCourses.length}</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Total PACEs Linked</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-3xl font-bold" data-testid="text-total-paces">
              {courseStats.reduce((s, c) => s + c.totalPaces, 0)}
            </p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Active PACEs</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-3xl font-bold text-emerald-600 dark:text-emerald-400" data-testid="text-active-paces">
              {courseStats.reduce((s, c) => s + c.activePaces, 0)}
            </p>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle className="text-base">PACEs by Subject</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="h-72">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={chartData} margin={{ top: 5, right: 10, left: -10, bottom: 5 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
                <XAxis dataKey="subject" tick={{ fontSize: 11 }} stroke="hsl(var(--muted-foreground))" angle={-20} textAnchor="end" height={60} />
                <YAxis tick={{ fontSize: 12 }} stroke="hsl(var(--muted-foreground))" />
                <Tooltip
                  contentStyle={{
                    backgroundColor: "hsl(var(--card))",
                    border: "1px solid hsl(var(--border))",
                    borderRadius: "6px",
                    fontSize: "12px",
                  }}
                />
                <Bar dataKey="totalPaces" name="Total PACEs" fill="hsl(var(--chart-1))" radius={[2, 2, 0, 0]} />
                <Bar dataKey="activePaces" name="Active PACEs" fill="hsl(var(--chart-5))" radius={[2, 2, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="text-base">Course Details</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="overflow-x-auto">
            <table className="w-full text-sm" data-testid="table-courses">
              <thead>
                <tr className="border-b">
                  <th className="text-left py-3 px-2 font-medium text-muted-foreground">ACE Name</th>
                  <th className="text-left py-3 px-2 font-medium text-muted-foreground">ICCE Name</th>
                  <th className="text-left py-3 px-2 font-medium text-muted-foreground">Certificate Name</th>
                  <th className="text-center py-3 px-2 font-medium text-muted-foreground">Subject</th>
                  <th className="text-center py-3 px-2 font-medium text-muted-foreground">Level</th>
                  <th className="text-center py-3 px-2 font-medium text-muted-foreground">PACE Range</th>
                  <th className="text-center py-3 px-2 font-medium text-muted-foreground">Stars</th>
                  <th className="text-center py-3 px-2 font-medium text-muted-foreground">PACEs</th>
                  <th className="text-center py-3 px-2 font-medium text-muted-foreground">Active</th>
                  <th className="text-center py-3 px-2 font-medium text-muted-foreground">Pass %</th>
                </tr>
              </thead>
              <tbody>
                {courseStats.slice(0, 50).map(cs => (
                  <tr key={cs.courseId} className="border-b last:border-0" data-testid={`row-course-${cs.courseId}`}>
                    <td className="py-3 px-2 font-medium">{cs.aceAlias}</td>
                    <td className="py-3 px-2 text-muted-foreground">{cs.icceAlias && cs.icceAlias !== cs.aceAlias ? cs.icceAlias : "—"}</td>
                    <td className="py-3 px-2 text-muted-foreground">{cs.certificateName && cs.certificateName !== cs.aceAlias ? cs.certificateName : "—"}</td>
                    <td className="text-center py-3 px-2">
                      <Badge variant="secondary">{cs.subjectAbb}</Badge>
                    </td>
                    <td className="text-center py-3 px-2 text-muted-foreground">{cs.level ?? "—"}</td>
                    <td className="text-center py-3 px-2 text-muted-foreground">{cs.paceRange}</td>
                    <td className="text-center py-3 px-2 text-muted-foreground">{cs.starValue}</td>
                    <td className="text-center py-3 px-2">{cs.totalPaces}</td>
                    <td className="text-center py-3 px-2">
                      <span className="text-emerald-600 dark:text-emerald-400 font-medium">{cs.activePaces}</span>
                    </td>
                    <td className="text-center py-3 px-2 text-muted-foreground">
                      {cs.passThreshold ? `${Math.round(cs.passThreshold * 100)}%` : "—"}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
            {courseStats.length > 50 && (
              <p className="text-sm text-muted-foreground text-center py-3">
                Showing 50 of {courseStats.length} courses. Use the subject filter to narrow results.
              </p>
            )}
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
