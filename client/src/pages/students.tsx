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
import { useState, useMemo, useRef, useEffect } from "react";
import type { Student, UserProfile, Personnel, Family, Parent } from "@shared/schema";
import { apiRequest, queryClient } from "@/lib/queryClient";
import { Plus, Pencil, Info } from "lucide-react";
import { Tooltip, TooltipContent, TooltipTrigger } from "@/components/ui/tooltip";

type ViewType = "students" | "personnel" | "parents" | "families";

const INACTIVE_REASONS = ["Moved", "Graduated", "Left school early", "Expelled", "Other"];
const PERSONNEL_GROUPS = ["Kindergarten", "ABCs", "Juniors", "Seniors"];
const PERSONNEL_TYPES = ["Supervisor", "Monitor", "Intern", "Secretary", "Board Member", "Principal"];

function stripPhone(phone: string): string {
  return phone.replace(/[\s\-()]/g, "");
}

export default function StudentsPage() {
  const { toast } = useToast();
  const [view, setView] = useState<ViewType>("students");
  const [search, setSearch] = useState("");

  const { data: profile } = useQuery<UserProfile>({ queryKey: ["/api/profile"] });
  const isTeacher = profile?.role === "teacher";

  return (
    <div className="p-6 max-w-6xl mx-auto space-y-6">
      <div className="flex items-center justify-between gap-4 flex-wrap">
        <div className="flex items-center gap-4">
          <Select value={view} onValueChange={(v) => { setView(v as ViewType); setSearch(""); }}>
            <SelectTrigger className="w-[200px]" data-testid="select-view">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="students">Students</SelectItem>
              <SelectItem value="personnel">Personnel</SelectItem>
              <SelectItem value="parents">Parents</SelectItem>
              <SelectItem value="families">Families</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </div>

      {view === "students" && <StudentsView isTeacher={isTeacher} search={search} setSearch={setSearch} />}
      {view === "personnel" && <PersonnelView isTeacher={isTeacher} search={search} setSearch={setSearch} />}
      {view === "parents" && <ParentsView isTeacher={isTeacher} search={search} setSearch={setSearch} />}
      {view === "families" && <FamiliesView isTeacher={isTeacher} search={search} setSearch={setSearch} />}
    </div>
  );
}

interface ViewProps {
  isTeacher: boolean;
  search: string;
  setSearch: (s: string) => void;
}

