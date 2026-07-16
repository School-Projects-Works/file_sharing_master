import { useNavigate } from "react-router-dom";
import { useQuery } from "@powersync/react";
import { Bell } from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { cn } from "@/lib/utils";
import { useProfileOutletContext } from "@/guards/AuthOutletContext";
import { powerSync } from "@/powersync/System";
import type { NotificationRecord } from "@/powersync/AppSchema";

export function NotificationsPage() {
  const { userId } = useProfileOutletContext();
  const navigate = useNavigate();

  const { data: notifications, isLoading } = useQuery<NotificationRecord>(
    "SELECT * FROM notifications WHERE recipient_id = ? ORDER BY created_at DESC",
    [userId]
  );

  const handleClick = async (n: NotificationRecord) => {
    if (!n.is_read) {
      await powerSync.execute("UPDATE notifications SET is_read = 1 WHERE id = ?", [n.id]);
    }
    if (n.file_id) navigate(`/files/${n.file_id}`);
  };

  return (
    <div className="mx-auto grid max-w-2xl gap-6">
      <div>
        <h1 className="text-2xl font-bold">Notifications</h1>
        <p className="text-muted-foreground">Updates on files shared with you.</p>
      </div>

      {isLoading ? (
        <p className="text-muted-foreground">Loading...</p>
      ) : notifications.length === 0 ? (
        <Card>
          <CardContent className="flex flex-col items-center gap-2 py-12 text-center text-muted-foreground">
            <Bell className="size-8" />
            <p>No notifications yet.</p>
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-2">
          {notifications.map((n) => (
            <Card
              key={n.id}
              className={cn("cursor-pointer transition-colors hover:border-primary", !n.is_read && "border-primary/50 bg-primary/5")}
              onClick={() => handleClick(n)}
            >
              <CardContent className="flex items-start gap-3 py-4">
                {!n.is_read && <span className="mt-1.5 size-2 shrink-0 rounded-full bg-primary" />}
                <div className={cn("min-w-0", n.is_read && "pl-5")}>
                  <p className="font-medium">{n.title}</p>
                  <p className="text-sm text-muted-foreground">{n.body}</p>
                  <p className="mt-1 text-xs text-muted-foreground">{n.created_at ? new Date(n.created_at).toLocaleString() : ""}</p>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
