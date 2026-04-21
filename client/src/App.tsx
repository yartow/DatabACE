import { Switch, Route, useLocation } from "wouter";
import { queryClient } from "./lib/queryClient";
import { QueryClientProvider, useQuery } from "@tanstack/react-query";
import { Toaster } from "@/components/ui/toaster";
import { TooltipProvider } from "@/components/ui/tooltip";
import { SidebarProvider, SidebarTrigger } from "@/components/ui/sidebar";
import { AppSidebar } from "@/components/app-sidebar";
import { useAuth } from "@/hooks/use-auth";
import { Skeleton } from "@/components/ui/skeleton";
import { PersistedStateProvider } from "@/lib/persisted-state";
import NotFound from "@/pages/not-found";
import LandingPage from "@/pages/landing";
import Dashboard from "@/pages/dashboard";
import SPCPage from "@/pages/spc";
import ReportsPage from "@/pages/reports";
import MaterialsPage from "@/pages/materials";
import StudentsPage from "@/pages/students";
import ImportPage from "@/pages/import";
import EnrollmentsPage from "@/pages/enrollments";
import ExportPage from "@/pages/export";
import AdminPage from "@/pages/admin";
import SetupProfilePage from "@/pages/setup-profile";
import InvitePage from "@/pages/invite";
import InventoryPage from "@/pages/inventory";
import OrderMaterialsPage from "@/pages/order-materials";
import GradesPage from "@/pages/grades";
import type { UserProfile } from "@shared/schema";

function AuthenticatedRouter() {
  return (
    <Switch>
      <Route path="/" component={Dashboard} />
      <Route path="/spc" component={SPCPage} />
      <Route path="/reports" component={ReportsPage} />
      <Route path="/materials" component={MaterialsPage} />
      <Route path="/students" component={StudentsPage} />
      <Route path="/enrollments" component={EnrollmentsPage} />
      <Route path="/import" component={ImportPage} />
      <Route path="/export" component={ExportPage} />
      <Route path="/inventory" component={InventoryPage} />
      <Route path="/order-materials" component={OrderMaterialsPage} />
      <Route path="/grades" component={GradesPage} />
      <Route path="/admin" component={AdminPage} />
      <Route component={NotFound} />
    </Switch>
  );
}

function AuthenticatedLayout() {
  const { data: profile, isLoading: profileLoading } = useQuery<UserProfile>({
    queryKey: ["/api/profile"],
  });

  if (profileLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="space-y-4 text-center">
          <Skeleton className="h-8 w-48 mx-auto" />
          <Skeleton className="h-4 w-32 mx-auto" />
        </div>
      </div>
    );
  }

  if (!profile) {
    return <SetupProfilePage />;
  }

  const sidebarStyle = {
    "--sidebar-width": "16rem",
    "--sidebar-width-icon": "3rem",
  };

  return (
    <PersistedStateProvider>
      <SidebarProvider style={sidebarStyle as React.CSSProperties}>
        <div className="flex h-screen w-full">
          <AppSidebar />
          <div className="flex flex-col flex-1 min-w-0">
            <header className="md:hidden flex items-center px-2 py-0.5 border-b">
              <SidebarTrigger data-testid="button-sidebar-toggle" />
            </header>
            <main className="flex-1 overflow-auto">
              <AuthenticatedRouter />
            </main>
          </div>
        </div>
      </SidebarProvider>
    </PersistedStateProvider>
  );
}

function AppContent() {
  const { user, isLoading } = useAuth();
  const [location] = useLocation();

  const inviteMatch = location.match(/^\/invite\/(.+)$/);
  if (inviteMatch) {
    if (isLoading) {
      return (
        <div className="min-h-screen flex items-center justify-center">
          <div className="space-y-4 text-center">
            <Skeleton className="h-8 w-48 mx-auto" />
            <Skeleton className="h-4 w-32 mx-auto" />
          </div>
        </div>
      );
    }
    return <InvitePage />;
  }

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="space-y-4 text-center">
          <Skeleton className="h-8 w-48 mx-auto" />
          <Skeleton className="h-4 w-32 mx-auto" />
        </div>
      </div>
    );
  }

  if (!user) {
    return <LandingPage />;
  }

  return <AuthenticatedLayout />;
}

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <TooltipProvider>
        <Toaster />
        <AppContent />
      </TooltipProvider>
    </QueryClientProvider>
  );
}

export default App;
