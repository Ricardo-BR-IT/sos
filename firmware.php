<?php
// SOS AEON: THE FOUNDRY (V12)
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SOS FOUNDRY [AEON]</title>
    <link rel="stylesheet" href="assets/css/aeon.css">
</head>
<body>

<div class="app-shell">
    <?php include 'includes/sidebar.php'; ?>

    <div class="main-content" style="padding: 40px; overflow-y: auto;">
        
        <h1 class="neon-text-red" style="font-family: var(--font-code); margin-bottom: 20px;">DEVICE FOUNDRY</h1>
        <p style="color: var(--text-dim); margin-bottom: 40px;">TRANSFORM CIVILIAN HARDWARE INTO INFRASTRUCTURE.</p>
        
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px;">
            
            <!-- ROUTERS -->
            <div class="hud-panel">
                <div class="hud-title">ROUTER INFRASTRUCTURE</div>
                <div style="text-align: center; padding: 20px;">
                    <div style="font-size: 3rem; margin-bottom: 10px;">📶</div>
                    <h3 style="color: #fff;">SOS MESH V15</h3>
                    <p style="font-size: 0.8rem; color: var(--text-dim); margin-bottom: 20px;">
                        OpenWrt Image Builder Script.
                    </p>
                    <a href="builds/router/sos_v15_mesh.sh" download class="btn-aeon">DOWNLOAD ROM (.SH)</a>
                </div>
            </div>

            <!-- ANDROID -->
            <div class="hud-panel">
                <div class="hud-title">MOBILE COMMAND</div>
                <div style="text-align: center; padding: 20px;">
                    <div style="font-size: 3rem; margin-bottom: 10px;">📱</div>
                    <h3 style="color: #fff;">SOS MOBILE V15</h3>
                    <p style="font-size: 0.8rem; color: var(--text-dim); margin-bottom: 20px;">
                        Android Termux "God Mode" Package.
                    </p>
                    <a href="builds/android/sos_v15_mobile.sh" download class="btn-aeon">DOWNLOAD ROM (.SH)</a>
                </div>
            </div>

            <!-- TV BOX / PC -->
            <div class="hud-panel">
                <div class="hud-title">CORE STATION</div>
                <div style="text-align: center; padding: 20px;">
                    <div style="font-size: 3rem; margin-bottom: 10px;">💻</div>
                    <h3 style="color: #fff;">SOS CORE V15</h3>
                    <p style="font-size: 0.8rem; color: var(--text-dim); margin-bottom: 20px;">
                        Docker / PC / TV Box Server Core.
                    </p>
                    <a href="builds/pc/sos_v15_core.sh" download class="btn-aeon">DOWNLOAD ROM (.SH)</a>
                </div>
            </div>

        </div>

        <div class="hud-panel" style="margin-top: 30px;">
            <div class="hud-title">SYSTEM VERSION</div>
            <div style="padding: 15px; font-family: var(--font-code);">
                CURRENT BUILD: <span class="neon-text-green">V12.0.0-OMEGA</span><br>
                CHECKING UPDATE... <span id="ota-status">LATEST</span>
            </div>
        </div>

    </div>
</div>

</body>
</html>