function StudentsView({ isTeacher, search, setSearch }: ViewProps) {
  const { toast } = useToast();
  const [open, setOpen] = useState(false);
  const [editId, setEditId] = useState<number | null>(null);
  const [statusFilter, setStatusFilter] = useState<"active" | "inactive" | "all">("active");
  const emptyForm = {
    surname: "", firstNames: "", callName: "", alias: "",
    isDyslexic: false, active: true, reasonInactive: "", remarks: "",
    dateOfBirth: "", familyId: "", group: "",
  };
  const [form, setForm] = useState(emptyForm);

  const { data: students } = useQuery<Student[]>({ queryKey: ["/api/students"] });
  const { data: familiesList } = useQuery<Family[]>({ queryKey: ["/api/families"] });

  const createStudent = useMutation({
    mutationFn: async () => {
      const body = {
        surname: form.surname,
        firstNames: form.firstNames || null,
        callName: form.callName,
        alias: form.alias || `${form.callName} ${form.surname}`,
        isDyslexic: form.isDyslexic,
        active: form.active,
        reasonInactive: !form.active && form.reasonInactive ? form.reasonInactive : null,
        remarks: form.remarks || null,
        dateOfBirth: form.dateOfBirth || null,
        familyId: form.familyId && form.familyId !== "0" ? parseInt(form.familyId) : null,
        group: form.group || null,
      };
      await apiRequest("POST", "/api/students", body);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/students"] });
      queryClient.invalidateQueries({ queryKey: ["/api/dashboard/stats"] });
      setOpen(false);
      setForm(emptyForm);
      toast({ title: "Student added successfully" });
    },
    onError: () => toast({ title: "Failed to add student", variant: "destructive" }),
  });

  const updateStudent = useMutation({
    mutationFn: async () => {
      if (!editId) return;
      const body = {
        surname: form.surname,
        firstNames: form.firstNames || null,
        callName: form.callName,
        alias: form.alias || `${form.callName} ${form.surname}`,
        isDyslexic: form.isDyslexic,
        active: form.active,
        reasonInactive: !form.active && form.reasonInactive ? form.reasonInactive : null,
        remarks: form.remarks || null,
        dateOfBirth: form.dateOfBirth || null,
        familyId: form.familyId && form.familyId !== "0" ? parseInt(form.familyId) : null,
        group: form.group || null,
      };
      await apiRequest("PATCH", `/api/students/${editId}`, body);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/students"] });
      setOpen(false);
      setEditId(null);
      setForm(emptyForm);
      toast({ title: "Student updated" });
    },
    onError: () => toast({ title: "Failed to update student", variant: "destructive" }),
  });

  const deleteStudent = useMutation({
    mutationFn: async (id: number) => { await apiRequest("DELETE", `/api/students/${id}`); },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/students"] });
      queryClient.invalidateQueries({ queryKey: ["/api/dashboard/stats"] });
      toast({ title: "Student removed" });
    },
  });

  function openEdit(s: Student) {
    setEditId(s.id);
    setForm({
      surname: s.surname, firstNames: s.firstNames || "", callName: s.callName,
      alias: s.alias, isDyslexic: s.isDyslexic, active: s.active,
      reasonInactive: s.reasonInactive || "", remarks: s.remarks || "",
      dateOfBirth: s.dateOfBirth || "", familyId: s.familyId ? String(s.familyId) : "",
      group: s.group || "",
    });
    setOpen(true);
  }

  function openAdd() {
    setEditId(null);
    setForm(emptyForm);
    setOpen(true);
  }

  const filteredStudents = students?.filter(s => {
    if (statusFilter === "active" && !s.active) return false;
    if (statusFilter === "inactive" && s.active) return false;
    if (!search) return true;
    const q = search.toLowerCase();
    return s.surname.toLowerCase().includes(q) || s.callName.toLowerCase().includes(q) ||
      s.alias.toLowerCase().includes(q) || (s.firstNames?.toLowerCase().includes(q));
  });

  return (
    <>
      <div className="flex items-center justify-between gap-4 flex-wrap">
        <div>
          <h1 className="text-2xl font-serif font-bold tracking-tight" data-testid="text-page-title">Students</h1>
          <p className="text-muted-foreground mt-1">{students?.length || 0} students</p>
        </div>
        {isTeacher && (
          <Button onClick={openAdd} data-testid="button-add-student"><Plus className="w-4 h-4 mr-2" />Add Student</Button>
        )}
      </div>

      <div className="flex items-center gap-3 flex-wrap">
        <Input placeholder="Search students..." value={search} onChange={e => setSearch(e.target.value)} className="max-w-sm" data-testid="input-search" />
        <Select value={statusFilter} onValueChange={(v) => setStatusFilter(v as "active" | "inactive" | "all")}>
          <SelectTrigger className="w-[140px]" data-testid="select-status-filter">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="active">Active only</SelectItem>
            <SelectItem value="inactive">Inactive only</SelectItem>
            <SelectItem value="all">All students</SelectItem>
          </SelectContent>
        </Select>
      </div>

      <Dialog open={open} onOpenChange={(v) => { setOpen(v); if (!v) setEditId(null); }}>
        <DialogContent className="max-w-lg max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>{editId ? "Edit Student" : "Add New Student"}</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 pt-2">
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>Surname</Label>
                <Input value={form.surname} onChange={e => setForm(p => ({ ...p, surname: e.target.value }))} data-testid="input-surname" />
              </div>
              <div className="space-y-2">
                <Label>Call Name</Label>
                <Input value={form.callName} onChange={e => setForm(p => ({ ...p, callName: e.target.value }))} data-testid="input-call-name" />
              </div>
            </div>
            <div className="space-y-2">
              <Label>First Names (full)</Label>
              <Input value={form.firstNames} onChange={e => setForm(p => ({ ...p, firstNames: e.target.value }))} data-testid="input-first-names" />
            </div>
            <div className="space-y-2">
              <Label>Alias</Label>
              <Input value={form.alias} onChange={e => setForm(p => ({ ...p, alias: e.target.value }))} placeholder="Auto-generated if empty" data-testid="input-alias" />
            </div>
            <div className="space-y-2">
              <Label>Date of Birth</Label>
              <Input type="date" value={form.dateOfBirth} onChange={e => setForm(p => ({ ...p, dateOfBirth: e.target.value }))} data-testid="input-dob" />
            </div>
            <div className="space-y-2">
              <Label>Family</Label>
              <FamilyAutocomplete
                value={form.familyId ? parseInt(form.familyId) : null}
                onChange={id => setForm(p => ({ ...p, familyId: id ? String(id) : "" }))}
                families={familiesList || []}
              />
            </div>
            <div className="space-y-2">
              <Label>Group</Label>
              <Select value={form.group} onValueChange={v => setForm(p => ({ ...p, group: v }))}>
                <SelectTrigger data-testid="select-student-group"><SelectValue placeholder="Select group..." /></SelectTrigger>
                <SelectContent>
                  {PERSONNEL_GROUPS.map(g => <SelectItem key={g} value={g}>{g}</SelectItem>)}
                </SelectContent>
              </Select>
            </div>
            <div className="flex items-center justify-between border rounded-md p-3">
              <Label htmlFor="is-dyslexic" className="cursor-pointer">Is dyslexic?</Label>
              <Switch id="is-dyslexic" checked={form.isDyslexic} onCheckedChange={v => setForm(p => ({ ...p, isDyslexic: v }))} data-testid="switch-dyslexic" />
            </div>
            <div className="flex items-center justify-between border rounded-md p-3">
              <Label htmlFor="is-active" className="cursor-pointer">Active</Label>
              <Switch id="is-active" checked={form.active} onCheckedChange={v => setForm(p => ({ ...p, active: v, reasonInactive: v ? "" : p.reasonInactive }))} data-testid="switch-active" />
            </div>
            {!form.active && (
              <div className="space-y-2">
                <Label>Reason Inactive</Label>
                <Select value={form.reasonInactive} onValueChange={v => setForm(p => ({ ...p, reasonInactive: v }))}>
                  <SelectTrigger data-testid="select-reason-inactive"><SelectValue placeholder="Select reason..." /></SelectTrigger>
                  <SelectContent>
                    {INACTIVE_REASONS.map(r => (<SelectItem key={r} value={r}>{r}</SelectItem>))}
                  </SelectContent>
                </Select>
              </div>
            )}
            <div className="space-y-2">
              <Label>Remarks</Label>
              <Textarea value={form.remarks} onChange={e => setForm(p => ({ ...p, remarks: e.target.value.slice(0, 1250) }))} maxLength={1250} placeholder="Remarks (max 1250 characters)..." className="min-h-[60px]" data-testid="input-remarks" />
            </div>
            <Button
              onClick={() => editId ? updateStudent.mutate() : createStudent.mutate()}
              disabled={!form.surname || !form.callName || createStudent.isPending || updateStudent.isPending}
              className="w-full"
              data-testid="button-submit-student"
            >
              {(createStudent.isPending || updateStudent.isPending) ? "Saving..." : editId ? "Save Changes" : "Add Student"}
            </Button>
            {editId && isTeacher && (
              <Button
                variant="ghost"
                className="w-full text-destructive hover:text-destructive"
                onClick={() => { deleteStudent.mutate(editId); setOpen(false); setEditId(null); }}
                disabled={deleteStudent.isPending}
                data-testid="button-delete-student-dialog"
              >
                {deleteStudent.isPending ? "Removing..." : "Remove Student"}
              </Button>
            )}
          </div>
        </DialogContent>
      </Dialog>

      <Card>
        <CardContent className="p-0">
          <div className="overflow-x-auto">
            <table className="w-full text-sm" data-testid="table-students">
              <thead>
                <tr className="border-b">
                  <th className="text-left py-3 px-4 font-medium text-muted-foreground">Call Name</th>
                  <th className="text-left py-3 px-4 font-medium text-muted-foreground">Surname</th>
                  <th className="text-left py-3 px-4 font-medium text-muted-foreground">Full Names</th>
                  <th className="text-left py-3 px-4 font-medium text-muted-foreground">Date of Birth</th>
                  <th className="text-left py-3 px-4 font-medium text-muted-foreground">Group</th>
                  <th className="text-center py-3 px-4 font-medium text-muted-foreground">Status</th>
                  <th className="text-center py-3 px-4 font-medium text-muted-foreground">Dyslexic</th>
                  <th className="text-left py-3 px-4 font-medium text-muted-foreground">Remarks</th>
                  {isTeacher && <th className="text-right py-3 px-4 font-medium text-muted-foreground">Actions</th>}
                </tr>
              </thead>
              <tbody>
                {filteredStudents && filteredStudents.length > 0 ? filteredStudents.map(student => (
                  <tr key={student.id} className="border-b last:border-0" data-testid={`row-student-${student.id}`}>
                    <td className="py-3 px-4 font-medium">{student.callName}</td>
                    <td className="py-3 px-4">{student.surname}</td>
                    <td className="py-3 px-4 text-muted-foreground text-xs">{student.firstNames || "—"}</td>
                    <td className="py-3 px-4 text-muted-foreground text-xs" data-testid={`text-dob-${student.id}`}>{student.dateOfBirth || "—"}</td>
                    <td className="py-3 px-4">{student.group ? <Badge variant="secondary">{student.group}</Badge> : "—"}</td>
                    <td className="py-3 px-4 text-center">
                      {student.active ? (
                        <Badge variant="secondary" className="bg-emerald-100 text-emerald-800 dark:bg-emerald-900 dark:text-emerald-200" data-testid={`badge-active-${student.id}`}>Active</Badge>
                      ) : (
                        <span className="inline-flex items-center gap-1">
                          <Badge variant="secondary" className="bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200" data-testid={`badge-inactive-${student.id}`}>Inactive</Badge>
                          {student.reasonInactive && (
                            <Tooltip>
                              <TooltipTrigger asChild>
                                <Info className="w-3.5 h-3.5 text-muted-foreground cursor-help" data-testid={`icon-inactive-reason-${student.id}`} />
                              </TooltipTrigger>
                              <TooltipContent>
                                <p>{student.reasonInactive}</p>
                              </TooltipContent>
                            </Tooltip>
                          )}
                        </span>
                      )}
                    </td>
                    <td className="py-3 px-4 text-center text-muted-foreground">{student.isDyslexic ? "Yes" : "—"}</td>
                    <td className="py-3 px-4 text-muted-foreground text-xs max-w-[200px] truncate" data-testid={`text-remarks-${student.id}`} title={student.remarks || ""}>{student.remarks || "—"}</td>
                    {isTeacher && (
                      <td className="py-3 px-4 text-right">
                        <Button variant="ghost" size="sm" onClick={() => openEdit(student)} data-testid={`button-edit-${student.id}`}>
                          <Pencil className="w-3.5 h-3.5" />
                        </Button>
                      </td>
                    )}
                  </tr>
                )) : (
                  <tr><td colSpan={isTeacher ? 9 : 8} className="text-center py-8 text-muted-foreground">{search ? "No students match your search." : "No students found."}</td></tr>
                )}
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>
    </>
  );
}

