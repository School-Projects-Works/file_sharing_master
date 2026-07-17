import { column, Schema, Table } from "@powersync/web";

// Mirrors the Postgres schema (supabase/migrations). Local table names match the
// Postgres table names regardless of which sync-rule stream populates them —
// stream names (docker/powersync.yaml) are just organizational sync-rule
// groupings and are invisible at this layer.

const profiles = new Table({
  email: column.text,
  full_name: column.text,
  phone: column.text,
  role: column.text,
  status: column.text,
  must_change_password: column.integer,
  created_at: column.text,
  updated_at: column.text,
});

const files = new Table({
  title: column.text,
  description: column.text,
  owner_id: column.text,
  created_at: column.text,
  updated_at: column.text,
});

const file_versions = new Table({
  file_id: column.text,
  storage_path: column.text,
  mime_type: column.text,
  file_size: column.integer,
  uploaded_by: column.text,
  created_at: column.text,
});

const file_shares = new Table({
  file_id: column.text,
  recipient_id: column.text,
  shared_by: column.text,
  source_group_id: column.text,
  created_at: column.text,
});

const groups = new Table({
  name: column.text,
  description: column.text,
  created_by: column.text,
  created_at: column.text,
});

const group_members = new Table({
  group_id: column.text,
  member_id: column.text,
  added_by: column.text,
  added_at: column.text,
});

const notifications = new Table({
  recipient_id: column.text,
  type: column.text,
  title: column.text,
  body: column.text,
  file_id: column.text,
  file_share_id: column.text,
  is_read: column.integer,
  created_at: column.text,
});

export const AppSchema = new Schema({
  profiles,
  files,
  file_versions,
  file_shares,
  groups,
  group_members,
  notifications,
});

export type Database = (typeof AppSchema)["types"];
export type ProfileRecord = Database["profiles"];
export type FileRecord = Database["files"];
export type FileVersionRecord = Database["file_versions"];
export type FileShareRecord = Database["file_shares"];
export type GroupRecord = Database["groups"];
export type GroupMemberRecord = Database["group_members"];
export type NotificationRecord = Database["notifications"];
