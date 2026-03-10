import { useQuery, useMutation } from "@tanstack/react-query";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Switch } from "@/components/ui/switch";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useToast } from "@/hooks/use-toast";
import { useState } from "react";
import { apiRequest, queryClient } from "@/lib/queryClient";
import { Plus, Copy, Trash2, ShieldAlert } from "lucide-react";
import type { Invitation, Family, UserProfile } from "@shared/schema";

type UserProfileWithUser = UserProfile & {
  email?: string | null;
  firstName?: string | null;
  lastName?: string | null;
};

function getInvitationStatus(inv: Invitation): "used" | "expired" | "pending" {
  if (inv.usedBy) return "used";
  if (new Date() > new Date(inv.expiresAt)) return "expired";
  return "pending";
}

function InvitationsTab() {
  const { toast } = useToast();
  const [role, setRole] = useState<string>("");
  const [familyId, setFamilyId] = useState<string>("");
  const [email, setEmail] = useState("");

  const { data: invitations, isLoading } = useQuery<Invitation[]>({
    queryKey: ["/api/invitations"],
  });

  const { data: families } = useQuery<Family[]>({
    queryKey: ["/api/families"],
  });

  const createInvitation = useMutation({
    mutationFn: async () => {
      const body: Record<string, unknown> = { role };
      if (role === "parent" && familyId) body.familyId = parseInt(familyId);
      if (email) body.email = email;
      await apiRequest("POST", "/api/invitations", body);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/invitations"] });
      setRole("");
      setFamilyId("");
      setEmail("");
      toast({ title: "Invitation created" });
    },
    onError: (err: Error) => toast({ title: "Failed to create invitation", description: err.message, variant: "destructive" }),
  });

  const deleteInvitation = useMutation({
    mutationFn: async (id: number) => {
      await apiRequest("DELETE", `/api/invitations/${id}`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/invitations"] });
      toast({ title: "Invitation revoked" });
    },
    onError: () => toast({ title: "Failed to revoke invitation", variant: "destructive" }),
  });

  function copyLink(token: string) {
    const link = `${window.location.origin}/invite/${token}`;
    navigator.clipboard.writeText(link).then(() => {
      toast({ title: "Link copied to clipboard" });
    }).catch(() => {
      toast({ title: "Failed to copy link", variant: "destructive" });
    });
  }

  const canCreate = role && (role === "teacher" || (role === "parent" && familyId));

  return (
    <div className="space-y-6">
      <Card>
        <CardContent className="p-6 space-y-4">
          <h3 className="text-base font-semibold" data-testid="text-create-invitation-title">Create New Invitation</h3>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div className="space-y-2">
              <Label>Role</Label>
              <Select value={role} onValueChange={(v) => { setRole(v); if (v === "teacher") setFamilyId(""); }}>
                <SelectTrigger data-testid="select-invite-role">
                  <SelectValue placeholder="Select role..." />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="teacher">Teacher</SelectItem>
                  <SelectItem value="parent">Parent</SelectItem>
                </SelectContent>
              </Select>
            </div>
            {role === "parent" && (
              <div className="space-y-2">
                <Label>Family</Label>
                <Select value={familyId} onValueChange={setFamilyId}>
                  <SelectTrigger data-testid="select-invite-family">
                    <SelectValue placeholder="Select family..." />
                  </SelectTrigger>
                  <SelectContent>
                    {families?.map((f) => (
                      <SelectItem key={f.id} value={String(f.id)}>
                        {f.firstName} {f.lastName}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            )}
            <div className="space-y-2">
              <Label>Email (optional)</Label>
              <Input
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="For reference only..."
                data-testid="input-invite-email"
              />
            </div>
          </div>
          <Button
            onClick={() => createInvitation.mutate()}
            disabled={!canCreate || createInvitation.isPending}
            data-testid="button-create-invitation"
          >
            <Plus className="w-4 h-4 mr-2" />
            {createInvitation.isPending ? "Creating..." : "Create Invitation"}
          </Button>
        </CardContent>
      </Card>

      <Card>
        <CardContent className="p-0">
          <div className="overflow-x-auto">
            <table className="w-full text-sm" data-testid="table-invitations">
              <thead>
                <tr className="border-b">
                  <th className="text-left py-3 px-4 font-medium text-muted-foreground">Role</th>
                  <th className="text-left py-3 px-4 font-medium text-muted-foreground">Email</th>
                  <th className="text-left py-3 px-4 font-medium text-muted-foreground">Status</th>
                  <th className="text-left py-3 px-4 font-medium text-muted-foreground">Created</th>
                  <th className="text-left py-3 px-4 font-medium text-muted-foreground">Expires</th>
                  <th className="text-right py-3 px-4 font-medium text-muted-foreground">Actions</th>
                </tr>
              </thead>
              <tbody>
                {isLoading ? (
                  <tr>
                    <td colSpan={6} className="text-center py-8 text-muted-foreground">Loading...</td>
                  </tr>
                ) : invitations && invitations.length > 0 ? (
                  invitations.map((inv) => {
                    const status = getInvitationStatus(inv);
                    return (
                      <tr key={inv.id} className="border-b last:border-0" data-testid={`row-invitation-${inv.id}`}>
                        <td className="py-3 px-4">
                          <Badge variant="secondary" className="capitalize">{inv.role}</Badge>
                        </td>
                        <td className="py-3 px-4 text-muted-foreground">{inv.email || "—"}</td>
                        <td className="py-3 px-4">
                          {status === "pending" && (
                            <Badge variant="secondary" className="bg-amber-100 text-amber-800 dark:bg-amber-900 dark:text-amber-200" data-testid={`badge-status-${inv.id}`}>Pending</Badge>
                          )}
                          {status === "used" && (
                            <Badge variant="secondary" className="bg-emerald-100 text-emerald-800 dark:bg-emerald-900 dark:text-emerald-200" data-testid={`badge-status-${inv.id}`}>Used</Badge>
                          )}
                          {status === "expired" && (
                            <Badge variant="secondary" className="bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200" data-testid={`badge-status-${inv.id}`}>Expired</Badge>
                          )}
                        </td>
                        <td className="py-3 px-4 text-muted-foreground text-xs">
                          {new Date(inv.createdAt).toLocaleDateString()}
                        </td>
                        <td className="py-3 px-4 text-muted-foreground text-xs">
                          {new Date(inv.expiresAt).toLocaleDateString()}
                        </td>
                        <td className="py-3 px-4 text-right space-x-1">
                          {status === "pending" && (
                            <Button
                              variant="ghost"
                              size="icon"
                              onClick={() => copyLink(inv.token)}
                              data-testid={`button-copy-link-${inv.id}`}
                            >
                              <Copy className="w-4 h-4" />
                            </Button>
                          )}
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => deleteInvitation.mutate(inv.id)}
                            className="text-destructive"
                            data-testid={`button-delete-invitation-${inv.id}`}
                          >
                            <Trash2 className="w-4 h-4" />
                          </Button>
                        </td>
                      </tr>
                    );
                  })
                ) : (
                  <tr>
                    <td colSpan={6} className="text-center py-8 text-muted-foreground">No invitations yet.</td>
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

function UsersTab() {
  const { toast } = useToast();
  const { data: profile } = useQuery<UserProfile>({ queryKey: ["/api/profile"] });

  const { data: usersList, isLoading } = useQuery<UserProfileWithUser[]>({
    queryKey: ["/api/admin/users"],
  });

  const { data: families } = useQuery<Family[]>({
    queryKey: ["/api/families"],
  });

  const toggleAdmin = useMutation({
    mutationFn: async ({ userId, isAdmin }: { userId: string; isAdmin: boolean }) => {
      await apiRequest("PATCH", `/api/admin/users/${userId}`, { isAdmin });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/admin/users"] });
      toast({ title: "Admin status updated" });
    },
    onError: (err: Error) => toast({ title: "Failed to update", description: err.message, variant: "destructive" }),
  });

  const deleteUser = useMutation({
    mutationFn: async (userId: string) => {
      await apiRequest("DELETE", `/api/admin/users/${userId}`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/admin/users"] });
      toast({ title: "User removed" });
    },
    onError: (err: Error) => toast({ title: "Failed to remove user", description: err.message, variant: "destructive" }),
  });

  function getFamilyName(familyId: number | null): string {
    if (!familyId || !families) return "—";
    const f = families.find((fam) => fam.id === familyId);
    return f ? `${f.firstName} ${f.lastName}` : "—";
  }

  return (
    <Card>
      <CardContent className="p-0">
        <div className="overflow-x-auto">
          <table className="w-full text-sm" data-testid="table-users">
            <thead>
              <tr className="border-b">
                <th className="text-left py-3 px-4 font-medium text-muted-foreground">Name</th>
                <th className="text-left py-3 px-4 font-medium text-muted-foreground">Email</th>
                <th className="text-left py-3 px-4 font-medium text-muted-foreground">Role</th>
                <th className="text-left py-3 px-4 font-medium text-muted-foreground">Family</th>
                <th className="text-center py-3 px-4 font-medium text-muted-foreground">Admin</th>
                <th className="text-right py-3 px-4 font-medium text-muted-foreground">Actions</th>
              </tr>
            </thead>
            <tbody>
              {isLoading ? (
                <tr>
                  <td colSpan={6} className="text-center py-8 text-muted-foreground">Loading...</td>
                </tr>
              ) : usersList && usersList.length > 0 ? (
                usersList.map((u) => {
                  const isSelf = u.userId === profile?.userId;
                  return (
                    <tr key={u.id} className="border-b last:border-0" data-testid={`row-user-${u.id}`}>
                      <td className="py-3 px-4 font-medium">
                        {u.firstName || ""} {u.lastName || ""}
                        {isSelf && <span className="text-xs text-muted-foreground ml-1">(you)</span>}
                      </td>
                      <td className="py-3 px-4 text-muted-foreground">{u.email || "—"}</td>
                      <td className="py-3 px-4">
                        <Badge variant="secondary" className="capitalize">{u.role}</Badge>
                      </td>
                      <td className="py-3 px-4 text-muted-foreground">{getFamilyName(u.familyId)}</td>
                      <td className="py-3 px-4 text-center">
                        {u.role === "teacher" ? (
                          <Switch
                            checked={u.isAdmin}
                            disabled={isSelf || toggleAdmin.isPending}
                            onCheckedChange={(checked) => toggleAdmin.mutate({ userId: u.userId, isAdmin: checked })}
                            data-testid={`switch-admin-${u.id}`}
                          />
                        ) : (
                          <span className="text-muted-foreground">—</span>
                        )}
                      </td>
                      <td className="py-3 px-4 text-right">
                        {!isSelf && (
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => deleteUser.mutate(u.userId)}
                            className="text-destructive"
                            data-testid={`button-delete-user-${u.id}`}
                          >
                            <Trash2 className="w-4 h-4" />
                          </Button>
                        )}
                      </td>
                    </tr>
                  );
                })
              ) : (
                <tr>
                  <td colSpan={6} className="text-center py-8 text-muted-foreground">No users found.</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </CardContent>
    </Card>
  );
}

export default function AdminPage() {
  const { data: profile, isLoading } = useQuery<UserProfile>({ queryKey: ["/api/profile"] });

  if (isLoading) {
    return (
      <div className="p-6 max-w-6xl mx-auto">
        <p className="text-muted-foreground">Loading...</p>
      </div>
    );
  }

  if (!profile || profile.role !== "teacher" || !profile.isAdmin) {
    return (
      <div className="p-6 max-w-4xl mx-auto space-y-6">
        <div className="flex flex-col items-center justify-center py-12 text-center">
          <ShieldAlert className="w-12 h-12 text-muted-foreground mb-4" />
          <h2 className="text-xl font-semibold" data-testid="text-access-denied">Access Denied</h2>
          <p className="text-muted-foreground mt-2">Only admin teachers can access this page.</p>
        </div>
      </div>
    );
  }

  return (
    <div className="p-6 max-w-6xl mx-auto space-y-6">
      <div>
        <h1 className="text-2xl font-serif font-bold tracking-tight" data-testid="text-page-title">Administration</h1>
        <p className="text-muted-foreground mt-1">Manage invitations and user accounts.</p>
      </div>

      <Tabs defaultValue="invitations">
        <TabsList data-testid="tabs-admin">
          <TabsTrigger value="invitations" data-testid="tab-invitations">Invitations</TabsTrigger>
          <TabsTrigger value="users" data-testid="tab-users">Users</TabsTrigger>
        </TabsList>
        <TabsContent value="invitations" className="mt-4">
          <InvitationsTab />
        </TabsContent>
        <TabsContent value="users" className="mt-4">
          <UsersTab />
        </TabsContent>
      </Tabs>
    </div>
  );
}
