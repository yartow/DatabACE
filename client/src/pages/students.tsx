import { useQuery, useMutation } from "@tanstack/react-query";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { useToast } from "@/hooks/use-toast";
import { useState } from "react";
import type { Student, UserProfile } from "@shared/schema";
import { apiRequest, queryClient } from "@/lib/queryClient";
import { Plus } from "lucide-react";
import { useQuery as useProfileQuery } from "@tanstack/react-query";

export default function StudentsPage() {
  const { toast } = useToast();
  const [open, setOpen] = useState(false);
  const [form, setForm] = useState({ id: "", surname: "", firstNames: "", callName: "", alias: "" });
  const [search, setSearch] = useState("");

  const { data: students, isLoading } = useQuery<Student[]>({ queryKey: ["/api/students"] });
  const { data: profile } = useProfileQuery<UserProfile>({ queryKey: ["/api/profile"] });

  const isTeacher = profile?.role === "teacher";

  const createStudent = useMutation({
    mutationFn: async () => {
      await apiRequest("POST", "/api/students", {
        id: parseInt(form.id),
        surname: form.surname,
        firstNames: form.firstNames || null,
        callName: form.callName,
        alias: form.alias || `${form.callName} ${form.surname}`,
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/students"] });
      queryClient.invalidateQueries({ queryKey: ["/api/dashboard/stats"] });
      setOpen(false);
      setForm({ id: "", surname: "", firstNames: "", callName: "", alias: "" });
      toast({ title: "Student added successfully" });
    },
    onError: () => toast({ title: "Failed to add student", variant: "destructive" }),
  });

  const deleteStudent = useMutation({
    mutationFn: async (id: number) => {
      await apiRequest("DELETE", `/api/students/${id}`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/students"] });
      queryClient.invalidateQueries({ queryKey: ["/api/dashboard/stats"] });
      toast({ title: "Student removed" });
    },
  });

  const filteredStudents = students?.filter(s => {
    if (!search) return true;
    const q = search.toLowerCase();
    return s.surname.toLowerCase().includes(q) ||
      s.callName.toLowerCase().includes(q) ||
      s.alias.toLowerCase().includes(q) ||
      (s.firstNames?.toLowerCase().includes(q));
  });

  return (
    <div className="p-6 max-w-6xl mx-auto space-y-6">
      <div className="flex items-center justify-between gap-4 flex-wrap">
        <div>
          <h1 className="text-2xl font-serif font-bold tracking-tight" data-testid="text-page-title">Students</h1>
          <p className="text-muted-foreground mt-1">Manage student records ({students?.length || 0} students).</p>
        </div>
        {isTeacher && (
          <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
              <Button data-testid="button-add-student">
                <Plus className="w-4 h-4 mr-2" />
                Add Student
              </Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>Add New Student</DialogTitle>
              </DialogHeader>
              <div className="space-y-4 pt-2">
                <div className="space-y-2">
                  <Label>ID</Label>
                  <Input
                    type="number"
                    value={form.id}
                    onChange={e => setForm(p => ({ ...p, id: e.target.value }))}
                    data-testid="input-student-id"
                  />
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label>Surname</Label>
                    <Input
                      value={form.surname}
                      onChange={e => setForm(p => ({ ...p, surname: e.target.value }))}
                      data-testid="input-surname"
                    />
                  </div>
                  <div className="space-y-2">
                    <Label>Call Name</Label>
                    <Input
                      value={form.callName}
                      onChange={e => setForm(p => ({ ...p, callName: e.target.value }))}
                      data-testid="input-call-name"
                    />
                  </div>
                </div>
                <div className="space-y-2">
                  <Label>First Names (full)</Label>
                  <Input
                    value={form.firstNames}
                    onChange={e => setForm(p => ({ ...p, firstNames: e.target.value }))}
                    data-testid="input-first-names"
                  />
                </div>
                <div className="space-y-2">
                  <Label>Alias</Label>
                  <Input
                    value={form.alias}
                    onChange={e => setForm(p => ({ ...p, alias: e.target.value }))}
                    placeholder="Auto-generated if empty"
                    data-testid="input-alias"
                  />
                </div>
                <Button
                  onClick={() => createStudent.mutate()}
                  disabled={!form.id || !form.surname || !form.callName || createStudent.isPending}
                  className="w-full"
                  data-testid="button-submit-student"
                >
                  {createStudent.isPending ? "Adding..." : "Add Student"}
                </Button>
              </div>
            </DialogContent>
          </Dialog>
        )}
      </div>

      <div>
        <Input
          placeholder="Search students..."
          value={search}
          onChange={e => setSearch(e.target.value)}
          className="max-w-sm"
          data-testid="input-search"
        />
      </div>

      <Card>
        <CardContent className="p-0">
          <table className="w-full text-sm" data-testid="table-students">
            <thead>
              <tr className="border-b">
                <th className="text-left py-3 px-4 font-medium text-muted-foreground">ID</th>
                <th className="text-left py-3 px-4 font-medium text-muted-foreground">Call Name</th>
                <th className="text-left py-3 px-4 font-medium text-muted-foreground">Surname</th>
                <th className="text-left py-3 px-4 font-medium text-muted-foreground">Full Names</th>
                <th className="text-left py-3 px-4 font-medium text-muted-foreground">Alias</th>
                {isTeacher && (
                  <th className="text-right py-3 px-4 font-medium text-muted-foreground">Actions</th>
                )}
              </tr>
            </thead>
            <tbody>
              {filteredStudents && filteredStudents.length > 0 ? filteredStudents.map(student => (
                <tr key={student.id} className="border-b last:border-0" data-testid={`row-student-${student.id}`}>
                  <td className="py-3 px-4 text-muted-foreground font-mono">{student.id}</td>
                  <td className="py-3 px-4 font-medium">{student.callName}</td>
                  <td className="py-3 px-4">{student.surname}</td>
                  <td className="py-3 px-4 text-muted-foreground text-xs">{student.firstNames || "—"}</td>
                  <td className="py-3 px-4 text-muted-foreground">{student.alias}</td>
                  {isTeacher && (
                    <td className="py-3 px-4 text-right">
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => deleteStudent.mutate(student.id)}
                        className="text-destructive"
                        data-testid={`button-delete-${student.id}`}
                      >
                        Remove
                      </Button>
                    </td>
                  )}
                </tr>
              )) : (
                <tr>
                  <td colSpan={isTeacher ? 6 : 5} className="text-center py-8 text-muted-foreground">
                    {search ? "No students match your search." : "No students found."}
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </CardContent>
      </Card>
    </div>
  );
}
