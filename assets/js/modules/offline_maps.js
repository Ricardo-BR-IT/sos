/**
 * SOS MODULE: OFFLINE MAPS (V22)
 * Caches Map Tiles using IndexedDB for "Grid Down" operation.
 * Strategy: Fetch -> Store in IDB -> Serve from IDB if fetch fails.
 * Limitations: Simple cache strategy (LRU not implemented for simplicity).
 */

const OfflineMaps = {
    dbName: "SOS_MAP_CACHE",
    storeName: "tiles",
    db: null,
    ready: false,

    init: async () => {
        console.log(">>> Offline Maps Module Loaded");

        // Open IndexedDB
        const request = indexedDB.open(OfflineMaps.dbName, 1);

        request.onupgradeneeded = (event) => {
            const db = event.target.result;
            if (!db.objectStoreNames.contains(OfflineMaps.storeName)) {
                db.createObjectStore(OfflineMaps.storeName, { keyPath: "key" });
            }
        };

        request.onsuccess = (event) => {
            OfflineMaps.db = event.target.result;
            OfflineMaps.ready = true;
            console.log(">>> Map Cache Ready");
        };

        request.onerror = (event) => {
            console.error("Map Cache Error", event);
        };
    },

    // Save a tile (Used when online)
    saveTile: async (x, y, z, blob) => {
        if (!OfflineMaps.ready) return;
        const key = `${z}/${x}/${y}`;

        const tx = OfflineMaps.db.transaction([OfflineMaps.storeName], "readwrite");
        const store = tx.objectStore(OfflineMaps.storeName);
        store.put({ key: key, blob: blob, timestamp: Date.now() });
    },

    // Load a tile (Used when offline)
    loadTile: async (x, y, z) => {
        return new Promise((resolve, reject) => {
            if (!OfflineMaps.ready) return reject("DB Not Ready");
            const key = `${z}/${x}/${y}`;
            const tx = OfflineMaps.db.transaction([OfflineMaps.storeName], "readonly");
            const store = tx.objectStore(OfflineMaps.storeName);
            const req = store.get(key);

            req.onsuccess = (event) => {
                if (req.result) resolve(req.result.blob);
                else resolve(null);
            };
            req.onerror = () => reject("Read Error");
        });
    },

    // Download Region (Simulated Batch)
    downloadRegion: async (lat, lon, zoom = 15, radius = 500) => {
        // This is a complex task usually: calculating tile coords from Geo
        // Simplified Logic: Just grab current view tiles
        UI.logSystem("Downloading Map Region...");
        // (Placeholder)
        // Would iterate X/Y based on Mercator projection
        // fetch(url).then(b => saveTile(x,y,z,b))
        setTimeout(() => UI.logSystem("Map Download Complete (Simulated)"), 2000);
    },

    // --- LEAFLET HOOK (Example Logic) ---
    // Override Leaflet's TileLayer.getTileUrl logic:
    // 1. Try Fetch (Online)
    // 2. Be smart: Cache successful fetches
    // 3. Fallback to IDB (Offline)
    // This requires modifying `radar.js` or monkey-patching Leaflet.
    // For V22, we expose the API for future integration.
};
