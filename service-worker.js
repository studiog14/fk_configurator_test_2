// Zwiększ wersję przy każdej zmianie - BŁĘDY JS FIX
const CACHE_NAME = 'v50-mobile-ui-panel';
const urlsToCache = [
  './',
  'index.html',
  'pseudo_ar.html',
  'manifest.json',
  'mobile.html',
  'pwa-install.js',
  'icons/FK_logo.png',
  'icons/favicon.png',
  'icons/favicon.jpg',
  'mobile_icons/soul.webp',
  'mobile_icons/soul_plus.webp',
  'mobile_icons/fargo.webp',
  'mobile_icons/tulla.webp'
];

self.addEventListener('install', e => {
  console.log('SW: Installing...');
  e.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('SW: Caching files');
        // Cache files one by one to see which ones fail
        return Promise.allSettled(
          urlsToCache.map(url => 
            cache.add(url).catch(err => {
              console.warn('SW: Failed to cache:', url, err);
              return null;
            })
          )
        );
      })
      .then(() => {
        console.log('SW: Cache complete');
        return self.skipWaiting();
      })
      .catch(err => {
        console.error('SW: Install failed:', err);
      })
  );
});

self.addEventListener('activate', e => {
  console.log('SW: Activating...');
  e.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheName !== CACHE_NAME) {
            console.log('SW: Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    }).then(() => self.clients.claim())
  );
});

self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});

// Network-first for navigation requests to avoid stale HTML on hard reloads
self.addEventListener('fetch', (event) => {
  const req = event.request;
  const accept = req.headers.get('accept') || '';
  const method = (req && req.method) || 'GET';
  const url = new URL(req.url);
  const scheme = url.protocol; // e.g., 'http:', 'https:', 'chrome-extension:'

  // Ignore non-http(s) schemes entirely
  if (scheme !== 'http:' && scheme !== 'https:') {
    return; // let the browser handle it
  }

  // Treat navigations and HTML requests as network-first
  const isNavigation = req.mode === 'navigate' || accept.includes('text/html');

  if (isNavigation) {
    event.respondWith((async () => {
      try {
        const networkResp = await fetch(req, { cache: 'no-store' });
        // Update cache in background (GET only)
        if (method === 'GET') {
          const cache = await caches.open(CACHE_NAME);
          cache.put(req, networkResp.clone());
        }
        return networkResp;
      } catch (err) {
        // Fallback to cache (offline)
        const cached = await caches.match(req);
        if (cached) return cached;
  // Final fallback to cached HTML if available
  return (await caches.match('index.html')) || (await caches.match('mobile.html'));
      }
    })());
    return;
  }

  // For other assets: cache-first with background update
  event.respondWith((async () => {
    // Do not try to cache non-GET requests (e.g. HEAD)
    if (method !== 'GET') {
      try { return await fetch(req); } catch (_) { return new Response('', { status: 504, statusText: 'Gateway Timeout' }); }
    }
    const cached = await caches.match(req);
    if (cached) {
      // Try to update in background
      fetch(req).then(async (resp) => {
        try {
          if (resp && resp.status === 200) {
            const cache = await caches.open(CACHE_NAME);
            cache.put(req, resp.clone());
          }
        } catch (_) { /* noop */ }
      }).catch(() => {});
      return cached;
    }
    try {
      const networkResp = await fetch(req);
      // Cache successful basic responses
      if (networkResp && networkResp.status === 200) {
        try {
          const cache = await caches.open(CACHE_NAME);
          cache.put(req, networkResp.clone());
        } catch (_) { /* noop */ }
      }
      return networkResp;
    } catch (err) {
      // As a last resort return nothing; specific fallbacks can be added per type
      return new Response('', { status: 504, statusText: 'Gateway Timeout' });
    }
  })());
});
