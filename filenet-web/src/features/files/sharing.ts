import { connector } from "@/powersync/SupabaseConnector";

/** Sharing goes through Postgres RPCs (not the PowerSync CRUD queue) — requires connectivity. */
export async function shareFileToUser(fileId: string, recipientId: string) {
  const { error } = await connector.client.rpc("share_file_to_user", {
    p_file_id: fileId,
    p_recipient_id: recipientId,
  });
  if (error) throw error;
}

export async function shareFileToGroup(fileId: string, groupId: string) {
  const { error } = await connector.client.rpc("share_file_to_group", {
    p_file_id: fileId,
    p_group_id: groupId,
  });
  if (error) throw error;
}
