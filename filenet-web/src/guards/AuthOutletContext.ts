import { useOutletContext } from "react-router-dom";
import type { ProfileRecord } from "@/powersync/AppSchema";

export type AuthOutletContext = { userId: string };
export type ProfileOutletContext = AuthOutletContext & { profile: ProfileRecord };

export const useAuthOutletContext = () => useOutletContext<AuthOutletContext>();
export const useProfileOutletContext = () => useOutletContext<ProfileOutletContext>();
