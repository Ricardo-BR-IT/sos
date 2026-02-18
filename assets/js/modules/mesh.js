import { log, updateNodeList } from './ui.js';
import { initRadar, updateRadarNodes } from './radar.js';
import { initComms } from './comms.js';

// Mesh Module
const API_URL = 'api/nodes.php';
let myId = localStorage.getItem('v7_node_id');

if (!myId) {
    myId = 'WEB-' + Math.random().toString(36).substr(2, 6).toUpperCase();
    localStorage.setItem('v7_node_id', myId);
}

// GPS State
let myLat = 0;
let myLng = 0;
let shareLoc = false;

export function initMesh() {
    log(`Initializing Mesh Protocol as ${myId}...`);

    // Init Subsystems
    initRadar();
    initComms();

    // 1. Heartbeat Loop
    setInterval(heartbeat, 15000);

    // 2. Discovery Loop
    setInterval(discover, 10000);

    // 3. GPS Loop (V11)
    updateGPS();
    setInterval(updateGPS, 30000); // Check every 30s

    // Initial call
    heartbeat();
}

function updateGPS() {
    shareLoc = localStorage.getItem('v11_gps_active') === 'true';

    if (shareLoc && navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(pos => {
            myLat = pos.coords.latitude;
            myLng = pos.coords.longitude;

            // Store for Radar module
            localStorage.setItem('my_lat', myLat);
            localStorage.setItem('my_lng', myLng);

            // log(`[GPS] Location Acquired: ${myLat.toFixed(4)}, ${myLng.toFixed(4)}`);
        }, err => {
            log(`[GPS] Error: ${err.message}`);
        });
    } else {
        myLat = 0;
        myLng = 0;
        localStorage.removeItem('my_lat');
        localStorage.removeItem('my_lng');
    }
}

async function heartbeat() {
    try {
        const payload = {
            id: myId,
            type: 'WEB_STATION',
            name: `Commander (${myId})`,
            lat: myLat,
            lng: myLng,
            share_loc: shareLoc ? 1 : 0,
            battery: 100
        };

        const res = await fetch(API_URL, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        if (!res.ok) {
            const txt = await res.text();
            log(`[ERROR] Heartbeat Failed: ${res.status} - ${txt.substring(0, 50)}`);
        }

    } catch (e) {
        log(`[NET] CONNECTION LOST: ${e.message}`);
    }
}

async function discover() {
    try {
        const res = await fetch(API_URL);
        if (res.ok) {
            const data = await res.json();
            if (data.nodes) {
                updateNodeList(data.nodes);
                updateRadarNodes(data.nodes);

                // Update Channel Selector (V7.2)
                const sel = document.getElementById('msg-target');
                if (sel) {
                    let current = sel.value;
                    // Keep PUBLIC + options
                    // Clear existing node options (keep index 0 'PUBLIC')
                    while (sel.options.length > 1) {
                        sel.remove(1);
                    }

                    data.nodes.forEach(n => {
                        // Don't add myself
                        if (n.id !== myId) {
                            let opt = document.createElement('option');
                            opt.value = n.id;
                            opt.text = n.name || n.id;
                            sel.add(opt);
                        }
                    });

                    // Restore selection if still exists
                    sel.value = current;
                }
            }
        } else {
            const txt = await res.text();
            log(`[ERROR] Discovery API: ${res.status} - ${txt.substring(0, 50)}`);
        }
    } catch (e) {
        log("Discovery Error: " + e.message);
    }
}
