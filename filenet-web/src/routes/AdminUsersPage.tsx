import { useState } from "react";
import { useQuery } from "@powersync/react";
import { toast } from "sonner";
import { Search } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { useProfileOutletContext } from "@/guards/AuthOutletContext";
import { ProvisionAccountDialog } from "@/features/admin/ProvisionAccountDialog";
import { powerSync } from "@/powersync/System";
import type { ProfileRecord } from "@/powersync/AppSchema";

export function AdminUsersPage() {
  const { userId } = useProfileOutletContext();
  const [search, setSearch] = useState("");
  const { data: users, isLoading } = useQuery<ProfileRecord>("SELECT * FROM profiles ORDER BY full_name");

  const filtered = users.filter(
    (u) =>
      (u.full_name ?? "").toLowerCase().includes(search.toLowerCase()) ||
      (u.email ?? "").toLowerCase().includes(search.toLowerCase())
  );

  const toggleStatus = async (u: ProfileRecord) => {
    const newStatus = u.status === "blocked" ? "active" : "blocked";
    try {
      await powerSync.execute("UPDATE profiles SET status = ? WHERE id = ?", [newStatus, u.id]);
      toast.success(newStatus === "blocked" ? `${u.full_name} blocked` : `${u.full_name} unblocked`);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Could not update status");
    }
  };

  return (
    <div className="grid gap-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">Users</h1>
          <p className="text-muted-foreground">Everyone on File Net.</p>
        </div>
        <ProvisionAccountDialog />
      </div>

      <div className="relative max-w-sm">
        <Search className="absolute top-2.5 left-2.5 size-4 text-muted-foreground" />
        <Input placeholder="Search users..." className="pl-8" value={search} onChange={(e) => setSearch(e.target.value)} />
      </div>

      {isLoading ? (
        <p className="text-muted-foreground">Loading...</p>
      ) : (
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Name</TableHead>
              <TableHead>Email</TableHead>
              <TableHead>Role</TableHead>
              <TableHead>Status</TableHead>
              <TableHead className="text-right">Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filtered.map((u) => (
              <TableRow key={u.id}>
                <TableCell className="font-medium">{u.full_name}</TableCell>
                <TableCell>{u.email}</TableCell>
                <TableCell className="capitalize">{u.role}</TableCell>
                <TableCell>
                  <Badge variant={u.status === "blocked" ? "destructive" : "secondary"}>{u.status}</Badge>
                </TableCell>
                <TableCell className="text-right">
                  {u.id !== userId && (
                    <Button variant="outline" size="sm" onClick={() => toggleStatus(u)}>
                      {u.status === "blocked" ? "Unblock" : "Block"}
                    </Button>
                  )}
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}
    </div>
  );
}
