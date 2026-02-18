<?php
// SOS AEON: LOGISTICS (V9)
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SOS LOGISTICS [AEON]</title>
    <link rel="stylesheet" href="assets/css/aeon.css">
    <style>
        .tab-btn {
            background: transparent;
            color: var(--text-dim);
            border: 1px solid transparent;
            padding: 10px 20px;
            cursor: pointer;
            font-family: var(--font-code);
            border-bottom: 2px solid transparent;
        }
        .tab-btn:hover { color: #fff; }
        .tab-btn.active {
            color: var(--neon-cyan);
            border-bottom: 2px solid var(--neon-cyan);
        }
        .tab-content { display: none; padding-top: 20px; }
        .tab-content.active { display: block; animation: fadeIn 0.3s; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
        
        .checklist-item {
            display: flex;
            align-items: center;
            padding: 10px;
            background: rgba(255,255,255,0.05);
            margin-bottom: 5px;
            border-radius: 4px;
        }
        .checklist-item:hover { background: rgba(0, 243, 255, 0.1); }
        .checklist-item input { margin-right: 15px; width: 18px; height: 18px; accent-color: var(--neon-cyan); }
    </style>
</head>
<body>

<div class="app-shell">
    <?php include 'includes/sidebar.php'; ?>

    <div class="main-content" style="padding: 40px; overflow-y: auto;">
        
        <h1 class="neon-text-green" style="font-family: var(--font-code); margin-bottom: 20px;">LOGISTICS CENTER</h1>
        
        <!-- TABS -->
        <div style="border-bottom: 1px solid rgba(255,255,255,0.1); margin-bottom: 20px;">
            <button class="tab-btn active" onclick="openTab('kits')">SURVIVAL KITS</button>
            <button class="tab-btn" onclick="openTab('library')">DIGITAL ARK</button>
            <button class="tab-btn" onclick="openTab('calcs')">CALCULATORS</button>
        </div>
        
        <!-- 1. KITS TAB -->
        <div id="kits" class="tab-content active">
            <div class="hud-panel">
                <div class="hud-title">72-HOUR BUG-OUT BAG</div>
                <div id="bob-list" style="margin-top: 15px;">
                    <!-- Populated via JS -->
                </div>
            </div>
        </div>
        
        <!-- 2. LIBRARY TAB -->
        <div id="library" class="tab-content">
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                <div class="hud-panel">
                    <div class="hud-title">OPERATING SYSTEMS</div>
                    <ul style="list-style: none; padding: 0;">
                        <li style="margin-bottom: 10px;"><a href="#" class="btn-aeon" style="display: block; text-align: center;">⬇ SOS Linux v8.iso</a></li>
                        <li><a href="#" class="btn-aeon" style="display: block; text-align: center;">⬇ Raspberry Pi Image</a></li>
                    </ul>
                </div>
                <div class="hud-panel">
                    <div class="hud-title">MANUALS</div>
                    <ul style="list-style: none; padding: 0;">
                        <li style="margin-bottom: 10px;"><a href="#" style="color: var(--text-main); text-decoration: none;">📄 US Army First Aid</a></li>
                        <li style="margin-bottom: 10px;"><a href="#" style="color: var(--text-main); text-decoration: none;">📄 Water Filtration Guide</a></li>
                    </ul>
                </div>
            </div>
        </div>
        
        <!-- 3. CALCS TAB -->
        <div id="calcs" class="tab-content">
            <div class="hud-panel" style="max-width: 400px;">
                <div class="hud-title">RATIONING CALCULATOR</div>
                
                <div style="margin: 15px 0;">
                    <label>PEOPLE</label>
                    <input type="number" id="calc-people" class="input-aeon" value="1">
                </div>
                
                <div style="margin: 15px 0;">
                    <label>DAYS</label>
                    <input type="number" id="calc-days" class="input-aeon" value="3">
                </div>
                
                <button onclick="calculateRations()" class="btn-aeon" style="width: 100%;">CALCULATE SUPPLY</button>
                
                <div id="calc-result" style="margin-top: 20px; border-top: 1px solid #333; padding-top: 10px; display: none;">
                    <!-- Results here -->
                </div>
            </div>
        </div>
        
    </div>
</div>

<script src="assets/js/modules/prep.js" type="module"></script>
<script>
    window.openTab = function(tabName) {
        document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
        document.querySelectorAll('.tab-btn').forEach(el => el.classList.remove('active'));
        
        document.getElementById(tabName).classList.add('active');
        event.currentTarget.classList.add('active');
    }
</script>

</body>
</html>
