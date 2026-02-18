<?php
// SOS AEON: COMMAND DASHBOARD (V9)
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SOS COMMAND [AEON]</title>
    <link rel="stylesheet" href="assets/css/aeon.css">
    <link rel="manifest" href="manifest.json">
    <script>
        if ('serviceWorker' in navigator) {
            navigator.serviceWorker.register('sw.js')
            .then(reg => console.log('[SW] Registered', reg))
            .catch(err => console.log('[SW] Fail', err));
        }
    </script>
</head>
<body>

<div class="app-shell">
    <!-- SIDEBAR NAVIGATION -->
    <?php include 'includes/sidebar.php'; ?>

    <!-- MAIN CONTENT (HUD) -->
    <div class="main-content">
        
        <!-- BACKGROUND LAYER: RADAR MAP -->
        <!-- The canvas fills the container behind the HUD -->
        <canvas id="radarCanvas" style="position: absolute; top:0; left:0; width:100%; height:100%; z-index: 0;"></canvas>

        <!-- HUD GRID (Floating Widgets) -->
        <div class="hud-grid" style="z-index: 1;">
            
            <!-- TOP LEFT: STATUS -->
            <div class="hud-panel" style="grid-column: 1; grid-row: 1;">
                <div class="hud-title">SYSTEM STATUS</div>
                <div style="font-size: 0.8rem; color: var(--neon-green);">
                    ONLINE <span style="animation: blink 1s infinite;">●</span><br>
                    NET: <span style="cursor:pointer;" onclick="Hardware.toggleTor()">ONION / MESH</span><br>
                    GPS: <span style="color:var(--text-bright);">3D FIX</span><br>
                    <span id="ai-threat-hud">THREAT: CALCULATING...</span>
                </div>
            </div>

            <!-- TOP RIGHT: CLOCK & PANIC -->
            <div class="clock-widget" style="grid-column: 3; grid-row: 1; display: flex; flex-direction: column; align-items: flex-end;">
                <div id="clock">00:00:00</div>
                <div style="font-size: 0.8rem; color: var(--neon-cyan); opacity: 0.7;">UTC-3</div>
                <button onclick="Panic.trigger()" style="background: red; color: white; border: 1px solid white; font-weight: bold; font-size: 0.6rem; cursor: pointer; margin-top: 5px; animation: blink 2s infinite;">⚠️ PANIC WIPE</button>
            </div>

            <!-- BOTTOM LEFT: NODE LIST -->
            <div class="hud-panel" style="grid-column: 1; grid-row: 2 / span 2; overflow: hidden; display: flex; flex-direction: column;">
                <div class="hud-title">
                    <span onclick="document.getElementById('node-list').style.display='block'; document.getElementById('resource-list').style.display='none';">NODES</span> / 
                    <span onclick="document.getElementById('resource-list').style.display='block'; document.getElementById('node-list').style.display='none';" style="cursor: pointer; color: var(--text-dim);">RESOURCES</span>
                </div>
                
                <div id="node-list" style="overflow-y: auto; flex: 1; font-size: 0.8rem;">
                    <!-- Populated via JS -->
                    <div style="color: var(--text-dim); padding: 5px;">SCANNING...</div>
                </div>
                
                <div id="resource-list" style="display: none; overflow-y: auto; flex: 1; font-size: 0.8rem;">
                    <!-- Added by JS -->
                    <button onclick="Resources.openAddModal()" style="width: 100%; border: 1px dashed var(--neon-cyan); color: var(--neon-cyan);">+ MARK LOOT</button>
                </div>
            </div>

            <!-- BOTTOM RIGHT: COMMS -->
            <div class="hud-panel" style="grid-column: 3; grid-row: 2 / span 2; display: flex; flex-direction: column;">
                <div class="hud-title">
                    SECURE COMMS 
                    <label style="cursor: pointer; display: flex; align-items: center; gap: 5px; font-size: 0.6rem; color: var(--text-dim);">
                        <input type="checkbox" id="translate-toggle"> TRANSLATE
                    </label>
                </div>
                
                <div id="chat-box" style="flex: 1; overflow-y: auto; font-size: 0.8rem; margin-bottom: 10px; padding-right: 5px;">
                    <!-- Messages -->
                </div>
                
                <div style="display: flex; gap: 5px;">
                    <select id="msg-target" class="input-aeon" style="width: 80px;">
                        <option value="PUBLIC">PUB</option>
                    </select>
                    <input type="text" id="msg-input" class="input-aeon" placeholder="CMD...">
                    <button id="send-btn" class="btn-aeon">SEND</button>
                </div>
            </div>

            <!-- BOTTOM CENTER: LOGS (Collapsed) -->
            <div class="hud-panel" style="grid-column: 2; grid-row: 3; height: 100%; opacity: 0.8;">
                <div class="hud-title">SYSTEM LOG</div>
                <div id="system-log" style="font-family: var(--font-code); font-size: 0.7rem; color: var(--text-dim); overflow-y: hidden;">
                    > AEON UI LOADED.<br>
                    > WAITING FOR TELEMETRY...
                </div>
            </div>

        </div>
    </div>
            <!-- EXPERIMENTAL: HARDWARE PANEL (Bottom Left Expanded) -->
            <div class="hud-panel" style="grid-column: 1; grid-row: 3; display: flex; gap: 5px; align-items: center; justify-content: space-around; flex-wrap: wrap;">
               <div class="hud-btn" onclick="Hardware.connectSerial()" title="Connect LoRa/GPS">🔌 SERIAL</div>
               <div class="hud-btn" onclick="OfflineMaps.downloadRegion()" title="Cache Offline Maps">🗺️ MAPS</div>
               <div class="hud-btn" onclick="Sonar.txBeacon()" title="Send Sonar Ping">🔊 SONAR</div>
               <div class="hud-btn" onclick="Sensors.requestPermission()" title="Calibrate Compass">🧭 CALIB</div>
               <!-- NEW V20 -->
               <div class="hud-btn" onclick="UI.toggleDeadDrop()" title="Encrypted Notes">🔒 SAFE</div>
               <div class="hud-btn" onclick="UI.toggleStego()" title="Hidden Messages">🕵️ STEGO</div>
            </div>

        </div>

        <!-- OVERLAY: COMPASS HUD -->
        <div id="hud-compass" style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); width: 200px; height: 200px; border: 1px dashed rgba(0,255,255,0.2); border-radius: 50%; pointer-events: none; z-index: 0; display: flex; justify-content: center; transition: transform 0.2s;">
            <div style="position: absolute; top: -10px; color: var(--neon-cyan); font-size: 0.8rem;">N</div>
            <div style="position: absolute; bottom: -10px; color: var(--neon-cyan); font-size: 0.8rem;">S</div>
            <div style="position: absolute; left: -10px; top: 50%; transform: translateY(-50%); color: var(--neon-cyan); font-size: 0.8rem;">W</div>
            <div style="position: absolute; right: -10px; top: 50%; transform: translateY(-50%); color: var(--neon-cyan); font-size: 0.8rem;">E</div>
            <div id="hud-heading-val" style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); color: rgba(0,255,255,0.5); font-size: 2rem;">0°</div>
        </div>

        <!-- MODAL: WEBRTC CALL -->
        <div id="call-modal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.9); z-index: 1000; flex-direction: column; align-items: center; justify-content: center;">
            <h2 class="neon-text-red" id="call-status">CALLING...</h2>
            <div style="display: flex; gap: 20px; margin-bottom: 20px;">
                <video id="localVideo" autoplay muted style="width: 150px; border: 1px solid var(--neon-cyan);"></video>
                <video id="remoteVideo" autoplay style="width: 300px; border: 1px solid var(--neon-red);"></video>
            </div>
            <button class="btn-aeon" style="background: red; color: white;" onclick="WebRTC.endCall()">END CALL</button>
        </div>

        </div>

        <!-- MODAL: MIND AI CONSULTATION -->
        <div id="mind-modal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.95); z-index: 1001; flex-direction: column; align-items: center; justify-content: center; padding: 20px;">
            <div class="hud-panel" style="width: 100%; max-width: 500px; height: 80vh; display: flex; flex-direction: column; border: 1px solid var(--neon-cyan); background: #000; position: relative;">
                <div style="display: flex; justify-content: space-between; align-items: center; padding: 10px; border-bottom: 1px solid rgba(0,255,255,0.2);">
                    <h2 class="neon-text-cyan" style="margin:0; font-size: 1.2rem;">MESH MIND AI</h2>
                    <button class="hud-btn" style="flex: 0; padding: 2px 10px;" onclick="UI.toggleMind()">X</button>
                </div>
                
                <div style="display: flex; gap: 5px; padding: 10px; background: rgba(0,255,255,0.05);">
                    <div class="hud-btn" onclick="Mind.setAgent('LOG_SOS')">📦 LOG</div>
                    <div class="hud-btn" id="mind-swarm-btn" onclick="Mind.toggleSwarm()">🐝 SWARM</div>
                    <div class="hud-btn" id="mind-oth-btn" style="border-color: var(--neon-green); color: var(--neon-green);" onclick="Mind.toggleOTH()">📡 OTH</div>
                    <div class="hud-btn" id="mind-link-btn" title="Neural & Trauma Interface" onclick="Mind.toggleLink()">🧠 LINK</div>
                    <div class="hud-btn" id="mind-forge-btn" title="Collective Computing" onclick="Mind.toggleForge()">⚒️ FORGE</div>
                    <div class="hud-btn" id="mind-kinetic-btn" title="Kinetic Security" onclick="Mind.toggleKinetic()">➰ KINETIC</div>
                    <div class="hud-btn" id="mind-pwr-btn" title="Predictive Autonomy" onclick="Mind.toggleAutonomy()">🔋 PWR</div>
                    <div class="hud-btn" id="mind-rf-btn" title="RF Compass" onclick="Mind.toggleRFCompass()">🧭 RF</div>
                    <div class="hud-btn" id="mind-vision-btn" title="Wi-Fi Sensing" onclick="Mind.toggleVision()">👁️ VISION</div>
                </div>
                <div style="display: flex; gap: 5px; background: rgba(0,255,255,0.05); padding: 5px; margin-bottom: 5px;">
                    <button class="hud-btn" id="mind-seismic-btn" style="flex: 1; border-color: var(--neon-cyan); font-size: 0.7rem; padding: 5px;" onclick="Mind.toggleSeismic()">📳 SÍSMICO</button>
                    <button class="hud-btn" id="mind-bio-btn" style="flex: 1; border-color: var(--neon-cyan); font-size: 0.7rem; padding: 5px;" onclick="Mind.toggleBio()">❤️ VITAIS</button>
                    <button class="hud-btn" id="mind-ar-btn" style="flex: 1; border-color: var(--neon-cyan); font-size: 0.7rem; padding: 5px;" onclick="Mind.toggleAR()">👁️ AR</button>
                    <button class="hud-btn" style="flex: 0.5; border-color: var(--neon-cyan); font-size: 0.7rem; padding: 5px;" onclick="window.location.reload()">🔄</button>
                </div>
                <div style="display: flex; gap: 5px; background: rgba(0,255,255,0.05); padding: 5px;">
                    <div class="hud-btn" id="mind-listen-btn" style="flex: 1; border-color: var(--neon-red);" onclick="Mind.toggleListen()">🎙️ AUTO</div>
                    <div class="hud-btn" style="flex: 0.2;" onclick="Mind.setListenMode('AUTO')">A</div>
                    <div class="hud-btn" style="flex: 0.2;" onclick="Mind.setListenMode('MORSE')">M</div>
                    <div class="hud-btn" style="flex: 0.2;" onclick="Mind.setListenMode('PHONETIC')">P</div>
                    <div class="hud-btn" style="flex: 0.2;" onclick="Mind.setListenMode('TAP')">T</div>
                </div>
                <div id="mind-active-label" style="font-size: 0.7rem; color: var(--neon-cyan); padding: 0 10px; margin-bottom: 5px; display: flex; justify-content: space-between; align-items: center;">
                    <div style="display:flex; flex-direction:column;">
                        <span id="mind-vitals-label">Agente: TAC_SOS</span>
                        <span id="mind-link-label" style="font-size: 0.6rem;">LINK: STANDBY</span>
                        <span id="skywave-status-label" style="font-size: 0.6rem;"></span>
                        <span id="vision-status-label" style="font-size: 0.55rem; color: var(--neon-green);"></span>
                    </div>
                    <div style="display:flex; gap: 5px; align-items:center;">
                        <div id="entropy-guage-container" style="width: 4px; height: 25px; background: rgba(0,255,255,0.1); position: relative;" title="Entropy Level">
                            <div id="entropy-bar" style="position: absolute; bottom: 0; width: 100%; height: 0%; background: var(--neon-green); transition: height 0.3s;"></div>
                        </div>
                        <span id="kinetic-lock-icon" style="font-size: 0.8rem; opacity: 0.3; transition: opacity 0.3s;">🔒</span>
                        <canvas id="rf-radar-canvas" width="60" height="60" style="border-radius: 50%; background: rgba(0,255,255,0.05); border: 1px solid var(--neon-cyan);"></canvas>
                        <canvas id="neural-pulse-cvs" width="60" height="25" style="border: 1px solid rgba(0,255,150,0.2);"></canvas>
                        <canvas id="optical-preview" width="50" height="30" style="background: #000; border: 1px solid var(--neon-cyan);"></canvas>
                    </div>
                </div>

                <div id="pwr-hud-container" style="padding: 0 10px; margin-bottom: 5px; border-bottom: 1px solid rgba(0,255,255,0.05); padding-bottom: 5px;">
                    <div style="display: flex; justify-content: space-between; align-items: center;">
                        <span id="pwr-status-label" style="font-size: 0.55rem; color: var(--neon-cyan); text-transform: uppercase;">PWR: STANDBY</span>
                        <div style="display: flex; gap: 3px;">
                            <div class="hud-btn" style="font-size: 0.5rem; padding: 2px 4px;" onclick="PowerAutonomy.setProfile('ECO')">ECO</div>
                            <div class="hud-btn" style="font-size: 0.5rem; padding: 2px 4px;" onclick="PowerAutonomy.setProfile('TACTICAL')">TAC</div>
                        </div>
                    </div>
                    <div style="width: 100%; height: 2px; background: rgba(0,255,255,0.1); margin-top: 2px;">
                        <div id="pwr-persistence-bar" style="width: 100%; height: 100%; background: var(--neon-cyan); transition: width 0.3s;"></div>
                    </div>
                </div>

                <div id="forge-hud-container" style="padding: 0 10px; margin-bottom: 5px;">
                    <div id="forge-status-label" style="font-size: 0.55rem; color: var(--neon-green); text-transform: uppercase;">FORGE: STANDBY</div>
                    <div style="width: 100%; height: 2px; background: rgba(0,255,100,0.1); margin-top: 2px;">
                        <div id="forge-power-bar" style="width: 0%; height: 100%; background: var(--neon-green); transition: width 0.3s;"></div>
                    </div>
                </div>

                <div id="mind-chat-log" style="flex: 1; overflow-y: auto; background: rgba(0,0,0,0.8); padding: 10px; border-top: 1px solid rgba(0,255,255,0.1); font-size: 0.85rem; line-height: 1.4; color: #fff;">
                    <!-- SWARM DASHBOARD OVERLAY -->
                    <div id="swarm-list" style="display:none; background: rgba(0,255,255,0.05); padding: 5px; margin-bottom: 10px; border: 1px solid rgba(255,255,255,0.1);"></div>
                    
                    <div class="mind-entry">
                        <div class="mind-agent-name" style="color: var(--neon-cyan); font-weight: bold;">[SISTEMA]</div>
                        <div class="mind-agent-text">Mente da Malha Online. Escolha um agente e faça sua consulta tática.</div>
                        <hr style="border: 0; border-top: 1px solid rgba(0,255,255,0.1); margin: 10px 0;">
                    </div>
                </div>

                <div id="mind-overlay" style="display: none; position: absolute; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.7); align-items: center; justify-content: center; color: var(--neon-cyan); font-weight: bold; z-index: 10;">
                    CONSULTANDO MENTE...
                </div>

                <div style="display: flex; gap: 5px; padding: 10px; border-top: 1px solid rgba(0,255,255,0.2);">
                    <input type="text" id="mind-input" placeholder="Perguntar à malha..." style="flex: 1; background: #111; border: 1px solid var(--neon-cyan); color: var(--neon-cyan); padding: 8px; font-family: monospace;">
                    <button class="hud-btn" style="flex: 0; padding: 5px 15px; background: var(--neon-red); color: white;" onclick="Mind.generateSignal()" title="Generate SOS Morse Audio">SIGNAL</button>
                    <button class="hud-btn" style="flex: 0; padding: 5px 15px; border-color: var(--neon-red); color: var(--neon-red);" onclick="Mind.generatePhonetic()" title="NATO Alpha-Zulu Voice">ALPHA</button>
                    <button class="hud-btn" style="flex: 0; padding: 5px 10px;" onclick="Mind.generateTap()" title="Tap Code (Knocking)">TAP</button>
                    <button class="hud-btn" id="mind-stealth-btn" style="flex: 0; padding: 5px 10px; border-color: var(--neon-red); color: var(--neon-red);" onclick="Mind.toggleStealth()" title="Hide Signal in Noise">STEALTH</button>
                    <button class="hud-btn" style="flex: 0; padding: 5px 15px; background: var(--neon-cyan); color: #000;" onclick="Mind.consult(document.getElementById('mind-input').value)">SEND</button>
                </div>
            </div>
        </div>

    </div>
