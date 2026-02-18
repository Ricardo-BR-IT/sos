<?php
// SOS AEON: WATCHTOWER (V9)
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SOS WATCHTOWER [AEON]</title>
    <link rel="stylesheet" href="assets/css/aeon.css">
    
    <!-- LEAFLET JS -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" 
          integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" 
          crossorigin=""/>
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" 
            integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" 
            crossorigin=""></script>

    <style>
        .leaflet-container { background: #000; }
        .alert-bar {
            background: rgba(20, 0, 0, 0.8);
            border-bottom: 1px solid var(--neon-red);
            color: var(--neon-red);
            padding: 10px;
            font-family: var(--font-code);
            font-weight: bold;
            display: flex;
            align-items: center;
        }
        .alert-ticker {
            white-space: nowrap;
            overflow: hidden;
            margin-left: 20px;
            animation: ticker 20s linear infinite;
        }
        @keyframes ticker { 0% { transform: translateX(100%); } 100% { transform: translateX(-100%); } }
    </style>
</head>
<body>

<div class="app-shell">
    <?php include 'includes/sidebar.php'; ?>

    <div class="main-content" style="display: flex; flex-direction: column;">
        
        <!-- ALERT BAR OVERLAY -->
        <div class="alert-bar">
            <span>⚠️ GLOBAL HAZARD FEED</span>
            <div id="ticker" class="alert-ticker">SCANNING...</div>
        </div>

        <!-- FULL MAP -->
        <div id="map" style="flex: 1; z-index: 0;"></div>
        
    </div>
</div>

<script>
    // 1. Initialize Map
    const map = L.map('map').setView([-14.2350, -51.9253], 4); 

    // Dark Map Tiles
    L.tileLayer('https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png', {
        attribution: '&copy; CARTO',
        subdomains: 'abcd',
        maxZoom: 19
    }).addTo(map);

    // 2. Fetch Hazards
    fetch('api/proxy_alerts.php')
        .then(res => res.json())
        .then(data => {
            const ticker = document.getElementById('ticker');
            
            if (data.alerts && data.alerts.length > 0) {
                let alertText = data.alerts.map(a => `[${a.type}] ${a.title}`).join(' /// ');
                ticker.innerText = alertText;
                
                // Plot Markers
                data.alerts.forEach(a => {
                    let color = a.level === 'CRITICAL' ? '#ff0055' : '#ffaa00';
                    
                    L.circleMarker([a.lat, a.lng], {
                        radius: 8,
                        fillColor: color,
                        color: "#fff",
                        weight: 1,
                        opacity: 1,
                        fillOpacity: 0.8
                    }).addTo(map)
                    .bindPopup(`<strong style="color:#000">${a.type}</strong><br><span style="color:#000">${a.title}</span>`);
                });
            } else {
                ticker.innerText = "NO ACTIVE GLOBAL THREATS DETECTED";
                ticker.style.color = "var(--neon-green)";
            }
        });
</script>

</body>
</html>
