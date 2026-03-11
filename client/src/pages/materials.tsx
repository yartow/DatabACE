import { useQuery, useMutation } from "@tanstack/react-query";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { useState, useMemo } from "react";
import type { Course, Pace, PaceCourse, UserProfile } from "@shared/schema";
import { BookOpen, Package, CheckCircle2, XCircle, Pencil, Check, X } from "lucide-react";
import { apiRequest, queryClient } from "@/lib/queryClient";
import { useToast } from "@/hooks/use-toast";

function EditableCourseRow({ c, onCancel, onSaved }: { c: Course; onCancel: () => void; onSaved: () => void }) {
  const { toast } = useToast();
  const [course, setCourse] = useState(c.course || "");
  const [level, setLevel] = useState(c.level?.toString() || "");
  const [starValue, setStarValue] = useState(c.starValue?.toString() || "");
  const [passThreshold, setPassThreshold] = useState(c.passThreshold != null ? Math.round(c.passThreshold * 100).toString() : "");
  const [courseType, setCourseType] = useState(c.courseType || "");
  const [remarks, setRemarks] = useState(c.remarks || "");

  const mutation = useMutation({
    mutationFn: async () => {
      await apiRequest("PATCH", `/api/courses/${c.id}`, {
        course: course || null,
        level: level ? parseInt(level) : null,
        starValue: starValue ? parseInt(starValue) : null,
        passThreshold: passThreshold ? parseFloat(passThreshold) / 100 : null,
        courseType: courseType || null,
        remarks: remarks || null,
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/courses"] });
      toast({ title: "Course updated" });
      onSaved();
    },
    onError: (err: Error) => toast({ title: "Failed", description: err.message, variant: "destructive" }),
  });

  return (
    <tr className="border-b bg-muted/20" data-testid={`row-course-edit-${c.id}`}>
      <td className="py-2 px-2">
        <Input value={course} onChange={e => setCourse(e.target.value)} className="h-7 text-xs" data-testid="input-edit-course-name" />
      </td>
      <td className="text-center py-2 px-2">
        <Badge variant="secondary">{c.subjectAbb || "—"}</Badge>
      </td>
      <td className="text-center py-2 px-2 text-muted-foreground text-xs">{c.subjectGroup || "—"}</td>
      <td className="text-center py-2 px-2">
        <Input value={level} onChange={e => setLevel(e.target.value)} className="h-7 w-16 text-xs text-center mx-auto" data-testid="input-edit-course-level" />
      </td>
      <td className="text-center py-2 px-2">
        <Input value={courseType} onChange={e => setCourseType(e.target.value)} className="h-7 w-20 text-xs text-center mx-auto" data-testid="input-edit-course-type" />
      </td>
      <td className="text-center py-2 px-2">
        <Input value={starValue} onChange={e => setStarValue(e.target.value)} className="h-7 w-14 text-xs text-center mx-auto" data-testid="input-edit-course-stars" />
      </td>
      <td className="text-center py-2 px-2">
        <Input value={passThreshold} onChange={e => setPassThreshold(e.target.value)} className="h-7 w-16 text-xs text-center mx-auto" data-testid="input-edit-course-pass" />
      </td>
      <td className="py-2 px-2">
        <Input value={remarks} onChange={e => setRemarks(e.target.value)} className="h-7 text-xs" maxLength={1000} data-testid="input-edit-course-remarks" />
      </td>
      <td className="text-center py-2 px-2">
        <div className="flex items-center gap-1 justify-center">
          <Button size="icon" variant="ghost" className="h-6 w-6" onClick={() => mutation.mutate()} disabled={mutation.isPending} data-testid="button-save-course">
            <Check className="h-3 w-3 text-emerald-600" />
          </Button>
          <Button size="icon" variant="ghost" className="h-6 w-6" onClick={onCancel} data-testid="button-cancel-course">
            <X className="h-3 w-3" />
          </Button>
        </div>
      </td>
    </tr>
  );
}

function EditablePcRow({ pc, courseMap, onCancel, onSaved }: { pc: PaceCourse; courseMap: Map<number, Course>; onCancel: () => void; onSaved: () => void }) {
  const { toast } = useToast();
  const [creditValue, setCreditValue] = useState(pc.creditValuePace?.toString() || "");
  const [passThreshold, setPassThreshold] = useState(pc.passThreshold != null ? Math.round(pc.passThreshold * 100).toString() : "");
  const [active, setActive] = useState(pc.active?.toString() || "1");

  const course = courseMap.get(pc.courseId);

  const mutation = useMutation({
    mutationFn: async () => {
      await apiRequest("PATCH", `/api/pace-courses/${pc.id}`, {
        creditValuePace: creditValue ? parseFloat(creditValue) : null,
        passThreshold: passThreshold ? parseFloat(passThreshold) / 100 : null,
        active: parseInt(active),
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/pace-courses"] });
      toast({ title: "PACE-Course updated" });
      onSaved();
    },
    onError: (err: Error) => toast({ title: "Failed", description: err.message, variant: "destructive" }),
  });

  return (
    <tr className="border-b bg-muted/20" data-testid={`row-pc-edit-${pc.id}`}>
      <td className="py-2 px-2 text-muted-foreground font-mono text-xs">{pc.id}</td>
      <td className="py-2 px-2 font-mono text-xs">{pc.code || "—"}</td>
      <td className="py-2 px-2 font-medium text-xs">{course?.course || course?.aceAlias || `#${pc.courseId}`}</td>
      <td className="text-center py-2 px-2">{pc.number ?? "—"}</td>
      <td className="text-center py-2 px-2">
        <Input value={creditValue} onChange={e => setCreditValue(e.target.value)} className="h-7 w-16 text-xs text-center mx-auto" data-testid="input-edit-pc-credit" />
      </td>
      <td className="text-center py-2 px-2">
        <Input value={passThreshold} onChange={e => setPassThreshold(e.target.value)} className="h-7 w-16 text-xs text-center mx-auto" data-testid="input-edit-pc-pass" />
      </td>
      <td className="text-center py-2 px-2">
        <Select value={active} onValueChange={setActive}>
          <SelectTrigger className="h-7 w-24 text-xs mx-auto" data-testid="select-edit-pc-active"><SelectValue /></SelectTrigger>
          <SelectContent>
            <SelectItem value="1">Active</SelectItem>
            <SelectItem value="0">Inactive</SelectItem>
          </SelectContent>
        </Select>
      </td>
      <td className="text-center py-2 px-2">
        <div className="flex items-center gap-1 justify-center">
          <Button size="icon" variant="ghost" className="h-6 w-6" onClick={() => mutation.mutate()} disabled={mutation.isPending} data-testid="button-save-pc">
            <Check className="h-3 w-3 text-emerald-600" />
          </Button>
          <Button size="icon" variant="ghost" className="h-6 w-6" onClick={onCancel} data-testid="button-cancel-pc">
            <X className="h-3 w-3" />
          </Button>
        </div>
      </td>
    </tr>
  );
}

export default function MaterialsPage() {
  const [selectedSubject, setSelectedSubject] = useState<string>("all");
  const [selectedCourse, setSelectedCourse] = useState<string>("all");
  const [levelFilter, setLevelFilter] = useState("");
  const [groupFilter, setGroupFilter] = useState("");
  const [subjectSearch, setSubjectSearch] = useState("");
  const [editingCourseId, setEditingCourseId] = useState<number | null>(null);
  const [editingPcId, setEditingPcId] = useState<number | null>(null);

  const { data: courses } = useQuery<Course[]>({ queryKey: ["/api/courses"] });
  const { data: allPaces } = useQuery<Pace[]>({ queryKey: ["/api/paces"] });
  const { data: paceCourses } = useQuery<PaceCourse[]>({ queryKey: ["/api/pace-courses"] });
  const { data: profile } = useQuery<UserProfile>({ queryKey: ["/api/profile"] });

  const isTeacher = profile?.role === "teacher";

  const uniqueSubjects = useMemo(() => {
    if (!courses) return [];
    return [...new Set(courses.filter(c => c.subjectTemp).map(c => c.subjectTemp!))].sort();
  }, [courses]);

  const uniqueLevels = useMemo(() => {
    if (!courses) return [];
    return [...new Set(courses.filter(c => c.level != null).map(c => c.level!))].sort((a, b) => a - b);
  }, [courses]);

  const uniqueGroups = useMemo(() => {
    if (!courses) return [];
    return [...new Set(courses.filter(c => c.subjectGroup).map(c => c.subjectGroup!))].sort();
  }, [courses]);

  const filteredCourses = useMemo(() => {
    if (!courses) return [];
    let result = courses;
    if (selectedSubject !== "all") {
      result = result.filter(c => c.subjectTemp === selectedSubject);
    }
    if (subjectSearch) {
      const search = subjectSearch.toLowerCase();
      result = result.filter(c =>
        (c.course || "").toLowerCase().includes(search) ||
        (c.aceAlias || "").toLowerCase().includes(search) ||
        (c.subjectAbb || "").toLowerCase().includes(search) ||
        (c.subjectTemp || "").toLowerCase().includes(search)
      );
    }
    if (levelFilter) {
      result = result.filter(c => c.level?.toString() === levelFilter);
    }
    if (groupFilter) {
      result = result.filter(c => c.subjectGroup === groupFilter);
    }
    return result;
  }, [courses, selectedSubject, subjectSearch, levelFilter, groupFilter]);

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

  const displayPaceCourses = useMemo(() => {
    if (!paceCourses) return [];
    let filtered = paceCourses;
    const hasFilters = selectedSubject !== "all" || subjectSearch || levelFilter || groupFilter;
    if (hasFilters) {
      const courseIds = new Set(filteredCourses.map(c => c.id));
      filtered = filtered.filter(pc => courseIds.has(pc.courseId));
    }
    if (selectedCourse !== "all") {
      filtered = filtered.filter(pc => pc.courseId === parseInt(selectedCourse));
    }
    return filtered;
  }, [paceCourses, selectedSubject, selectedCourse, filteredCourses, subjectSearch, levelFilter, groupFilter]);

  const filteredSubjects = useMemo(() => {
    if (!subjectSearch) return uniqueSubjects;
    const search = subjectSearch.toLowerCase();
    return uniqueSubjects.filter(s => s.toLowerCase().includes(search));
  }, [uniqueSubjects, subjectSearch]);

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
          <label className="text-sm font-medium">Search</label>
          <Input
            value={subjectSearch}
            onChange={e => setSubjectSearch(e.target.value)}
            placeholder="Type to search..."
            className="w-[200px]"
            data-testid="input-search-courses"
          />
        </div>
        <div className="space-y-1.5">
          <label className="text-sm font-medium">Subject</label>
          <Select value={selectedSubject} onValueChange={(v) => { setSelectedSubject(v); setSelectedCourse("all"); }}>
            <SelectTrigger className="w-[180px]" data-testid="select-subject">
              <SelectValue placeholder="All subjects" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Subjects</SelectItem>
              {(subjectSearch ? filteredSubjects : uniqueSubjects).map(s => (
                <SelectItem key={s} value={s}>{s}</SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
        <div className="space-y-1.5">
          <label className="text-sm font-medium">Level</label>
          <Select value={levelFilter || "all"} onValueChange={v => setLevelFilter(v === "all" ? "" : v)}>
            <SelectTrigger className="w-[120px]" data-testid="select-level">
              <SelectValue placeholder="All levels" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Levels</SelectItem>
              {uniqueLevels.map(l => (
                <SelectItem key={l} value={l.toString()}>Level {l}</SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
        <div className="space-y-1.5">
          <label className="text-sm font-medium">Group</label>
          <Select value={groupFilter || "all"} onValueChange={v => setGroupFilter(v === "all" ? "" : v)}>
            <SelectTrigger className="w-[200px]" data-testid="select-group">
              <SelectValue placeholder="All groups" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Groups</SelectItem>
              {uniqueGroups.map(g => (
                <SelectItem key={g} value={g}>{g}</SelectItem>
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
                      {isTeacher && <th className="text-center py-3 px-2 font-medium text-muted-foreground w-[50px]"></th>}
                    </tr>
                  </thead>
                  <tbody>
                    {displayPaceCourses.slice(0, 100).map(pc => {
                      if (editingPcId === pc.id) {
                        return <EditablePcRow key={pc.id} pc={pc} courseMap={courseMap} onCancel={() => setEditingPcId(null)} onSaved={() => setEditingPcId(null)} />;
                      }
                      const course = courseMap.get(pc.courseId);
                      return (
                        <tr key={pc.id} className="border-b last:border-0" data-testid={`row-pc-${pc.id}`}>
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
                          {isTeacher && (
                            <td className="text-center py-2 px-2">
                              <Button size="icon" variant="ghost" className="h-6 w-6" onClick={() => setEditingPcId(pc.id)} data-testid={`button-edit-pc-${pc.id}`}>
                                <Pencil className="h-3 w-3" />
                              </Button>
                            </td>
                          )}
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
                      <th className="text-left py-3 px-2 font-medium text-muted-foreground">Remarks</th>
                      {isTeacher && <th className="text-center py-3 px-2 font-medium text-muted-foreground w-[50px]"></th>}
                    </tr>
                  </thead>
                  <tbody>
                    {filteredCourses.map(c => {
                      if (editingCourseId === c.id) {
                        return <EditableCourseRow key={c.id} c={c} onCancel={() => setEditingCourseId(null)} onSaved={() => setEditingCourseId(null)} />;
                      }
                      return (
                        <tr key={c.id} className="border-b last:border-0" data-testid={`row-course-${c.id}`}>
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
                          <td className="py-3 px-2 text-xs text-muted-foreground max-w-[200px]" data-testid={`text-course-remarks-${c.id}`}>
                            {c.remarks ? (
                              <span className="block truncate cursor-help" title={c.remarks}>{c.remarks}</span>
                            ) : "—"}
                          </td>
                          {isTeacher && (
                            <td className="text-center py-3 px-2">
                              <Button size="icon" variant="ghost" className="h-6 w-6" onClick={() => setEditingCourseId(c.id)} data-testid={`button-edit-course-${c.id}`}>
                                <Pencil className="h-3 w-3" />
                              </Button>
                            </td>
                          )}
                        </tr>
                      );
                    })}
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
