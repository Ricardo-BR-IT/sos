/**
 * SOS RF COMPASS (V40)
 * Multispectral Signal Direction Finder.
 */
const RFCompass = {
    isActive: false,
    signals: [], // [{freq, rssi, bearing, type}]
    currentBearing: 0,
    scanRange: 'FM', // FM, AM, CELL, TV
    radarCanvas: null,
    ctx: null,

    init: () => {
        console.log(">>> RF Compass Module Initialized");
        window.addEventListener('deviceorientation', RFCompass.handleOrientation);
        RFCompass.radarCanvas = document.getElementById('rf-radar-canvas');
        if (RFCompass.radarCanvas) RFCompass.ctx = RFCompass.radarCanvas.getContext('2d');
    },

    start: () => {
        RFCompass.isActive = true;
        console.log("Multispectral RF Scanner Active.");
        RFCompass.loop();
    },

    stop: () => {
        RFCompass.isActive = false;
        if (RFCompass.ctx) RFCompass.ctx.clearRect(0, 0, RFCompass.radarCanvas.width, RFCompass.radarCanvas.height);
    },

    handleOrientation: (event) => {
        if (event.webkitCompassHeading) {
            RFCompass.currentBearing = event.webkitCompassHeading;
        } else {
            RFCompass.currentBearing = 360 - event.alpha;
        }
    },

    loop: () => {
        if (!RFCompass.isActive) return;
        RFCompass.updateSignals();
        RFCompass.renderRadar();
        requestAnimationFrame(RFCompass.loop);
    },

    updateSignals: async () => {
        // Simulated / Native Signal Fetching
        // In a real scenario, this would interface with SDR or Android Telemetry API
        if (Math.random() > 0.95) {
            const newSignal = {
                id: 'SIG-' + Math.random().toString(36).substr(2, 4),
                freq: '98.1 MHz',
                rssi: -40 - Math.random() * 50,
                bearing: Math.random() * 360,
                type: RFCompass.scanRange,
                ts: Date.now()
            };
            RFCompass.signals.push(newSignal);
            if (RFCompass.signals.length > 10) RFCompass.signals.shift();

            // Report to backend for mapping
            fetch(`api/rf.php?action=log&freq=${newSignal.freq}&rssi=${newSignal.rssi}&bearing=${newSignal.bearing}`);
        }
    },

    setRange: (range) => {
        RFCompass.scanRange = range;
        RFCompass.signals = [];
        console.log("Scanner Range set to: " + range);
    },

    renderRadar: () => {
        if (!RFCompass.ctx) return;
        const width = RFCompass.radarCanvas.width;
        const height = RFCompass.radarCanvas.height;
        const centerX = width / 2;
        const centerY = height / 2;
        const radius = Math.min(centerX, centerY) - 5;

        RFCompass.ctx.clearRect(0, 0, width, height);

        // Draw Rings
        RFCompass.ctx.strokeStyle = 'rgba(0, 255, 255, 0.2)';
        RFCompass.ctx.beginPath();
        RFCompass.ctx.arc(centerX, centerY, radius, 0, Math.PI * 2);
        RFCompass.ctx.stroke();
        RFCompass.ctx.beginPath();
        RFCompass.ctx.arc(centerX, centerY, radius / 2, 0, Math.PI * 2);
        RFCompass.ctx.stroke();

        // Draw Sweep Line
        const sweepAngle = (Date.now() / 500) % (Math.PI * 2);
        RFCompass.ctx.strokeStyle = 'var(--neon-cyan)';
        RFCompass.ctx.lineWidth = 2;
        RFCompass.ctx.beginPath();
        RFCompass.ctx.moveTo(centerX, centerY);
        RFCompass.ctx.lineTo(centerX + Math.cos(sweepAngle) * radius, centerY + Math.sin(sweepAngle) * radius);
        RFCompass.ctx.stroke();

        // Draw Signals
        RFCompass.signals.forEach(sig => {
            const age = (Date.now() - sig.ts) / 5000;
            if (age > 1) return;

            const angle = (sig.bearing - RFCompass.currentBearing - 90) * (Math.PI / 180);
            const dist = (100 + sig.rssi) / 100 * radius; // Poor man's distance estimation

            RFCompass.ctx.fillStyle = sig.rssi > -60 ? 'var(--neon-green)' : 'var(--neon-yellow)';
            RFCompass.ctx.globalAlpha = 1 - age;
            RFCompass.ctx.beginPath();
            RFCompass.ctx.arc(centerX + Math.cos(angle) * dist, centerY + Math.sin(angle) * dist, 3, 0, Math.PI * 2);
            RFCompass.ctx.fill();
        });
        RFCompass.ctx.globalAlpha = 1.0;
    }
};
