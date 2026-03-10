import { useQuery } from "@tanstack/react-query";
import { useAuth } from "@/hooks/use-auth";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { Users, BookOpen, BarChart3, Calendar } from "lucide-react";
import type { UserProfile, Student } from "@shared/schema";
import { Link } from "wouter";

export default function Dashboard() {
  const { user } = useAuth();

  const { data: profile } = useQuery<UserProfile>({
    queryKey: ["/api/profile"],
  });

  const { data: stats, isLoading } = useQuery<{
    totalStudents: number;
    totalCourses: number;
    totalPaces: number;
    totalPaceCourses: number;
  }>({
    queryKey: ["/api/dashboard/stats"],
  });

  const { data: students } = useQuery<Student[]>({
    queryKey: ["/api/students"],
  });

  const isTeacher = profile?.role === "teacher";

  return (
    <div className="p-6 max-w-6xl mx-auto space-y-8">
      <div>
        <h1 className="text-2xl font-serif font-bold tracking-tight" data-testid="text-welcome">
          Welcome back, {user?.firstName || "User"}
        </h1>
        <p className="text-muted-foreground mt-1">
          {isTeacher ? "Here's an overview of your school data." : "View your children's academic progress."}
        </p>
      </div>

      {isTeacher && (
        <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {[
            { label: "Students", value: stats?.totalStudents, icon: Users, color: "text-chart-1" },
            { label: "Courses", value: stats?.totalCourses, icon: BookOpen, color: "text-chart-2" },
            { label: "PACEs", value: stats?.totalPaces, icon: BarChart3, color: "text-chart-3" },
            { label: "PACE-Courses", value: stats?.totalPaceCourses, icon: Calendar, color: "text-chart-4" },
          ].map((stat) => (
            <Card key={stat.label}>
              <CardHeader className="flex flex-row items-center justify-between gap-1 space-y-0 pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground">{stat.label}</CardTitle>
                <stat.icon className={`w-4 h-4 ${stat.color}`} />
              </CardHeader>
              <CardContent>
                {isLoading ? (
                  <Skeleton className="h-8 w-16" />
                ) : (
                  <p className="text-2xl font-bold" data-testid={`text-stat-${stat.label.toLowerCase().replace(/\s/g, "-")}`}>
                    {stat.value ?? 0}
                  </p>
                )}
              </CardContent>
            </Card>
          ))}
        </div>
      )}

      <div className="grid lg:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle className="text-base">Quick Actions</CardTitle>
          </CardHeader>
          <CardContent className="space-y-2">
            {[
              { label: "Student Progress Chart", href: "/spc", icon: BarChart3 },
              { label: "Term Reports", href: "/reports", icon: Calendar },
              { label: "Courses & PACEs", href: "/materials", icon: BookOpen },
            ].map((action) => (
              <Link key={action.href} href={action.href}>
                <div className="flex items-center gap-3 p-3 rounded-md hover-elevate cursor-pointer" data-testid={`link-action-${action.label.toLowerCase().replace(/\s+/g, "-")}`}>
                  <action.icon className="w-4 h-4 text-muted-foreground" />
                  <span className="text-sm font-medium">{action.label}</span>
                </div>
              </Link>
            ))}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-base">{isTeacher ? "Students" : "Your Children"}</CardTitle>
          </CardHeader>
          <CardContent>
            {students && students.length > 0 ? (
              <div className="space-y-2">
                {students.slice(0, 8).map((student) => (
                  <div key={student.id} className="flex items-center justify-between gap-4 p-3 rounded-md bg-muted/30" data-testid={`card-student-${student.id}`}>
                    <div>
                      <p className="text-sm font-medium">{student.callName} {student.surname}</p>
                      <p className="text-xs text-muted-foreground">{student.alias}</p>
                    </div>
                  </div>
                ))}
                {isTeacher && students.length > 8 && (
                  <Link href="/students">
                    <p className="text-sm text-muted-foreground text-center pt-2 cursor-pointer">
                      View all {students.length} students
                    </p>
                  </Link>
                )}
              </div>
            ) : (
              <p className="text-sm text-muted-foreground py-4 text-center">No students found.</p>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
