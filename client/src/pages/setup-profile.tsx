import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { GraduationCap, Mail } from "lucide-react";

export default function SetupProfilePage() {
  return (
    <div className="min-h-screen bg-background flex items-center justify-center p-6">
      <Card className="w-full max-w-md">
        <CardHeader className="text-center space-y-2">
          <div className="flex justify-center mb-2">
            <div className="w-12 h-12 rounded-md bg-primary flex items-center justify-center">
              <GraduationCap className="w-6 h-6 text-primary-foreground" />
            </div>
          </div>
          <CardTitle className="text-xl font-serif" data-testid="text-no-profile-title">Welcome to Ceder</CardTitle>
          <p className="text-sm text-muted-foreground">Your account is not yet set up.</p>
        </CardHeader>
        <CardContent className="space-y-4 text-center">
          <div className="p-4 rounded-md border bg-muted/30 space-y-3">
            <Mail className="w-8 h-8 mx-auto text-muted-foreground" />
            <p className="text-sm text-muted-foreground" data-testid="text-contact-admin">
              Contact your school administrator for an invitation link to get started.
            </p>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
