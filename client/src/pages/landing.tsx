import { Button } from "@/components/ui/button";
import { GraduationCap, BarChart3, FileText, BookOpen, Shield, Users } from "lucide-react";

export default function LandingPage() {
  return (
    <div className="min-h-screen bg-background">
      <nav className="fixed top-0 left-0 right-0 z-50 backdrop-blur-md bg-background/80 border-b">
        <div className="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="flex items-center justify-center w-9 h-9 rounded-md bg-primary">
              <GraduationCap className="w-5 h-5 text-primary-foreground" />
            </div>
            <span className="font-semibold text-lg tracking-tight" data-testid="text-brand">Ceder</span>
          </div>
          <a href="/api/login">
            <Button data-testid="button-login">Sign In</Button>
          </a>
        </div>
      </nav>

      <section className="pt-32 pb-20 px-6">
        <div className="max-w-6xl mx-auto grid lg:grid-cols-2 gap-16 items-center">
          <div className="space-y-8">
            <div className="space-y-4">
              <h1 className="text-4xl sm:text-5xl font-serif font-bold leading-tight tracking-tight" data-testid="text-hero-heading">
                Track Student Progress with Clarity
              </h1>
              <p className="text-lg text-muted-foreground leading-relaxed max-w-lg">
                A comprehensive school grading management system. Monitor student progress charts, generate term reports, and manage course materials — all in one place.
              </p>
            </div>
            <div className="flex flex-wrap items-center gap-3">
              <a href="/api/login">
                <Button size="lg" data-testid="button-get-started">Get Started</Button>
              </a>
            </div>
            <div className="flex flex-wrap items-center gap-6 text-sm text-muted-foreground">
              <div className="flex items-center gap-2">
                <Shield className="w-4 h-4" />
                <span>Secure & Private</span>
              </div>
              <div className="flex items-center gap-2">
                <Users className="w-4 h-4" />
                <span>Family Accounts</span>
              </div>
            </div>
          </div>

          <div className="relative hidden lg:block">
            <div className="bg-card rounded-md border p-8 space-y-6">
              <div className="flex items-center gap-3 mb-6">
                <div className="w-10 h-10 rounded-md bg-primary/10 flex items-center justify-center">
                  <BarChart3 className="w-5 h-5 text-primary" />
                </div>
                <div>
                  <p className="font-medium text-sm">Student Progress Chart</p>
                  <p className="text-xs text-muted-foreground">Term 2 — 2026</p>
                </div>
              </div>
              <div className="space-y-3">
                {["Mathematics", "English", "Science", "History"].map((subject, i) => (
                  <div key={subject} className="space-y-1.5">
                    <div className="flex items-center justify-between gap-4">
                      <span className="text-sm">{subject}</span>
                      <span className="text-sm font-medium text-muted-foreground">{[88, 76, 92, 71][i]}%</span>
                    </div>
                    <div className="h-2 rounded-sm bg-muted">
                      <div
                        className="h-full rounded-sm bg-primary transition-all duration-500"
                        style={{ width: `${[88, 76, 92, 71][i]}%` }}
                      />
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </section>

      <section className="py-20 px-6 bg-card/50">
        <div className="max-w-6xl mx-auto space-y-12">
          <div className="text-center space-y-3">
            <h2 className="text-2xl font-serif font-bold" data-testid="text-features-heading">Everything You Need</h2>
            <p className="text-muted-foreground max-w-md mx-auto">Designed for teachers and parents to stay informed about student performance.</p>
          </div>
          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {[
              { icon: BarChart3, title: "Student Progress Chart", desc: "Visual tracking of grades across all subjects and terms with detailed trend analysis." },
              { icon: FileText, title: "Term Reports", desc: "Generate comprehensive term reports for each student with scores and teacher comments." },
              { icon: BookOpen, title: "Materials & Exams", desc: "Track course completion, examination status, and material ordering in one view." },
            ].map((feature) => (
              <div key={feature.title} className="p-6 rounded-md border bg-background space-y-3 hover-elevate">
                <div className="w-10 h-10 rounded-md bg-primary/10 flex items-center justify-center">
                  <feature.icon className="w-5 h-5 text-primary" />
                </div>
                <h3 className="font-semibold">{feature.title}</h3>
                <p className="text-sm text-muted-foreground leading-relaxed">{feature.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      <footer className="py-8 px-6 border-t">
        <div className="max-w-6xl mx-auto flex items-center justify-between gap-4 text-sm text-muted-foreground">
          <p>&copy; 2026 Ceder. All rights reserved.</p>
        </div>
      </footer>
    </div>
  );
}
