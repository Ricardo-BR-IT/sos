
// RADAR MODULE (V7.1)
// Draws active nodes on the tactical canvas

let canvas;
let ctx;
let nodes = [];
let myPos = { x: 0, y: 0 };

export function initRadar() {
    canvas = document.getElementById('radarCanvas');
    if (!canvas) return;

    ctx = canvas.getContext('2d');
    resize();
    window.addEventListener('resize', resize);

    // Animation Loop
    loop();
}

export function updateRadarNodes(incomingNodes) {
    nodes = incomingNodes || [];
}

function resize() {
    if (!canvas) return;
    // Get parent dimensions
    const rect = canvas.parentElement.getBoundingClientRect();
    canvas.width = rect.width;
    canvas.height = rect.height;

    myPos = { x: canvas.width / 2, y: canvas.height / 2 };
}

function loop() {
    if (ctx) draw();
    requestAnimationFrame(loop);
}

function draw() {
    // 1. Clear & Background
    ctx.fillStyle = "#001100";
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    // 2. Draw Rings
    ctx.strokeStyle = "rgba(0, 255, 0, 0.2)";
    ctx.lineWidth = 1;

    // Rings
    for (let r = 50; r < 500; r += 50) {
        ctx.beginPath();
        ctx.arc(myPos.x, myPos.y, r, 0, Math.PI * 2);
        ctx.stroke();
    }

    // Crosshair
    ctx.beginPath();
    ctx.moveTo(myPos.x, 0); ctx.lineTo(myPos.x, canvas.height);
    ctx.moveTo(0, myPos.y); ctx.lineTo(canvas.width, myPos.y);
    ctx.stroke();

    // 3. Scanning Line (Radar Sweep)
    let time = Date.now() / 1000;
    let angle = (time % 4) / 4 * Math.PI * 2;

    // 4. Draw Nodes (Blips)
    if (nodes && nodes.length > 0) {
        nodes.forEach(node => {
            let x = 0, y = 0;
            let distLabel = "";

            // V11: Real Geolocation Calculation
            // We need My Position (which we don't have globally here yet, but we can assume center for now)
            // Ideally we need to pass myLat/myLng to this module. 
            // For now, let's just use the mock position logic BUT calculate distance if data exists.

            // NOTE: In a real tactical map, we would project Lat/Lng to X/Y relative to center.
            // Here we are still using the "Mock Random" position for the *visual* blip to avoid overlapping center,
            // BUT we will calculate the *text* distance accurately if data is present.

            let hash = 0;
            if (node.id) {
                for (let i = 0; i < node.id.length; i++) {
                    hash = ((hash << 5) - hash) + node.id.charCodeAt(i);
                    hash |= 0;
                }
            }
            let orbit = (Math.abs(hash) % 150) + 50;
            let ang = (Math.abs(hash) % 360) * (Math.PI / 180);

            x = myPos.x + Math.cos(ang) * orbit;
            y = myPos.y + Math.sin(ang) * orbit;

            // Distance Calc (Haversine) - ONLY if both share location
            // We need to fetch my local coords from localStorage for this visual calc
            const myLat = parseFloat(localStorage.getItem('my_lat') || 0);
            const myLng = parseFloat(localStorage.getItem('my_lng') || 0);
            const nodeLat = parseFloat(node.lat || 0);
            const nodeLng = parseFloat(node.lng || 0);

            if (myLat !== 0 && nodeLat !== 0 && node.share_loc == 1) {
                const R = 6371e3; // metres
                const φ1 = myLat * Math.PI / 180;
                const φ2 = nodeLat * Math.PI / 180;
                const Δφ = (nodeLat - myLat) * Math.PI / 180;
                const Δλ = (nodeLng - myLng) * Math.PI / 180;

                const a = Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
                    Math.cos(φ1) * Math.cos(φ2) *
                    Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
                const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
                const d = R * c;

                if (d > 1000) {
                    distLabel = ` [ ${(d / 1000).toFixed(1)}km ]`;
                } else {
                    distLabel = ` [ ${Math.round(d)}m ]`;
                }
            }

            // Draw Blip
            ctx.fillStyle = isMe ? '#0ff' : (node.status === 'ONLINE' ? '#0f0' : '#f00');
            ctx.beginPath();
            ctx.arc(x, y, 4, 0, Math.PI * 2);
            ctx.fill();

            // V15: Vector Guidance
            if (!isMe && nodeLat !== 0 && myLat !== 0 && node.share_loc == 1) {
                // Vector Line
                ctx.beginPath();
                ctx.strokeStyle = 'rgba(0, 255, 0, 0.4)';
                ctx.lineWidth = 1;
                ctx.setLineDash([4, 4]);
                ctx.moveTo(myPos.x, myPos.y);
                ctx.lineTo(x, y);
                ctx.stroke();
                ctx.setLineDash([]);

                // Bearing Calculation for Label
                // Simple Bearing visualization (arrow) would be nice but text is clearer for now
                // We already have distLabel calculated above
            }

            // Halo
            ctx.strokeStyle = "rgba(0, 255, 0, 0.5)";
            ctx.beginPath();
            ctx.arc(x, y, 8, 0, Math.PI * 2);
            ctx.stroke();

            // Label
            ctx.fillStyle = "#0f0";
            ctx.font = "10px monospace";
            ctx.fillText((node.name || node.id) + distLabel, x + 10, y + 4);
        });
    }

    // 5. Draw Me (Center)
    ctx.fillStyle = "#fff";
    ctx.beginPath();
    ctx.arc(myPos.x, myPos.y, 3, 0, Math.PI * 2);
    ctx.fill();
    ctx.fillText("CMD", myPos.x + 5, myPos.y - 5);

    // 6. Draw Sweep Line on top
    ctx.strokeStyle = "rgba(0, 255, 0, 0.5)";
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(myPos.x, myPos.y);
    ctx.lineTo(myPos.x + Math.cos(angle) * 1000, myPos.y + Math.sin(angle) * 1000);
    ctx.stroke();
}
