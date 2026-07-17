import { useState } from "react";
import { useLocation } from "react-router-dom";
import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { connector } from "@/powersync/SupabaseConnector";
import { powerSync } from "@/powersync/System";
import { useProfileOutletContext } from "@/guards/AuthOutletContext";

const schema = z
  .object({
    newPassword: z.string().min(6, "Password must be at least 6 characters"),
    confirmPassword: z.string(),
  })
  .refine((data) => data.newPassword === data.confirmPassword, {
    message: "Passwords don't match",
    path: ["confirmPassword"],
  });
type FormValues = z.infer<typeof schema>;

export function AccountPage() {
  const { profile, userId } = useProfileOutletContext();
  const location = useLocation();
  const forced = Boolean((location.state as { forcePasswordChange?: boolean })?.forcePasswordChange) || profile.must_change_password;
  const [submitting, setSubmitting] = useState(false);
  const {
    register,
    handleSubmit,
    reset,
    formState: { errors },
  } = useForm<FormValues>({ resolver: zodResolver(schema) });

  const onSubmit = async (values: FormValues) => {
    setSubmitting(true);
    try {
      const { error } = await connector.client.auth.updateUser({ password: values.newPassword });
      if (error) throw error;
      await powerSync.execute("UPDATE profiles SET must_change_password = 0 WHERE id = ?", [userId]);
      toast.success("Password updated");
      reset();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Could not update password");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="mx-auto grid max-w-lg gap-6">
      <Card>
        <CardHeader>
          <CardTitle>My account</CardTitle>
          <CardDescription>{profile.email}</CardDescription>
        </CardHeader>
        <CardContent className="grid gap-1 text-sm">
          <div><span className="text-muted-foreground">Name:</span> {profile.full_name}</div>
          <div><span className="text-muted-foreground">Phone:</span> {profile.phone || "—"}</div>
          <div><span className="text-muted-foreground">Role:</span> {profile.role}</div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Change password</CardTitle>
          {forced && (
            <CardDescription className="text-destructive">
              Your account was set up with a temporary password — you must set a new one before continuing.
            </CardDescription>
          )}
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit(onSubmit)} className="grid gap-4">
            <div className="grid gap-2">
              <Label htmlFor="newPassword">New password</Label>
              <Input id="newPassword" type="password" autoComplete="new-password" {...register("newPassword")} />
              {errors.newPassword && <p className="text-sm text-destructive">{errors.newPassword.message}</p>}
            </div>
            <div className="grid gap-2">
              <Label htmlFor="confirmPassword">Confirm password</Label>
              <Input id="confirmPassword" type="password" autoComplete="new-password" {...register("confirmPassword")} />
              {errors.confirmPassword && <p className="text-sm text-destructive">{errors.confirmPassword.message}</p>}
            </div>
            <Button type="submit" disabled={submitting}>
              {submitting ? "Updating..." : "Update password"}
            </Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
