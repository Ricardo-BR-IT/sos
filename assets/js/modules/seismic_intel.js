/**
 * SOS SEISMIC INTELLIGENCE (V30)
 * Uses Accelerometer to detect ground vibrations.
 */
const SeismicIntel = {
    isActive: false,
    history: [],
    threshold: 0.5,
    callback: null,

    init: () => {
        console.log("Seismic Intel Initialized.");
    },

    start: (onEvent) => {
        if (SeismicIntel.isActive) return;
        SeismicIntel.isActive = true;
        SeismicIntel.callback = onEvent;

        window.addEventListener('devicemotion', SeismicIntel.handleMotion, true);
        console.log("Seismic Monitoring Started.");
    },

    stop: () => {
        SeismicIntel.isActive = false;
        window.removeEventListener('devicemotion', SeismicIntel.handleMotion, true);
        console.log("Seismic Monitoring Stopped.");
    },

    handleMotion: (event) => {
        const acc = event.acceleration || event.accelerationIncludingGravity;
        if (!acc) return;

        // Calculate magnitude (excluding gravity if possible)
        const magnitude = Math.sqrt(acc.x ** 2 + acc.y ** 2 + acc.z ** 2);
        SeismicIntel.history.push(magnitude.toFixed(2));

        if (SeismicIntel.history.length > 50) {
            const batch = SeismicIntel.history.splice(0, 50);
            SeismicIntel.analyze(batch);
        }
    },

    analyze: async (samples) => {
        try {
            const resp = await fetch(`api/seismic.php?d=${samples.join(',')}`);
            const data = await resp.json();

            if (data.status !== 'IDLE' && SeismicIntel.callback) {
                SeismicIntel.callback(data);
            }
        } catch (e) {
            console.error("Seismic Analysis Failed:", e);
        }
    }
};
