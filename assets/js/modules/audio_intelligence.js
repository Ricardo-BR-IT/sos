/**
 * SOS MODULE: AUDIO INTELLIGENCE (V26)
 * Real-time Signal Analysis and Morse Pulse Detection.
 */

const AudioIntelligence = {
    audioCtx: null,
    analyser: null,
    micStream: null,
    isListening: false,

    // Config for Goertzel / Pulse Detection
    TARGET_FREQ: 800, // Common Morse frequency
    THRESHOLD: 0.1,   // Amplitude threshold
    DIT_MS: 150,      // Ideal Dit length

    pulses: "",       // Stream of "." and "-"
    lastUpdate: 0,

    init: async () => {
        console.log(">>> Audio Intelligence Loaded");
    },

    start: async (callback) => {
        if (AudioIntelligence.isListening) return;

        try {
            AudioIntelligence.audioCtx = new (window.AudioContext || window.webkitAudioContext)();
            AudioIntelligence.micStream = await navigator.mediaDevices.getUserMedia({ audio: true });
            const source = AudioIntelligence.audioCtx.createMediaStreamSource(AudioIntelligence.micStream);

            AudioIntelligence.analyser = AudioIntelligence.audioCtx.createAnalyser();
            AudioIntelligence.analyser.fftSize = 1024;
            source.connect(AudioIntelligence.analyser);

            AudioIntelligence.isListening = true;
            AudioIntelligence.lastUpdate = Date.now();
            AudioIntelligence.process(callback);

        } catch (e) {
            console.error("Mic Access Failed", e);
            alert("Erro ao acessar microfone. Verifique as permissões do navegador.");
        }
    },

    stop: () => {
        AudioIntelligence.isListening = false;
        if (AudioIntelligence.micStream) {
            AudioIntelligence.micStream.getTracks().forEach(t => t.stop());
        }
        if (AudioIntelligence.audioCtx) {
            AudioIntelligence.audioCtx.close();
        }
    },

    process: (callback) => {
        if (!AudioIntelligence.isListening) return;

        const bufferLength = AudioIntelligence.analyser.frequencyBinCount;
        const dataArray = new Uint8Array(bufferLength);
        AudioIntelligence.analyser.getByteFrequencyData(dataArray);

        // Simple Peak Detection at TARGET_FREQ
        const bin = Math.floor(AudioIntelligence.TARGET_FREQ * AudioIntelligence.analyser.fftSize / AudioIntelligence.audioCtx.sampleRate);
        const amplitude = dataArray[bin] / 255.0;

        if (amplitude > AudioIntelligence.THRESHOLD) {
            AudioIntelligence.recordPulse(true, callback);
        } else {
            AudioIntelligence.recordPulse(false, callback);
        }

        requestAnimationFrame(() => AudioIntelligence.process(callback));
    },

    state: { active: false, startTime: 0 },

    recordPulse: (detected, callback) => {
        const now = Date.now();
        if (detected && !AudioIntelligence.state.active) {
            // Start of pulse
            const quietDuration = now - AudioIntelligence.state.startTime;
            if (quietDuration > AudioIntelligence.DIT_MS * 3) AudioIntelligence.pulses += " ";
            if (quietDuration > AudioIntelligence.DIT_MS * 7) AudioIntelligence.pulses += " / ";

            AudioIntelligence.state.active = true;
            AudioIntelligence.state.startTime = now;
        } else if (!detected && AudioIntelligence.state.active) {
            // End of pulse
            const duration = now - AudioIntelligence.state.startTime;
            AudioIntelligence.pulses += (duration < AudioIntelligence.DIT_MS * 2) ? "." : "-";
            AudioIntelligence.state.active = false;
            AudioIntelligence.state.startTime = now;

            if (callback) callback(AudioIntelligence.pulses);
        }
    },

    // --- TAP CODE DETECTION (Transient pulses) ---
    tapState: { lastPeak: 0, count: 0, sequence: [] },
    recordTap: (callback) => {
        const now = Date.now();
        if (now - AudioIntelligence.tapState.lastPeak < 100) return; // Debounce

        AudioIntelligence.tapState.lastPeak = now;
        AudioIntelligence.tapState.count++;

        clearTimeout(AudioIntelligence.tapTimeout);
        AudioIntelligence.tapTimeout = setTimeout(() => {
            AudioIntelligence.tapState.sequence.push(AudioIntelligence.tapState.count);
            AudioIntelligence.tapState.count = 0;

            if (AudioIntelligence.tapState.sequence.length === 2) {
                const tapStr = AudioIntelligence.tapState.sequence.join(",");
                AudioIntelligence.pulses += tapStr + " ";
                AudioIntelligence.tapState.sequence = [];
                if (callback) callback(AudioIntelligence.pulses);
            }
        }, 600); // 600ms pause indicates end of row/col set
    },

    processTap: (callback) => {
        if (!AudioIntelligence.isListening) return;
        const dataArray = new Uint8Array(AudioIntelligence.analyser.frequencyBinCount);
        AudioIntelligence.analyser.getByteTimeDomainData(dataArray);

        // Simple Peak Detection (transient spikes)
        let max = 0;
        for (let i = 0; i < dataArray.length; i++) {
            const val = Math.abs(dataArray[i] - 128);
            if (val > max) max = val;
        }

        if (max > 60) { // Spike threshold for a physical tap/knock
            AudioIntelligence.recordTap(callback);
        }

        requestAnimationFrame(() => AudioIntelligence.processTap(callback));
    },

    // --- OPTICAL DETECTION (Light flickers via Camera) ---
    videoTrack: null,
    opticalCanvas: null,
    opticalCtx: null,

    startOptical: async (callback) => {
        try {
            const stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: 'environment' } });
            AudioIntelligence.videoTrack = stream.getVideoTracks()[0];
            const video = document.createElement('video');
            video.srcObject = stream;
            video.play();

            AudioIntelligence.opticalCanvas = document.getElementById('optical-preview') || document.createElement('canvas');
            AudioIntelligence.opticalCtx = AudioIntelligence.opticalCanvas.getContext('2d', { willReadFrequently: true });

            const analyzeFrame = () => {
                if (!AudioIntelligence.videoTrack || AudioIntelligence.videoTrack.readyState === 'ended') return;

                AudioIntelligence.opticalCtx.drawImage(video, 0, 0, AudioIntelligence.opticalCanvas.width, AudioIntelligence.opticalCanvas.height);
                const data = AudioIntelligence.opticalCtx.getImageData(0, 0, AudioIntelligence.opticalCanvas.width, AudioIntelligence.opticalCanvas.height).data;

                let brightness = 0;
                for (let i = 0; i < data.length; i += 4) {
                    brightness += (data[i] + data[i + 1] + data[i + 2]) / 3;
                }
                brightness /= (data.length / 4);

                // Analyze brightness as an "amplitude" for Morse/Tap logic
                AudioIntelligence.processOpticalBrightness(brightness, callback);
                requestAnimationFrame(analyzeFrame);
            };
            analyzeFrame();
        } catch (e) {
            console.error("Optical Init Failed:", e);
        }
    },

    opticalState: { threshold: 128, history: [] },
    processOpticalBrightness: (b, callback) => {
        // Simple peak/valley detection for light pulses
        const isOn = b > AudioIntelligence.opticalState.threshold + 20;
        AudioIntelligence.processPulse(isOn, callback); // Reuse Morse logic for Light
    },

    stopOptical: () => {
        if (AudioIntelligence.videoTrack) AudioIntelligence.videoTrack.stop();
        AudioIntelligence.videoTrack = null;
    }
};
