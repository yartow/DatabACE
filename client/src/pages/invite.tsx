import { useQuery, useMutation } from "@tanstack/react-query";
import { useLocation } from "wouter";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { useToast } from "@/hooks/use-toast";
import { useAuth } from "@/hooks/use-auth";
import { apiRequest, queryClient, getQueryFn } from "@/lib/queryClient";
import { GraduationCap, ShieldCheck, Users, AlertCircle, CheckCircle2 } from "lucide-react";
import { useEffect, useRef, useMemo } from "react";
import type { UserProfile } from "@shared/schema";

interface InvitationInfo {
  role: string;
  familyId: number | null;
  familyName: string | null;
  email: string | null;
  expired: boolean;
  used: boolean;
}

export default function InvitePage() {
  const [location] = useLocation();
  const token = useMemo(() => {
    const match = location.match(/^\/invite\/(.+)$/);
    return match ? match[1] : "";
  }, [location]);
  const { user, isLoading: authLoading } = useAuth();
  const { toast } = useToast();
  const hasAutoRedeemed = useRef(false);

  const { data: invitation, isLoading: invLoading, error: invError } = useQuery<InvitationInfo>({
    queryKey: ["/api/invitations/redeem", token],
    enabled: !!token,
    retry: false,
  });

  const { data: profile, isLoading: profileLoading } = useQuery<UserProfile | null>({
    queryKey: ["/api/profile"],
    queryFn: getQueryFn<UserProfile | null>({ on401: "returnNull" }),
    enabled: !!user,
  });

  const redeemMutation = useMutation({
    mutationFn: async () => {
      await apiRequest("POST", `/api/invitations/redeem/${token}`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/profile"] });
      queryClient.invalidateQueries({ queryKey: ["/api/invitations/redeem", token!] });
      toast({ title: "Welcome! Your account has been set up." });
      window.location.href = "/";
    },
    onError: (err: Error) => {
      toast({ title: "Failed to redeem invitation", description: err.message, variant: "destructive" });
    },
  });

  useEffect(() => {
    if (
      user &&
      !profileLoading &&
      !profile &&
      invitation &&
      !invitation.expired &&
      !invitation.used &&
      !redeemMutation.isPending &&
      !redeemMutation.isSuccess &&
      !hasAutoRedeemed.current
    ) {
      hasAutoRedeemed.current = true;
      redeemMutation.mutate();
    }
  }, [user, profileLoading, profile, invitation, redeemMutation.isPending, redeemMutation.isSuccess]);

  const isLoading = authLoading || invLoading || (user && profileLoading);

  if (isLoading) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center p-6">
        <Card className="w-full max-w-md">
          <CardHeader className="text-center space-y-2">
            <Skeleton className="h-12 w-12 mx-auto rounded-md" />
            <Skeleton className="h-6 w-48 mx-auto" />
            <Skeleton className="h-4 w-64 mx-auto" />
          </CardHeader>
          <CardContent>
            <Skeleton className="h-10 w-full" />
          </CardContent>
        </Card>
      </div>
    );
  }

  if (invError || !invitation) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center p-6">
        <Card className="w-full max-w-md">
          <CardHeader className="text-center space-y-2">
            <div className="flex justify-center mb-2">
              <div className="w-12 h-12 rounded-md bg-destructive/10 flex items-center justify-center">
                <AlertCircle className="w-6 h-6 text-destructive" />
              </div>
            </div>
            <CardTitle className="text-xl font-serif" data-testid="text-invite-error">Invalid Invitation</CardTitle>
            <p className="text-sm text-muted-foreground">This invitation link is not valid. It may have been revoked or the link is incorrect.</p>
          </CardHeader>
          <CardContent className="text-center">
            <a href="/">
              <Button variant="outline" data-testid="button-go-home">Go to Home</Button>
            </a>
          </CardContent>
        </Card>
      </div>
    );
  }

  if (invitation.expired) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center p-6">
        <Card className="w-full max-w-md">
          <CardHeader className="text-center space-y-2">
            <div className="flex justify-center mb-2">
              <div className="w-12 h-12 rounded-md bg-destructive/10 flex items-center justify-center">
                <AlertCircle className="w-6 h-6 text-destructive" />
              </div>
            </div>
            <CardTitle className="text-xl font-serif" data-testid="text-invite-expired">Invitation Expired</CardTitle>
            <p className="text-sm text-muted-foreground">This invitation has expired. Please contact your school administrator for a new one.</p>
          </CardHeader>
          <CardContent className="text-center">
            <a href="/">
              <Button variant="outline" data-testid="button-go-home-expired">Go to Home</Button>
            </a>
          </CardContent>
        </Card>
      </div>
    );
  }

  if (invitation.used) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center p-6">
        <Card className="w-full max-w-md">
          <CardHeader className="text-center space-y-2">
            <div className="flex justify-center mb-2">
              <div className="w-12 h-12 rounded-md bg-muted flex items-center justify-center">
                <CheckCircle2 className="w-6 h-6 text-muted-foreground" />
              </div>
            </div>
            <CardTitle className="text-xl font-serif" data-testid="text-invite-used">Invitation Already Used</CardTitle>
            <p className="text-sm text-muted-foreground">This invitation has already been redeemed.</p>
          </CardHeader>
          <CardContent className="text-center">
            <a href="/">
              <Button variant="outline" data-testid="button-go-home-used">Go to Home</Button>
            </a>
          </CardContent>
        </Card>
      </div>
    );
  }

  if (user && profile) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center p-6">
        <Card className="w-full max-w-md">
          <CardHeader className="text-center space-y-2">
            <div className="flex justify-center mb-2">
              <div className="w-12 h-12 rounded-md bg-primary/10 flex items-center justify-center">
                <CheckCircle2 className="w-6 h-6 text-primary" />
              </div>
            </div>
            <CardTitle className="text-xl font-serif" data-testid="text-already-has-account">You Already Have an Account</CardTitle>
            <p className="text-sm text-muted-foreground">You are already registered as a {profile.role}. You don't need to use this invitation.</p>
          </CardHeader>
          <CardContent className="text-center">
            <a href="/">
              <Button data-testid="button-go-dashboard">Go to Dashboard</Button>
            </a>
          </CardContent>
        </Card>
      </div>
    );
  }

  if (user && !profile) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center p-6">
        <Card className="w-full max-w-md">
          <CardHeader className="text-center space-y-2">
            <div className="flex justify-center mb-2">
              <div className="w-12 h-12 rounded-md bg-primary flex items-center justify-center">
                {invitation.role === "teacher" ? (
                  <ShieldCheck className="w-6 h-6 text-primary-foreground" />
                ) : (
                  <Users className="w-6 h-6 text-primary-foreground" />
                )}
              </div>
            </div>
            <CardTitle className="text-xl font-serif" data-testid="text-invite-redeeming">Setting Up Your Account</CardTitle>
            <p className="text-sm text-muted-foreground">
              Creating your {invitation.role} account{invitation.familyName ? ` for the ${invitation.familyName} family` : ""}...
            </p>
          </CardHeader>
          <CardContent className="flex justify-center">
            <Skeleton className="h-10 w-full" />
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background flex items-center justify-center p-6">
      <Card className="w-full max-w-md">
        <CardHeader className="text-center space-y-2">
          <div className="flex justify-center mb-2">
            <div className="w-12 h-12 rounded-md bg-primary flex items-center justify-center">
              {invitation.role === "teacher" ? (
                <ShieldCheck className="w-6 h-6 text-primary-foreground" />
              ) : (
                <Users className="w-6 h-6 text-primary-foreground" />
              )}
            </div>
          </div>
          <CardTitle className="text-xl font-serif" data-testid="text-invite-title">
            You've Been Invited as a {invitation.role === "teacher" ? "Teacher" : "Parent"}
          </CardTitle>
          {invitation.familyName && (
            <p className="text-sm text-muted-foreground" data-testid="text-invite-family">
              Family: {invitation.familyName}
            </p>
          )}
          <p className="text-sm text-muted-foreground">
            Sign in with Replit to accept this invitation and set up your account.
          </p>
        </CardHeader>
        <CardContent className="space-y-4">
          <a href="/api/login">
            <Button className="w-full" data-testid="button-login-accept">
              <GraduationCap className="w-4 h-4 mr-2" />
              Sign In to Accept
            </Button>
          </a>
        </CardContent>
      </Card>
    </div>
  );
}
