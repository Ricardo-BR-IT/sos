/**
 * SOS EXPERIMENTAL MODULE: SONAR (Acoustic Comms)
 * Uses Web Audio API to transmit data via Sound (Ultrasonic or AFSK).
 */

const Sonar = {
    audioCtx: null,
    oscillator: null,
    gainNode: null,

    init: () => {
        console.log(">>> Sonar Module Loaded");
        // Init Audio Context on first user interaction (browser policy)
        document.addEventListener('click', () => {
            if (!Sonar.audioCtx) Sonar.audioCtx = new (window.AudioContext || window.webkitAudioContext)();
        }, { once: true });
    },

    txBeacon: (freq = 18000, duration = 1000) => {
        if (!Sonar.audioCtx) return;

        Sonar.oscillator = Sonar.audioCtx.createOscillator();
        Sonar.gainNode = Sonar.audioCtx.createGain();

        Sonar.oscillator.type = 'sine';
        Sonar.oscillator.frequency.setValueAtTime(freq, Sonar.audioCtx.currentTime);

        Sonar.oscillator.connect(Sonar.gainNode);
        Sonar.gainNode.connect(Sonar.audioCtx.destination);

        Sonar.oscillator.start();
        UI.logSystem(`SONAR TX: ${freq}Hz`);

        // Ramp down to avoid click
        Sonar.gainNode.gain.setValueAtTime(1, Sonar.audioCtx.currentTime);
        Sonar.gainNode.gain.exponentialRampToValueAtTime(0.001, Sonar.audioCtx.currentTime + (duration / 1000));

        setTimeout(() => {
            Sonar.oscillator.stop();
        }, duration);
    },

    sendMorse: (text) => {
        // Placeholder for AFSK / Morse logic
        // Transmits short bursts at 800Hz
        const dot = 100;
        let timing = 0;

        // Simple SOS pattern
        const pattern = [1, 1, 1, 3, 3, 3, 1, 1, 1]; // Not real morse timing, just demo

        pattern.forEach(p => {
            setTimeout(() => {
                Sonar.txBeacon(800, p === 1 ? 100 : 300);
            }, timing);
            timing += 400;
        });
    }
};
