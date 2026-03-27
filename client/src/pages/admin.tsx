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
import { Plus, Copy, Trash2, ShieldAlert, AlertTriangle, Upload, Download } from "lucide-react";
import { Link } from "wouter";
import type { Invitation, Family, UserProfile, AppSettings, GoldStarRule, ClubThresholds, HonorRollThresholds } from "@shared/schema";

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

const defaultClubThresholds: ClubThresholds = { bronze: 10, silver: 20, gold: 30, platinum: 40 };
const defaultHonorRoll: HonorRollThresholds = { b: 95, a: 97, aPlus: 99 };

function SettingsSection() {
  const { toast } = useToast();

  const { data: settings, isLoading } = useQuery<AppSettings>({
    queryKey: ["/api/settings"],
  });

  const [goldStarRules, setGoldStarRules] = useState<GoldStarRule[]>([]);
  const [clubThresholds, setClubThresholds] = useState<ClubThresholds>(defaultClubThresholds);
  const [honorRoll, setHonorRoll] = useState<HonorRollThresholds>(defaultHonorRoll);
  const [initialized, setInitialized] = useState(false);

  if (settings && !initialized) {
    setGoldStarRules(settings.goldStarRules ?? []);
    setClubThresholds(settings.clubThresholds ?? defaultClubThresholds);
    setHonorRoll(settings.honorRollThresholds ?? defaultHonorRoll);
    setInitialized(true);
  }

  const saveSettings = useMutation({
    mutationFn: async () => {
      await apiRequest("PUT", "/api/settings", {
        goldStarRules,
        clubThresholds,
        honorRollThresholds: honorRoll,
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/settings"] });
      toast({ title: "Settings saved" });
    },
    onError: (err: Error) => toast({ title: "Failed to save settings", description: err.message, variant: "destructive" }),
  });

  function addRule() {
    setGoldStarRules(rules => [...rules, { levelFrom: 1, levelTo: 12, paceFrom: 1, paceTo: 144, minScore: 100 }]);
  }

  function removeRule(index: number) {
    setGoldStarRules(rules => rules.filter((_, i) => i !== index));
  }

  function updateRule(index: number, field: keyof GoldStarRule, value: number) {
    setGoldStarRules(rules => rules.map((r, i) => i === index ? { ...r, [field]: value } : r));
  }

  if (isLoading) return <p className="text-muted-foreground text-sm">Loading settings...</p>;

  return (
    <div className="space-y-8">
      {/* Gold Star Rules */}
      <Card>
        <CardContent className="p-6 space-y-4">
          <div>
            <h3 className="text-base font-semibold">Gold Star Rules</h3>
            <p className="text-sm text-muted-foreground mt-1">
              A student earns a gold star for each passed test meeting the minimum score for their level and PACE number range.
            </p>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b">
                  <th className="text-left py-2 px-2 font-medium text-muted-foreground">Level from</th>
                  <th className="text-left py-2 px-2 font-medium text-muted-foreground">Level to</th>
                  <th className="text-left py-2 px-2 font-medium text-muted-foreground">PACE # from</th>
                  <th className="text-left py-2 px-2 font-medium text-muted-foreground">PACE # to</th>
                  <th className="text-left py-2 px-2 font-medium text-muted-foreground">Min score (%)</th>
                  <th />
                </tr>
              </thead>
              <tbody>
                {goldStarRules.length === 0 && (
                  <tr>
                    <td colSpan={6} className="py-4 text-center text-muted-foreground text-sm">No rules defined. Add one below.</td>
                  </tr>
                )}
                {goldStarRules.map((rule, i) => (
                  <tr key={i} className="border-b last:border-0">
                    {(["levelFrom", "levelTo", "paceFrom", "paceTo", "minScore"] as (keyof GoldStarRule)[]).map(field => (
                      <td key={field} className="py-1.5 px-2">
                        <Input
                          type="number"
                          className="w-20 h-8 text-sm"
                          value={rule[field]}
                          onChange={e => updateRule(i, field, parseFloat(e.target.value))}
                        />
                      </td>
                    ))}
                    <td className="py-1.5 px-2">
                      <Button variant="ghost" size="icon" onClick={() => removeRule(i)} className="text-destructive h-8 w-8">
                        <Trash2 className="w-4 h-4" />
                      </Button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <Button variant="outline" size="sm" onClick={addRule}>
            <Plus className="w-4 h-4 mr-2" />
            Add rule
          </Button>
        </CardContent>
      </Card>

      {/* Club Membership Thresholds */}
      <Card>
        <CardContent className="p-6 space-y-4">
          <div>
            <h3 className="text-base font-semibold">Club Membership Thresholds</h3>
            <p className="text-sm text-muted-foreground mt-1">
              Number of gold stars required to reach each club level. Gold stars accumulate over the school year and reset at the start of a new year.
            </p>
          </div>
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
            {(["bronze", "silver", "gold", "platinum"] as (keyof ClubThresholds)[]).map(level => (
              <div key={level} className="space-y-2">
                <Label className="capitalize">{level}</Label>
                <Input
                  type="number"
                  value={clubThresholds[level]}
                  onChange={e => setClubThresholds(t => ({ ...t, [level]: parseInt(e.target.value) }))}
                />
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Honor Roll Thresholds */}
      <Card>
        <CardContent className="p-6 space-y-4">
          <div>
            <h3 className="text-base font-semibold">Honor Roll Thresholds</h3>
            <p className="text-sm text-muted-foreground mt-1">
              Minimum weighted average score (%) required for each honor roll level. Honor roll is calculated per term and resets each term.
            </p>
          </div>
          <div className="grid grid-cols-3 gap-4">
            <div className="space-y-2">
              <Label>B Honor Roll (%)</Label>
              <Input
                type="number"
                value={honorRoll.b}
                onChange={e => setHonorRoll(h => ({ ...h, b: parseFloat(e.target.value) }))}
              />
            </div>
            <div className="space-y-2">
              <Label>A Honor Roll (%)</Label>
              <Input
                type="number"
                value={honorRoll.a}
                onChange={e => setHonorRoll(h => ({ ...h, a: parseFloat(e.target.value) }))}
              />
            </div>
            <div className="space-y-2">
              <Label>A+ Honor Roll (%)</Label>
              <Input
                type="number"
                value={honorRoll.aPlus}
                onChange={e => setHonorRoll(h => ({ ...h, aPlus: parseFloat(e.target.value) }))}
              />
            </div>
          </div>
        </CardContent>
      </Card>

      <Button onClick={() => saveSettings.mutate()} disabled={saveSettings.isPending}>
        {saveSettings.isPending ? "Saving..." : "Save Settings"}
      </Button>
    </div>
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
    <div className="p-6 max-w-6xl mx-auto space-y-12">
      <div>
        <h1 className="text-2xl font-serif font-bold tracking-tight" data-testid="text-page-title">Administration</h1>
      </div>

      {/* Section 1: User management */}
      <section className="space-y-4">
        <div className="border-b pb-2">
          <h2 className="text-lg font-semibold">Manage invitations and user accounts</h2>
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
      </section>

      {/* Section 2: Gold stars, clubs, honor roll */}
      <section className="space-y-4">
        <div className="border-b pb-2">
          <h2 className="text-lg font-semibold">Manage settings for gold stars, club memberships and honor roll</h2>
        </div>
        <SettingsSection />
      </section>

      {/* Section 3: Import & Export */}
      <section className="space-y-4">
        <div className="border-b pb-2">
          <h2 className="text-lg font-semibold">Import and Export data</h2>
        </div>
        <div className="flex items-start gap-3 rounded-md border border-amber-300 bg-amber-50 dark:bg-amber-950/30 dark:border-amber-800 p-4">
          <AlertTriangle className="w-5 h-5 text-amber-600 dark:text-amber-400 mt-0.5 shrink-0" />
          <p className="text-sm text-amber-800 dark:text-amber-300 font-medium">
            Do not use this unless you know what you're doing.
          </p>
        </div>
        <div className="flex gap-4">
          <Button variant="outline" asChild>
            <Link href="/import">
              <Upload className="w-4 h-4 mr-2" />
              Import Data
            </Link>
          </Button>
          <Button variant="outline" asChild>
            <Link href="/export">
              <Download className="w-4 h-4 mr-2" />
              Export Data
            </Link>
          </Button>
        </div>
      </section>
    </div>
  );
}
