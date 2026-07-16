import { useState } from "react";
import { useQuery } from "@powersync/react";
import { toast } from "sonner";
import { Trash2, UsersRound } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog";
import { useProfileOutletContext } from "@/guards/AuthOutletContext";
import { CreateGroupDialog } from "@/features/groups/CreateGroupDialog";
import { ManageMembersDialog } from "@/features/groups/ManageMembersDialog";
import { deleteGroup } from "@/features/groups/api";
import type { GroupRecord } from "@/powersync/AppSchema";

export function GroupsPage() {
  const { userId } = useProfileOutletContext();
  const [managingGroup, setManagingGroup] = useState<GroupRecord | null>(null);

  const { data: groups, isLoading } = useQuery<GroupRecord>("SELECT * FROM groups ORDER BY name");

  const handleDelete = async (id: string) => {
    try {
      await deleteGroup(id);
      toast.success("Group deleted");
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Could not delete group");
    }
  };

  return (
    <div className="grid gap-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">Groups</h1>
          <p className="text-muted-foreground">Create groups to share files with multiple people at once.</p>
        </div>
        <CreateGroupDialog createdBy={userId} />
      </div>

      {isLoading ? (
        <p className="text-muted-foreground">Loading...</p>
      ) : groups.length === 0 ? (
        <Card>
          <CardContent className="flex flex-col items-center gap-2 py-12 text-center text-muted-foreground">
            <UsersRound className="size-8" />
            <p>No groups yet.</p>
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
          {groups.map((g) => (
            <Card key={g.id}>
              <CardContent className="pt-6">
                <div className="flex items-start justify-between gap-2">
                  <div className="min-w-0">
                    <p className="truncate font-medium">{g.name}</p>
                    <p className="truncate text-sm text-muted-foreground">{g.description || "No description"}</p>
                  </div>
                  <AlertDialog>
                    <AlertDialogTrigger asChild>
                      <Button variant="ghost" size="icon-sm">
                        <Trash2 className="size-4" />
                      </Button>
                    </AlertDialogTrigger>
                    <AlertDialogContent>
                      <AlertDialogHeader>
                        <AlertDialogTitle>Delete "{g.name}"?</AlertDialogTitle>
                        <AlertDialogDescription>This removes the group and its membership list.</AlertDialogDescription>
                      </AlertDialogHeader>
                      <AlertDialogFooter>
                        <AlertDialogCancel>Cancel</AlertDialogCancel>
                        <AlertDialogAction onClick={() => handleDelete(g.id)}>Delete</AlertDialogAction>
                      </AlertDialogFooter>
                    </AlertDialogContent>
                  </AlertDialog>
                </div>
                <Button variant="outline" size="sm" className="mt-3" onClick={() => setManagingGroup(g)}>
                  <UsersRound className="size-4" />
                  Manage members
                </Button>
              </CardContent>
            </Card>
          ))}
        </div>
      )}

      {managingGroup && (
        <ManageMembersDialog
          groupId={managingGroup.id}
          groupName={managingGroup.name ?? ""}
          currentUserId={userId}
          open={Boolean(managingGroup)}
          onOpenChange={(open) => !open && setManagingGroup(null)}
        />
      )}
    </div>
  );
}