function PersonnelView({ isTeacher, search, setSearch }: ViewProps) {
  const { toast } = useToast();
  const [open, setOpen] = useState(false);
  const [editId, setEditId] = useState<number | null>(null);
  const emptyForm = { firstName: "", lastName: "", group: "", type: "", rank: "", email: "", isAdmin: false };
  const [form, setForm] = useState(emptyForm);

  const { data: personnelList } = useQuery<Personnel[]>({ queryKey: ["/api/personnel"] });

  const create = useMutation({
    mutationFn: async () => { await apiRequest("POST", "/api/personnel", { ...form, rank: form.rank ? parseInt(form.rank) : null, email: form.email || null }); },
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ["/api/personnel"] }); setOpen(false); setForm(emptyForm); toast({ title: "Personnel added" }); },
    onError: () => toast({ title: "Failed to add personnel", variant: "destructive" }),
  });

  const update = useMutation({
    mutationFn: async () => { if (!editId) return; await apiRequest("PATCH", `/api/personnel/${editId}`, { ...form, rank: form.rank ? parseInt(form.rank) : null, email: form.email || null }); },
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ["/api/personnel"] }); setOpen(false); setEditId(null); setForm(emptyForm); toast({ title: "Personnel updated" }); },
    onError: () => toast({ title: "Failed to update", variant: "destructive" }),
  });

  const remove = useMutation({
    mutationFn: async (id: number) => { await apiRequest("DELETE", `/api/personnel/${id}`); },
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ["/api/personnel"] }); toast({ title: "Personnel removed" }); },
  });

  function openEdit(p: Personnel) {
    setEditId(p.id); setForm({ firstName: p.firstName, lastName: p.lastName, group: p.group, type: p.type, rank: p.rank?.toString() || "", email: p.email || "", isAdmin: p.isAdmin }); setOpen(true);
  }

  const filtered = personnelList?.filter(p => {
    if (!search) return true;
    const q = search.toLowerCase();
    return p.firstName.toLowerCase().includes(q) || p.lastName.toLowerCase().includes(q) || p.group.toLowerCase().includes(q) || p.type.toLowerCase().includes(q);
  });

  return (
    <>
      <div className="flex items-center justify-between gap-4 flex-wrap">
        <div>
          <h1 className="text-2xl font-serif font-bold tracking-tight" data-testid="text-page-title">Personnel</h1>
          <p className="text-muted-foreground mt-1">{personnelList?.length || 0} members</p>
        </div>
        {isTeacher && <Button onClick={() => { setEditId(null); setForm(emptyForm); setOpen(true); }} data-testid="button-add-personnel"><Plus className="w-4 h-4 mr-2" />Add Personnel</Button>}
      </div>

      <Input placeholder="Search personnel..." value={search} onChange={e => setSearch(e.target.value)} className="max-w-sm" data-testid="input-search" />

      <Dialog open={open} onOpenChange={(v) => { setOpen(v); if (!v) setEditId(null); }}>
        <DialogContent className="max-w-md">
          <DialogHeader><DialogTitle>{editId ? "Edit Personnel" : "Add Personnel"}</DialogTitle></DialogHeader>
          <div className="space-y-4 pt-2">
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>First Name</Label>
                <Input value={form.firstName} onChange={e => setForm(p => ({ ...p, firstName: e.target.value }))} data-testid="input-first-name" />
              </div>
              <div className="space-y-2">
                <Label>Last Name</Label>
                <Input value={form.lastName} onChange={e => setForm(p => ({ ...p, lastName: e.target.value }))} data-testid="input-last-name" />
              </div>
            </div>
            <div className="space-y-2">
              <Label>Group</Label>
              <Select value={form.group} onValueChange={v => setForm(p => ({ ...p, group: v }))}>
                <SelectTrigger data-testid="select-group"><SelectValue placeholder="Select group..." /></SelectTrigger>
                <SelectContent>
                  {PERSONNEL_GROUPS.map(g => <SelectItem key={g} value={g}>{g}</SelectItem>)}
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-2">
              <Label>Type</Label>
              <Select value={form.type} onValueChange={v => setForm(p => ({ ...p, type: v }))}>
                <SelectTrigger data-testid="select-type"><SelectValue placeholder="Select type..." /></SelectTrigger>
                <SelectContent>
                  {PERSONNEL_TYPES.map(t => <SelectItem key={t} value={t}>{t}</SelectItem>)}
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-2">
              <Label>Rank</Label>
              <Input type="number" min="1" value={form.rank} onChange={e => setForm(p => ({ ...p, rank: e.target.value }))} placeholder="e.g. 1" data-testid="input-rank" />
            </div>
            <div className="space-y-2">
              <Label>Email</Label>
              <Input type="email" value={form.email} onChange={e => setForm(p => ({ ...p, email: e.target.value }))} placeholder="email@example.com" data-testid="input-email" />
            </div>
            <div className="flex items-center justify-between border rounded-md p-3">
              <Label htmlFor="is-admin-personnel" className="cursor-pointer">Admin</Label>
              <Switch id="is-admin-personnel" checked={form.isAdmin} onCheckedChange={v => setForm(p => ({ ...p, isAdmin: v }))} data-testid="switch-admin" />
            </div>
            <Button
              onClick={() => editId ? update.mutate() : create.mutate()}
              disabled={!form.firstName || !form.lastName || !form.group || !form.type || create.isPending || update.isPending}
              className="w-full" data-testid="button-submit-personnel"
            >
              {(create.isPending || update.isPending) ? "Saving..." : editId ? "Save Changes" : "Add Personnel"}
            </Button>
          </div>
        </DialogContent>
      </Dialog>

      <Card>
        <CardContent className="p-0">
          <div className="overflow-x-auto">
            <table className="w-full text-sm" data-testid="table-personnel">
              <thead>
                <tr className="border-b">
                  <th className="text-left py-3 px-4 font-medium text-muted-foreground">First Name</th>
                  <th className="text-left py-3 px-4 font-medium text-muted-foreground">Last Name</th>
                  <th className="text-left py-3 px-4 font-medium text-muted-foreground">Email</th>
                  <th className="text-left py-3 px-4 font-medium text-muted-foreground">Group</th>
                  <th className="text-left py-3 px-4 font-medium text-muted-foreground">Type</th>
                  <th className="text-left py-3 px-4 font-medium text-muted-foreground">Rank</th>
                  <th className="text-center py-3 px-4 font-medium text-muted-foreground">Admin</th>
                  {isTeacher && <th className="text-right py-3 px-4 font-medium text-muted-foreground">Actions</th>}
                </tr>
              </thead>
              <tbody>
                {filtered && filtered.length > 0 ? filtered.map(p => (
                  <tr key={p.id} className="border-b last:border-0" data-testid={`row-personnel-${p.id}`}>
                    <td className="py-3 px-4 font-medium">{p.firstName}</td>
                    <td className="py-3 px-4">{p.lastName}</td>
                    <td className="py-3 px-4 text-muted-foreground text-xs" data-testid={`text-email-${p.id}`}>{p.email || "—"}</td>
                    <td className="py-3 px-4"><Badge variant="secondary">{p.group}</Badge></td>
                    <td className="py-3 px-4"><Badge variant="outline">{p.type}</Badge></td>
                    <td className="py-3 px-4">{p.rank ?? "—"}</td>
                    <td className="py-3 px-4 text-center" data-testid={`text-admin-${p.id}`}>{p.isAdmin ? <Badge variant="secondary" className="bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200">Admin</Badge> : "—"}</td>
                    {isTeacher && (
                      <td className="py-3 px-4 text-right space-x-1">
                        <Button variant="ghost" size="sm" onClick={() => openEdit(p)} data-testid={`button-edit-${p.id}`}><Pencil className="w-3.5 h-3.5" /></Button>
                        <Button variant="ghost" size="sm" onClick={() => remove.mutate(p.id)} className="text-destructive" data-testid={`button-delete-${p.id}`}>Remove</Button>
                      </td>
                    )}
                  </tr>
                )) : (
                  <tr><td colSpan={isTeacher ? 8 : 7} className="text-center py-8 text-muted-foreground">{search ? "No matches." : "No personnel found."}</td></tr>
                )}
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>
    </>
  );
}

