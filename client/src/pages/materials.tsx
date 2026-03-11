import { useQuery, useMutation } from "@tanstack/react-query";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu";
import { useState, useMemo, useRef } from "react";
import type { Course, Pace, PaceCourse, Subject, SubjectGroup, UserProfile } from "@shared/schema";
import { BookOpen, Package, CheckCircle2, XCircle, Pencil, Check, X, Plus, Upload, Download, ChevronDown, AlertTriangle } from "lucide-react";
import { apiRequest, queryClient } from "@/lib/queryClient";
import { useToast } from "@/hooks/use-toast";

function EditableCourseRow({ c, subjectMap, subjectGroupMap, onCancel, onSaved }: { c: Course; subjectMap: Map<number, Subject>; subjectGroupMap: Map<number, SubjectGroup>; onCancel: () => void; onSaved: () => void }) {
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

  const subj = c.subjectId ? subjectMap.get(c.subjectId) : null;
  const grp = c.subjectGroupId ? subjectGroupMap.get(c.subjectGroupId) : null;

  return (
    <tr className="border-b bg-muted/20" data-testid={`row-course-edit-${c.id}`}>
      <td className="py-2 px-2">
        <Input value={course} onChange={e => setCourse(e.target.value)} className="h-7 text-xs" data-testid="input-edit-course-name" />
      </td>
      <td className="text-center py-2 px-2">
        <Badge variant="secondary">{subj?.subject || "—"}</Badge>
      </td>
      <td className="text-center py-2 px-2 text-muted-foreground text-xs">{grp?.subjectGroup || "—"}</td>
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

type ImportResult = { sessionId: string; newCount: number; conflictCount: number; skippedIdentical: number; errors: string[]; conflicts: { index: number; excelRow: any; dbRow: any }[] };

function ImportConflictDialog({ result, onResolve, onClose, importType }: { result: ImportResult; onResolve: (sessionId: string, choices: string[], overrideAll?: boolean) => void; onClose: () => void; importType: string }) {
  const [choices, setChoices] = useState<Record<number, "excel" | "skip">>(
    Object.fromEntries(result.conflicts.map((c, i) => [i, "skip"]))
  );

  const entityLabel = importType === "pace-courses" ? "PaceCourse" : "Course";
  const idKey = importType === "pace-courses" ? "id" : "id";

  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent className="max-w-4xl max-h-[80vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>Import Conflicts – {entityLabel}s</DialogTitle>
        </DialogHeader>
        <div className="space-y-3 text-sm">
          <p className="text-muted-foreground">
            {result.newCount} new · {result.conflictCount} conflicts · {result.skippedIdentical} identical (skipped)
          </p>
          {result.errors.length > 0 && (
            <div className="p-3 bg-destructive/10 rounded text-destructive text-xs space-y-1">
              {result.errors.slice(0, 5).map((e, i) => <p key={i}>{e}</p>)}
              {result.errors.length > 5 && <p>…and {result.errors.length - 5} more errors</p>}
            </div>
          )}
          {result.conflicts.length > 0 && (
            <div className="space-y-2">
              <div className="flex gap-2">
                <Button size="sm" variant="outline" onClick={() => setChoices(Object.fromEntries(result.conflicts.map((_, i) => [i, "excel"])))}>Select All: Use Excel</Button>
                <Button size="sm" variant="outline" onClick={() => setChoices(Object.fromEntries(result.conflicts.map((_, i) => [i, "skip"])))}>Select All: Skip</Button>
              </div>
              {result.conflicts.map((c) => (
                <Card key={c.index} className="text-xs">
                  <CardContent className="pt-3 pb-2">
                    <div className="flex items-start justify-between gap-4">
                      <div className="space-y-1 flex-1">
                        <p className="font-medium">ID {c.excelRow[idKey]}</p>
                        <div className="grid grid-cols-2 gap-x-4">
                          <div>
                            <p className="text-muted-foreground font-medium mb-1">Current (DB)</p>
                            {Object.keys(c.excelRow).filter(k => k !== "id" && c.excelRow[k] !== c.dbRow[k]).map(k => (
                              <p key={k}><span className="font-mono">{k}</span>: {String(c.dbRow[k] ?? "—")}</p>
                            ))}
                          </div>
                          <div>
                            <p className="text-muted-foreground font-medium mb-1">Excel (new)</p>
                            {Object.keys(c.excelRow).filter(k => k !== "id" && c.excelRow[k] !== c.dbRow[k]).map(k => (
                              <p key={k} className="text-primary"><span className="font-mono">{k}</span>: {String(c.excelRow[k] ?? "—")}</p>
                            ))}
                          </div>
                        </div>
                      </div>
                      <div className="flex gap-1 shrink-0">
                        <Button size="sm" variant={choices[c.index] === "excel" ? "default" : "outline"} className="h-7 text-xs" onClick={() => setChoices(prev => ({ ...prev, [c.index]: "excel" }))}>Use Excel</Button>
                        <Button size="sm" variant={choices[c.index] === "skip" ? "secondary" : "outline"} className="h-7 text-xs" onClick={() => setChoices(prev => ({ ...prev, [c.index]: "skip" }))}>Skip</Button>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          )}
        </div>
        <DialogFooter className="gap-2">
          <Button variant="outline" onClick={onClose}>Cancel</Button>
          <Button variant="outline" onClick={() => onResolve(result.sessionId, [], true)}>Override All</Button>
          <Button onClick={() => onResolve(result.sessionId, result.conflicts.map((_, i) => choices[i] || "skip"))}>Apply Selections</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

export default function MaterialsPage() {
  const [selectedSubjectId, setSelectedSubjectId] = useState<string>("all");
  const [selectedCourse, setSelectedCourse] = useState<string>("all");
  const [levelFilter, setLevelFilter] = useState("");
  const [subjectGroupIdFilter, setSubjectGroupIdFilter] = useState<string>("all");
  const [search, setSearch] = useState("");
  const [editingCourseId, setEditingCourseId] = useState<number | null>(null);
  const [editingPcId, setEditingPcId] = useState<number | null>(null);
  const [showAddCourse, setShowAddCourse] = useState(false);
  const [importResult, setImportResult] = useState<ImportResult | null>(null);
  const [importType, setImportType] = useState<"courses" | "pace-courses">("courses");
  const courseFileRef = useRef<HTMLInputElement>(null);
  const { toast } = useToast();

  const { data: courses } = useQuery<Course[]>({ queryKey: ["/api/courses"] });
  const { data: allPaces } = useQuery<Pace[]>({ queryKey: ["/api/paces"] });
  const { data: paceCourses } = useQuery<PaceCourse[]>({ queryKey: ["/api/pace-courses"] });
  const { data: subjects } = useQuery<Subject[]>({ queryKey: ["/api/subjects"] });
  const { data: subjectGroups } = useQuery<SubjectGroup[]>({ queryKey: ["/api/subject-groups"] });
  const { data: profile } = useQuery<UserProfile>({ queryKey: ["/api/profile"] });

  const isTeacher = profile?.role === "teacher";

  const subjectMap = useMemo(() => new Map(subjects?.map(s => [s.id, s]) || []), [subjects]);
  const subjectGroupMap = useMemo(() => new Map(subjectGroups?.map(g => [g.id, g]) || []), [subjectGroups]);

  const uniqueLevels = useMemo(() => {
    if (!courses) return [];
    return [...new Set(courses.filter(c => c.level != null).map(c => c.level!))].sort((a, b) => a - b);
  }, [courses]);

  const filteredCourses = useMemo(() => {
    if (!courses) return [];
    let result = courses;
    if (selectedSubjectId !== "all") result = result.filter(c => c.subjectId === parseInt(selectedSubjectId));
    if (subjectGroupIdFilter !== "all") result = result.filter(c => c.subjectGroupId === parseInt(subjectGroupIdFilter));
    if (search) {
      const q = search.toLowerCase();
      result = result.filter(c =>
        (c.course || "").toLowerCase().includes(q) ||
        (c.aceAlias || "").toLowerCase().includes(q) ||
        (c.certificateName || "").toLowerCase().includes(q)
      );
    }
    if (levelFilter) result = result.filter(c => c.level?.toString() === levelFilter);
    return result;
  }, [courses, selectedSubjectId, subjectGroupIdFilter, search, levelFilter]);

  const activePaceCourses = useMemo(() => paceCourses?.filter(pc => pc.active === 1) || [], [paceCourses]);
  const inactivePaceCourses = useMemo(() => paceCourses?.filter(pc => pc.active === 0) || [], [paceCourses]);

  const courseMap = useMemo(() => new Map(courses?.map(c => [c.id, c]) || []), [courses]);

  const displayPaceCourses = useMemo(() => {
    if (!paceCourses) return [];
    let filtered = paceCourses;
    const hasFilters = selectedSubjectId !== "all" || search || levelFilter || subjectGroupIdFilter !== "all";
    if (hasFilters) {
      const courseIds = new Set(filteredCourses.map(c => c.id));
      filtered = filtered.filter(pc => courseIds.has(pc.courseId));
    }
    if (selectedCourse !== "all") filtered = filtered.filter(pc => pc.courseId === parseInt(selectedCourse));
    return filtered;
  }, [paceCourses, selectedSubjectId, selectedCourse, filteredCourses, search, levelFilter, subjectGroupIdFilter]);

  const handleImportUpload = async (file: File, type: "courses" | "pace-courses") => {
    setImportType(type);
    const formData = new FormData();
    formData.append("file", file);
    try {
      const res = await fetch(`/api/courses/import?type=${type}`, {
        method: "POST",
        body: formData,
        credentials: "include",
      });
      const data = await res.json();
      if (!res.ok) { toast({ title: "Import failed", description: data.message, variant: "destructive" }); return; }
      if (data.conflictCount === 0 && data.newCount > 0) {
        await fetch("/api/courses/import/resolve", { method: "POST", headers: { "Content-Type": "application/json" }, credentials: "include", body: JSON.stringify({ sessionId: data.sessionId, choices: [], overrideAll: false }) });
        queryClient.invalidateQueries({ queryKey: ["/api/courses"] });
        queryClient.invalidateQueries({ queryKey: ["/api/pace-courses"] });
        toast({ title: "Import complete", description: `${data.newCount} inserted, ${data.skippedIdentical} identical skipped` });
      } else if (data.conflictCount > 0 || data.newCount > 0) {
        setImportResult(data);
      } else {
        toast({ title: "Nothing to import", description: `${data.skippedIdentical} identical rows skipped` });
      }
    } catch (e: any) {
      toast({ title: "Upload failed", description: e.message, variant: "destructive" });
    }
  };

  const handleResolve = async (sessionId: string, choices: string[], overrideAll = false) => {
    try {
      const res = await fetch("/api/courses/import/resolve", { method: "POST", headers: { "Content-Type": "application/json" }, credentials: "include", body: JSON.stringify({ sessionId, choices, overrideAll }) });
      const data = await res.json();
      if (!res.ok) { toast({ title: "Failed", description: data.message, variant: "destructive" }); return; }
      queryClient.invalidateQueries({ queryKey: ["/api/courses"] });
      queryClient.invalidateQueries({ queryKey: ["/api/pace-courses"] });
      toast({ title: "Import applied", description: `${data.inserted} inserted, ${data.updated} updated, ${data.skipped} skipped` });
      setImportResult(null);
    } catch (e: any) {
      toast({ title: "Failed", description: e.message, variant: "destructive" });
    }
  };

  return (
    <div className="p-6 max-w-6xl mx-auto space-y-6">
      <div className="flex items-start justify-between gap-4">
        <div>
          <h1 className="text-2xl font-serif font-bold tracking-tight" data-testid="text-page-title">Courses & PACEs</h1>
          <p className="text-muted-foreground mt-1">Browse courses, PACEs, and their active status.</p>
        </div>
        {isTeacher && (
          <div className="flex items-center gap-2 shrink-0">
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="outline" size="sm" data-testid="button-download-template">
                  <Download className="h-4 w-4 mr-1" /> Template <ChevronDown className="h-3 w-3 ml-1" />
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent>
                <DropdownMenuItem onClick={() => window.open("/api/courses/template?type=courses", "_blank")} data-testid="menu-template-courses">Courses template</DropdownMenuItem>
                <DropdownMenuItem onClick={() => window.open("/api/courses/template?type=pace-courses", "_blank")} data-testid="menu-template-pace-courses">PaceCourses template</DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="outline" size="sm" data-testid="button-import">
                  <Upload className="h-4 w-4 mr-1" /> Import <ChevronDown className="h-3 w-3 ml-1" />
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent>
                <DropdownMenuItem onClick={() => { setImportType("courses"); courseFileRef.current && (courseFileRef.current.dataset.type = "courses") && courseFileRef.current.click(); }} data-testid="menu-import-courses">Import Courses</DropdownMenuItem>
                <DropdownMenuItem onClick={() => { setImportType("pace-courses"); courseFileRef.current && (courseFileRef.current.dataset.type = "pace-courses") && courseFileRef.current.click(); }} data-testid="menu-import-pace-courses">Import PaceCourses</DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
            <input ref={courseFileRef} type="file" accept=".xlsx,.xls" className="hidden" onChange={e => { const f = e.target.files?.[0]; if (f) handleImportUpload(f, (courseFileRef.current?.dataset.type as any) || "courses"); e.target.value = ""; }} />
            <Button size="sm" onClick={() => setShowAddCourse(true)} data-testid="button-add-course">
              <Plus className="h-4 w-4 mr-1" /> Add Course
            </Button>
          </div>
        )}
      </div>

      <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between gap-1 space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Total Courses</CardTitle>
            <BookOpen className="w-4 h-4 text-chart-1" />
          </CardHeader>
          <CardContent><p className="text-2xl font-bold" data-testid="text-total-courses">{courses?.length || 0}</p></CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between gap-1 space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Total PACEs</CardTitle>
            <Package className="w-4 h-4 text-chart-2" />
          </CardHeader>
          <CardContent><p className="text-2xl font-bold" data-testid="text-total-paces">{allPaces?.length || 0}</p></CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between gap-1 space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Active PACE-Courses</CardTitle>
            <CheckCircle2 className="w-4 h-4 text-emerald-500" />
          </CardHeader>
          <CardContent><p className="text-2xl font-bold text-emerald-600 dark:text-emerald-400" data-testid="text-active">{activePaceCourses.length}</p></CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between gap-1 space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Inactive PACE-Courses</CardTitle>
            <XCircle className="w-4 h-4 text-red-500" />
          </CardHeader>
          <CardContent><p className="text-2xl font-bold" data-testid="text-inactive">{inactivePaceCourses.length}</p></CardContent>
        </Card>
      </div>

      <div className="flex flex-wrap items-end gap-4">
        <div className="space-y-1.5">
          <label className="text-sm font-medium">Search</label>
          <Input value={search} onChange={e => setSearch(e.target.value)} placeholder="Name, alias…" className="w-[200px]" data-testid="input-search-courses" />
        </div>
        <div className="space-y-1.5">
          <label className="text-sm font-medium">Subject</label>
          <Select value={selectedSubjectId} onValueChange={v => { setSelectedSubjectId(v); setSelectedCourse("all"); }}>
            <SelectTrigger className="w-[200px]" data-testid="select-subject"><SelectValue placeholder="All subjects" /></SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Subjects</SelectItem>
              {subjects?.map(s => <SelectItem key={s.id} value={s.id.toString()}>{s.subject}</SelectItem>)}
            </SelectContent>
          </Select>
        </div>
        <div className="space-y-1.5">
          <label className="text-sm font-medium">Group</label>
          <Select value={subjectGroupIdFilter} onValueChange={setSubjectGroupIdFilter}>
            <SelectTrigger className="w-[200px]" data-testid="select-group"><SelectValue placeholder="All groups" /></SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Groups</SelectItem>
              {subjectGroups?.map(g => <SelectItem key={g.id} value={g.id.toString()}>{g.subjectGroup}</SelectItem>)}
            </SelectContent>
          </Select>
        </div>
        <div className="space-y-1.5">
          <label className="text-sm font-medium">Level</label>
          <Select value={levelFilter || "all"} onValueChange={v => setLevelFilter(v === "all" ? "" : v)}>
            <SelectTrigger className="w-[120px]" data-testid="select-level"><SelectValue placeholder="All levels" /></SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Levels</SelectItem>
              {uniqueLevels.map(l => <SelectItem key={l} value={l.toString()}>Level {l}</SelectItem>)}
            </SelectContent>
          </Select>
        </div>
        <div className="space-y-1.5">
          <label className="text-sm font-medium">Course</label>
          <Select value={selectedCourse} onValueChange={setSelectedCourse}>
            <SelectTrigger className="w-[250px]" data-testid="select-course"><SelectValue placeholder="All courses" /></SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Courses</SelectItem>
              {filteredCourses.map(c => <SelectItem key={c.id} value={c.id.toString()}>{c.course || c.aceAlias || `Course ${c.id}`}</SelectItem>)}
            </SelectContent>
          </Select>
        </div>
      </div>

      <Tabs defaultValue="courses" className="space-y-4">
        <TabsList>
          <TabsTrigger value="courses" data-testid="tab-courses">Courses</TabsTrigger>
          <TabsTrigger value="pace-courses" data-testid="tab-pace-courses">PACE-Course Links</TabsTrigger>
        </TabsList>

        <TabsContent value="courses">
          <Card>
            <CardHeader><CardTitle className="text-base">Courses ({filteredCourses.length})</CardTitle></CardHeader>
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
                      {isTeacher && <th className="w-[50px]" />}
                    </tr>
                  </thead>
                  <tbody>
                    {filteredCourses.map(c => {
                      if (editingCourseId === c.id) {
                        return <EditableCourseRow key={c.id} c={c} subjectMap={subjectMap} subjectGroupMap={subjectGroupMap} onCancel={() => setEditingCourseId(null)} onSaved={() => setEditingCourseId(null)} />;
                      }
                      const subj = c.subjectId ? subjectMap.get(c.subjectId) : null;
                      const grp = c.subjectGroupId ? subjectGroupMap.get(c.subjectGroupId) : null;
                      return (
                        <tr key={c.id} className="border-b last:border-0" data-testid={`row-course-${c.id}`}>
                          <td className="py-3 px-2 font-medium">{c.course || c.aceAlias || `Course ${c.id}`}</td>
                          <td className="text-center py-3 px-2"><Badge variant="secondary">{subj?.subject || "—"}</Badge></td>
                          <td className="text-center py-3 px-2 text-muted-foreground text-xs">{grp?.subjectGroup || "—"}</td>
                          <td className="text-center py-3 px-2">{c.level ?? "—"}</td>
                          <td className="text-center py-3 px-2 text-muted-foreground">{c.courseType || "—"}</td>
                          <td className="text-center py-3 px-2">{c.starValue ?? "—"}</td>
                          <td className="text-center py-3 px-2 text-muted-foreground">{c.passThreshold != null ? `${Math.round(c.passThreshold * 100)}%` : "—"}</td>
                          <td className="py-3 px-2 text-xs text-muted-foreground max-w-[200px]" data-testid={`text-course-remarks-${c.id}`}>
                            {c.remarks ? <span className="block truncate cursor-help" title={c.remarks}>{c.remarks}</span> : "—"}
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

        <TabsContent value="pace-courses">
          <Card>
            <CardHeader><CardTitle className="text-base">PACE-Course Links ({displayPaceCourses.length})</CardTitle></CardHeader>
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
                      {isTeacher && <th className="w-[50px]" />}
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
                          <td className="py-2 px-2 font-medium text-xs">{course?.course || course?.aceAlias || `#${pc.courseId}`}</td>
                          <td className="text-center py-2 px-2">{pc.number ?? "—"}</td>
                          <td className="text-center py-2 px-2">{pc.creditValuePace ?? "—"}</td>
                          <td className="text-center py-2 px-2 text-muted-foreground">{pc.passThreshold != null ? `${Math.round(pc.passThreshold * 100)}%` : "—"}</td>
                          <td className="text-center py-2 px-2">
                            <Badge variant={pc.active === 1 ? "default" : "secondary"}>{pc.active === 1 ? "Active" : "Inactive"}</Badge>
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
                  <p className="text-sm text-muted-foreground text-center py-3">Showing 100 of {displayPaceCourses.length}. Use filters to narrow results.</p>
                )}
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>

      {showAddCourse && (
        <AddCourseDialog
          subjects={subjects || []}
          subjectGroups={subjectGroups || []}
          onClose={() => setShowAddCourse(false)}
          onCreated={() => {
            setShowAddCourse(false);
            queryClient.invalidateQueries({ queryKey: ["/api/courses"] });
            queryClient.invalidateQueries({ queryKey: ["/api/paces"] });
            queryClient.invalidateQueries({ queryKey: ["/api/pace-courses"] });
          }}
        />
      )}

      {importResult && (
        <ImportConflictDialog
          result={importResult}
          importType={importType}
          onResolve={handleResolve}
          onClose={() => setImportResult(null)}
        />
      )}
    </div>
  );
}

function AddCourseDialog({ subjects, subjectGroups, onClose, onCreated }: { subjects: Subject[]; subjectGroups: SubjectGroup[]; onClose: () => void; onCreated: () => void }) {
  const { toast } = useToast();
  const [courseName, setCourseName] = useState("");
  const [aceAlias, setAceAlias] = useState("");
  const [icceAlias, setIcceAlias] = useState("");
  const [certificateName, setCertificateName] = useState("");
  const [level, setLevel] = useState("");
  const [starValue, setStarValue] = useState("");
  const [subjectId, setSubjectId] = useState("");
  const [subjectGroupId, setSubjectGroupId] = useState("");
  const [courseType, setCourseType] = useState("");
  const [passThreshold, setPassThreshold] = useState("");
  const [remarks, setRemarks] = useState("");
  const [paceCount, setPaceCount] = useState("");
  const [paceNumbers, setPaceNumbers] = useState<string[]>([]);

  const handlePaceCountChange = (val: string) => {
    setPaceCount(val);
    const n = parseInt(val);
    if (!isNaN(n) && n >= 0 && n <= 50) {
      setPaceNumbers(prev => {
        const arr = [...prev];
        while (arr.length < n) arr.push("");
        return arr.slice(0, n);
      });
    }
  };

  const mutation = useMutation({
    mutationFn: async () => {
      const nums = paceNumbers.filter(p => p.trim() !== "");
      await apiRequest("POST", "/api/courses/create-with-paces", {
        course: courseName || null,
        aceAlias: aceAlias || null,
        icceAlias: icceAlias || null,
        certificateName: certificateName || null,
        level: level ? parseInt(level) : null,
        starValue: starValue ? parseInt(starValue) : null,
        subjectId: subjectId ? parseInt(subjectId) : null,
        subjectGroupId: subjectGroupId ? parseInt(subjectGroupId) : null,
        courseType: courseType || null,
        passThreshold: passThreshold ? parseFloat(passThreshold) / 100 : null,
        remarks: remarks || null,
        paceNumbers: nums,
      });
    },
    onSuccess: () => { toast({ title: "Course created" }); onCreated(); },
    onError: (err: Error) => toast({ title: "Failed", description: err.message, variant: "destructive" }),
  });

  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent className="max-w-2xl max-h-[85vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>Add New Course</DialogTitle>
        </DialogHeader>
        <div className="grid grid-cols-2 gap-4 py-2">
          <div className="space-y-1.5">
            <Label>Course name</Label>
            <Input value={courseName} onChange={e => setCourseName(e.target.value)} placeholder="e.g. Mathematics I" data-testid="input-new-course-name" />
          </div>
          <div className="space-y-1.5">
            <Label>ACE alias</Label>
            <Input value={aceAlias} onChange={e => setAceAlias(e.target.value)} placeholder="e.g. Math I" data-testid="input-new-ace-alias" />
          </div>
          <div className="space-y-1.5">
            <Label>ICCE alias</Label>
            <Input value={icceAlias} onChange={e => setIcceAlias(e.target.value)} data-testid="input-new-icce-alias" />
          </div>
          <div className="space-y-1.5">
            <Label>Certificate name</Label>
            <Input value={certificateName} onChange={e => setCertificateName(e.target.value)} data-testid="input-new-cert-name" />
          </div>
          <div className="space-y-1.5">
            <Label>Level</Label>
            <Input type="number" value={level} onChange={e => setLevel(e.target.value)} placeholder="e.g. 3" data-testid="input-new-level" />
          </div>
          <div className="space-y-1.5">
            <Label>Course type</Label>
            <Input value={courseType} onChange={e => setCourseType(e.target.value)} placeholder="e.g. ACE" data-testid="input-new-course-type" />
          </div>
          <div className="space-y-1.5">
            <Label>Subject</Label>
            <Select value={subjectId || "none"} onValueChange={v => setSubjectId(v === "none" ? "" : v)}>
              <SelectTrigger data-testid="select-new-subject"><SelectValue placeholder="Select subject" /></SelectTrigger>
              <SelectContent>
                <SelectItem value="none">— none —</SelectItem>
                {subjects.map(s => <SelectItem key={s.id} value={s.id.toString()}>{s.subject}</SelectItem>)}
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-1.5">
            <Label>Subject group</Label>
            <Select value={subjectGroupId || "none"} onValueChange={v => setSubjectGroupId(v === "none" ? "" : v)}>
              <SelectTrigger data-testid="select-new-subject-group"><SelectValue placeholder="Select group" /></SelectTrigger>
              <SelectContent>
                <SelectItem value="none">— none —</SelectItem>
                {subjectGroups.map(g => <SelectItem key={g.id} value={g.id.toString()}>{g.subjectGroup}</SelectItem>)}
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-1.5">
            <Label>Star value</Label>
            <Input type="number" value={starValue} onChange={e => setStarValue(e.target.value)} data-testid="input-new-star-value" />
          </div>
          <div className="space-y-1.5">
            <Label>Pass threshold (%)</Label>
            <Input type="number" value={passThreshold} onChange={e => setPassThreshold(e.target.value)} placeholder="e.g. 80" data-testid="input-new-pass-threshold" />
          </div>
          <div className="col-span-2 space-y-1.5">
            <Label>Remarks</Label>
            <Textarea value={remarks} onChange={e => setRemarks(e.target.value)} maxLength={1000} rows={2} data-testid="input-new-remarks" />
          </div>
          <div className="col-span-2 space-y-1.5 border-t pt-4">
            <Label>Number of PACEs in this course</Label>
            <Input type="number" min="0" max="50" value={paceCount} onChange={e => handlePaceCountChange(e.target.value)} placeholder="e.g. 6" className="w-32" data-testid="input-new-pace-count" />
          </div>
          {paceNumbers.length > 0 && (
            <div className="col-span-2 space-y-2">
              <Label>PACE numbers</Label>
              <div className="grid grid-cols-6 gap-2">
                {paceNumbers.map((num, i) => (
                  <div key={i} className="space-y-1">
                    <label className="text-xs text-muted-foreground">#{i + 1}</label>
                    <Input
                      type="number"
                      value={num}
                      onChange={e => setPaceNumbers(prev => { const arr = [...prev]; arr[i] = e.target.value; return arr; })}
                      placeholder={`PACE ${i + 1}`}
                      className="text-center"
                      data-testid={`input-pace-number-${i}`}
                    />
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={onClose}>Cancel</Button>
          <Button onClick={() => mutation.mutate()} disabled={mutation.isPending} data-testid="button-create-course">
            {mutation.isPending ? "Creating…" : "Create Course"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
