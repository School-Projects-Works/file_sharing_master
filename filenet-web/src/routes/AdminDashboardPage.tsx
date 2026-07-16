import { useQuery } from "@powersync/react";
import { FileText, ShieldCheck, UsersRound, Users } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

export function AdminDashboardPage() {
  const { data: fileCount } = useQuery<{ n: number }>("SELECT COUNT(*) as n FROM files");
  const { data: userCount } = useQuery<{ n: number }>("SELECT COUNT(*) as n FROM profiles");
  const { data: groupCount } = useQuery<{ n: number }>("SELECT COUNT(*) as n FROM groups");
  const { data: blockedCount } = useQuery<{ n: number }>("SELECT COUNT(*) as n FROM profiles WHERE status = 'blocked'");

  const stats = [
    { label: "Total Files", value: fileCount[0]?.n ?? 0, icon: FileText },
    { label: "Total Users", value: userCount[0]?.n ?? 0, icon: Users },
    { label: "Groups", value: groupCount[0]?.n ?? 0, icon: UsersRound },
    { label: "Blocked Users", value: blockedCount[0]?.n ?? 0, icon: ShieldCheck },
  ];

  return (
    <div className="grid gap-6">
      <div>
        <h1 className="text-2xl font-bold">Admin Dashboard</h1>
        <p className="text-muted-foreground">Platform-wide overview.</p>
      </div>
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {stats.map((s) => (
          <Card key={s.label}>
            <CardHeader className="flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">{s.label}</CardTitle>
              <s.icon className="size-4 text-muted-foreground" />
            </CardHeader>
            <CardContent className="text-2xl font-bold">{s.value}</CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}
