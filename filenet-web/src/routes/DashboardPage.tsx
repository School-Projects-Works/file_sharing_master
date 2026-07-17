import { useQuery, useStatus } from "@powersync/react";
import { FileText, Users, Wifi, WifiOff } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { useProfileOutletContext } from "@/guards/AuthOutletContext";
import type { ProfileRecord, FileRecord } from "@/powersync/AppSchema";

export function DashboardPage() {
  const { profile, userId } = useProfileOutletContext();
  const status = useStatus();
  const { data: directory } = useQuery<ProfileRecord>("SELECT * FROM profiles");
  const { data: myFiles } = useQuery<FileRecord>("SELECT * FROM files WHERE owner_id = ?", [userId]);

  return (
    <div className="grid gap-6">
      <div>
        <h1 className="text-2xl font-bold">Welcome back, {profile.full_name || profile.email}</h1>
        <p className="text-muted-foreground">Here's what's happening on File Net.</p>
      </div>

      <div className="grid gap-4 sm:grid-cols-3">
        <Card>
          <CardHeader className="flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">My Files</CardTitle>
            <FileText className="size-4 text-muted-foreground" />
          </CardHeader>
          <CardContent className="text-2xl font-bold">{myFiles.length}</CardContent>
        </Card>
        <Card>
          <CardHeader className="flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">People on File Net</CardTitle>
            <Users className="size-4 text-muted-foreground" />
          </CardHeader>
          <CardContent className="text-2xl font-bold">{directory.length}</CardContent>
        </Card>
        <Card>
          <CardHeader className="flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Sync status</CardTitle>
            {status.connected ? (
              <Wifi className="size-4 text-emerald-600" />
            ) : (
              <WifiOff className="size-4 text-destructive" />
            )}
          </CardHeader>
          <CardContent className="text-sm">
            {status.connected ? "Online — up to date" : "Offline — showing cached data"}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
