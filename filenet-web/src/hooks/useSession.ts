import { useEffect, useState } from "react";
import type { Session } from "@supabase/supabase-js";
import { connector } from "@/powersync/SupabaseConnector";
import { connectPowerSync, disconnectPowerSync } from "@/powersync/System";

/**
 * Tracks the Supabase auth session and keeps PowerSync's connection in lockstep
 * with it — connected while logged in, disconnected on logout. Every protected
 * route ultimately depends on this, so it lives once at the app root.
 */
export function useSession() {
  const [session, setSession] = useState<Session | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;

    (async () => {
      const restored = await connector.restoreSession();
      if (restored) {
        await connectPowerSync();
      }
      if (!cancelled) {
        setSession(restored);
        setLoading(false);
      }
    })();

    const { data: subscription } = connector.client.auth.onAuthStateChange(async (event, newSession) => {
      if (event === "SIGNED_OUT") {
        await disconnectPowerSync();
        setSession(null);
        return;
      }
      if (newSession) {
        await connectPowerSync();
        setSession(newSession);
      }
    });

    return () => {
      cancelled = true;
      subscription.subscription.unsubscribe();
    };
  }, []);

  return { session, loading };
}
