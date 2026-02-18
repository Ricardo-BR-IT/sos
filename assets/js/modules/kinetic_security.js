/**
 * SOS KINETIC SECURITY (V38)
 * Uses device motion for cryptographic entropy.
 */
const KineticSecurity = {
    isActive: false,
    entropyBuffer: [],
    maxBufferSize: 100,
    entropyLevel: 0,
    currentSeed: null,

    init: () => {
        console.log(">>> Kinetic Security Module Initialized");
    },

    start: () => {
        if (typeof DeviceMotionEvent !== 'undefined' && typeof DeviceMotionEvent.requestPermission === 'function') {
            DeviceMotionEvent.requestPermission()
                .then(response => {
                    if (response == 'granted') {
                        window.addEventListener('devicemotion', KineticSecurity.handleMotion);
                        KineticSecurity.isActive = true;
                    }
                })
                .catch(console.error);
        } else {
            window.addEventListener('devicemotion', KineticSecurity.handleMotion);
            KineticSecurity.isActive = true;
        }
        console.log("Kinetic Entropy Collection Active.");
    },

    stop: () => {
        window.removeEventListener('devicemotion', KineticSecurity.handleMotion);
        KineticSecurity.isActive = false;
        KineticSecurity.entropyLevel = 0;
    },

    handleMotion: (event) => {
        const acc = event.accelerationIncludingGravity;
        if (!acc) return;

        // Extract micro-variations (jitter) as entropy
        const jitter = (Math.abs(acc.x) + Math.abs(acc.y) + Math.abs(acc.z)) % 1;
        KineticSecurity.entropyBuffer.push(jitter);

        if (KineticSecurity.entropyBuffer.length > KineticSecurity.maxBufferSize) {
            KineticSecurity.entropyBuffer.shift();
        }

        KineticSecurity.calculateEntropy();
    },

    calculateEntropy: () => {
        if (KineticSecurity.entropyBuffer.length === 0) return;

        // Simple entropy proxy based on variance
        let sum = KineticSecurity.entropyBuffer.reduce((a, b) => a + b, 0);
        let avg = sum / KineticSecurity.entropyBuffer.length;
        let variance = KineticSecurity.entropyBuffer.reduce((a, b) => a + Math.pow(b - avg, 2), 0);

        KineticSecurity.entropyLevel = Math.min(100, variance * 500); // Scale for UI
        KineticSecurity.updateHUD();

        if (KineticSecurity.entropyLevel > 80 && !KineticSecurity.currentSeed) {
            KineticSecurity.generateSeed();
        }
    },

    generateSeed: async () => {
        const raw = KineticSecurity.entropyBuffer.join(',');
        const msgUint8 = new TextEncoder().encode(raw);
        const hashBuffer = await crypto.subtle.digest('SHA-256', msgUint8);
        const hashArray = Array.from(new Uint8Array(hashBuffer));
        KineticSecurity.currentSeed = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');

        console.log("Kinetic Seed Rotated: " + KineticSecurity.currentSeed.substring(0, 8) + "...");

        // Send to backend for context update
        fetch('api/security.php?action=seed', {
            method: 'POST',
            body: JSON.stringify({ seed: KineticSecurity.currentSeed })
        });
    },

    updateHUD: () => {
        const bar = document.getElementById('entropy-bar');
        const icon = document.getElementById('kinetic-lock-icon');
        if (bar) bar.style.height = KineticSecurity.entropyLevel + '%';
        if (icon) {
            icon.style.opacity = KineticSecurity.entropyLevel > 50 ? 1 : 0.3;
            icon.style.color = KineticSecurity.entropyLevel > 80 ? 'var(--neon-green)' : 'var(--neon-yellow)';
        }
    }
};