</div>

<!-- STYLES FOR EXPERIMENTAL -->
<style>
.hud-btn {
    border: 1px solid var(--neon-cyan);
    padding: 5px 10px;
    font-size: 0.7rem;
    cursor: pointer;
    color: var(--neon-cyan);
    text-align: center;
    background: rgba(0,0,0,0.5);
    flex: 1 1 30%; /* Wrap if needed */
}
.hud-btn:hover { background: var(--neon-cyan); color: #000; }
</style>

</style>

<!-- TACTICAL AR OVERLAY -->
<div id="mind-ar-view" style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; pointer-events: none; z-index: 5;">
    <canvas id="ar-canvas" style="width: 100%; height: 100%;"></canvas>
    <canvas id="vision-overlay-canvas" style="width: 100%; height: 100%; position: absolute; top: 0; left: 0; opacity: 0.7; mix-blend-mode: screen;"></canvas>
</div>

<!-- AR OVERLAY LAYER -->
<div id="ar-overlay" style="display: none; position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; z-index: 5; pointer-events: none;">
    <video id="ar-video" style="width: 100%; height: 100%; object-fit: cover;" autoplay playsinline muted></video>
    <canvas id="ar-canvas" width="1920" height="1080" style="position: absolute; top: 0; left: 0; width: 100%; height: 100%;"></canvas>
</div>

<!-- MODULES -->
<script src="assets/js/modules/webrtc.js"></script>
<script src="assets/js/modules/hardware.js"></script>
<script src="assets/js/modules/sonar.js"></script>
<script src="assets/js/modules/sensors.js"></script>
<script src="assets/js/modules/steganography.js"></script>
<script src="assets/js/modules/audio_intelligence.js"></script>
<script src="assets/js/modules/seismic_intel.js"></script>
<script src="assets/js/modules/bio_sync.js"></script>
<script src="assets/js/modules/tactical_ar.js"></script>
<script src="assets/js/modules/swarm_mesh.js"></script>
<script src="assets/js/modules/skywave_link.js"></script>
<script src="assets/js/modules/mind_link.js"></script>
<script src="assets/js/modules/mesh_forge.js"></script>
<script src="assets/js/modules/kinetic_security.js"></script>
<script src="assets/js/modules/power_autonomy.js"></script>
<script src="assets/js/modules/rf_compass.js"></script>
<script src="assets/js/modules/wifi_sensing.js"></script>
<script src="assets/js/modules/mind.js"></script>
<script src="assets/js/modules/deaddrop.js"></script>
<script src="assets/js/modules/panic.js"></script>
<script src="assets/js/modules/ai_lite.js"></script>
<script src="assets/js/modules/offline_maps.js"></script>
<script src="assets/js/modules/resources.js"></script>

<script type="module">
    import { initMesh } from './assets/js/modules/mesh.js';
    import { initUI } from './assets/js/modules/ui.js';
    
    // UI Helpers for Clock
    function updateClock() {
        const now = new Date();
        document.getElementById('clock').innerText = now.toLocaleTimeString();
    }
    setInterval(updateClock, 1000);
    updateClock();

    document.addEventListener('DOMContentLoaded', () => {
        initUI(); // Initialize UI helpers
        initMesh(); // Start Mesh Protocol
        
        // Init Experimental Modules
        setTimeout(() => {
            if(window.WebRTC) WebRTC.init();
            if(window.Hardware) Hardware.init();
            if(window.Sonar) Sonar.init();
            if(window.Sensors) Sensors.init();
            if(window.Steganography) Steganography.init();
            if(window.DeadDrop) DeadDrop.init();
            if(window.Panic) Panic.init();
            if(window.AILite) AILite.init();
            if(window.OfflineMaps) OfflineMaps.init();
            if(window.Resources) Resources.init();
            if(window.AudioIntelligence) AudioIntelligence.init();
            if(window.SeismicIntel) SeismicIntel.init();
            if(window.BioSync) BioSync.init();
            if(window.TacticalAR) TacticalAR.init();
        }, 1000);
        
        // Expose UI Helpers for new buttons (Quick Hack)
        window.UI.toggleDeadDrop = () => {
            const pwd = prompt("ENTER SAFE PASSWORD:");
            if(!pwd) return;
            const action = confirm("LOAD (OK) or SAVE (Cancel)?");
            if(action) {
                DeadDrop.load("NOTES", pwd).then(t => alert(t ? "CONTENT:\n" + t : "DECRYPT FAIL"));
            } else {
                const data = prompt("ENTER SECRET DATA:");
                if(data) DeadDrop.save("NOTES", data, pwd);
            }
        };
        
        window.UI.toggleStego = () => {
            alert("FEATURE: Drop image in Chat to decode, or use Console: Steganography.encode(file, 'text')");
        };

        window.UI.toggleMind = () => {
            const modal = document.getElementById('mind-modal');
            modal.style.display = (modal.style.display === 'none') ? 'flex' : 'none';
        };
    });
</script>

<style>
@keyframes blink { 0% { opacity: 1; } 50% { opacity: 0; } 100% { opacity: 1; } }
</style>

</body>
</html>
