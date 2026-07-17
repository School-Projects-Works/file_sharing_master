import { useRef, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { useQuery } from "@powersync/react";
import { toast } from "sonner";
import { FileText, RotateCw, Trash2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
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
import { ShareDialog } from "@/features/files/ShareDialog";
import { deleteFile, uploadNewVersion, validateUpload } from "@/features/files/api";
import { VersionRow, type VersionRowData } from "@/features/files/VersionRow";
import type { FileRecord } from "@/powersync/AppSchema";

export function FileDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { profile, userId } = useProfileOutletContext();
  const [reuploading, setReuploading] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const { data: files } = useQuery<FileRecord>("SELECT * FROM files WHERE id = ?", [id ?? ""]);
  const file = files[0];

  const { data: versions } = useQuery<VersionRowData>(
    `SELECT fv.*, p.full_name as uploader_name,
            ROW_NUMBER() OVER (PARTITION BY fv.file_id ORDER BY fv.created_at) as version_number
     FROM file_versions fv
     LEFT JOIN profiles p ON p.id = fv.uploaded_by
     WHERE fv.file_id = ?
     ORDER BY fv.created_at DESC`,
    [id ?? ""]
  );

  if (!file) {
    return <p className="text-muted-foreground">Loading, or you don't have access to this file.</p>;
  }

  const isOwner = file.owner_id === userId;
  const canManage = isOwner || profile.role === "admin";

  const handleReuploadChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const selected = e.target.files?.[0];
    e.target.value = "";
    if (!selected) return;
    const validationError = validateUpload(selected);
    if (validationError) {
      toast.error(validationError);
      return;
    }
    setReuploading(true);
    try {
      await uploadNewVersion({ fileId: file.id, ownerId: file.owner_id!, uploadedBy: userId, blob: selected });
      toast.success("New version uploaded");
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Upload failed");
    } finally {
      setReuploading(false);
    }
  };

  const handleDelete = async () => {
    await deleteFile(file.id);
    toast.success("File deleted");
    navigate("/files");
  };

  return (
    <div className="mx-auto grid max-w-2xl gap-6">
      <Card>
        <CardHeader className="flex-row items-start justify-between space-y-0">
          <div className="flex gap-3">
            <FileText className="size-8 shrink-0 text-primary" />
            <div>
              <CardTitle>{file.title}</CardTitle>
              <p className="mt-1 text-sm text-muted-foreground">{file.description || "No description"}</p>
            </div>
          </div>
          <div className="flex shrink-0 gap-2">
            {canManage && <ShareDialog fileId={file.id} currentUserId={userId} />}
            {canManage && (
              <AlertDialog>
                <AlertDialogTrigger asChild>
                  <Button variant="outline" size="icon">
                    <Trash2 className="size-4" />
                  </Button>
                </AlertDialogTrigger>
                <AlertDialogContent>
                  <AlertDialogHeader>
                    <AlertDialogTitle>Delete this file?</AlertDialogTitle>
                    <AlertDialogDescription>
                      This removes "{file.title}" and all its versions. This can't be undone.
                    </AlertDialogDescription>
                  </AlertDialogHeader>
                  <AlertDialogFooter>
                    <AlertDialogCancel>Cancel</AlertDialogCancel>
                    <AlertDialogAction onClick={handleDelete}>Delete</AlertDialogAction>
                  </AlertDialogFooter>
                </AlertDialogContent>
              </AlertDialog>
            )}
          </div>
        </CardHeader>
      </Card>

      <Card>
        <CardHeader className="flex-row items-center justify-between space-y-0">
          <CardTitle className="text-base">Version history</CardTitle>
          {canManage && (
            <>
              <input ref={fileInputRef} type="file" accept="application/pdf" className="hidden" onChange={handleReuploadChange} />
              <Button variant="outline" size="sm" disabled={reuploading} onClick={() => fileInputRef.current?.click()}>
                <RotateCw className="size-4" />
                {reuploading ? "Uploading..." : "Upload new version"}
              </Button>
            </>
          )}
        </CardHeader>
        <CardContent className="grid gap-2">
          {versions.map((v) => (
            <VersionRow key={v.id} version={v} isLatest={v.version_number === versions.length} />
          ))}
        </CardContent>
      </Card>
    </div>
  );
}
