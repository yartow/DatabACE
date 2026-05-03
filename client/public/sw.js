const ASSET_CACHE = "ceder-assets-v2";
const API_CACHE = "ceder-api-v2";

// API paths safe to serve from cache while offline
const CACHEABLE_API = /^\/api\/(students|courses|subjects|dates|pace-courses|paces|subject-groups|profile|enrollments|supplementary-activities|dashboard|settings|inventory|personnel|families|parents|pace-versions)\b/;

// Never cache auth flows or file operations
const SKIP_CACHE = /^\/api\/(login|logout|invitations\/redeem|.*\/(import|template|export))/;

// ── Lifecycle ──────────────────────────────────────────────────────────────

self.addEventListener("install", () => self.skipWaiting());

self.addEventListener("activate", (e) => {
  e.waitUntil(
    caches
      .keys()
      .then((keys) =>
        Promise.all(
          keys
            .filter((k) => k !== ASSET_CACHE && k !== API_CACHE)
            .map((k) => caches.delete(k)),
        ),
      )
      .then(() => self.clients.claim()),
  );
});

// ── Fetch handler ──────────────────────────────────────────────────────────

self.addEventListener("fetch", (e) => {
  const { request } = e;
  const url = new URL(request.url);

  // Only handle same-origin requests
  if (url.origin !== self.location.origin) return;

  // Never intercept non-GET mutations — let them reach the server
  if (request.method !== "GET") return;

  // Skip explicitly uncacheable routes
  if (SKIP_CACHE.test(url.pathname)) return;

  if (url.pathname.startsWith("/api/") && CACHEABLE_API.test(url.pathname)) {
    e.respondWith(networkFirstAPI(request));
    return;
  }

  // Static assets (JS/CSS/images with content hashes) — cache-first
  if (
    url.pathname.startsWith("/assets/") ||
    url.pathname.match(/\.(js|css|woff2?|ttf|png|jpg|jpeg|webp|svg|ico)$/)
  ) {
    e.respondWith(cacheFirstAsset(request));
    return;
  }

  // HTML navigation (SPA shell) — network-first, fall back to cached index
  e.respondWith(networkFirstShell(request));
});

// ── Strategies ─────────────────────────────────────────────────────────────

async function networkFirstAPI(request) {
  const cache = await caches.open(API_CACHE);
  try {
    const response = await fetch(request.clone());
    if (response.ok) {
      // Store with a timestamp header so stale age can be calculated
      const headers = new Headers(response.headers);
      headers.set("sw-cached-at", Date.now().toString());
      const stored = new Response(await response.clone().arrayBuffer(), {
        status: response.status,
        statusText: response.statusText,
        headers,
      });
      cache.put(request, stored);
    }
    return response;
  } catch {
    const cached = await cache.match(request);
    if (cached) return cached;
    return new Response(
      JSON.stringify({ offline: true, error: "You are offline" }),
      { status: 503, headers: { "Content-Type": "application/json" } },
    );
  }
}

async function cacheFirstAsset(request) {
  const cache = await caches.open(ASSET_CACHE);
  const cached = await cache.match(request);
  if (cached) return cached;
  const response = await fetch(request);
  if (response.ok) cache.put(request, response.clone());
  return response;
}

async function networkFirstShell(request) {
  const cache = await caches.open(ASSET_CACHE);
  try {
    const response = await fetch(request);
    if (response.ok) cache.put(request, response.clone());
    return response;
  } catch {
    const cached =
      (await cache.match(request)) ?? (await cache.match("/"));
    return (
      cached ??
      new Response("App is offline. Please try again when connected.", {
        status: 503,
        headers: { "Content-Type": "text/plain" },
      })
    );
  }
}
