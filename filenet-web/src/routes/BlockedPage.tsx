import { ShieldAlert } from "lucide-react";
import { Button } from "@/components/ui/button";
import { connector } from "@/powersync/SupabaseConnector";

export function BlockedPage() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center gap-4 p-4 text-center">
      <ShieldAlert className="size-12 text-destructive" />
      <h1 className="text-xl font-bold">Your account has been blocked</h1>
      <p className="max-w-sm text-muted-foreground">
        Contact your administrator if you believe this is a mistake.
      </p>
      <Button variant="outline" onClick={() => connector.logout()}>
        Sign out
      </Button>
    </div>
  );
}
