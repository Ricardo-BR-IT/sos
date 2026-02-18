/**
 * SOS SWARM MESH (V34)
 * Coordinates multiple devices into a single survival organism.
 */
const SwarmMesh = {
    peers: {}, // { nodeId: { health: 'STABLE', safety: 'SAFE', signal: 0.9, lastSeen: Date } }
    broadcastInterval: null,

    init: () => {
        console.log(">>> Swarm Mesh Module Initialized");
    },

    start: () => {
        console.log("Swarm Sync Active.");
        SwarmMesh.broadcastInterval = setInterval(SwarmMesh.broadcastStatus, 5000); // Sync every 5s
    },

    stop: () => {
        if (SwarmMesh.broadcastInterval) clearInterval(SwarmMesh.broadcastInterval);
    },

    broadcastStatus: async () => {
        // Collect local telemetry
        const localStatus = {
            id: Hardware.deviceId || 'NODE_' + Math.floor(Math.random() * 1000),
            health: window.BioSync ? (BioSync.isDistress ? 'DISTRESS' : 'STABLE') : 'UNKNOWN',
            safety: window.SeismicIntel ? (SeismicIntel.isThreat ? 'THREAT' : 'SAFE') : 'UNKNOWN',
            bpm: window.BioSync ? BioSync.bpm : 0,
            signal: navigator.onLine ? 1.0 : 0.5 // Simplified local signal quality
        };

        // Broadcast via available transports (Simulation via API for now)
        try {
            const resp = await fetch('api/swarm.php', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(localStatus)
            });
            const swarmState = await resp.json();
            SwarmMesh.updatePeers(swarmState);
        } catch (e) {
            console.error("Swarm Broadcast Failed", e);
        }
    },

    updatePeers: (data) => {
        // data: Array of peer statuses
        data.forEach(peer => {
            if (peer.id === Hardware.deviceId) return;

            const isNew = !SwarmMesh.peers[peer.id];
            const wasSafe = SwarmMesh.peers[peer.id]?.safety === 'SAFE' || !SwarmMesh.peers[peer.id];

            SwarmMesh.peers[peer.id] = {
                ...peer,
                lastSeen: Date.now()
            };

            // Alert UI if a peer enters DISTRESS or THREAT
            if (wasSafe && (peer.safety === 'THREAT' || peer.health === 'DISTRESS')) {
                Mind.displayResponse({
                    agent: "SWARM_ALERTA",
                    response: `ALERTA CRÍTICO: Nó ${peer.id} em perigo! Status: ${peer.safety}/${peer.health}`
                });

                // Visual Flash in HUD
                const hud = document.getElementById('mind-chat-log');
                if (hud) {
                    hud.style.boxShadow = "inset 0 0 50px rgba(255,0,0,0.5)";
                    setTimeout(() => hud.style.boxShadow = "", 2000);
                }
            }
        });
        SwarmMesh.renderSwarmUI();
    },

    renderSwarmUI: () => {
        const container = document.getElementById('swarm-list');
        if (!container) return;

        container.innerHTML = '';
        Object.values(SwarmMesh.peers).forEach(peer => {
            const age = (Date.now() - peer.lastSeen) / 1000;
            if (age > 60) return; // Hide stale nodes

            const item = document.createElement('div');
            item.className = 'swarm-item';
            item.style.padding = '5px';
            item.style.borderBottom = '1px solid rgba(0,255,255,0.1)';
            item.style.color = (peer.safety === 'THREAT' || peer.health === 'DISTRESS') ? 'var(--neon-red)' : 'var(--neon-cyan)';

            item.innerHTML = `
                <div style="display:flex; justify-content:space-between; font-size: 0.75rem;">
                    <span><b>${peer.id}</b></span>
                    <span>${peer.bpm} BPM</span>
                </div>
                <div style="font-size: 0.65rem; opacity: 0.8;">
                    STATUS: ${peer.safety} | VITAIS: ${peer.health} | LINK: ${Math.round(peer.signal * 100)}%
                </div>
            `;
            container.appendChild(item);
        });
    }
};
