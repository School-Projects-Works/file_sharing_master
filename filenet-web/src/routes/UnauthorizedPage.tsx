import { Link } from "react-router-dom";
import { Lock } from "lucide-react";
import { Button } from "@/components/ui/button";

export function UnauthorizedPage() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center gap-4 p-4 text-center">
      <Lock className="size-12 text-muted-foreground" />
      <h1 className="text-xl font-bold">You don't have access to this page</h1>
      <Button asChild variant="outline">
        <Link to="/dashboard">Back to dashboard</Link>
      </Button>
    </div>
  );
}
