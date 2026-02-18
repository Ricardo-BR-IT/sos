<header style="border-bottom: 1px solid var(--terminal-green); padding: 5px 10px; display: flex; justify-content: space-between; align-items: center; background: #000;">
    <div style="font-size: 1.2rem; font-weight: bold; display: flex; align-items: center; gap: 15px;">
        <span>SOS <span style="color: #fff;">OMEGA</span></span>
        
        <nav style="font-size: 0.9rem;">
            <a href="index.php" class="nav-link">[COMMAND]</a>
            <a href="prep.php" class="nav-link">[LOGISTICS]</a>
            <a href="monitor.php" class="nav-link">[WATCHTOWER]</a>
            <a href="matrix.php" class="nav-link">[TECH DECK]</a>
        </nav>
    </div>
    <div id="clock">00:00:00</div>
</header>

<style>
    .nav-link {
        color: var(--terminal-green);
        text-decoration: none;
        margin-right: 15px;
        opacity: 0.7;
        transition: opacity 0.2s;
    }
    .nav-link:hover, .nav-link.active {
        opacity: 1;
        text-shadow: 0 0 5px var(--terminal-green);
        border-bottom: 1px solid var(--terminal-green);
    }
</style>

<script>
    // Simple Active State
    document.querySelectorAll('.nav-link').forEach(link => {
        if (link.href === window.location.href) {
            link.classList.add('active');
        }
    });
</script>
