import { useNavigate } from "react-router-dom";
import { useQuery } from "@powersync/react";
import { FileText, Share2 } from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { useProfileOutletContext } from "@/guards/AuthOutletContext";

type SharedFileRow = {
  id: string;
  title: string;
  description: string;
  owner_id: string;
  owner_name: string | null;
  shared_at: string;
};

export function SharedPage() {
  const { userId } = useProfileOutletContext();
  const navigate = useNavigate();

  const { data: files, isLoading } = useQuery<SharedFileRow>(
    `SELECT f.id, f.title, f.description, f.owner_id, p.full_name as owner_name, fs.created_at as shared_at
     FROM file_shares fs
     JOIN files f ON f.id = fs.file_id
     LEFT JOIN profiles p ON p.id = f.owner_id
     WHERE fs.recipient_id = ?
     ORDER BY fs.created_at DESC`,
    [userId]
  );

  return (
    <div className="grid gap-6">
      <div>
        <h1 className="text-2xl font-bold">Shared With Me</h1>
        <p className="text-muted-foreground">Files other people have shared with you.</p>
      </div>

      {isLoading ? (
        <p className="text-muted-foreground">Loading...</p>
      ) : files.length === 0 ? (
        <Card>
          <CardContent className="flex flex-col items-center gap-2 py-12 text-center text-muted-foreground">
            <Share2 className="size-8" />
            <p>Nothing has been shared with you yet.</p>
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
          {files.map((f) => (
            <Card key={f.id} className="cursor-pointer transition-colors hover:border-primary" onClick={() => navigate(`/files/${f.id}`)}>
              <CardContent className="flex items-start gap-3 pt-6">
                <FileText className="size-8 shrink-0 text-primary" />
                <div className="min-w-0">
                  <p className="truncate font-medium">{f.title}</p>
                  <p className="truncate text-sm text-muted-foreground">Shared by {f.owner_name ?? "someone"}</p>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
