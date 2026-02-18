const CACHE_NAME = 'sos-tactical-v13';
const ASSETS_TO_CACHE = [
    './',
    'index.php',
    'assets/css/aeon.css',
    'assets/js/modules/ui.js',
    'assets/js/modules/mesh.js',
    'assets/js/modules/comms.js',
    'assets/js/modules/radar.js',
    'assets/js/modules/prep.js',
    'manifest.json'
];

// INSTALL (Cache Assets)
self.addEventListener('install', (evt) => {
    evt.waitUntil(
        caches.open(CACHE_NAME).then((cache) => {
            console.log('[SW] Caching shell assets');
            return cache.addAll(ASSETS_TO_CACHE);
        })
    );
});

// ACTIVATE (Cleanup Old Caches)
self.addEventListener('activate', (evt) => {
    evt.waitUntil(
        caches.keys().then((keys) => {
            return Promise.all(keys.map((key) => {
                if (key !== CACHE_NAME) {
                    console.log('[SW] Clearing old cache', key);
                    return caches.delete(key);
                }
            }));
        })
    );
});

// FETCH (Network First, fallback to Cache for API; Cache First for static)
self.addEventListener('fetch', (evt) => {
    // 1. API Calls (Network Only or Network First)
    if (evt.request.url.includes('api/')) {
        evt.respondWith(
            fetch(evt.request).catch(() => {
                // Optional: Return last known data from IndexedDB or specific cache
                return new Response(JSON.stringify({ error: "OFFLINE" }), {
                    headers: { 'Content-Type': 'application/json' }
                });
            })
        );
        return;
    }

    // 2. Static Assets (Stale-While-Revalidate or Cache First)
    evt.respondWith(
        caches.match(evt.request).then((cacheRes) => {
            return cacheRes || fetch(evt.request).then((fetchRes) => {
                return caches.open(CACHE_NAME).then((cache) => {
                    cache.put(evt.request.url, fetchRes.clone());
                    return fetchRes;
                });
            });
        }).catch(() => {
            // Fallback for HTML
            if (evt.request.headers.get('accept').includes('text/html')) {
                return caches.match('index.php');
            }
        })
    );
});
