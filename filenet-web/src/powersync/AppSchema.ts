import { column, Schema, Table } from "@powersync/web";

// Mirrors the `profiles` / `files` Postgres tables — see supabase/migrations.
// Only what's actually in scope for the current sync-rule streams (docker/powersync.yaml)
// is defined here; group/share/notification tables are added alongside the streams
// that sync them in later phases.

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
  storage_path: column.text,
  mime_type: column.text,
  file_size: column.integer,
  owner_id: column.text,
  created_at: column.text,
  updated_at: column.text,
});

export const AppSchema = new Schema({
  profiles,
  files,
});

export type Database = (typeof AppSchema)["types"];
export type ProfileRecord = Database["profiles"];
export type FileRecord = Database["files"];
