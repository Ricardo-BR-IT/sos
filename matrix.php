<?php
// SOS AEON: TECH DECK (V9)
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SOS TECH DECK [AEON]</title>
    <link rel="stylesheet" href="assets/css/aeon.css">
</head>
<body>

<div class="app-shell">
    <?php include 'includes/sidebar.php'; ?>

    <div class="main-content" style="padding: 40px; overflow-y: auto;">
        
        <h1 class="neon-text-cyan" style="font-family: var(--font-code); margin-bottom: 20px;">TECHNOLOGY MATRIX</h1>
        
        <div class="hud-panel">
            <div class="hud-title">SYSTEM INTEROPERABILITY TABLE</div>
            
            <table style="width: 100%; border-collapse: collapse; margin-top: 20px; font-family: var(--font-code); font-size: 0.9rem;">
                <thead>
                    <tr style="border-bottom: 1px solid var(--neon-cyan); color: var(--neon-cyan); text-align: left;">
                        <th style="padding: 15px;">PLATFORM</th>
                        <th>VERSION</th>
                        <th>PROTOCOL</th>
                        <th>CAPABILITIES</th>
                        <th>INTEROP</th>
                        <th>STATUS</th>
                    </tr>
                </thead>
                <tbody id="matrix-body">
                    <!-- Populated via JS -->
                </tbody>
            </table>
        </div>

    </div>
</div>

<script>
    fetch('assets/data/matrix.json')
        .then(res => res.json())
        .then(data => {
            const tbody = document.getElementById('matrix-body');
            data.forEach(item => {
                const tr = document.createElement('tr');
                tr.style.borderBottom = '1px solid rgba(255,255,255,0.1)';
                
                let statusColor = item.status === 'ACTIVE' ? 'var(--neon-green)' : (item.status === 'LEGACY' ? 'var(--neon-cyan)' : '#888');
                
                tr.innerHTML = `
                    <td style="padding: 15px; font-weight: bold; color: #fff;">${item.platform}</td>
                    <td>${item.version}</td>
                    <td>${item.protocol}</td>
                    <td>${item.capabilities.join(', ')}</td>
                    <td>${item.interop.join(', ')}</td>
                    <td style="color: ${statusColor}; text-shadow: 0 0 5px ${statusColor};">${item.status}</td>
                `;
                tbody.appendChild(tr);
            });
        });
</script>

</body>
</html>
