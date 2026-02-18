<?php
// SOS AEON: PROFILE (V11)
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SOS PROFILE [AEON]</title>
    <link rel="stylesheet" href="assets/css/aeon.css">
</head>
<body>

<div class="app-shell">
    <?php include 'includes/sidebar.php'; ?>

    <div class="main-content" style="display: flex; justify-content: center; align-items: center;">
        
        <div class="hud-panel" style="width: 400px; padding: 30px;">
            <div class="hud-title">OPERATOR PROFILE</div>
            
            <div style="margin: 20px 0;">
                <label style="color: var(--text-dim); font-size: 0.8rem;">CALL SIGN (NODE ID)</label>
                <div id="display-id" style="font-size: 1.5rem; color: var(--neon-cyan); font-family: var(--font-code);">LOADING...</div>
            </div>

            <hr style="border: 0; border-bottom: 1px solid rgba(255,255,255,0.1); margin: 20px 0;">

            <div class="hud-title">PRIVACY & TRACKING</div>
            
            <div style="display: flex; align-items: center; justify-content: space-between; margin-top: 15px;">
                <span style="color: #fff;">BROADCAST LOCATION</span>
                <label class="switch">
                    <input type="checkbox" id="gps-toggle">
                    <span class="slider"></span>
                </label>
            </div>
            <div style="font-size: 0.7rem; color: var(--text-dim); margin-top: 5px;">
                When active, your GPS coordinates are sent to the mesh. Distance to other nodes will be calculated.
            </div>

            <button onclick="saveProfile()" class="btn-aeon" style="width: 100%; margin-top: 30px;">SAVE CONFIGURATION</button>
            <div id="save-msg" style="text-align: center; margin-top: 10px; font-size: 0.8rem; color: var(--neon-green); opacity: 0;">SAVED</div>

        </div>
    </div>
</div>

<style>
/* CUSTOM TOGGLE FOR AEON */
.switch { position: relative; display: inline-block; width: 40px; height: 20px; }
.switch input { opacity: 0; width: 0; height: 0; }
.slider { position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0; background-color: #333; transition: .4s; border-radius: 20px; border: 1px solid #555; }
.slider:before { position: absolute; content: ""; height: 14px; width: 14px; left: 3px; bottom: 2px; background-color: white; transition: .4s; border-radius: 50%; }
input:checked + .slider { background-color: var(--neon-cyan); border-color: var(--neon-cyan); }
input:checked + .slider:before { transform: translateX(20px); background-color: #000; }
</style>

<script>
    const myId = localStorage.getItem('v7_node_id') || 'UNKNOWN';
    document.getElementById('display-id').innerText = myId;
    
    // Load State
    const gpsState = localStorage.getItem('v11_gps_active') === 'true';
    document.getElementById('gps-toggle').checked = gpsState;

    function saveProfile() {
        const isActive = document.getElementById('gps-toggle').checked;
        localStorage.setItem('v11_gps_active', isActive);
        
        // Visual Feedback
        const msg = document.getElementById('save-msg');
        msg.style.opacity = 1;
        setTimeout(() => msg.style.opacity = 0, 2000);
        
        // Force immediate sync in other tabs logic would go here, 
        // but mesh.js picks it up on next heartbeat.
    }
</script>

</body>
</html>
