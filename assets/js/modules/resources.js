/**
 * SOS MODULE: RESOURCES (V22)
 * Survival Intel Layer: Water, Food, Meds, Ammo, Shelter.
 * Stores map markers in LocalStorage/SQLite and shares via Mesh.
 */

const Resources = {
    markers: [],
    categories: {
        'W': { icon: '💧', label: 'WATER' },
        'F': { icon: '🥫', label: 'FOOD' },
        'M': { icon: '💊', label: 'MEDS' },
        'A': { icon: '🔫', label: 'AMMO' },
        'S': { icon: '🏠', label: 'SHELTER' }
    },

    init: () => {
        console.log(">>> Resources Module Loaded");
        Resources.loadLocal();
    },

    loadLocal: () => {
        const data = localStorage.getItem('SOS_RESOURCES');
        if (data) {
            Resources.markers = JSON.parse(data);
            // Render on Radar (requires Radar hook)
            Resources.markers.forEach(Resources.renderMarker);
        }
    },

    addMarker: (lat, lon, type, notes) => {
        const marker = {
            id: Date.now().toString(36),
            lat: lat,
            lon: lon,
            type: type,
            notes: notes || "",
            timestamp: Date.now()
        };
        Resources.markers.push(marker);
        localStorage.setItem('SOS_RESOURCES', JSON.stringify(Resources.markers));

        Resources.renderMarker(marker);

        // Share via Mesh (if hardware available)
        if (window.Mesh) Mesh.broadcastResource(marker);

        UI.logSystem(`Resource Marked: ${Resources.categories[type].label}`);
    },

    renderMarker: (m) => {
        // Since Radar is canvas, we can't easily add DOM markers without modifying radar.js
        // For V22, we overlay them on the HUD Compass as "Points of Interest"
        // OR add to a "Resource List" panel.

        const list = document.getElementById('resource-list');
        if (list) {
            const el = document.createElement('div');
            el.innerHTML = `${Resources.categories[m.type].icon} ${m.lat.toFixed(4)}, ${m.lon.toFixed(4)} <small>${m.notes}</small>`;
            el.style.color = "var(--text-bright)";
            el.style.fontSize = "0.8rem";
            el.style.padding = "2px";
            list.appendChild(el);
        }
    },

    // UI Helper
    openAddModal: () => {
        const type = prompt("TYPE: (W)ater, (F)ood, (M)eds, (A)mmo, (S)helter")?.toUpperCase();
        if (!Resources.categories[type]) return alert("Invalid Type");

        const notes = prompt("Notes (optional):");

        // Use current GPS or Center of Map
        // For now, simulate GPS
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(pos => {
                Resources.addMarker(pos.coords.latitude, pos.coords.longitude, type, notes);
            }, () => alert("GPS Error"));
        } else {
            alert("No GPS");
        }
    }
};
