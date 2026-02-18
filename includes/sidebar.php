<div class="sidebar">
    <div style="font-family: 'JetBrains Mono'; font-weight: bold; color: var(--neon-cyan); margin-bottom: 30px; font-size: 1.5rem;">S</div>
    
    <a href="index.php" class="nav-item">
        <span class="icon">⌖</span>
        <span class="label">COMMAND</span>
    </a>
    
    <a href="prep.php" class="nav-item">
        <span class="icon">⍰</span>
        <span class="label">LOGISTICS</span>
    </a>
    
    <a href="monitor.php" class="nav-item">
        <span class="icon">⚠️</span>
        <span class="label">WATCHTOWER</span>
    </a>
    
    <a href="matrix.php" class="nav-item">
        <span class="icon">☷</span>
        <span class="label">TECH DECK</span>
    </a>

    <a href="profile.php" class="nav-item">
        <span class="icon">👤</span>
        <span class="label">PROFILE</span>
    </a>

    <a href="firmware.php" class="nav-item">
        <span class="icon">🔥</span>
        <span class="label">FOUNDRY</span>
    </a>

    <a href="upgrade.php" class="nav-item">
        <span class="icon">🧬</span>
        <span class="label">EVOLUTION</span>
    </a>

    <a href="#" id="pwa-install-btn" class="nav-item" style="display: none;">
        <span class="icon">⬇️</span>
        <span class="label">INSTALL APP</span>
    </a>

    <a href="versions.php" class="nav-item">
        <span class="icon">📜</span>
        <span class="label">LEDGER</span>
    </a>

    <div style="flex: 1;"></div>
    
    <div class="nav-item" style="font-size: 0.7rem; color: #555;">
        <span class="icon">V15</span>
        <span class="label">AEON OS</span>
    </div>
</div>

<script>
    // Active State
    document.querySelectorAll('.nav-item').forEach(link => {
        if (link.href === window.location.href) {
            link.classList.add('active');
        }
    });
</script>
