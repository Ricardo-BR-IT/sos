/**
 * SOS TACTICAL AR (V32)
 * Overlays spatial mesh data onto the camera feed.
 */
const TacticalAR = {
    isActive: false,
    video: null,
    canvas: null,
    ctx: null,
    orientation: { alpha: 0, beta: 0, gamma: 0 },
    nodes: [], // Dynamic nodes from SwarmMesh

    init: () => {
        console.log("Tactical AR Module Initialized.");
        TacticalAR.canvas = document.getElementById('ar-canvas');
        if (TacticalAR.canvas) {
            TacticalAR.ctx = TacticalAR.canvas.getContext('2d');
        }
    },

    start: async () => {
        try {
            TacticalAR.video = document.getElementById('ar-video');
            if (!TacticalAR.video) return;

            const stream = await navigator.mediaDevices.getUserMedia({
                video: { facingMode: "environment" },
                audio: false
            });
            TacticalAR.video.srcObject = stream;
            TacticalAR.video.play();

            TacticalAR.isActive = true;
            window.addEventListener('deviceorientation', TacticalAR.handleOrientation, true);
            TacticalAR.render();
            return true;
        } catch (e) {
            console.error("AR Camera Access Failed:", e);
            return false;
        }
    },

    stop: () => {
        TacticalAR.isActive = false;
        if (TacticalAR.video && TacticalAR.video.srcObject) {
            TacticalAR.video.srcObject.getTracks().forEach(track => track.stop());
        }
        window.removeEventListener('deviceorientation', TacticalAR.handleOrientation);
    },

    handleOrientation: (event) => {
        // alpha: rotation around z-axis [0, 360] (compass)
        TacticalAR.orientation.alpha = event.alpha || 0;
        TacticalAR.orientation.beta = event.beta || 0;
        TacticalAR.orientation.gamma = event.gamma || 0;
    },

    render: () => {
        if (!TacticalAR.isActive) return;

        const w = TacticalAR.canvas.width;
        const h = TacticalAR.canvas.height;
        const ctx = TacticalAR.ctx;

        ctx.clearRect(0, 0, w, h);

        // Compass Heading
        const heading = 360 - TacticalAR.orientation.alpha;

        // Draw Radar Lines (Grid)
        ctx.strokeStyle = 'rgba(0, 255, 255, 0.2)';
        ctx.lineWidth = 1;
        ctx.beginPath();
        ctx.moveTo(0, h / 2); ctx.lineTo(w, h / 2);
        ctx.moveTo(w / 2, 0); ctx.lineTo(w / 2, h);
        ctx.stroke();

        // Crosshair
        ctx.strokeStyle = 'var(--neon-cyan)';
        ctx.lineWidth = 2;
        ctx.strokeRect(w / 2 - 20, h / 2 - 20, 40, 40);

        // Draw Swarm Nodes
        const swarmNodes = window.SwarmMesh ? Object.values(SwarmMesh.peers) : [];

        swarmNodes.forEach(peer => {
            // Simulation: Assign bearings to peers if they don't have one
            if (!peer.bearing) peer.bearing = Math.floor(Math.random() * 360);

            let diff = peer.bearing - heading;
            if (diff > 180) diff -= 360;
            if (diff < -180) diff += 360;

            if (Math.abs(diff) < 45) {
                const x = (w / 2) + (diff * (w / 90));
                const y = h / 2;
                const statusColor = (peer.safety === 'THREAT' || peer.health === 'DISTRESS') ? '#f00' : 'var(--neon-cyan)';

                // Draw Marker
                ctx.fillStyle = statusColor;
                ctx.beginPath();
                ctx.arc(x, y, 12, 0, Math.PI * 2);
                ctx.fill();

                // Pulsing effect for danger
                if (statusColor === '#f00') {
                    ctx.strokeStyle = '#f00';
                    ctx.beginPath();
                    ctx.arc(x, y, 12 + (Date.now() % 1000) / 50, 0, Math.PI * 2);
                    ctx.stroke();
                }

                // Draw Label
                ctx.fillStyle = '#fff';
                ctx.font = '12px monospace';
                ctx.fillText(peer.id, x + 15, y - 5);
                ctx.font = '10px monospace';
                ctx.fillText(`${peer.bpm} BPM | ${peer.safety}`, x + 15, y + 10);
            }
        });

        // Draw OTH (Over-the-Horizon) Long Range Nodes
        if (window.SkywaveLink && SkywaveLink.isActive) {
            const skipDist = SkywaveLink.skipDistance;
            // Draw a semi-transparent marker for skywave target
            const x = w / 2;
            const y = h / 2 - 100;
            ctx.fillStyle = 'rgba(0, 255, 100, 0.4)';
            ctx.beginPath();
            ctx.moveTo(x - 20, y);
            ctx.lineTo(x + 20, y);
            ctx.lineTo(x, y - 40);
            ctx.fill();
            ctx.fillStyle = '#fff';
            ctx.fillText(`OTH SKIP: ${skipDist}km`, x + 25, y - 20);
        }

        // Overlay status from other modules
        ctx.fillStyle = 'var(--neon-cyan)';
        ctx.font = '12px monospace';
        ctx.fillText(`HEADING: ${Math.round(heading)}°`, 20, 30);

        if (window.BioSync && BioSync.isActive) {
            ctx.fillStyle = '#f00';
            ctx.fillText(`❤️ BPM: ${BioSync.bpm}`, 20, 50);
        }

        requestAnimationFrame(TacticalAR.render);
    }
};
