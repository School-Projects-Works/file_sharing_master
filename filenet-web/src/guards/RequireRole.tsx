import { Navigate, Outlet } from "react-router-dom";
import { useProfileOutletContext } from "@/guards/AuthOutletContext";

/**
 * Route-level gate for admin-only screens. This is a UX convenience, not the
 * security boundary — RLS and PowerSync sync rules are what actually stop a
 * non-admin from reading/writing admin-only data, even from a tampered client
 * (unlike the old Flutter app, where hidden menu items were the only gate).
 */
export function RequireRole({ role }: { role: string }) {
  const { profile } = useProfileOutletContext();

  if (profile.role !== role) {
    return <Navigate to="/unauthorized" replace />;
  }

  return <Outlet />;
}
