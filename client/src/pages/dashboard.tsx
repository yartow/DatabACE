import { useQuery, useMutation } from "@tanstack/react-query";
import { useAuth } from "@/hooks/use-auth";
import { Link, useLocation } from "wouter";
import { useState } from "react";
import { Package, ShoppingCart, BookOpen, GraduationCap, BarChart3, FileText, Settings, User, Users, ChevronRight } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu";
import { Input } from "@/components/ui/input";
import { useToast } from "@/hooks/use-toast";
import { queryClient, apiRequest } from "@/lib/queryClient";
import type { UserProfile, Student } from "@shared/schema";
import { useForm } from "react-hook-form";
import { Form, FormField, FormItem, FormLabel, FormControl, FormMessage } from "@/components/ui/form";

const TEACHER_TILES = [
  {
    label: "Inventory",
    description: "Track physical PACE booklets and stock",
    href: "/inventory",
    icon: Package,
    accent: "from-amber-500/10 to-amber-500/5 border-amber-400/30 hover:border-amber-400/60",
    iconColor: "text-amber-500",
  },
  {
    label: "Order Materials",
    description: "Manage PACE material orders and deliveries",
    href: "/order-materials",
    icon: ShoppingCart,
    accent: "from-emerald-500/10 to-emerald-500/5 border-emerald-400/30 hover:border-emerald-400/60",
    iconColor: "text-emerald-500",
  },
  {
    label: "Courses & PACEs",
    description: "Browse and edit courses, PACE links and editions",
    href: "/materials",
    icon: BookOpen,
    accent: "from-blue-500/10 to-blue-500/5 border-blue-400/30 hover:border-blue-400/60",
    iconColor: "text-blue-500",
  },
  {
    label: "Grades",
    description: "Manage student enrollments and PACE grades",
    href: "/enrollments",
    icon: GraduationCap,
    accent: "from-violet-500/10 to-violet-500/5 border-violet-400/30 hover:border-violet-400/60",
    iconColor: "text-violet-500",
  },
  {
    label: "Student Progress Chart",
    description: "Visual overview of each student's PACE progress",
    href: "/spc",
    icon: BarChart3,
    accent: "from-rose-500/10 to-rose-500/5 border-rose-400/30 hover:border-rose-400/60",
    iconColor: "text-rose-500",
  },
  {
    label: "Reports",
    description: "Generate and print year reports per student",
    href: "/reports",
    icon: FileText,
    accent: "from-sky-500/10 to-sky-500/5 border-sky-400/30 hover:border-sky-400/60",
    iconColor: "text-sky-500",
  },
];

function ProfileDialog({ open, onClose, profile }: { open: boolean; onClose: () => void; profile: UserProfile | null | undefined }) {
  const { user } = useAuth();
  const { toast } = useToast();

  const form = useForm({
    defaultValues: {
      firstName: profile?.firstName ?? user?.firstName ?? "",
      lastName: profile?.lastName ?? user?.lastName ?? "",
      email: profile?.email ?? user?.email ?? "",
    },
  });

  const mutation = useMutation({
    mutationFn: (data: { firstName: string; lastName: string; email: string }) =>
      apiRequest("PATCH", "/api/profile", data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/profile"] });
      toast({ title: "Profile saved" });
      onClose();
    },
    onError: (e: any) => {
      toast({ title: "Failed to save", description: e.message, variant: "destructive" });
    },
  });

  return (
    <Dialog open={open} onOpenChange={v => !v && onClose()}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>Manage Profile</DialogTitle>
        </DialogHeader>
        <Form {...form}>
          <form onSubmit={form.handleSubmit(d => mutation.mutate(d))} className="space-y-4">
            <FormField
              control={form.control}
              name="firstName"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>First Name</FormLabel>
                  <FormControl>
                    <Input {...field} data-testid="input-profile-firstname" />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name="lastName"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Last Name</FormLabel>
                  <FormControl>
                    <Input {...field} data-testid="input-profile-lastname" />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name="email"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Email</FormLabel>
                  <FormControl>
                    <Input type="email" {...field} data-testid="input-profile-email" />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
            <DialogFooter>
              <Button type="button" variant="ghost" onClick={onClose}>Cancel</Button>
              <Button type="submit" disabled={mutation.isPending} data-testid="button-profile-save">
                {mutation.isPending ? "Saving…" : "Save"}
              </Button>
            </DialogFooter>
          </form>
        </Form>
      </DialogContent>
    </Dialog>
  );
}

