import { NavLink, Outlet } from "react-router-dom";
import { useQuery } from "@powersync/react";
import { FileText, LayoutDashboard, Users, UsersRound, Bell, UserCircle, LogOut, Share2, ShieldCheck } from "lucide-react";
import { cn } from "@/lib/utils";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { connector } from "@/powersync/SupabaseConnector";
import { useProfileOutletContext } from "@/guards/AuthOutletContext";

const navItem = (to: string, label: string, Icon: React.ComponentType<{ className?: string }>, badge?: number) => (
  <NavLink
    key={to}
    to={to}
    className={({ isActive }) =>
      cn(
        "flex items-center gap-3 rounded-md px-3 py-2 text-sm font-medium transition-colors",
        isActive ? "bg-sidebar-accent text-sidebar-accent-foreground" : "text-sidebar-foreground/80 hover:bg-sidebar-accent/60"
      )
    }
  >
    <Icon className="size-4" />
    <span className="flex-1">{label}</span>
    {Boolean(badge) && (
      <Badge variant="destructive" className="h-5 min-w-5 justify-center px-1">
        {badge}
      </Badge>
    )}
  </NavLink>
);

export function AppShell() {
  const { profile } = useProfileOutletContext();
  const isAdmin = profile.role === "admin";
  const { data: unread } = useQuery<{ n: number }>(
    "SELECT COUNT(*) as n FROM notifications WHERE recipient_id = ? AND is_read = 0",
    [profile.id]
  );
  const unreadCount = unread[0]?.n ?? 0;

  return (
    <div className="flex min-h-screen bg-background">
      <aside className="hidden w-64 shrink-0 flex-col border-r border-sidebar-border bg-sidebar p-4 md:flex">
        <div className="mb-6 px-2 text-xl font-bold text-primary">File Net</div>
        <nav className="flex flex-1 flex-col gap-1">
          {navItem("/dashboard", "Dashboard", LayoutDashboard)}
          {navItem("/files", "My Files", FileText)}
          {navItem("/shared", "Shared With Me", Share2)}
          {navItem("/notifications", "Notifications", Bell, unreadCount)}
          {isAdmin && (
            <>
              <div className="mt-4 mb-1 px-3 text-xs font-semibold tracking-wide text-sidebar-foreground/50 uppercase">
                Admin
              </div>
              {navItem("/admin/dashboard", "Overview", ShieldCheck)}
              {navItem("/groups", "Groups", UsersRound)}
              {navItem("/admin/users", "Users", Users)}
            </>
          )}
        </nav>
        <div className="mt-auto flex flex-col gap-1 border-t border-sidebar-border pt-4">
          {navItem("/account", "Account", UserCircle)}
          <button
            onClick={() => connector.logout()}
            className="flex items-center gap-3 rounded-md px-3 py-2 text-sm font-medium text-sidebar-foreground/80 hover:bg-sidebar-accent/60"
          >
            <LogOut className="size-4" />
            Sign out
          </button>
        </div>
      </aside>

      <div className="flex flex-1 flex-col">
        <header className="flex items-center justify-between border-b border-border bg-card px-4 py-3 md:hidden">
          <div className="text-lg font-bold text-primary">File Net</div>
          <Button variant="ghost" size="icon" onClick={() => connector.logout()}>
            <LogOut className="size-4" />
          </Button>
        </header>
        <main className="flex-1 p-6">
          <Outlet context={{ userId: profile.id, profile }} />
        </main>
      </div>
    </div>
  );
}
