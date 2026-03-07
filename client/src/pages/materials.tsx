import { useQuery } from "@tanstack/react-query";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useState, useMemo } from "react";
import type { Course, Pace, PaceCourse } from "@shared/schema";
import { BookOpen, Package, CheckCircle2, XCircle } from "lucide-react";

export default function MaterialsPage() {
  const [selectedSubject, setSelectedSubject] = useState<string>("all");
  const [selectedCourse, setSelectedCourse] = useState<string>("all");

  const { data: courses } = useQuery<Course[]>({ queryKey: ["/api/courses"] });
  const { data: allPaces } = useQuery<Pace[]>({ queryKey: ["/api/paces"] });
  const { data: paceCourses } = useQuery<PaceCourse[]>({ queryKey: ["/api/pace-courses"] });

  const uniqueSubjects = useMemo(() => {
    if (!courses) return [];
    return [...new Set(courses.filter(c => c.subjectTemp).map(c => c.subjectTemp!))].sort();
  }, [courses]);

  const filteredCourses = useMemo(() => {
    if (!courses) return [];
    if (selectedSubject === "all") return courses;
    return courses.filter(c => c.subjectTemp === selectedSubject);
  }, [courses, selectedSubject]);

  const activePaceCourses = useMemo(() => {
    if (!paceCourses) return [];
    return paceCourses.filter(pc => pc.active === 1);
  }, [paceCourses]);

  const inactivePaceCourses = useMemo(() => {
    if (!paceCourses) return [];
    return paceCourses.filter(pc => pc.active === 0);
  }, [paceCourses]);

  const courseMap = useMemo(() => {
    return new Map(courses?.map(c => [c.id, c]) || []);
  }, [courses]);

  const paceMap = useMemo(() => {
    return new Map(allPaces?.map(p => [p.id, p]) || []);
  }, [allPaces]);

  const displayPaceCourses = useMemo(() => {
    if (!paceCourses) return [];
    let filtered = paceCourses;
    if (selectedSubject !== "all") {
      const courseIds = new Set(filteredCourses.map(c => c.id));
      filtered = filtered.filter(pc => courseIds.has(pc.courseId));
    }
    if (selectedCourse !== "all") {
      filtered = filtered.filter(pc => pc.courseId === parseInt(selectedCourse));
    }
    return filtered;
  }, [paceCourses, selectedSubject, selectedCourse, filteredCourses]);

  return (
    <div className="p-6 max-w-6xl mx-auto space-y-6">
      <div>
        <h1 className="text-2xl font-serif font-bold tracking-tight" data-testid="text-page-title">Courses & PACEs</h1>
        <p className="text-muted-foreground mt-1">Browse courses, PACEs, and their active status.</p>
      </div>

      <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between gap-1 space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Total Courses</CardTitle>
            <BookOpen className="w-4 h-4 text-chart-1" />
          </CardHeader>
          <CardContent>
            <p className="text-2xl font-bold" data-testid="text-total-courses">{courses?.length || 0}</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between gap-1 space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Total PACEs</CardTitle>
            <Package className="w-4 h-4 text-chart-2" />
          </CardHeader>
          <CardContent>
            <p className="text-2xl font-bold" data-testid="text-total-paces">{allPaces?.length || 0}</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between gap-1 space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Active PACE-Courses</CardTitle>
            <CheckCircle2 className="w-4 h-4 text-emerald-500" />
          </CardHeader>
          <CardContent>
            <p className="text-2xl font-bold text-emerald-600 dark:text-emerald-400" data-testid="text-active">{activePaceCourses.length}</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between gap-1 space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Inactive PACE-Courses</CardTitle>
            <XCircle className="w-4 h-4 text-red-500" />
          </CardHeader>
          <CardContent>
            <p className="text-2xl font-bold" data-testid="text-inactive">{inactivePaceCourses.length}</p>
          </CardContent>
        </Card>
      </div>

      <div className="flex flex-wrap items-end gap-4">
        <div className="space-y-1.5">
          <label className="text-sm font-medium">Subject</label>
          <Select value={selectedSubject} onValueChange={(v) => { setSelectedSubject(v); setSelectedCourse("all"); }}>
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
        <div className="space-y-1.5">
          <label className="text-sm font-medium">Course</label>
          <Select value={selectedCourse} onValueChange={setSelectedCourse}>
            <SelectTrigger className="w-[250px]" data-testid="select-course">
              <SelectValue placeholder="All courses" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Courses</SelectItem>
              {filteredCourses.map(c => (
                <SelectItem key={c.id} value={c.id.toString()}>
                  {c.course || c.aceAlias || `Course ${c.id}`}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      </div>

      <Tabs defaultValue="pace-courses" className="space-y-4">
        <TabsList>
          <TabsTrigger value="pace-courses" data-testid="tab-pace-courses">PACE-Course Links</TabsTrigger>
          <TabsTrigger value="courses" data-testid="tab-courses">Courses</TabsTrigger>
        </TabsList>

        <TabsContent value="pace-courses">
          <Card>
            <CardHeader>
              <CardTitle className="text-base">
                PACE-Course Links ({displayPaceCourses.length})
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="overflow-x-auto">
                <table className="w-full text-sm" data-testid="table-pace-courses">
                  <thead>
                    <tr className="border-b">
                      <th className="text-left py-3 px-2 font-medium text-muted-foreground">ID</th>
                      <th className="text-left py-3 px-2 font-medium text-muted-foreground">Code</th>
                      <th className="text-left py-3 px-2 font-medium text-muted-foreground">Course</th>
                      <th className="text-center py-3 px-2 font-medium text-muted-foreground">PACE #</th>
                      <th className="text-center py-3 px-2 font-medium text-muted-foreground">Credit</th>
                      <th className="text-center py-3 px-2 font-medium text-muted-foreground">Pass %</th>
                      <th className="text-center py-3 px-2 font-medium text-muted-foreground">Active</th>
                    </tr>
                  </thead>
                  <tbody>
                    {displayPaceCourses.slice(0, 100).map(pc => {
                      const course = courseMap.get(pc.courseId);
                      return (
                        <tr key={pc.id} className="border-b last:border-0">
                          <td className="py-2 px-2 text-muted-foreground font-mono text-xs">{pc.id}</td>
                          <td className="py-2 px-2 font-mono text-xs">{pc.code || "—"}</td>
                          <td className="py-2 px-2 font-medium text-xs">
                            {course?.course || course?.aceAlias || `#${pc.courseId}`}
                          </td>
                          <td className="text-center py-2 px-2">{pc.number ?? "—"}</td>
                          <td className="text-center py-2 px-2">{pc.creditValuePace ?? "—"}</td>
                          <td className="text-center py-2 px-2 text-muted-foreground">
                            {pc.passThreshold != null ? `${Math.round(pc.passThreshold * 100)}%` : "—"}
                          </td>
                          <td className="text-center py-2 px-2">
                            <Badge variant={pc.active === 1 ? "default" : "secondary"}>
                              {pc.active === 1 ? "Active" : "Inactive"}
                            </Badge>
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
                {displayPaceCourses.length > 100 && (
                  <p className="text-sm text-muted-foreground text-center py-3">
                    Showing 100 of {displayPaceCourses.length}. Use filters to narrow results.
                  </p>
                )}
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="courses">
          <Card>
            <CardHeader>
              <CardTitle className="text-base">Courses ({filteredCourses.length})</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="overflow-x-auto">
                <table className="w-full text-sm" data-testid="table-courses-list">
                  <thead>
                    <tr className="border-b">
                      <th className="text-left py-3 px-2 font-medium text-muted-foreground">Course</th>
                      <th className="text-center py-3 px-2 font-medium text-muted-foreground">Subject</th>
                      <th className="text-center py-3 px-2 font-medium text-muted-foreground">Group</th>
                      <th className="text-center py-3 px-2 font-medium text-muted-foreground">Level</th>
                      <th className="text-center py-3 px-2 font-medium text-muted-foreground">Type</th>
                      <th className="text-center py-3 px-2 font-medium text-muted-foreground">Stars</th>
                      <th className="text-center py-3 px-2 font-medium text-muted-foreground">Pass %</th>
                    </tr>
                  </thead>
                  <tbody>
                    {filteredCourses.map(c => (
                      <tr key={c.id} className="border-b last:border-0">
                        <td className="py-3 px-2 font-medium">{c.course || c.aceAlias || `Course ${c.id}`}</td>
                        <td className="text-center py-3 px-2">
                          <Badge variant="secondary">{c.subjectAbb || "—"}</Badge>
                        </td>
                        <td className="text-center py-3 px-2 text-muted-foreground text-xs">{c.subjectGroup || "—"}</td>
                        <td className="text-center py-3 px-2">{c.level ?? "—"}</td>
                        <td className="text-center py-3 px-2 text-muted-foreground">{c.courseType || "—"}</td>
                        <td className="text-center py-3 px-2">{c.starValue ?? "—"}</td>
                        <td className="text-center py-3 px-2 text-muted-foreground">
                          {c.passThreshold != null ? `${Math.round(c.passThreshold * 100)}%` : "—"}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
