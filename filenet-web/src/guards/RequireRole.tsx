import { Navigate, Outlet } from "react-router-dom";
import { useProfileOutletContext } from "@/guards/AuthOutletContext";

/**
 * Route-level gate for admin-only screens. This is a UX convenience, not the
 * security boundary — RLS and PowerSync sync rules are what actually stop a
 * non-admin from reading/writing admin-only data, even from a tampered client
 * (unlike the old Flutter app, where hidden menu items were the only gate).
 */
export function RequireRole({ role }: { role: string }) {
  const context = useProfileOutletContext();

  if (context.profile.role !== role) {
    return <Navigate to="/unauthorized" replace />;
  }

  // useOutletContext only sees the NEAREST ancestor Outlet's context — without
  // passing it through explicitly here, nested routes under this guard (e.g.
  // GroupsPage) get undefined instead of inheriting AppShell's context.
  // Confirmed via a real crash: "Cannot destructure property 'userId' of
  // useProfileOutletContext(...) as it is undefined" on GroupsPage.
  return <Outlet context={context} />;
}