function FamiliesView({ isTeacher, search, setSearch }: ViewProps) {
  const { toast } = useToast();
  const [open, setOpen] = useState(false);
  const [editId, setEditId] = useState<number | null>(null);
  const emptyForm = { firstName: "", lastName: "", address: "", city: "", postalCode: "" };
  const [form, setForm] = useState(emptyForm);

  const { data: familiesList } = useQuery<Family[]>({ queryKey: ["/api/families"] });

  const create = useMutation({
    mutationFn: async () => {
      await apiRequest("POST", "/api/families", {
        firstName: form.firstName, lastName: form.lastName,
        address: form.address || null, city: form.city || null, postalCode: form.postalCode || null,
      });
    },
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ["/api/families"] }); setOpen(false); setForm(emptyForm); toast({ title: "Family added" }); },
    onError: () => toast({ title: "Failed to add family", variant: "destructive" }),
  });

  const update = useMutation({
    mutationFn: async () => {
      if (!editId) return;
      await apiRequest("PATCH", `/api/families/${editId}`, {
        firstName: form.firstName, lastName: form.lastName,
        address: form.address || null, city: form.city || null, postalCode: form.postalCode || null,
      });
    },
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ["/api/families"] }); setOpen(false); setEditId(null); setForm(emptyForm); toast({ title: "Family updated" }); },
    onError: () => toast({ title: "Failed to update family", variant: "destructive" }),
  });

  const remove = useMutation({
    mutationFn: async (id: number) => { await apiRequest("DELETE", `/api/families/${id}`); },
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ["/api/families"] }); toast({ title: "Family removed" }); },
  });

  function openEdit(f: Family) {
    setEditId(f.id);
    setForm({ firstName: f.firstName, lastName: f.lastName, address: f.address || "", city: f.city || "", postalCode: f.postalCode || "" });
    setOpen(true);
  }

  const filtered = familiesList?.filter(f => {
    if (!search) return true;
    const q = search.toLowerCase();
    return f.firstName.toLowerCase().includes(q) || f.lastName.toLowerCase().includes(q) || (f.city?.toLowerCase().includes(q));
  });

  return (
    <>
      <div className="flex items-center justify-between gap-4 flex-wrap">
        <div>
          <h1 className="text-2xl font-serif font-bold tracking-tight" data-testid="text-page-title">Families</h1>
          <p className="text-muted-foreground mt-1">{familiesList?.length || 0} families</p>
        </div>
        {isTeacher && <Button onClick={() => { setEditId(null); setForm(emptyForm); setOpen(true); }} data-testid="button-add-family"><Plus className="w-4 h-4 mr-2" />Add Family</Button>}
      </div>

      <Input placeholder="Search families..." value={search} onChange={e => setSearch(e.target.value)} className="max-w-sm" data-testid="input-search" />

      <Dialog open={open} onOpenChange={(v) => { setOpen(v); if (!v) setEditId(null); }}>
        <DialogContent className="max-w-md">
          <DialogHeader><DialogTitle>{editId ? "Edit Family" : "Add Family"}</DialogTitle></DialogHeader>
          <div className="space-y-4 pt-2">
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>First Name</Label>
                <Input value={form.firstName} onChange={e => setForm(p => ({ ...p, firstName: e.target.value }))} data-testid="input-first-name" />
              </div>
              <div className="space-y-2">
                <Label>Last Name</Label>
                <Input value={form.lastName} onChange={e => setForm(p => ({ ...p, lastName: e.target.value }))} data-testid="input-last-name" />
              </div>
            </div>
            <div className="space-y-2">
              <Label>Address</Label>
              <Input value={form.address} onChange={e => setForm(p => ({ ...p, address: e.target.value.slice(0, 120) }))} maxLength={120} data-testid="input-address" />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>City</Label>
                <Input value={form.city} onChange={e => setForm(p => ({ ...p, city: e.target.value }))} data-testid="input-city" />
              </div>
              <div className="space-y-2">
                <Label>Postal Code</Label>
                <Input value={form.postalCode} onChange={e => setForm(p => ({ ...p, postalCode: e.target.value }))} data-testid="input-postal-code" />
              </div>
            </div>
            <Button
              onClick={() => editId ? update.mutate() : create.mutate()}
              disabled={!form.firstName || !form.lastName || create.isPending || update.isPending}
              className="w-full" data-testid="button-submit-family"
            >
              {(create.isPending || update.isPending) ? "Saving..." : editId ? "Save Changes" : "Add Family"}
            </Button>
          </div>
        </DialogContent>
      </Dialog>

      <Card>
        <CardContent className="p-0">
          <div className="overflow-x-auto">
            <table className="w-full text-sm" data-testid="table-families">
              <thead>
                <tr className="border-b">
                  <th className="text-left py-3 px-4 font-medium text-muted-foreground">First Name</th>
                  <th className="text-left py-3 px-4 font-medium text-muted-foreground">Last Name</th>
                  <th className="text-left py-3 px-4 font-medium text-muted-foreground">Address</th>
                  <th className="text-left py-3 px-4 font-medium text-muted-foreground">City</th>
                  <th className="text-left py-3 px-4 font-medium text-muted-foreground">Postal Code</th>
                  {isTeacher && <th className="text-right py-3 px-4 font-medium text-muted-foreground">Actions</th>}
                </tr>
              </thead>
              <tbody>
                {filtered && filtered.length > 0 ? filtered.map(f => (
                  <tr key={f.id} className="border-b last:border-0" data-testid={`row-family-${f.id}`}>
                    <td className="py-3 px-4 font-medium">{f.firstName}</td>
                    <td className="py-3 px-4">{f.lastName}</td>
                    <td className="py-3 px-4 text-muted-foreground text-xs">{f.address || "—"}</td>
                    <td className="py-3 px-4">{f.city || "—"}</td>
                    <td className="py-3 px-4">{f.postalCode || "—"}</td>
                    {isTeacher && (
                      <td className="py-3 px-4 text-right space-x-1">
                        <Button variant="ghost" size="sm" onClick={() => openEdit(f)} data-testid={`button-edit-${f.id}`}><Pencil className="w-3.5 h-3.5" /></Button>
                        <Button variant="ghost" size="sm" onClick={() => remove.mutate(f.id)} className="text-destructive" data-testid={`button-delete-${f.id}`}>Remove</Button>
                      </td>
                    )}
                  </tr>
                )) : (
                  <tr><td colSpan={isTeacher ? 6 : 5} className="text-center py-8 text-muted-foreground">{search ? "No matches." : "No families found."}</td></tr>
                )}
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>
    </>
  );
}

