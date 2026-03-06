import { Link, useLocation } from "wouter";
import {
  BarChart3, FileText, BookOpen, Users, Upload, LayoutDashboard, LogOut, GraduationCap
} from "lucide-react";
import {
  Sidebar, SidebarContent, SidebarGroup, SidebarGroupContent, SidebarGroupLabel,
  SidebarMenu, SidebarMenuButton, SidebarMenuItem, SidebarHeader, SidebarFooter,
} from "@/components/ui/sidebar";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { useAuth } from "@/hooks/use-auth";
import { useQuery } from "@tanstack/react-query";
import type { UserProfile } from "@shared/schema";

const teacherItems = [
  { title: "Dashboard", url: "/", icon: LayoutDashboard },
  { title: "Student Progress Chart", url: "/spc", icon: BarChart3 },
  { title: "Term Reports", url: "/reports", icon: FileText },
  { title: "Materials & Exams", url: "/materials", icon: BookOpen },
  { title: "Students", url: "/students", icon: Users },
  { title: "Import Data", url: "/import", icon: Upload },
];

const parentItems = [
  { title: "Dashboard", url: "/", icon: LayoutDashboard },
  { title: "Student Progress Chart", url: "/spc", icon: BarChart3 },
  { title: "Term Reports", url: "/reports", icon: FileText },
  { title: "Materials & Exams", url: "/materials", icon: BookOpen },
];

export function AppSidebar() {
  const { user, logout } = useAuth();
  const [location] = useLocation();

  const { data: profile } = useQuery<UserProfile>({
    queryKey: ["/api/profile"],
    enabled: !!user,
  });

  const items = profile?.role === "teacher" ? teacherItems : parentItems;
  const initials = user
    ? `${user.firstName?.[0] || ""}${user.lastName?.[0] || ""}`.toUpperCase() || "U"
    : "U";

  return (
    <Sidebar>
      <SidebarHeader className="p-4">
        <div className="flex items-center gap-3">
          <div className="flex items-center justify-center w-9 h-9 rounded-md bg-primary">
            <GraduationCap className="w-5 h-5 text-primary-foreground" />
          </div>
          <div>
            <h2 className="text-sm font-semibold tracking-tight" data-testid="text-app-name">Ceder</h2>
            <p className="text-xs text-muted-foreground">School Management</p>
          </div>
        </div>
      </SidebarHeader>
      <SidebarContent>
        <SidebarGroup>
          <SidebarGroupLabel>Navigation</SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu>
              {items.map((item) => (
                <SidebarMenuItem key={item.title}>
                  <SidebarMenuButton asChild data-active={location === item.url}>
                    <Link href={item.url} data-testid={`link-nav-${item.title.toLowerCase().replace(/\s+/g, "-")}`}>
                      <item.icon className="w-4 h-4" />
                      <span>{item.title}</span>
                    </Link>
                  </SidebarMenuButton>
                </SidebarMenuItem>
              ))}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>
      </SidebarContent>
      <SidebarFooter className="p-4">
        <div className="flex items-center gap-3">
          <Avatar className="h-8 w-8">
            <AvatarImage src={user?.profileImageUrl || undefined} />
            <AvatarFallback className="text-xs">{initials}</AvatarFallback>
          </Avatar>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-medium truncate" data-testid="text-user-name">
              {user?.firstName} {user?.lastName}
            </p>
            <p className="text-xs text-muted-foreground capitalize" data-testid="text-user-role">
              {profile?.role || "user"}
            </p>
          </div>
          <Button
            size="icon"
            variant="ghost"
            onClick={() => logout()}
            data-testid="button-logout"
          >
            <LogOut className="w-4 h-4" />
          </Button>
        </div>
      </SidebarFooter>
    </Sidebar>
  );
}
