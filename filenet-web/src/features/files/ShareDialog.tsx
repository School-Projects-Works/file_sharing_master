import { useState } from "react";
import { useQuery } from "@powersync/react";
import { toast } from "sonner";
import { Share2, User, UsersRound } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Command, CommandEmpty, CommandGroup, CommandInput, CommandItem, CommandList } from "@/components/ui/command";
import { shareFileToUser, shareFileToGroup } from "@/features/files/sharing";
import type { ProfileRecord, GroupRecord } from "@/powersync/AppSchema";

export function ShareDialog({ fileId, currentUserId }: { fileId: string; currentUserId: string }) {
  const [open, setOpen] = useState(false);
  const [sharing, setSharing] = useState<string | null>(null);

  const { data: people } = useQuery<ProfileRecord>("SELECT * FROM profiles WHERE id != ? ORDER BY full_name", [
    currentUserId,
  ]);
  const { data: groups } = useQuery<GroupRecord>("SELECT * FROM groups ORDER BY name");

  const handleShareToUser = async (recipientId: string) => {
    setSharing(recipientId);
    try {
      await shareFileToUser(fileId, recipientId);
      toast.success("Shared");
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Could not share");
    } finally {
      setSharing(null);
    }
  };

  const handleShareToGroup = async (groupId: string) => {
    setSharing(groupId);
    try {
      await shareFileToGroup(fileId, groupId);
      toast.success("Shared with the group");
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Could not share");
    } finally {
      setSharing(null);
    }
  };

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button variant="outline">
          <Share2 className="size-4" />
          Share
        </Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Share file</DialogTitle>
          <DialogDescription>Share with a specific person, or an entire group.</DialogDescription>
        </DialogHeader>
        <Tabs defaultValue="person">
          <TabsList className="w-full">
            <TabsTrigger value="person">
              <User className="size-4" />
              Person
            </TabsTrigger>
            <TabsTrigger value="group">
              <UsersRound className="size-4" />
              Group
            </TabsTrigger>
          </TabsList>
          <TabsContent value="person">
            <Command className="rounded-md border">
              <CommandInput placeholder="Search people..." />
              <CommandList>
                <CommandEmpty>No one found.</CommandEmpty>
                <CommandGroup>
                  {people.map((p) => (
                    <CommandItem
                      key={p.id}
                      value={`${p.full_name} ${p.email}`}
                      onSelect={() => handleShareToUser(p.id)}
                      disabled={sharing === p.id}
                    >
                      {p.full_name} <span className="text-muted-foreground">({p.email})</span>
                    </CommandItem>
                  ))}
                </CommandGroup>
              </CommandList>
            </Command>
          </TabsContent>
          <TabsContent value="group">
            {groups.length === 0 ? (
              <p className="p-4 text-sm text-muted-foreground">You're not part of any groups.</p>
            ) : (
              <Command className="rounded-md border">
                <CommandInput placeholder="Search groups..." />
                <CommandList>
                  <CommandEmpty>No groups found.</CommandEmpty>
                  <CommandGroup>
                    {groups.map((g) => (
                      <CommandItem
                        key={g.id}
                        value={g.name ?? ""}
                        onSelect={() => handleShareToGroup(g.id)}
                        disabled={sharing === g.id}
                      >
                        {g.name}
                      </CommandItem>
                    ))}
                  </CommandGroup>
                </CommandList>
              </Command>
            )}
          </TabsContent>
        </Tabs>
      </DialogContent>
    </Dialog>
  );
}