function FamilyAutocomplete({ value, onChange, families }: { value: number | null; onChange: (id: number | null) => void; families: Family[] }) {
  const [inputVal, setInputVal] = useState("");
  const [showDropdown, setShowDropdown] = useState(false);
  const [showCreateDialog, setShowCreateDialog] = useState(false);
  const [newFamily, setNewFamily] = useState({ firstName: "", lastName: "" });
  const [highlightIndex, setHighlightIndex] = useState(-1);
  const { toast } = useToast();
  const ref = useRef<HTMLDivElement>(null);

  const selectedFamily = families.find(f => f.id === value);

  useEffect(() => {
    if (selectedFamily) setInputVal(`${selectedFamily.firstName} ${selectedFamily.lastName}`);
    else setInputVal("");
  }, [value, selectedFamily]);

  useEffect(() => {
    function handleClickOutside(e: MouseEvent) {
      if (ref.current && !ref.current.contains(e.target as Node)) setShowDropdown(false);
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const filtered = families.filter(f => {
    if (!inputVal) return true;
    const q = inputVal.toLowerCase();
    return `${f.firstName} ${f.lastName}`.toLowerCase().includes(q);
  });

  const totalItems = filtered.length + 1;

  function handleKeyDown(e: React.KeyboardEvent) {
    if (!showDropdown) return;
    if (e.key === "ArrowDown") {
      e.preventDefault();
      setHighlightIndex(prev => (prev + 1) % totalItems);
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      setHighlightIndex(prev => (prev - 1 + totalItems) % totalItems);
    } else if (e.key === "Enter" && highlightIndex >= 0) {
      e.preventDefault();
      if (highlightIndex === 0) {
        setShowDropdown(false);
        setShowCreateDialog(true);
      } else {
        const fam = filtered[highlightIndex - 1];
        if (fam) { onChange(fam.id); setShowDropdown(false); }
      }
      setHighlightIndex(-1);
    } else if (e.key === "Escape") {
      setShowDropdown(false);
      setHighlightIndex(-1);
    }
  }

  const createFamily = useMutation({
    mutationFn: async () => {
      const res = await apiRequest("POST", "/api/families", {
        firstName: newFamily.firstName, lastName: newFamily.lastName,
        address: null, city: null, postalCode: null,
      });
      return res.json();
    },
    onSuccess: (data: Family) => {
      queryClient.invalidateQueries({ queryKey: ["/api/families"] });
      onChange(data.id);
      setShowCreateDialog(false);
      setNewFamily({ firstName: "", lastName: "" });
      toast({ title: "Family created" });
    },
    onError: () => toast({ title: "Failed to create family", variant: "destructive" }),
  });

  return (
    <div className="relative" ref={ref}>
      <Input
        value={inputVal}
        onChange={e => { setInputVal(e.target.value); setShowDropdown(true); setHighlightIndex(-1); if (!e.target.value) onChange(null); }}
        onFocus={() => setShowDropdown(true)}
        onKeyDown={handleKeyDown}
        placeholder="Add to family..."
        data-testid="input-family-search"
      />
      {showDropdown && (
        <div className="absolute z-50 top-full left-0 right-0 mt-1 bg-popover border rounded-md shadow-lg max-h-48 overflow-y-auto">
          <button
            type="button"
            className={`w-full px-3 py-2 text-left text-sm font-medium text-primary hover:bg-accent ${highlightIndex === 0 ? "bg-accent" : ""}`}
            onClick={() => { setShowDropdown(false); setShowCreateDialog(true); }}
            data-testid="button-create-new-family"
          >
            + Create new family
          </button>
          {filtered.map((f, i) => (
            <button
              key={f.id}
              type="button"
              className={`w-full px-3 py-2 text-left text-sm hover:bg-accent ${highlightIndex === i + 1 ? "bg-accent" : ""} ${f.id === value ? "font-medium" : ""}`}
              onClick={() => { onChange(f.id); setShowDropdown(false); }}
              data-testid={`option-family-${f.id}`}
            >
              {f.firstName} {f.lastName}
            </button>
          ))}
          {filtered.length === 0 && (
            <div className="px-3 py-2 text-sm text-muted-foreground">No families found</div>
          )}
        </div>
      )}

      <Dialog open={showCreateDialog} onOpenChange={setShowCreateDialog}>
        <DialogContent className="max-w-sm">
          <DialogHeader><DialogTitle>Create New Family</DialogTitle></DialogHeader>
          <div className="space-y-4 pt-2">
            <div className="space-y-2">
              <Label>First Name</Label>
              <Input value={newFamily.firstName} onChange={e => setNewFamily(p => ({ ...p, firstName: e.target.value }))} data-testid="input-new-family-first" />
            </div>
            <div className="space-y-2">
              <Label>Last Name</Label>
              <Input value={newFamily.lastName} onChange={e => setNewFamily(p => ({ ...p, lastName: e.target.value }))} data-testid="input-new-family-last" />
            </div>
            <Button
              onClick={() => createFamily.mutate()}
              disabled={!newFamily.firstName || !newFamily.lastName || createFamily.isPending}
              className="w-full" data-testid="button-submit-new-family"
            >
              {createFamily.isPending ? "Creating..." : "Create Family"}
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}

function ParentsView({ isTeacher, search, setSearch }: ViewProps) {
  const { toast } = useToast();
  const [open, setOpen] = useState(false);
  const [editId, setEditId] = useState<number | null>(null);
  const emptyForm = { firstName: "", lastName: "", phoneNumber: "", familyId: null as number | null };
  const [form, setForm] = useState(emptyForm);

  const { data: parentsList } = useQuery<Parent[]>({ queryKey: ["/api/parents"] });
  const { data: familiesList } = useQuery<Family[]>({ queryKey: ["/api/families"] });
  const familiesMap = useMemo(() => {
    const map = new Map<number, Family>();
    familiesList?.forEach(f => map.set(f.id, f));
    return map;
  }, [familiesList]);

  const create = useMutation({
    mutationFn: async () => {
      await apiRequest("POST", "/api/parents", {
        firstName: form.firstName, lastName: form.lastName,
        phoneNumber: form.phoneNumber ? stripPhone(form.phoneNumber) : null,
        familyId: form.familyId,
      });
    },
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ["/api/parents"] }); setOpen(false); setForm(emptyForm); toast({ title: "Parent added" }); },
    onError: () => toast({ title: "Failed to add parent", variant: "destructive" }),
  });

  const update = useMutation({
    mutationFn: async () => {
      if (!editId) return;
      await apiRequest("PATCH", `/api/parents/${editId}`, {
        firstName: form.firstName, lastName: form.lastName,
        phoneNumber: form.phoneNumber ? stripPhone(form.phoneNumber) : null,
        familyId: form.familyId,
      });
    },
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ["/api/parents"] }); setOpen(false); setEditId(null); setForm(emptyForm); toast({ title: "Parent updated" }); },
    onError: () => toast({ title: "Failed to update parent", variant: "destructive" }),
  });

  const remove = useMutation({
    mutationFn: async (id: number) => { await apiRequest("DELETE", `/api/parents/${id}`); },
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ["/api/parents"] }); toast({ title: "Parent removed" }); },
  });

  function openEdit(p: Parent) {
    setEditId(p.id);
    setForm({ firstName: p.firstName, lastName: p.lastName, phoneNumber: p.phoneNumber || "", familyId: p.familyId });
    setOpen(true);
  }

  const filtered = parentsList?.filter(p => {
    if (!search) return true;
    const q = search.toLowerCase();
    return p.firstName.toLowerCase().includes(q) || p.lastName.toLowerCase().includes(q) || (p.phoneNumber?.includes(q));
  });

  return (
    <>
      <div className="flex items-center justify-between gap-4 flex-wrap">
        <div>
          <h1 className="text-2xl font-serif font-bold tracking-tight" data-testid="text-page-title">Parents</h1>
          <p className="text-muted-foreground mt-1">{parentsList?.length || 0} parents</p>
        </div>
        {isTeacher && <Button onClick={() => { setEditId(null); setForm(emptyForm); setOpen(true); }} data-testid="button-add-parent"><Plus className="w-4 h-4 mr-2" />Add Parent</Button>}
      </div>

      <Input placeholder="Search parents..." value={search} onChange={e => setSearch(e.target.value)} className="max-w-sm" data-testid="input-search" />

      <Dialog open={open} onOpenChange={(v) => { setOpen(v); if (!v) setEditId(null); }}>
        <DialogContent className="max-w-md">
          <DialogHeader><DialogTitle>{editId ? "Edit Parent" : "Add Parent"}</DialogTitle></DialogHeader>
          <div className="space-y-4 pt-2">
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>First Name</Label>
                <Input value={form.firstName} onChange={e => setForm(p => ({ ...p, firstName: e.target.value }))} data-testid="input-first-name" />
              </div>
              <div className="space-y-2">
                <Label>Last Name</Label>
                <Input value={form.lastName} onChange={e => setForm(p => ({ ...p, lastName: e.target.value }))} data-testid="input-last-name" />
              </div>
            </div>
            <div className="space-y-2">
              <Label>Phone Number</Label>
              <Input value={form.phoneNumber} onChange={e => setForm(p => ({ ...p, phoneNumber: e.target.value }))} placeholder="+31624745057" data-testid="input-phone" />
            </div>
            <div className="space-y-2">
              <Label>Family</Label>
              <FamilyAutocomplete value={form.familyId} onChange={id => setForm(p => ({ ...p, familyId: id }))} families={familiesList || []} />
            </div>
            <Button
              onClick={() => editId ? update.mutate() : create.mutate()}
              disabled={!form.firstName || !form.lastName || create.isPending || update.isPending}
              className="w-full" data-testid="button-submit-parent"
            >
              {(create.isPending || update.isPending) ? "Saving..." : editId ? "Save Changes" : "Add Parent"}
            </Button>
          </div>
        </DialogContent>
      </Dialog>

      <Card>
        <CardContent className="p-0">
          <div className="overflow-x-auto">
            <table className="w-full text-sm" data-testid="table-parents">
              <thead>
                <tr className="border-b">
                  <th className="text-left py-3 px-4 font-medium text-muted-foreground">First Name</th>
                  <th className="text-left py-3 px-4 font-medium text-muted-foreground">Last Name</th>
                  <th className="text-left py-3 px-4 font-medium text-muted-foreground">Phone Number</th>
                  <th className="text-left py-3 px-4 font-medium text-muted-foreground">Family</th>
                  {isTeacher && <th className="text-right py-3 px-4 font-medium text-muted-foreground">Actions</th>}
                </tr>
              </thead>
              <tbody>
                {filtered && filtered.length > 0 ? filtered.map(p => {
                  const fam = p.familyId ? familiesMap.get(p.familyId) : null;
                  return (
                    <tr key={p.id} className="border-b last:border-0" data-testid={`row-parent-${p.id}`}>
                      <td className="py-3 px-4 font-medium">{p.firstName}</td>
                      <td className="py-3 px-4">{p.lastName}</td>
                      <td className="py-3 px-4 font-mono text-xs">{p.phoneNumber || "—"}</td>
                      <td className="py-3 px-4">{fam ? `${fam.firstName} ${fam.lastName}` : "—"}</td>
                      {isTeacher && (
                        <td className="py-3 px-4 text-right space-x-1">
                          <Button variant="ghost" size="sm" onClick={() => openEdit(p)} data-testid={`button-edit-${p.id}`}><Pencil className="w-3.5 h-3.5" /></Button>
                          <Button variant="ghost" size="sm" onClick={() => remove.mutate(p.id)} className="text-destructive" data-testid={`button-delete-${p.id}`}>Remove</Button>
                        </td>
                      )}
                    </tr>
                  );
                }) : (
                  <tr><td colSpan={isTeacher ? 5 : 4} className="text-center py-8 text-muted-foreground">{search ? "No matches." : "No parents found."}</td></tr>
                )}
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>
    </>
  );
}
