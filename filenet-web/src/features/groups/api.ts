import { powerSync } from "@/powersync/System";

export async function createGroup(params: { name: string; description: string; createdBy: string }) {
  const { name, description, createdBy } = params;
  const id = crypto.randomUUID();
  const now = new Date().toISOString();
  await powerSync.execute("INSERT INTO groups (id, name, description, created_by, created_at) VALUES (?, ?, ?, ?, ?)", [
    id,
    name,
    description,
    createdBy,
    now,
  ]);
  return id;
}

export async function deleteGroup(groupId: string) {
  await powerSync.execute("DELETE FROM groups WHERE id = ?", [groupId]);
}

export async function addGroupMember(params: { groupId: string; memberId: string; addedBy: string }) {
  const { groupId, memberId, addedBy } = params;
  const id = crypto.randomUUID();
  const now = new Date().toISOString();
  await powerSync.execute(
    "INSERT INTO group_members (id, group_id, member_id, added_by, added_at) VALUES (?, ?, ?, ?, ?)",
    [id, groupId, memberId, addedBy, now]
  );
}

export async function removeGroupMember(groupId: string, memberId: string) {
  await powerSync.execute("DELETE FROM group_members WHERE group_id = ? AND member_id = ?", [groupId, memberId]);
}
