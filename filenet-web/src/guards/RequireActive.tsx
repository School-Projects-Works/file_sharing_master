import { Navigate, Outlet, useLocation } from "react-router-dom";
import { useProfile } from "@/hooks/useProfile";
import { useAuthOutletContext } from "@/guards/AuthOutletContext";

/**
 * Blocks banned users and forces a password change when required. This is a
 * UX convenience only — the real enforcement is server-side: a blocked user's
 * PowerSync buckets simply stop returning rows, and RLS rejects their writes.
 */
export function RequireActive() {
  const { userId } = useAuthOutletContext();
  const { profile, isLoading } = useProfile(userId);
  const location = useLocation();

  if (isLoading || !profile) {
    return <div className="flex h-screen items-center justify-center text-muted-foreground">Loading...</div>;
  }

  if (profile.status === "blocked") {
    return <Navigate to="/blocked" replace />;
  }

  if (profile.must_change_password && location.pathname !== "/account") {
    return <Navigate to="/account" state={{ forcePasswordChange: true }} replace />;
  }

  return <Outlet context={{ userId, profile }} />;
}
