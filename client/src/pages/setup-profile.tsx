import { useMutation, useQuery } from "@tanstack/react-query";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Label } from "@/components/ui/label";
import { useToast } from "@/hooks/use-toast";
import { useState } from "react";
import { apiRequest, queryClient } from "@/lib/queryClient";
import type { Family } from "@shared/schema";
import { GraduationCap, ShieldCheck, Users } from "lucide-react";

export default function SetupProfilePage({ onComplete }: { onComplete: () => void }) {
  const { toast } = useToast();
  const [role, setRole] = useState<string>("");
  const [familyId, setFamilyId] = useState<string>("");

  const { data: families } = useQuery<Family[]>({
    queryKey: ["/api/families"],
  });

  const setupMutation = useMutation({
    mutationFn: async () => {
      await apiRequest("POST", "/api/profile", {
        role,
        familyId: role === "parent" ? parseInt(familyId) : null,
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/profile"] });
      toast({ title: "Profile set up successfully" });
      onComplete();
    },
    onError: () => toast({ title: "Failed to set up profile", variant: "destructive" }),
  });

  return (
    <div className="min-h-screen bg-background flex items-center justify-center p-6">
      <Card className="w-full max-w-md">
        <CardHeader className="text-center space-y-2">
          <div className="flex justify-center mb-2">
            <div className="w-12 h-12 rounded-md bg-primary flex items-center justify-center">
              <GraduationCap className="w-6 h-6 text-primary-foreground" />
            </div>
          </div>
          <CardTitle className="text-xl font-serif">Welcome to Ceder</CardTitle>
          <p className="text-sm text-muted-foreground">Set up your profile to get started.</p>
        </CardHeader>
        <CardContent className="space-y-6">
          <div className="space-y-2">
            <Label>I am a...</Label>
            <div className="grid grid-cols-2 gap-3">
              <button
                onClick={() => setRole("teacher")}
                className={`p-4 rounded-md border text-center space-y-2 transition-colors ${
                  role === "teacher" ? "border-primary bg-primary/5" : "hover-elevate"
                }`}
                data-testid="button-role-teacher"
              >
                <ShieldCheck className={`w-6 h-6 mx-auto ${role === "teacher" ? "text-primary" : "text-muted-foreground"}`} />
                <p className="text-sm font-medium">Teacher</p>
              </button>
              <button
                onClick={() => setRole("parent")}
                className={`p-4 rounded-md border text-center space-y-2 transition-colors ${
                  role === "parent" ? "border-primary bg-primary/5" : "hover-elevate"
                }`}
                data-testid="button-role-parent"
              >
                <Users className={`w-6 h-6 mx-auto ${role === "parent" ? "text-primary" : "text-muted-foreground"}`} />
                <p className="text-sm font-medium">Parent</p>
              </button>
            </div>
          </div>

          {role === "parent" && (
            <div className="space-y-2">
              <Label>Select Your Family</Label>
              <Select value={familyId} onValueChange={setFamilyId}>
                <SelectTrigger data-testid="select-family">
                  <SelectValue placeholder="Choose family" />
                </SelectTrigger>
                <SelectContent>
                  {families?.map(f => (
                    <SelectItem key={f.id} value={f.id.toString()}>{f.name}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
              {families?.length === 0 && (
                <p className="text-xs text-muted-foreground">No families exist yet. Ask a teacher to create one.</p>
              )}
            </div>
          )}

          <Button
            onClick={() => setupMutation.mutate()}
            disabled={!role || (role === "parent" && !familyId) || setupMutation.isPending}
            className="w-full"
            data-testid="button-complete-setup"
          >
            {setupMutation.isPending ? "Setting up..." : "Complete Setup"}
          </Button>
        </CardContent>
      </Card>
    </div>
  );
}
