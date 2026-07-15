import { NavLink, Outlet } from "react-router-dom";
import { FileText, LayoutDashboard, Users, UsersRound, Bell, UserCircle, LogOut, Share2 } from "lucide-react";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { connector } from "@/powersync/SupabaseConnector";
import { useProfileOutletContext } from "@/guards/AuthOutletContext";

const navItem = (to: string, label: string, Icon: React.ComponentType<{ className?: string }>) => (
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
    {label}
  </NavLink>
);

export function AppShell() {
  const { profile } = useProfileOutletContext();
  const isAdmin = profile.role === "admin";

  return (
    <div className="flex min-h-screen bg-background">
      <aside className="hidden w-64 shrink-0 flex-col border-r border-sidebar-border bg-sidebar p-4 md:flex">
        <div className="mb-6 px-2 text-xl font-bold text-primary">File Net</div>
        <nav className="flex flex-1 flex-col gap-1">
          {navItem("/dashboard", "Dashboard", LayoutDashboard)}
          {navItem("/files", "My Files", FileText)}
          {navItem("/shared", "Shared With Me", Share2)}
          {navItem("/notifications", "Notifications", Bell)}
          {isAdmin && (
            <>
              <div className="mt-4 mb-1 px-3 text-xs font-semibold tracking-wide text-sidebar-foreground/50 uppercase">
                Admin
              </div>
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
