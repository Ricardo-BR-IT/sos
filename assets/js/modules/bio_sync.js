/**
 * SOS BIO-SYNC INTELLIGENCE (V31)
 * Integrates external health sensors and automated SOS protocols.
 */
const BioSync = {
    isActive: false,
    device: null,
    server: null,
    characteristic: null,
    bpm: 0,
    spo2: 100, // Default if not provided
    callback: null,
    distressCounter: 0,

    init: () => {
        console.log("Bio-Sync Module Initialized.");
    },

    pair: async () => {
        try {
            BioSync.device = await navigator.bluetooth.requestDevice({
                filters: [{ services: ['heart_rate'] }]
            });
            BioSync.server = await BioSync.device.gatt.connect();
            const service = await BioSync.server.getPrimaryService('heart_rate');
            BioSync.characteristic = await service.getCharacteristic('heart_rate_measurement');

            await BioSync.characteristic.startNotifications();
            BioSync.characteristic.addEventListener('characteristicvaluechanged', BioSync.handleHRChange);

            console.log("Bio-Sensor Paired Successfully.");
            return true;
        } catch (e) {
            console.error("Bluetooth Pairing Failed:", e);
            // Fallback for simulation
            return false;
        }
    },

    handleHRChange: (event) => {
        const value = event.target.value;
        const flags = value.getUint8(0);
        let rate;
        if (flags & 0x01) {
            rate = value.getUint16(1, true);
        } else {
            rate = value.getUint8(1);
        }
        BioSync.bpm = rate;
        BioSync.processVitals();
    },

    start: (onEvent) => {
        BioSync.isActive = true;
        BioSync.callback = onEvent;
        // If not paired, start simulation for testing
        if (!BioSync.device) BioSync.simulate();
    },

    stop: () => {
        BioSync.isActive = false;
        if (BioSync.server) BioSync.server.disconnect();
    },

    processVitals: async () => {
        if (!BioSync.isActive) return;

        try {
            const resp = await fetch(`api/vitals.php?bpm=${BioSync.bpm}&spo2=${BioSync.spo2}`);
            const data = await resp.json();

            if (BioSync.callback) BioSync.callback(data, BioSync.bpm);

            // "Dead Man's Switch" Logic
            if (data.status === 'CRITICAL_FAILURE' || (BioSync.bpm < 30 && BioSync.bpm > 0)) {
                BioSync.distressCounter++;
                if (BioSync.distressCounter > 5) { // 5 consecutive failures
                    BioSync.triggerAutomatedSOS("BIOLOGICAL_FAILURE_DETECTED");
                }
            } else {
                BioSync.distressCounter = 0;
            }
        } catch (e) { }
    },

    triggerAutomatedSOS: (reason) => {
        console.warn("AUTOMATED SOS TRIGGERED:", reason);
        if (window.Panic) {
            Panic.trigger(); // Trigger global panic
            Mind.updateLiveTranscription(`SOS AUTOMÁTICO: FALHA BIOLÓGICA DETECTADA!`);
        }
    },

    simulate: () => {
        if (!BioSync.isActive) return;
        // Mocking vitals for testing if no BT device
        BioSync.bpm = 70 + Math.floor(Math.random() * 10);
        BioSync.processVitals();
        setTimeout(BioSync.simulate, 2000);
    }
};