export default function Dashboard() {
  const { user } = useAuth();
  const [, navigate] = useLocation();
  const [profileOpen, setProfileOpen] = useState(false);

  const { data: profile } = useQuery<UserProfile>({ queryKey: ["/api/profile"] });
  const { data: students } = useQuery<Student[]>({ queryKey: ["/api/students"] });

  const isTeacher = profile?.role === "teacher";

  const displayName =
    profile?.firstName
      ? `${profile.firstName}${profile.lastName ? " " + profile.lastName : ""}`
      : user?.firstName
        ? `${user.firstName}${user.lastName ? " " + user.lastName : ""}`
        : "User";

  if (isTeacher) {
    return (
      <div className="relative h-full flex flex-col p-5 gap-4">
        <div>
          <h1 className="text-xl font-serif font-bold tracking-tight" data-testid="text-welcome">
            Welcome back, {displayName}
          </h1>
        </div>

        <div className="flex-1 grid grid-cols-2 lg:grid-cols-3 gap-4 min-h-0">
          {TEACHER_TILES.map(tile => (
            <Link key={tile.href} href={tile.href}>
              <div
                className={`h-full flex flex-col items-center justify-center gap-3 rounded-xl border-2 bg-gradient-to-br cursor-pointer transition-all duration-150 hover:scale-[1.015] hover:shadow-lg p-6 text-center ${tile.accent}`}
                data-testid={`tile-${tile.label.toLowerCase().replace(/\s+/g, "-")}`}
              >
                <tile.icon className={`w-10 h-10 ${tile.iconColor}`} strokeWidth={1.5} />
                <div>
                  <p className="font-semibold text-base leading-snug">{tile.label}</p>
                  <p className="text-xs text-muted-foreground mt-1 leading-snug">{tile.description}</p>
                </div>
              </div>
            </Link>
          ))}
        </div>

        <div className="fixed bottom-6 right-6 z-50">
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button
                size="lg"
                className="rounded-full shadow-lg gap-2 pl-4 pr-5"
                data-testid="button-settings"
              >
                <Settings className="w-4 h-4" />
                Settings
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-52">
              <DropdownMenuItem
                className="gap-2 cursor-pointer"
                onSelect={() => setProfileOpen(true)}
                data-testid="menuitem-manage-profile"
              >
                <User className="w-4 h-4" />
                Manage profile
              </DropdownMenuItem>
              <DropdownMenuItem
                className="gap-2 cursor-pointer"
                onSelect={() => navigate("/students")}
                data-testid="menuitem-manage-people"
              >
                <Users className="w-4 h-4" />
                Manage people
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>

        <ProfileDialog open={profileOpen} onClose={() => setProfileOpen(false)} profile={profile} />
      </div>
    );
  }

  return (
    <div className="p-6 max-w-2xl mx-auto space-y-6">
      <div>
        <h1 className="text-2xl font-serif font-bold tracking-tight" data-testid="text-welcome">
          Welcome back, {displayName}
        </h1>
        <p className="text-muted-foreground mt-1">View your children's academic progress.</p>
      </div>

      <div className="space-y-2">
        {students && students.length > 0 ? (
          students.map(student => (
            <Link key={student.id} href={`/spc`}>
              <div
                className="flex items-center justify-between gap-4 p-4 rounded-lg border hover-elevate cursor-pointer"
                data-testid={`card-student-${student.id}`}
              >
                <div>
                  <p className="font-medium">{student.callName} {student.surname}</p>
                  <p className="text-xs text-muted-foreground">{student.alias}</p>
                </div>
                <ChevronRight className="w-4 h-4 text-muted-foreground" />
              </div>
            </Link>
          ))
        ) : (
          <p className="text-sm text-muted-foreground py-4 text-center">No students found.</p>
        )}
      </div>
    </div>
  );
}
