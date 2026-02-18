/**
 * SOS MIND-LINK (V36)
 * Dual-layer neural interface: Vocal Stress & Raw EEG.
 */
const MindLink = {
    audioCtx: null,
    analyser: null,
    microphone: null,
    isAudioActive: false,
    isEEGActive: false,
    stressLevel: 0, // 0 to 100
    focusLevel: 0,  // 0 to 100
    renderInterval: null,

    init: () => {
        console.log(">>> Mind-Link Module Initialized");
    },

    startAudio: async () => {
        try {
            MindLink.audioCtx = new (window.AudioContext || window.webkitAudioContext)();
            const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
            MindLink.microphone = MindLink.audioCtx.createMediaStreamSource(stream);
            MindLink.analyser = MindLink.audioCtx.createAnalyser();
            MindLink.analyser.fftSize = 2048;
            MindLink.microphone.connect(MindLink.analyser);

            MindLink.isAudioActive = true;
            MindLink.startMonitor();
            console.log("Mind-Link: Audio Stress Analysis Active.");
        } catch (e) {
            console.error("Audio Access Denied for Mind-Link", e);
        }
    },

    stop: () => {
        MindLink.isAudioActive = false;
        MindLink.isEEGActive = false;
        if (MindLink.renderInterval) clearInterval(MindLink.renderInterval);
        if (MindLink.audioCtx) MindLink.audioCtx.close();
    },

    startMonitor: () => {
        const bufferLength = MindLink.analyser.frequencyBinCount;
        const dataArray = new Uint8Array(bufferLength);

        MindLink.renderInterval = setInterval(() => {
            if (!MindLink.isAudioActive && !MindLink.isEEGActive) return;

            if (MindLink.isAudioActive) {
                MindLink.analyser.getByteFrequencyData(dataArray);
                // Simple Micro-tremor simulation: check for instability in the vocal range (100Hz-300Hz)
                let sum = 0;
                for (let i = 10; i < 40; i++) sum += dataArray[i]; // Lower vocal range bins
                let avg = sum / 30;

                // Variation calculation as stress proxy
                let variance = Math.abs(avg - (MindLink._lastAvg || avg));
                MindLink._lastAvg = avg;

                if (avg > 50) { // Only if speaking
                    MindLink.stressLevel = Math.min(100, MindLink.stressLevel + (variance > 5 ? 10 : -2));
                } else {
                    MindLink.stressLevel = Math.max(0, MindLink.stressLevel - 1);
                }
            }

            MindLink.drawNeuralPulse(dataArray);
            MindLink.updateHUD();
        }, 100);
    },

    updateHUD: () => {
        const label = document.getElementById('mind-link-label');
        if (label) {
            const status = MindLink.stressLevel > 70 ? 'CRÍTICO' : (MindLink.stressLevel > 40 ? 'ALERTA' : 'ESTÁVEL');
            label.innerText = `LINK: ${status} [STR: ${Math.round(MindLink.stressLevel)}% | FOC: ${Math.round(MindLink.focusLevel)}%]`;
            label.style.color = status === 'CRÍTICO' ? 'var(--neon-red)' : (status === 'ALERTA' ? 'orange' : 'var(--neon-cyan)');
        }
    },

    drawNeuralPulse: (data) => {
        const canvas = document.getElementById('neural-pulse-cvs');
        if (!canvas) return;
        const ctx = canvas.getContext('2d');
        const w = canvas.width;
        const h = canvas.height;

        ctx.fillStyle = 'rgba(0,0,0,0.2)';
        ctx.fillRect(0, 0, w, h);

        ctx.strokeStyle = MindLink.isAudioActive ? 'var(--neon-cyan)' : 'var(--neon-green)';
        ctx.lineWidth = 1;
        ctx.beginPath();

        const sliceWidth = w / data.length;
        let x = 0;
        for (let i = 0; i < data.length; i++) {
            const v = data[i] / 128.0;
            const y = v * h / 2;
            if (i === 0) ctx.moveTo(x, y);
            else ctx.lineTo(x, y);
            x += sliceWidth;
        }
        ctx.lineTo(w, h / 2);
        ctx.stroke();
    },

    // EEG Simulation/Parser
    parseEEGRaw: (payload) => {
        // Expected format: { alpha: 0.5, beta: 0.2, gamma: 0.1 }
        MindLink.isEEGActive = true;
        MindLink.focusLevel = (payload.beta / (payload.alpha + 0.1)) * 50; // Focus ratio
        MindLink.focusLevel = Math.min(100, Math.max(0, MindLink.focusLevel));
        MindLink.updateHUD();
    }
};
