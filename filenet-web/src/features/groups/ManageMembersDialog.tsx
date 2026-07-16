import { useState } from "react";
import { useQuery } from "@powersync/react";
import { toast } from "sonner";
import { UsersRound, X } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Command, CommandEmpty, CommandGroup, CommandInput, CommandItem, CommandList } from "@/components/ui/command";
import { addGroupMember, removeGroupMember } from "@/features/groups/api";
import type { ProfileRecord } from "@/powersync/AppSchema";

type MemberRow = { member_id: string; full_name: string; email: string };

export function ManageMembersDialog({
  groupId,
  groupName,
  currentUserId,
  open,
  onOpenChange,
}: {
  groupId: string;
  groupName: string;
  currentUserId: string;
  open: boolean;
  onOpenChange: (open: boolean) => void;
}) {
  const [busy, setBusy] = useState<string | null>(null);

  const { data: members } = useQuery<MemberRow>(
    `SELECT gm.member_id, p.full_name, p.email
     FROM group_members gm JOIN profiles p ON p.id = gm.member_id
     WHERE gm.group_id = ? ORDER BY p.full_name`,
    [groupId]
  );
  const { data: allPeople } = useQuery<ProfileRecord>("SELECT * FROM profiles ORDER BY full_name");

  const memberIds = new Set(members.map((m) => m.member_id));
  const nonMembers = allPeople.filter((p) => !memberIds.has(p.id));

  const handleAdd = async (memberId: string) => {
    setBusy(memberId);
    try {
      await addGroupMember({ groupId, memberId, addedBy: currentUserId });
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Could not add member");
    } finally {
      setBusy(null);
    }
  };

  const handleRemove = async (memberId: string) => {
    setBusy(memberId);
    try {
      await removeGroupMember(groupId, memberId);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Could not remove member");
    } finally {
      setBusy(null);
    }
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Members of {groupName}</DialogTitle>
        </DialogHeader>

        <div className="flex flex-wrap gap-2">
          {members.length === 0 && <p className="text-sm text-muted-foreground">No members yet.</p>}
          {members.map((m) => (
            <Badge key={m.member_id} variant="secondary" className="gap-1 py-1 pr-1">
              {m.full_name}
              <button
                onClick={() => handleRemove(m.member_id)}
                disabled={busy === m.member_id}
                className="rounded-full p-0.5 hover:bg-muted-foreground/20"
              >
                <X className="size-3" />
              </button>
            </Badge>
          ))}
        </div>

        <Command className="rounded-md border">
          <CommandInput placeholder="Add a member..." />
          <CommandList>
            <CommandEmpty>Everyone is already a member.</CommandEmpty>
            <CommandGroup>
              {nonMembers.map((p) => (
                <CommandItem key={p.id} value={`${p.full_name} ${p.email}`} onSelect={() => handleAdd(p.id)} disabled={busy === p.id}>
                  <UsersRound className="size-4" />
                  {p.full_name} <span className="text-muted-foreground">({p.email})</span>
                </CommandItem>
              ))}
            </CommandGroup>
          </CommandList>
        </Command>
      </DialogContent>
    </Dialog>
  );
}
