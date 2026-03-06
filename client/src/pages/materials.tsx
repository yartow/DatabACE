import { useQuery, useMutation } from "@tanstack/react-query";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Checkbox } from "@/components/ui/checkbox";
import { useState } from "react";
import type { Student, Subject, Material, StudentSubject, UserProfile } from "@shared/schema";
import { apiRequest, queryClient } from "@/lib/queryClient";
import { useToast } from "@/hooks/use-toast";
import { BookOpen, Package, CheckCircle2, XCircle, AlertTriangle } from "lucide-react";

export default function MaterialsPage() {
  const [selectedStudent, setSelectedStudent] = useState<string>("");
  const { toast } = useToast();

  const { data: students } = useQuery<Student[]>({ queryKey: ["/api/students"] });
  const { data: subjects } = useQuery<Subject[]>({ queryKey: ["/api/subjects"] });
  const { data: materials } = useQuery<Material[]>({ queryKey: ["/api/materials"] });
  const { data: studentSubjects } = useQuery<StudentSubject[]>({
    queryKey: ["/api/student-subjects", selectedStudent],
    queryFn: async () => {
      if (!selectedStudent) return [];
      const res = await fetch(`/api/student-subjects?studentId=${selectedStudent}`, { credentials: "include" });
      if (!res.ok) throw new Error("Failed to fetch");
      return res.json();
    },
    enabled: !!selectedStudent,
  });
  const { data: profile } = useQuery<UserProfile>({ queryKey: ["/api/profile"] });

  const isTeacher = profile?.role === "teacher";
  const subjectMap = new Map(subjects?.map(s => [s.id, s]) || []);

  const updateMaterial = useMutation({
    mutationFn: async ({ id, data }: { id: number; data: Partial<Material> }) => {
      await apiRequest("PATCH", `/api/materials/${id}`, data);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/materials"] });
      toast({ title: "Material updated" });
    },
  });

  const updateStudentSubject = useMutation({
    mutationFn: async ({ id, data }: { id: number; data: Partial<StudentSubject> }) => {
      await apiRequest("PATCH", `/api/student-subjects/${id}`, data);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/student-subjects"] });
      toast({ title: "Status updated" });
    },
  });

  const notPassedSubjects = studentSubjects?.filter(ss => !ss.passed) || [];
  const notExaminedSubjects = studentSubjects?.filter(ss => !ss.examined) || [];
  const pendingMaterials = materials?.filter(m => !m.received) || [];
  const notOrderedMaterials = materials?.filter(m => !m.ordered) || [];

  return (
    <div className="p-6 max-w-6xl mx-auto space-y-6">
      <div>
        <h1 className="text-2xl font-serif font-bold tracking-tight" data-testid="text-page-title">Materials & Examinations</h1>
        <p className="text-muted-foreground mt-1">Track course completion, exams, and material orders.</p>
      </div>

      <Tabs defaultValue="exams" className="space-y-6">
        <TabsList>
          <TabsTrigger value="exams" data-testid="tab-exams">Exams & Courses</TabsTrigger>
          <TabsTrigger value="materials" data-testid="tab-materials">Materials</TabsTrigger>
        </TabsList>

        <TabsContent value="exams" className="space-y-6">
          <div className="space-y-1.5">
            <label className="text-sm font-medium">Student</label>
            <Select value={selectedStudent} onValueChange={setSelectedStudent}>
              <SelectTrigger className="w-[220px]" data-testid="select-student-materials">
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

          {!selectedStudent ? (
            <Card>
              <CardContent className="py-16 text-center">
                <p className="text-muted-foreground">Select a student to view their course and exam status.</p>
              </CardContent>
            </Card>
          ) : (
            <div className="grid sm:grid-cols-3 gap-4 mb-6">
              <Card>
                <CardHeader className="flex flex-row items-center justify-between gap-1 space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium text-muted-foreground">Not Passed</CardTitle>
                  <XCircle className="w-4 h-4 text-red-500" />
                </CardHeader>
                <CardContent>
                  <p className="text-2xl font-bold" data-testid="text-not-passed">{notPassedSubjects.length}</p>
                </CardContent>
              </Card>
              <Card>
                <CardHeader className="flex flex-row items-center justify-between gap-1 space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium text-muted-foreground">Not Examined</CardTitle>
                  <AlertTriangle className="w-4 h-4 text-amber-500" />
                </CardHeader>
                <CardContent>
                  <p className="text-2xl font-bold" data-testid="text-not-examined">{notExaminedSubjects.length}</p>
                </CardContent>
              </Card>
              <Card>
                <CardHeader className="flex flex-row items-center justify-between gap-1 space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium text-muted-foreground">Total Courses</CardTitle>
                  <CheckCircle2 className="w-4 h-4 text-emerald-500" />
                </CardHeader>
                <CardContent>
                  <p className="text-2xl font-bold" data-testid="text-total-courses">{studentSubjects?.length || 0}</p>
                </CardContent>
              </Card>
            </div>
          )}

          {selectedStudent && studentSubjects && (
            <Card>
              <CardHeader>
                <CardTitle className="text-base">Course Status</CardTitle>
              </CardHeader>
              <CardContent>
                <table className="w-full text-sm" data-testid="table-courses">
                  <thead>
                    <tr className="border-b">
                      <th className="text-left py-3 px-2 font-medium text-muted-foreground">Subject</th>
                      <th className="text-center py-3 px-2 font-medium text-muted-foreground">Passed</th>
                      <th className="text-center py-3 px-2 font-medium text-muted-foreground">Examined</th>
                      <th className="text-center py-3 px-2 font-medium text-muted-foreground">Exam Date</th>
                    </tr>
                  </thead>
                  <tbody>
                    {studentSubjects.map(ss => {
                      const subject = subjectMap.get(ss.subjectId);
                      return (
                        <tr key={ss.id} className="border-b last:border-0">
                          <td className="py-3 px-2 font-medium">{subject?.name || "Unknown"}</td>
                          <td className="text-center py-3 px-2">
                            {isTeacher ? (
                              <Checkbox
                                checked={ss.passed}
                                onCheckedChange={(checked) => updateStudentSubject.mutate({ id: ss.id, data: { passed: !!checked } })}
                                data-testid={`checkbox-passed-${ss.id}`}
                              />
                            ) : (
                              <Badge variant={ss.passed ? "default" : "destructive"}>
                                {ss.passed ? "Yes" : "No"}
                              </Badge>
                            )}
                          </td>
                          <td className="text-center py-3 px-2">
                            {isTeacher ? (
                              <Checkbox
                                checked={ss.examined}
                                onCheckedChange={(checked) => updateStudentSubject.mutate({ id: ss.id, data: { examined: !!checked } })}
                                data-testid={`checkbox-examined-${ss.id}`}
                              />
                            ) : (
                              <Badge variant={ss.examined ? "default" : "secondary"}>
                                {ss.examined ? "Yes" : "No"}
                              </Badge>
                            )}
                          </td>
                          <td className="text-center py-3 px-2 text-muted-foreground">
                            {ss.examDate || "—"}
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </CardContent>
            </Card>
          )}
        </TabsContent>

        <TabsContent value="materials" className="space-y-6">
          <div className="grid sm:grid-cols-2 gap-4">
            <Card>
              <CardHeader className="flex flex-row items-center justify-between gap-1 space-y-0 pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground">Pending Delivery</CardTitle>
                <Package className="w-4 h-4 text-amber-500" />
              </CardHeader>
              <CardContent>
                <p className="text-2xl font-bold" data-testid="text-pending-materials">{pendingMaterials.length}</p>
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="flex flex-row items-center justify-between gap-1 space-y-0 pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground">Not Ordered</CardTitle>
                <BookOpen className="w-4 h-4 text-red-500" />
              </CardHeader>
              <CardContent>
                <p className="text-2xl font-bold" data-testid="text-not-ordered">{notOrderedMaterials.length}</p>
              </CardContent>
            </Card>
          </div>

          <Card>
            <CardHeader>
              <CardTitle className="text-base">All Materials</CardTitle>
            </CardHeader>
            <CardContent>
              <table className="w-full text-sm" data-testid="table-materials">
                <thead>
                  <tr className="border-b">
                    <th className="text-left py-3 px-2 font-medium text-muted-foreground">Material</th>
                    <th className="text-left py-3 px-2 font-medium text-muted-foreground">Subject</th>
                    <th className="text-center py-3 px-2 font-medium text-muted-foreground">Type</th>
                    <th className="text-center py-3 px-2 font-medium text-muted-foreground">Ordered</th>
                    <th className="text-center py-3 px-2 font-medium text-muted-foreground">Received</th>
                  </tr>
                </thead>
                <tbody>
                  {materials?.map(mat => {
                    const subject = subjectMap.get(mat.subjectId);
                    return (
                      <tr key={mat.id} className="border-b last:border-0">
                        <td className="py-3 px-2 font-medium">{mat.name}</td>
                        <td className="py-3 px-2 text-muted-foreground">{subject?.name || "Unknown"}</td>
                        <td className="text-center py-3 px-2">
                          <Badge variant="secondary">{mat.type}</Badge>
                        </td>
                        <td className="text-center py-3 px-2">
                          {isTeacher ? (
                            <Checkbox
                              checked={mat.ordered}
                              onCheckedChange={(checked) => updateMaterial.mutate({ id: mat.id, data: { ordered: !!checked } })}
                              data-testid={`checkbox-ordered-${mat.id}`}
                            />
                          ) : (
                            <Badge variant={mat.ordered ? "default" : "destructive"}>
                              {mat.ordered ? "Yes" : "No"}
                            </Badge>
                          )}
                        </td>
                        <td className="text-center py-3 px-2">
                          {isTeacher ? (
                            <Checkbox
                              checked={mat.received}
                              onCheckedChange={(checked) => updateMaterial.mutate({ id: mat.id, data: { received: !!checked } })}
                              data-testid={`checkbox-received-${mat.id}`}
                            />
                          ) : (
                            <Badge variant={mat.received ? "default" : "secondary"}>
                              {mat.received ? "Yes" : "No"}
                            </Badge>
                          )}
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
