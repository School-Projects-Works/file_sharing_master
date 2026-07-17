import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useQuery } from "@powersync/react";
import { FileText, Search } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Card, CardContent } from "@/components/ui/card";
import { useProfileOutletContext } from "@/guards/AuthOutletContext";
import { NewFileDialog } from "@/features/files/NewFileDialog";
import type { FileRecord } from "@/powersync/AppSchema";

export function FilesPage() {
  const { userId } = useProfileOutletContext();
  const navigate = useNavigate();
  const [search, setSearch] = useState("");

  const { data: files, isLoading } = useQuery<FileRecord>(
    "SELECT * FROM files WHERE owner_id = ? ORDER BY updated_at DESC",
    [userId]
  );

  const filtered = files.filter((f) => (f.title ?? "").toLowerCase().includes(search.toLowerCase()));

  return (
    <div className="grid gap-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">My Files</h1>
          <p className="text-muted-foreground">Files you've uploaded and own.</p>
        </div>
        <NewFileDialog ownerId={userId} onCreated={(fileId) => navigate(`/files/${fileId}`)} />
      </div>

      <div className="relative max-w-sm">
        <Search className="absolute top-2.5 left-2.5 size-4 text-muted-foreground" />
        <Input placeholder="Search files..." className="pl-8" value={search} onChange={(e) => setSearch(e.target.value)} />
      </div>

      {isLoading ? (
        <p className="text-muted-foreground">Loading...</p>
      ) : filtered.length === 0 ? (
        <Card>
          <CardContent className="flex flex-col items-center gap-2 py-12 text-center text-muted-foreground">
            <FileText className="size-8" />
            <p>{files.length === 0 ? "You haven't uploaded any files yet." : "No files match your search."}</p>
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
          {filtered.map((f) => (
            <Card
              key={f.id}
              className="cursor-pointer transition-colors hover:border-primary"
              onClick={() => navigate(`/files/${f.id}`)}
            >
              <CardContent className="flex items-start gap-3 pt-6">
                <FileText className="size-8 shrink-0 text-primary" />
                <div className="min-w-0">
                  <p className="truncate font-medium">{f.title}</p>
                  <p className="truncate text-sm text-muted-foreground">{f.description || "No description"}</p>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
