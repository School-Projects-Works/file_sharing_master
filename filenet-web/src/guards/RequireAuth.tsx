import { Navigate, Outlet, useLocation } from "react-router-dom";
import { useSession } from "@/hooks/useSession";

export function RequireAuth() {
  const { session, loading } = useSession();
  const location = useLocation();

  if (loading) {
    return <div className="flex h-screen items-center justify-center text-muted-foreground">Loading...</div>;
  }

  if (!session) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  return <Outlet context={{ userId: session.user.id }} />;
}
