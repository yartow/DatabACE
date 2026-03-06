import { useQuery, useMutation } from "@tanstack/react-query";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { useToast } from "@/hooks/use-toast";
import { useState } from "react";
import type { Student, Family } from "@shared/schema";
import { apiRequest, queryClient } from "@/lib/queryClient";
import { Plus, Users } from "lucide-react";

export default function StudentsPage() {
  const { toast } = useToast();
  const [open, setOpen] = useState(false);
  const [familyOpen, setFamilyOpen] = useState(false);
  const [form, setForm] = useState({ firstName: "", lastName: "", familyId: "", classGroup: "" });
  const [familyName, setFamilyName] = useState("");

  const { data: students, isLoading } = useQuery<Student[]>({ queryKey: ["/api/students"] });
  const { data: families } = useQuery<Family[]>({ queryKey: ["/api/families"] });

  const createStudent = useMutation({
    mutationFn: async () => {
      await apiRequest("POST", "/api/students", {
        firstName: form.firstName,
        lastName: form.lastName,
        familyId: parseInt(form.familyId),
        classGroup: form.classGroup || null,
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/students"] });
      queryClient.invalidateQueries({ queryKey: ["/api/dashboard/stats"] });
      setOpen(false);
      setForm({ firstName: "", lastName: "", familyId: "", classGroup: "" });
      toast({ title: "Student added successfully" });
    },
    onError: () => toast({ title: "Failed to add student", variant: "destructive" }),
  });

  const createFamily = useMutation({
    mutationFn: async () => {
      await apiRequest("POST", "/api/families", { name: familyName });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/families"] });
      setFamilyOpen(false);
      setFamilyName("");
      toast({ title: "Family created" });
    },
    onError: () => toast({ title: "Failed to create family", variant: "destructive" }),
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

  const familyMap = new Map(families?.map(f => [f.id, f]) || []);

  return (
    <div className="p-6 max-w-6xl mx-auto space-y-6">
      <div className="flex items-center justify-between gap-4 flex-wrap">
        <div>
          <h1 className="text-2xl font-serif font-bold tracking-tight" data-testid="text-page-title">Students</h1>
          <p className="text-muted-foreground mt-1">Manage student records and family associations.</p>
        </div>
        <div className="flex flex-wrap gap-2">
          <Dialog open={familyOpen} onOpenChange={setFamilyOpen}>
            <DialogTrigger asChild>
              <Button variant="secondary" data-testid="button-add-family">
                <Users className="w-4 h-4 mr-2" />
                Add Family
              </Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>Add New Family</DialogTitle>
              </DialogHeader>
              <div className="space-y-4 pt-2">
                <div className="space-y-2">
                  <Label>Family Name</Label>
                  <Input
                    value={familyName}
                    onChange={e => setFamilyName(e.target.value)}
                    placeholder="e.g. Smith"
                    data-testid="input-family-name"
                  />
                </div>
                <Button
                  onClick={() => createFamily.mutate()}
                  disabled={!familyName || createFamily.isPending}
                  className="w-full"
                  data-testid="button-submit-family"
                >
                  {createFamily.isPending ? "Creating..." : "Create Family"}
                </Button>
              </div>
            </DialogContent>
          </Dialog>

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
                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label>First Name</Label>
                    <Input
                      value={form.firstName}
                      onChange={e => setForm(p => ({ ...p, firstName: e.target.value }))}
                      data-testid="input-first-name"
                    />
                  </div>
                  <div className="space-y-2">
                    <Label>Last Name</Label>
                    <Input
                      value={form.lastName}
                      onChange={e => setForm(p => ({ ...p, lastName: e.target.value }))}
                      data-testid="input-last-name"
                    />
                  </div>
                </div>
                <div className="space-y-2">
                  <Label>Family</Label>
                  <Select value={form.familyId} onValueChange={v => setForm(p => ({ ...p, familyId: v }))}>
                    <SelectTrigger data-testid="select-family">
                      <SelectValue placeholder="Select family" />
                    </SelectTrigger>
                    <SelectContent>
                      {families?.map(f => (
                        <SelectItem key={f.id} value={f.id.toString()}>{f.name}</SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
                <div className="space-y-2">
                  <Label>Class Group</Label>
                  <Input
                    value={form.classGroup}
                    onChange={e => setForm(p => ({ ...p, classGroup: e.target.value }))}
                    placeholder="e.g. Grade 8A"
                    data-testid="input-class-group"
                  />
                </div>
                <Button
                  onClick={() => createStudent.mutate()}
                  disabled={!form.firstName || !form.lastName || !form.familyId || createStudent.isPending}
                  className="w-full"
                  data-testid="button-submit-student"
                >
                  {createStudent.isPending ? "Adding..." : "Add Student"}
                </Button>
              </div>
            </DialogContent>
          </Dialog>
        </div>
      </div>

      <Card>
        <CardContent className="p-0">
          <table className="w-full text-sm" data-testid="table-students">
            <thead>
              <tr className="border-b">
                <th className="text-left py-3 px-4 font-medium text-muted-foreground">Name</th>
                <th className="text-left py-3 px-4 font-medium text-muted-foreground">Family</th>
                <th className="text-left py-3 px-4 font-medium text-muted-foreground">Class</th>
                <th className="text-right py-3 px-4 font-medium text-muted-foreground">Actions</th>
              </tr>
            </thead>
            <tbody>
              {students && students.length > 0 ? students.map(student => (
                <tr key={student.id} className="border-b last:border-0" data-testid={`row-student-${student.id}`}>
                  <td className="py-3 px-4 font-medium">{student.firstName} {student.lastName}</td>
                  <td className="py-3 px-4 text-muted-foreground">{familyMap.get(student.familyId)?.name || "—"}</td>
                  <td className="py-3 px-4 text-muted-foreground">{student.classGroup || "—"}</td>
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
                </tr>
              )) : (
                <tr>
                  <td colSpan={4} className="text-center py-8 text-muted-foreground">No students found.</td>
                </tr>
              )}
            </tbody>
          </table>
        </CardContent>
      </Card>
    </div>
  );
}
