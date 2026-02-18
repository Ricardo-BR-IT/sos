/**
 * SOS MODULE: AI LITE (V21)
 * Threat Prediction Engine (Heuristics / TF.js Shim).
 * Uses local sensor data to predict Threat Levels (0-100%).
 */

const AILite = {
    factors: {
        radiation: 0,
        temp: 0,
        hostiles: 0,
        battery: 100
    },

    threatLevel: 0,

    init: () => {
        console.log(">>> AI Lite Module Loaded");
        // Simulate Sensor inputs every 5s
        setInterval(AILite.predict, 5000);
    },

    updateInput: (key, value) => {
        if (key in AILite.factors) AILite.factors[key] = value;
    },

    pedometer: () => {
        // Placeholder for "Movement Prediction"
        // Would use accelerometer to estimate calorie burn / fatigue
    },

    predict: () => {
        // Simple Heuristic Model (Decision Tree)
        // If Rad > 50 OR Hostiles > 2 -> Threat High

        let score = 0;

        // Radiation Check (CPM)
        if (AILite.factors.radiation > 100) score += 50;
        else if (AILite.factors.radiation > 50) score += 20;

        // Hostile Reports (Nodes marked "Enemy")
        score += (AILite.factors.hostiles * 15);

        // Environmental Stress (Temp < 0 or > 40C)
        if (AILite.factors.temp < 0 || AILite.factors.temp > 40) score += 10;

        // Battery Critical
        if (AILite.factors.battery < 15) score += 5;

        AILite.threatLevel = Math.min(score, 100);

        AILite.render();
    },

    render: () => {
        const hudEl = document.getElementById('ai-threat-hud');
        if (hudEl) {
            let color = 'green';
            if (AILite.threatLevel > 30) color = 'yellow';
            if (AILite.threatLevel > 70) color = 'red';

            hudEl.innerHTML = `THREAT: <span style="color:${color}">${AILite.threatLevel}%</span>`;
        }
    }
};
