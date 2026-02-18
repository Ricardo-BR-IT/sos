<?php
// SOS AEON: SMART UPGRADE (V14)
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SOS EVOLUTION [AEON]</title>
    <link rel="stylesheet" href="assets/css/aeon.css">
</head>
<body>

<div class="app-shell">
    <?php include 'includes/sidebar.php'; ?>

    <div class="main-content" style="padding: 40px; overflow-y: auto;">
        
        <h1 class="neon-text-green" style="font-family: var(--font-code); margin-bottom: 20px;">SYSTEM EVOLUTION</h1>
        <p style="color: var(--text-dim); margin-bottom: 40px;">INTELLIGENT HARDWARE TRANSFORMATION PROTOCOL.</p>
        
        <!-- AUTO DETECT PANEL -->
        <div class="hud-panel" id="detect-panel" style="margin-bottom: 30px; border: 1px solid var(--neon-cyan);">
            <div class="hud-title" style="background: rgba(0, 255, 255, 0.1);">ANALYZING HARDWARE...</div>
            <div style="padding: 20px; text-align: center;">
                <div id="loading-scan" style="font-size: 2rem;">⏳</div>
                <div id="scan-result" style="display: none;">
                    <h2 id="device-name" style="color: #fff;">UNKNOWN DEVICE</h2>
                    <p id="device-desc" style="color: var(--text-dim); margin-bottom: 20px;">...</p>
                    <a id="rec-link" href="#" download class="btn-aeon" style="background: var(--neon-cyan); color: #000;">DOWNLOAD PAYLOAD</a>
                </div>
            </div>
        </div>

        <div class="hud-title">MANUAL SELECTION</div>
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin-top: 10px;">
            
            <div class="hud-panel">
                <div class="hud-title">ANDROID (LEGACY)</div>
                <div style="padding: 15px; text-align: center;">
                    <div style="font-size: 2rem;">📱</div>
                    <p style="font-size: 0.8rem; color: var(--text-dim);">Turn old phones into Wifi Servers.</p>
                    <a href="scripts/termux_sos.sh" download class="btn-aeon">GET SCRIPT</a>
                </div>
            </div>

            <div class="hud-panel">
                <div class="hud-title">PC / SERVER (DOCKER)</div>
                <div style="padding: 15px; text-align: center;">
                    <div style="font-size: 2rem;">💻</div>
                    <p style="font-size: 0.8rem; color: var(--text-dim);">Full Node with AI capabilities.</p>
                    <a href="scripts/docker_sos.sh" download class="btn-aeon">GET SCRIPT</a>
                </div>
            </div>

            <div class="hud-panel">
                <div class="hud-title">ROUTER (OPENWRT)</div>
                <div style="padding: 15px; text-align: center;">
                    <div style="font-size: 2rem;">📶</div>
                    <p style="font-size: 0.8rem; color: var(--text-dim);">Infrastructure Mesh Node.</p>
                    <a href="scripts/openwrt_sos.sh" download class="btn-aeon">GET SCRIPT</a>
                </div>
            </div>

        </div>
    </div>
</div>

<script>
    setTimeout(() => {
        const ua = navigator.userAgent;
        const scan = document.getElementById('loading-scan');
        const res = document.getElementById('scan-result');
        const name = document.getElementById('device-name');
        const desc = document.getElementById('device-desc');
        const link = document.getElementById('rec-link');

        scan.style.display = 'none';
        res.style.display = 'block';

        if (/Android/i.test(ua)) {
            name.innerText = "ANDROID DETECTED";
            desc.innerText = "Optimal Protocol: TERMUX GOD MODE. Transforms this device into a portable server.";
            link.href = "scripts/termux_sos.sh";
            link.innerText = "INITIATE GOD MODE";
        } else if (/Win|Mac|Linux/i.test(ua) && !/Android/i.test(ua)) {
            name.innerText = "DESKTOP CLASS DETECTED";
            desc.innerText = "Optimal Protocol: DOCKER CONTAINER. Deploys full SOS Core with AI support.";
            link.href = "scripts/docker_sos.sh";
            link.innerText = "DEPLOY CONTAINER";
        } else {
            name.innerText = "UNKNOWN ARCHITECTURE";
            desc.innerText = "Please select a protocol from the manual list below.";
            link.style.display = 'none';
        }

    }, 1500);
</script>

</body>
</html>
