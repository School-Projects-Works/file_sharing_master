const CACHE_NAME = "filenet-file-blobs-v1";

// Storage paths aren't real URLs, so they're wrapped in a synthetic same-origin
// request the Cache API can key on.
const cacheKeyFor = (storagePath: string) => new Request(`https://filenet.local/blob/${encodeURIComponent(storagePath)}`);

export async function isBlobCached(storagePath: string): Promise<boolean> {
  if (!("caches" in window)) return false;
  const cache = await caches.open(CACHE_NAME);
  const match = await cache.match(cacheKeyFor(storagePath));
  return Boolean(match);
}

/** Downloads the file from its signed URL and stores it for offline access. */
export async function cacheBlob(storagePath: string, signedUrl: string): Promise<void> {
  const response = await fetch(signedUrl);
  if (!response.ok) throw new Error(`Failed to download file: ${response.status}`);
  const cache = await caches.open(CACHE_NAME);
  await cache.put(cacheKeyFor(storagePath), response);
}

/** Returns a local, offline-usable object URL for a previously cached blob, or null if not cached. */
export async function getCachedBlobUrl(storagePath: string): Promise<string | null> {
  if (!("caches" in window)) return null;
  const cache = await caches.open(CACHE_NAME);
  const match = await cache.match(cacheKeyFor(storagePath));
  if (!match) return null;
  const blob = await match.blob();
  return URL.createObjectURL(blob);
}

export async function removeCachedBlob(storagePath: string): Promise<void> {
  const cache = await caches.open(CACHE_NAME);
  await cache.delete(cacheKeyFor(storagePath));
}
