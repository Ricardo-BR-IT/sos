<?php
// SOS AEON: PROPHECY MATRIX (V18)
// DETAILED PROTOCOLS & FUTURE ROADMAP
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SOS PROPHECY MATRIX</title>
    <link rel="stylesheet" href="assets/css/aeon.css">
    <style>
        .matrix-table {
            width: 100%;
            border-collapse: collapse;
            font-family: var(--font-code);
            font-size: 0.70rem;
            color: #fff;
            white-space: nowrap;
        }
        .matrix-table th {
            text-align: center;
            padding: 10px 5px;
            border-bottom: 2px solid var(--neon-cyan);
            background: rgba(0, 20, 20, 0.95);
            position: sticky;
            top: 0;
            z-index: 10;
            writing-mode: vertical-rl;
            transform: rotate(180deg);
            height: 120px;
        }
        .matrix-table th:first-child {
            writing-mode: horizontal-tb;
            transform: none;
            text-align: left;
            width: 250px;
            background: #000;
            z-index: 20;
            left: 0;
            position: sticky;
        }
        .matrix-table td {
            padding: 8px 5px;
            border-bottom: 1px solid #333;
            border-right: 1px solid #222;
            text-align: center;
        }
        .matrix-table td:first-child {
            text-align: left;
            position: sticky;
            left: 0;
            background: rgba(0, 10, 10, 0.95);
            border-right: 2px solid var(--neon-cyan);
            z-index: 15;
            font-weight: bold;
            color: var(--neon-green);
        }
        .matrix-table tr:hover td {
            background: rgba(0, 255, 255, 0.1) !important;
        }
        .cat-row td {
            background: rgba(0, 255, 0, 0.15) !important;
            font-weight: bold;
            color: #fff;
            text-transform: uppercase;
            letter-spacing: 2px;
            text-align: left;
            padding: 15px 10px;
        }
        .future-row td {
            background: rgba(138, 43, 226, 0.15) !important; /* Purple for Future */
            color: #d8b4fe;
            border-left: 5px solid #8a2be2;
        }
        .check { color: #0f0; }
        .cross { color: #555; opacity: 0.5; }
        .partial { color: #ff0; }
        .planned { color: #d8b4fe; text-shadow: 0 0 5px #8a2be2; } /* Purple Neon */
        .note { font-size: 0.6rem; color: #aaa; display: block; }
    </style>
</head>
<body>

<div class="app-shell">
    <?php include 'includes/sidebar.php'; ?>

    <div class="main-content" style="padding: 0; overflow-y: hidden; display: flex; flex-direction: column;">
        
        <div style="padding: 20px; flex-shrink: 0;">
            <h1 class="neon-text-red" style="font-family: var(--font-code); margin: 0;">OPERATION PROPHECY</h1>
            <p style="color: var(--text-dim); font-family: var(--font-code); font-size: 0.8rem; margin: 5px 0;">
                DETAILED PROTOCOLS & FUTURE ROADMAP [V15 -> V20+]
            </p>
        </div>

        <div style="flex-grow: 1; overflow: auto; padding-bottom: 50px;">
            <table class="matrix-table">
                <thead>
                    <tr>
                        <th>PROTOCOL / TECHNOLOGY</th>
                        <th>WINDOWS<br><span class="note">DOCKER/WEB</span></th>
                        <th>LINUX<br><span class="note">NATIVE</span></th>
                        <th>ANDROID<br><span class="note">TERMUX/APK</span></th>
                        <th>iOS<br><span class="note">PWA/WEB</span></th>
                        <th>JAVA<br><span class="note">WRAPPER</span></th>
                        <th>TV BOX<br><span class="note">ANDROID</span></th>
                        <th>SMART TV<br><span class="note">BROWSER</span></th>
                        <th>WATCH<br><span class="note">LITE</span></th>
                        <th>ROUTER<br><span class="note">OPENWRT</span></th>
                        <th>ROMs/ISOs<br><span class="note">INSTALLER</span></th>
                    </tr>
                </thead>
                <tbody>
                    <!-- CURRENT: CORE KERNEL -->
                    <tr class="cat-row"><td colspan="11">CORE KERNEL (ACTIVE)</td></tr>
                    <tr>
                        <td>PHP 8.2 Engine</td>
                        <td class="check">✅</td><td class="check">✅</td><td class="check">✅</td><td class="cross">❌</td><td class="partial">⚠️</td><td class="check">✅</td><td class="cross">❌</td><td class="cross">❌</td><td class="partial">⚠️</td><td class="check">✅</td>
                    </tr>
                    <tr>
                        <td>HTTP/2 Transport</td>
                        <td class="check">✅</td><td class="check">✅</td><td class="check">✅</td><td class="check">✅</td><td class="check">✅</td><td class="check">✅</td><td class="check">✅</td><td class="partial">⚠️</td><td class="check">✅</td><td class="check">✅</td>
                    </tr>
                    <tr>
                        <td>Async Polling (AJAX)</td>
                        <td class="check">✅</td><td class="check">✅</td><td class="check">✅</td><td class="check">✅</td><td class="check">✅</td><td class="check">✅</td><td class="check">✅</td><td class="check">✅</td><td class="cross">❌</td><td class="check">✅</td>
                    </tr>
                    <tr>
                        <td>Service Workers (Cache)</td>
                        <td class="check">✅</td><td class="check">✅</td><td class="check">✅</td><td class="check">✅</td><td class="check">✅</td><td class="check">✅</td><td class="partial">⚠️</td><td class="cross">❌</td><td class="cross">❌</td><td class="cross">❌</td>
                    </tr>

                    <!-- CURRENT: CRYPTO & SECURITY -->
                    <tr class="cat-row"><td colspan="11">SECURITY (AES-256-GCM)</td></tr>
                    <tr>
                        <td>AES-256-GCM (OpenSSL)</td>
                        <td class="check">✅</td><td class="check">✅</td><td class="check">✅</td><td class="check">✅</td><td class="check">✅</td><td class="check">✅</td><td class="check">✅</td><td class="cross">❌</td><td class="partial">⚠️</td><td class="check">✅</td>
                    </tr>
                    <tr>
                        <td>TLS 1.3 Strict</td>
                        <td class="check">✅</td><td class="check">✅</td><td class="check">✅</td><td class="check">✅</td><td class="check">✅</td><td class="check">✅</td><td class="check">✅</td><td class="partial">⚠️</td><td class="partial">⚠️</td><td class="check">✅</td>
                    </tr>
                     <tr>
                        <td>WAF (Anti-DDoS Logic)</td>
                        <td class="check">✅</td><td class="check">✅</td><td class="check">✅</td><td class="cross">❌</td><td class="check">✅</td><td class="check">✅</td><td class="cross">❌</td><td class="cross">❌</td><td class="check">✅</td><td class="check">✅</td>
                    </tr>

                    <!-- CURRENT: MESH -->
                    <tr class="cat-row"><td colspan="11">MESH NETWORKING</td></tr>
                    <tr>
                        <td>802.11s (Layer 2)</td>
                        <td class="cross">❌</td><td class="check">✅</td><td class="cross">❌</td><td class="cross">❌</td><td class="cross">❌</td><td class="cross">❌</td><td class="cross">❌</td><td class="cross">❌</td><td class="check">✅</td><td class="check">✅</td>
                    </tr>
                    <tr>
                        <td>mDNS Discovery</td>
                        <td class="check">✅</td><td class="check">✅</td><td class="check">✅</td><td class="check">✅</td><td class="check">✅</td><td class="check">✅</td><td class="cross">❌</td><td class="cross">❌</td><td class="check">✅</td><td class="check">✅</td>
                    </tr>

                    <!-- FUTURE ROADMAP -->
                    <tr class="cat-row future-row"><td colspan="11">🔮 THE PROPHECY (PLANNED / NOT DEVELOPED)</td></tr>
                    
                    <tr>
                        <td>LoRaWAN Bridge (915MHz)</td>
                        <td class="planned">🔮</td><td class="planned">🔮</td><td class="planned">🔮</td><td class="cross">❌</td><td class="planned">🔮</td><td class="planned">🔮</td><td class="cross">❌</td><td class="cross">❌</td><td class="planned">🔮</td><td class="planned">🔮</td>
                    </tr>
                     <tr>
                        <td>WebRTC Voice (P2P Call)</td>
                        <td class="planned">🔮</td><td class="planned">🔮</td><td class="planned">🔮</td><td class="planned">🔮</td><td class="planned">🔮</td><td class="planned">🔮</td><td class="planned">🔮</td><td class="cross">❌</td><td class="cross">❌</td><td class="planned">🔮</td>
                    </tr>
                    <tr>
                        <td>Offline AI (WebLLM WASM)</td>
                        <td class="planned">🔮</td><td class="planned">🔮</td><td class="planned">🔮</td><td class="planned">🔮</td><td class="planned">🔮</td><td class="planned">🔮</td><td class="cross">❌</td><td class="cross">❌</td><td class="cross">❌</td><td class="planned">🔮</td>
                    </tr>
                    <tr>
                        <td>IPFS Distributed Storage</td>
                         <td class="planned">🔮</td><td class="planned">🔮</td><td class="planned">🔮</td><td class="planned">🔮</td><td class="planned">🔮</td><td class="planned">🔮</td><td class="cross">❌</td><td class="cross">❌</td><td class="planned">🔮</td><td class="planned">🔮</td>
                    </tr>
                    <tr>
                        <td>Satellite Uplink (Iridium)</td>
                         <td class="planned">🔮</td><td class="planned">🔮</td><td class="planned">🔮</td><td class="cross">❌</td><td class="planned">🔮</td><td class="planned">🔮</td><td class="cross">❌</td><td class="cross">❌</td><td class="planned">🔮</td><td class="planned">🔮</td>
                    </tr>
                     <tr>
                        <td>Blockchain Identity (SSI)</td>
                         <td class="planned">🔮</td><td class="planned">🔮</td><td class="planned">🔮</td><td class="planned">🔮</td><td class="planned">🔮</td><td class="planned">🔮</td><td class="cross">❌</td><td class="cross">❌</td><td class="cross">❌</td><td class="planned">🔮</td>
                    </tr>
                    <tr>
                        <td>Meshtastic Integration</td>
                         <td class="planned">🔮</td><td class="planned">🔮</td><td class="planned">🔮</td><td class="planned">🔮</td><td class="planned">🔮</td><td class="planned">🔮</td><td class="cross">❌</td><td class="cross">❌</td><td class="planned">🔮</td><td class="planned">🔮</td>
                    </tr>

                </tbody>
            </table>
        </div>

    </div>
</div>

</body>
</html>
