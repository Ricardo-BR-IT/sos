/**
 * SOS POWER AUTONOMY (V39)
 * AI-driven battery management and persistence prediction.
 */
const PowerAutonomy = {
    isActive: false,
    currentLevel: 1.0,
    isCharging: false,
    drainRate: 0.05, // % per hour (simulated)
    predictedHours: 24,
    profile: 'TACTICAL', // ECO, TACTICAL, SURVIVAL

    init: async () => {
        console.log(">>> Power Autonomy Module Initialized");
        if (navigator.getBattery) {
            const bat = await navigator.getBattery();
            PowerAutonomy.updateFromBattery(bat);
            bat.addEventListener('levelchange', () => PowerAutonomy.updateFromBattery(bat));
            bat.addEventListener('chargingchange', () => PowerAutonomy.updateFromBattery(bat));
        }
    },

    start: () => {
        PowerAutonomy.isActive = true;
        console.log("Predictive Power Monitoring Active.");
        PowerAutonomy.pollPrediction();
    },

    stop: () => {
        PowerAutonomy.isActive = false;
    },

    updateFromBattery: (bat) => {
        PowerAutonomy.currentLevel = bat.level;
        PowerAutonomy.isCharging = bat.charging;
        console.log(`Battery: ${Math.round(bat.level * 100)}% | Charging: ${bat.charging}`);
        PowerAutonomy.pollPrediction();
    },

    setProfile: (name) => {
        PowerAutonomy.profile = name;
        console.log("Power Profile set to: " + name);

        // Adjust other modules based on profile
        if (name === 'ECO') {
            if (window.MeshForge) MeshForge.stop();
            if (window.SwarmMesh) SwarmMesh.setSlowMode(true);
        } else if (name === 'SURVIVAL') {
            if (window.MeshForge) MeshForge.stop();
            if (window.SwarmMesh) SwarmMesh.stop();
            if (window.TacticalAR) TacticalAR.stop();
        }

        PowerAutonomy.pollPrediction();
        PowerAutonomy.updateUI();
    },

    pollPrediction: async () => {
        try {
            const resp = await fetch(`api/power.php?action=predict&level=${PowerAutonomy.currentLevel}&drain=${PowerAutonomy.drainRate}&profile=${PowerAutonomy.profile}`);
            const data = await resp.json();
            PowerAutonomy.predictedHours = data.hours || 0;
            PowerAutonomy.updateUI();
        } catch (e) {
            console.error("Power Prediction Error", e);
        }
    },

    updateUI: () => {
        const label = document.getElementById('pwr-status-label');
        const bar = document.getElementById('pwr-persistence-bar');
        if (label) {
            label.innerText = `PWR: ${PowerAutonomy.profile} | RESTA: ${Math.round(PowerAutonomy.predictedHours)}H`;
            label.style.color = PowerAutonomy.currentLevel < 0.2 ? 'var(--neon-red)' : 'var(--neon-cyan)';
        }
        if (bar) {
            bar.style.width = (PowerAutonomy.currentLevel * 100) + '%';
            bar.style.background = PowerAutonomy.currentLevel < 0.2 ? 'var(--neon-red)' : 'var(--neon-cyan)';
        }
    }
};
