/**
 * SOS WI-FI SENSING (V41)
 * "Wall-Vision" using Channel State Information (CSI).
 */
const WiFiSensing = {
    isActive: false,
    detections: [], // [{x, y, z, intensity, confidence}]
    sensingConfidence: 0,
    scanInterval: null,

    init: () => {
        console.log(">>> Wi-Fi Sensing Module Initialized");
    },

    start: () => {
        WiFiSensing.isActive = true;
        console.log("Wi-Fi Sensing (Wall-Vision) Active.");
        WiFiSensing.scanInterval = setInterval(WiFiSensing.pollSensingData, 2000);
        WiFiSensing.renderLoop();
    },

    stop: () => {
        WiFiSensing.isActive = false;
        clearInterval(WiFiSensing.scanInterval);
    },

    voxelGrid: [], // 2D array
    gridResolution: 16,

    pollSensingData: async () => {
        if (!WiFiSensing.isActive) return;

        try {
            // Simulated CSI reporting from mesh nodes
            const resp = await fetch('api/sensing.php?action=status');
            const data = await resp.json();

            if (data.grid) {
                WiFiSensing.voxelGrid = data.grid;
                WiFiSensing.gridResolution = data.grid_res;
                WiFiSensing.sensingConfidence = data.confidence;
            }
            WiFiSensing.updateUI();
        } catch (e) {
            console.error("Sensing Poll Error", e);
        }
    },

    renderLoop: () => {
        if (!WiFiSensing.isActive) return;

        const canvas = document.getElementById('vision-overlay-canvas');
        if (!canvas) return;
        const ctx = canvas.getContext('2d');
        const w = canvas.width;
        const h = canvas.height;

        ctx.clearRect(0, 0, w, h);

        // Draw Thermal Voxel Grid
        if (WiFiSensing.voxelGrid && WiFiSensing.voxelGrid.length > 0) {
            const cellW = w / WiFiSensing.gridResolution;
            const cellH = h / WiFiSensing.gridResolution;

            for (let x = 0; x < WiFiSensing.gridResolution; x++) {
                for (let y = 0; y < WiFiSensing.gridResolution; y++) {
                    const val = WiFiSensing.voxelGrid[x][y]; // 0.0 to 1.0
                    if (val > 0.1) {
                        // Thermal Gradient: Blue (Cold) -> Red (Hot)
                        const r = Math.floor(val * 255);
                        const b = Math.floor((1 - val) * 255);

                        ctx.fillStyle = `rgba(${r}, 0, ${b}, ${val * 0.8})`;
                        ctx.fillRect(x * cellW, y * cellH, cellW, cellH);
                    }
                }
            }
        }

        // Scanline Effect
        const scanY = (Date.now() / 10) % h;
        ctx.fillStyle = 'rgba(0, 255, 0, 0.1)';
        ctx.fillRect(0, scanY, w, 2);

        requestAnimationFrame(WiFiSensing.renderLoop);
    },

    updateUI: () => {
        const label = document.getElementById('vision-status-label');
        if (label) {
            label.innerText = `VISION: ${Math.round(WiFiSensing.sensingConfidence * 100)}% CONF`;
            label.style.color = WiFiSensing.sensingConfidence > 0.8 ? 'var(--neon-green)' : 'var(--neon-yellow)';
        }
    }
};
