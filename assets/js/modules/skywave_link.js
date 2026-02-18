/**
 * SOS SKYWAVE LINK (V35)
 * Manages Over-the-Horizon (OTH) long-range communication.
 */
const SkywaveLink = {
    isActive: false,
    condition: 'FAIR', // POOR, FAIR, GOOD
    skipDistance: 0,
    activeLinks: [],

    init: () => {
        console.log(">>> Skywave Link Module Initialized");
    },

    start: () => {
        SkywaveLink.isActive = true;
        console.log("Skywave Monitoring Active.");
        SkywaveLink.updateConditions();
        setInterval(SkywaveLink.updateConditions, 30000); // Update every 30s
    },

    stop: () => {
        SkywaveLink.isActive = false;
    },

    updateConditions: async () => {
        try {
            const resp = await fetch('api/skywave.php?action=status');
            const data = await resp.json();
            SkywaveLink.condition = data.condition;
            SkywaveLink.skipDistance = data.skip;

            const label = document.getElementById('skywave-status-label');
            if (label) {
                label.innerText = `IONO: ${SkywaveLink.condition} | SKIP: ${SkywaveLink.skipDistance}km`;
                label.style.color = SkywaveLink.condition === 'GOOD' ? 'var(--neon-green)' :
                    SkywaveLink.condition === 'POOR' ? 'var(--neon-red)' : 'var(--neon-cyan)';
            }
        } catch (e) {
            console.error("Failed to update Skywave conditions", e);
        }
    },

    sendOTH: async (text) => {
        if (!SkywaveLink.isActive) {
            alert("Modo OTH desativado.");
            return;
        }

        Mind.displayResponse({ agent: "OTH_PROXY", response: `Iniciando transmissão de longo alcance (Skywave)...` });

        // Simulate Batching progress
        let progress = 0;
        const progressId = 'oth-progress-' + Date.now();
        Mind.updateLiveTranscription(`[OTH] TRANSMITINDO: 0% <progress id="${progressId}" value="0" max="100"></progress>`);

        const interval = setInterval(() => {
            progress += 5;
            const bar = document.getElementById(progressId);
            if (bar) bar.value = progress;
            if (progress >= 100) {
                clearInterval(interval);
                SkywaveLink.finalizeSend(text);
            }
        }, 300);
    },

    finalizeSend: async (text) => {
        try {
            const url = `api/skywave.php?action=send&q=${encodeURIComponent(text)}`;
            const audio = new Audio(url);
            audio.play();
            Mind.displayResponse({ agent: "OTH_PROXY", response: `Sinal HF disparado para a ionosfera. Aguardando eco/salto...` });
        } catch (e) {
            console.error("OTH Send Failed", e);
        }
    }
};
