import { connector } from "@/powersync/SupabaseConnector";
import { powerSync } from "@/powersync/System";

export const STORAGE_BUCKET = "files";
export const MAX_FILE_SIZE_BYTES = 25 * 1024 * 1024; // matches the Storage bucket's file_size_limit
export const ALLOWED_MIME_TYPES = ["application/pdf"];

/** Creates the file "document" record and uploads its first version. Requires connectivity for the blob upload. */
export async function createFileWithFirstVersion(params: {
  ownerId: string;
  title: string;
  description: string;
  blob: File;
}) {
  const { ownerId, title, description, blob } = params;
  const fileId = crypto.randomUUID();
  const versionId = crypto.randomUUID();
  const now = new Date().toISOString();
  const storagePath = `${ownerId}/${fileId}/${versionId}.pdf`;

  const { error: uploadError } = await connector.client.storage.from(STORAGE_BUCKET).upload(storagePath, blob, {
    contentType: blob.type || "application/pdf",
  });
  if (uploadError) throw uploadError;

  await powerSync.execute(
    "INSERT INTO files (id, title, description, owner_id, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?)",
    [fileId, title, description, ownerId, now, now]
  );
  await powerSync.execute(
    "INSERT INTO file_versions (id, file_id, storage_path, mime_type, file_size, uploaded_by, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)",
    [versionId, fileId, storagePath, blob.type || "application/pdf", blob.size, ownerId, now]
  );

  return fileId;
}

/** Uploads a new version of an existing file. Owner (or admin) only, enforced by RLS either way. */
export async function uploadNewVersion(params: { fileId: string; ownerId: string; uploadedBy: string; blob: File }) {
  const { fileId, ownerId, uploadedBy, blob } = params;
  const versionId = crypto.randomUUID();
  const now = new Date().toISOString();
  const storagePath = `${ownerId}/${fileId}/${versionId}.pdf`;

  const { error: uploadError } = await connector.client.storage.from(STORAGE_BUCKET).upload(storagePath, blob, {
    contentType: blob.type || "application/pdf",
  });
  if (uploadError) throw uploadError;

  await powerSync.execute(
    "INSERT INTO file_versions (id, file_id, storage_path, mime_type, file_size, uploaded_by, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)",
    [versionId, fileId, storagePath, blob.type || "application/pdf", blob.size, uploadedBy, now]
  );
  await powerSync.execute("UPDATE files SET updated_at = ? WHERE id = ?", [now, fileId]);
}

export async function getDownloadUrl(storagePath: string) {
  const { data, error } = await connector.client.storage.from(STORAGE_BUCKET).createSignedUrl(storagePath, 60);
  if (error) throw error;
  return data.signedUrl;
}

export async function deleteFile(fileId: string) {
  await powerSync.execute("DELETE FROM files WHERE id = ?", [fileId]);
}

export function validateUpload(file: File): string | null {
  if (!ALLOWED_MIME_TYPES.includes(file.type)) return "Only PDF files are allowed.";
  if (file.size > MAX_FILE_SIZE_BYTES) return `File is too large — the limit is ${MAX_FILE_SIZE_BYTES / 1024 / 1024}MB.`;
  return null;
}
