import { useEffect, useState } from "react";
import { toast } from "sonner";
import { Download, HardDriveDownload, Trash2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { getDownloadUrl } from "@/features/files/api";
import { cacheBlob, getCachedBlobUrl, isBlobCached, removeCachedBlob } from "@/lib/offlineBlobs";

export type VersionRowData = {
  id: string;
  storage_path: string;
  file_size: number | null;
  uploaded_by: string;
  created_at: string;
  uploader_name: string | null;
  version_number: number;
};

export function VersionRow({ version, isLatest }: { version: VersionRowData; isLatest: boolean }) {
  const [cached, setCached] = useState(false);
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    isBlobCached(version.storage_path).then(setCached);
  }, [version.storage_path]);

  const handleOpen = async () => {
    setBusy(true);
    try {
      if (navigator.onLine) {
        const url = await getDownloadUrl(version.storage_path);
        window.open(url, "_blank");
      } else {
        const cachedUrl = await getCachedBlobUrl(version.storage_path);
        if (!cachedUrl) {
          toast.error("You're offline and this version isn't saved for offline viewing.");
          return;
        }
        window.open(cachedUrl, "_blank");
      }
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Could not open file");
    } finally {
      setBusy(false);
    }
  };

  const handleToggleOffline = async () => {
    setBusy(true);
    try {
      if (cached) {
        await removeCachedBlob(version.storage_path);
        setCached(false);
        toast.success("Removed from offline storage");
      } else {
        const url = await getDownloadUrl(version.storage_path);
        await cacheBlob(version.storage_path, url);
        setCached(true);
        toast.success("Available offline");
      }
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Could not update offline storage");
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="flex items-center justify-between rounded-md border p-3">
      <div>
        <p className="font-medium">
          Version {version.version_number}
          {isLatest && <span className="ml-2 text-xs text-muted-foreground">(latest)</span>}
          {cached && <span className="ml-2 text-xs text-emerald-600">available offline</span>}
        </p>
        <p className="text-sm text-muted-foreground">
          {version.uploader_name ?? "Unknown"} &middot; {new Date(version.created_at).toLocaleString()}
          {version.file_size ? ` · ${(version.file_size / 1024).toFixed(0)} KB` : ""}
        </p>
      </div>
      <div className="flex gap-1">
        <Button
          variant="ghost"
          size="icon"
          disabled={busy}
          title={cached ? "Remove from offline storage" : "Save for offline viewing"}
          onClick={handleToggleOffline}
        >
          {cached ? <Trash2 className="size-4" /> : <HardDriveDownload className="size-4" />}
        </Button>
        <Button variant="ghost" size="icon" disabled={busy} onClick={handleOpen} title="Open / download">
          <Download className="size-4" />
        </Button>
      </div>
    </div>
  );
}
