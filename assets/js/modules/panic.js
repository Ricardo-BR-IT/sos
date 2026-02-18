/**
 * SOS MODULE: PANIC SUITE (V21)
 * "The Red Button" for Emergency Wipe & Hardening.
 */

const Panic = {
    init: () => {
        console.log(">>> Panic Module Loaded");
    },

    trigger: (code) => {
        if (code === "0000") {
            Panic.fakeLogin();
            return;
        }

        if (confirm("⚠️ CRITICAL: WIPE ALL DATA? THIS CANNOT BE UNDONE.")) {
            Panic.executeWipe();
        }
    },

    executeWipe: async () => {
        console.warn("INITIATING WIPE SEQUENCE...");

        // 1. Broadcast "Dead Man" Signal
        if (window.Comms) Comms.sendMessage("PUBLIC", "🚨 [PANIC] NODE COMPROMISED. GOING DARK.");

        // 2. Shred Local Storage (Overwrite 3x)
        const keys = Object.keys(localStorage);
        for (let i = 0; i < 3; i++) {
            keys.forEach(k => {
                const len = localStorage.getItem(k).length;
                localStorage.setItem(k, "0".repeat(len)); // Zero out
                localStorage.setItem(k, "1".repeat(len)); // One out
                localStorage.setItem(k, Math.random().toString()); // Random out
            });
        }
        localStorage.clear();
        sessionStorage.clear();

        // 3. Drop DB Tables (requires API)
        try {
            await fetch('api/panic.php?action=shred', { method: 'POST' });
        } catch (e) { console.error("Server Wipe Failed", e); }

        // 4. Kill UI
        document.body.innerHTML = "<h1 style='color:red; text-align:center; margin-top:20%'>SYSTEM HALTED</h1>";

        // 5. Reload to blank
        setTimeout(() => window.location.href = "about:blank", 2000);
    },

    fakeLogin: () => {
        // Loads a benign "Weather App" or "Notes" dashboard
        document.body.innerHTML = `
            <div style="font-family: sans-serif; padding: 20px; background: #eee; color: #333; height: 100vh;">
                <h1>My Notes</h1>
                <p>Grocery List:</p>
                <ul><li>Milk</li><li>Eggs</li><li>Bread</li></ul>
            </div>
        `;
    }
};
