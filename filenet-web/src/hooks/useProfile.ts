import { useQuery } from "@powersync/react";
import type { ProfileRecord } from "@/powersync/AppSchema";

/** The current user's own profile row, reactively synced via PowerSync. */
export function useProfile(userId: string | undefined) {
  const { data, isLoading } = useQuery<ProfileRecord>(
    "SELECT * FROM profiles WHERE id = ?",
    [userId ?? ""],
    { runQueryOnce: false }
  );

  return { profile: userId ? data[0] : undefined, isLoading: userId ? isLoading : false };
}
