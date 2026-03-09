import { useQuery, useMutation } from "@tanstack/react-query";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Switch } from "@/components/ui/switch";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Badge } from "@/components/ui/badge";
import { useToast } from "@/hooks/use-toast";
import { useState } from "react";
import type { Student, UserProfile } from "@shared/schema";
import { apiRequest, queryClient } from "@/lib/queryClient";
import { Plus } from "lucide-react";
import { useQuery as useProfileQuery } from "@tanstack/react-query";

interface StudentForm {
  surname: string;
  firstNames: string;
  callName: string;
  alias: string;
  isDyslexic: boolean;
  active: boolean;
  reasonInactive: string;
  remarks: string;
}

const INACTIVE_REASONS = ["Moved", "Graduated", "Left school early", "Expelled", "Other"];

export default function StudentsPage() {
  const { toast } = useToast();
  const [open, setOpen] = useState(false);
  const [form, setForm] = useState<StudentForm>({
    surname: "", firstNames: "", callName: "", alias: "",
    isDyslexic: false, active: true, reasonInactive: "", remarks: "",
  });
  const [search, setSearch] = useState("");

  const { data: students, isLoading } = useQuery<Student[]>({ queryKey: ["/api/students"] });
  const { data: profile } = useProfileQuery<UserProfile>({ queryKey: ["/api/profile"] });

  const isTeacher = profile?.role === "teacher";

  const createStudent = useMutation({
    mutationFn: async () => {
      await apiRequest("POST", "/api/students", {
        surname: form.surname,
        firstNames: form.firstNames || null,
        callName: form.callName,
        alias: form.alias || `${form.callName} ${form.surname}`,
        isDyslexic: form.isDyslexic,
        active: form.active,
        reasonInactive: !form.active && form.reasonInactive ? form.reasonInactive : null,
        remarks: form.remarks || null,
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/students"] });
      queryClient.invalidateQueries({ queryKey: ["/api/dashboard/stats"] });
      setOpen(false);
      setForm({
        surname: "", firstNames: "", callName: "", alias: "",
        isDyslexic: false, active: true, reasonInactive: "", remarks: "",
      });
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
            <DialogContent className="max-w-lg">
              <DialogHeader>
                <DialogTitle>Add New Student</DialogTitle>
              </DialogHeader>
              <div className="space-y-4 pt-2">
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
                <div className="flex items-center justify-between border rounded-md p-3">
                  <Label htmlFor="is-dyslexic" className="cursor-pointer">Is dyslexic?</Label>
                  <Switch
                    id="is-dyslexic"
                    checked={form.isDyslexic}
                    onCheckedChange={v => setForm(p => ({ ...p, isDyslexic: v }))}
                    data-testid="switch-dyslexic"
                  />
                </div>
                <div className="flex items-center justify-between border rounded-md p-3">
                  <Label htmlFor="is-active" className="cursor-pointer">Active</Label>
                  <Switch
                    id="is-active"
                    checked={form.active}
                    onCheckedChange={v => setForm(p => ({ ...p, active: v, reasonInactive: v ? "" : p.reasonInactive }))}
                    data-testid="switch-active"
                  />
                </div>
                {!form.active && (
                  <div className="space-y-2">
                    <Label>Reason Inactive</Label>
                    <Select value={form.reasonInactive} onValueChange={v => setForm(p => ({ ...p, reasonInactive: v }))}>
                      <SelectTrigger data-testid="select-reason-inactive">
                        <SelectValue placeholder="Select reason..." />
                      </SelectTrigger>
                      <SelectContent>
                        {INACTIVE_REASONS.map(r => (
                          <SelectItem key={r} value={r}>{r}</SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                )}
                <div className="space-y-2">
                  <Label>Remarks</Label>
                  <Textarea
                    value={form.remarks}
                    onChange={e => setForm(p => ({ ...p, remarks: e.target.value.slice(0, 1250) }))}
                    maxLength={1250}
                    placeholder="Remarks (max 1250 characters)..."
                    className="min-h-[60px]"
                    data-testid="input-remarks"
                  />
                </div>
                <Button
                  onClick={() => createStudent.mutate()}
                  disabled={!form.surname || !form.callName || createStudent.isPending}
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
          <div className="overflow-x-auto">
            <table className="w-full text-sm" data-testid="table-students">
              <thead>
                <tr className="border-b">
                  <th className="text-left py-3 px-4 font-medium text-muted-foreground">ID</th>
                  <th className="text-left py-3 px-4 font-medium text-muted-foreground">Call Name</th>
                  <th className="text-left py-3 px-4 font-medium text-muted-foreground">Surname</th>
                  <th className="text-left py-3 px-4 font-medium text-muted-foreground">Full Names</th>
                  <th className="text-center py-3 px-4 font-medium text-muted-foreground">Status</th>
                  <th className="text-center py-3 px-4 font-medium text-muted-foreground">Dyslexic</th>
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
                    <td className="py-3 px-4 text-center">
                      {student.active ? (
                        <Badge variant="secondary" className="bg-emerald-100 text-emerald-800 dark:bg-emerald-900 dark:text-emerald-200" data-testid={`badge-active-${student.id}`}>Active</Badge>
                      ) : (
                        <Badge variant="secondary" className="bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200" data-testid={`badge-inactive-${student.id}`}>
                          {student.reasonInactive || "Inactive"}
                        </Badge>
                      )}
                    </td>
                    <td className="py-3 px-4 text-center text-muted-foreground">
                      {student.isDyslexic ? "Yes" : "—"}
                    </td>
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
                    <td colSpan={isTeacher ? 7 : 6} className="text-center py-8 text-muted-foreground">
                      {search ? "No students match your search." : "No students found."}
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
