<?php

declare(strict_types=1);

require_once __DIR__ . '/includes/lang_bootstrap.php';
$bootstrapJson = htmlspecialchars(sos_bootstrap_json(), ENT_QUOTES, 'UTF-8');
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Operator Profile</title>
    <link rel="stylesheet" href="assets/css/portal.css">
    <style>
        .profile-wrap {
            max-width: 760px;
            margin: 0 auto;
        }

        .form-grid {
            display: grid;
            gap: 12px;
            margin-top: 14px;
        }

        .field {
            border: 1px solid var(--edge);
            border-radius: 12px;
            padding: 12px;
            background: rgba(255, 255, 255, 0.04);
        }

        .field label {
            display: block;
            margin-bottom: 6px;
            color: var(--ink-muted);
            font-family: 'IBM Plex Mono', monospace;
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.08em;
        }

        .field-value {
            font-family: 'IBM Plex Mono', monospace;
            word-break: break-all;
        }

        .toggle-line {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            align-items: center;
        }

        .status-msg {
            margin-top: 12px;
            min-height: 18px;
            color: var(--ink-muted);
        }
    </style>
</head>
<body data-bootstrap="<?= $bootstrapJson ?>">
<div class="page profile-wrap">
    <header class="topbar">
        <div class="brand">
            <div class="eyebrow">SOS / PROFILE</div>
            <h1 data-i18n="profile_title">Operator Profile</h1>
            <p data-i18n="profile_subtitle">Persist operational preferences on this device and on the server profile.</p>
        </div>
        <div class="topbar-controls">
            <a class="pill" href="index.php" data-i18n="profile_back">Back to portal</a>
        </div>
    </header>

    <section class="panel">
        <div class="form-grid">
            <div class="field">
                <label data-i18n="profile_node">Node ID</label>
                <div id="nodeValue" class="field-value">--</div>
            </div>

            <div class="field">
                <div class="toggle-line">
                    <label style="margin: 0" data-i18n="profile_gps">Broadcast location</label>
                    <input type="checkbox" id="gpsToggle">
                </div>
                <p class="panel-subtitle" data-i18n="profile_gps_help">When enabled, coordinates are published to mesh peers for distance and routing awareness.</p>
            </div>

            <div class="field">
                <label for="langSelect" data-i18n="profile_language">Preferred language</label>
                <select id="langSelect" class="select-control" style="width: 100%; border-radius: 10px;">
                    <option value="en">English</option>
                    <option value="pt">Portugues</option>
                    <option value="es">Espanol</option>
                    <option value="fr">Francais</option>
                    <option value="de">Deutsch</option>
                    <option value="ar">العربية</option>
                    <option value="ru">Русский</option>
                    <option value="zh">中文</option>
                </select>
            </div>
        </div>

        <div class="action-row">
            <button class="btn" id="saveBtn" data-i18n="profile_save">Save profile</button>
        </div>
        <div class="status-msg" id="saveMsg"></div>
    </section>
</div>

<script type="module">
    import {
        createOrGetNodeId,
        onLanguageChange,
        resolveInitialLanguage,
        setLanguage,
        t,
    } from './assets/js/modules/i18n.js';

    const bootstrap = JSON.parse(document.body.dataset.bootstrap || '{"language":"en","country":null}');
    const nodeId = createOrGetNodeId();
    const gpsKey = 'v11_gps_active';

    const nodeValue = document.getElementById('nodeValue');
    const gpsToggle = document.getElementById('gpsToggle');
    const langSelect = document.getElementById('langSelect');
    const saveBtn = document.getElementById('saveBtn');
    const saveMsg = document.getElementById('saveMsg');

    nodeValue.textContent = nodeId;
    gpsToggle.checked = localStorage.getItem(gpsKey) === 'true';

    function showMessage(key, fallback, isError = false) {
        saveMsg.textContent = t(key, fallback);
        saveMsg.style.color = isError ? 'var(--accent-red)' : 'var(--accent-cyan)';
    }

    onLanguageChange((lang) => {
        langSelect.value = lang;
    });

    saveBtn.addEventListener('click', async () => {
        localStorage.setItem(gpsKey, String(gpsToggle.checked));

        try {
            await setLanguage(langSelect.value, {
                persist: true,
                nodeId,
                country: bootstrap.country || null,
            });
            showMessage('profile_saved', 'Saved and synchronized.');
        } catch (_) {
            showMessage('profile_sync_error', 'Saved locally, but server sync failed.', true);
        }

        setTimeout(() => {
            saveMsg.textContent = '';
        }, 2600);
    });

    (async () => {
        const initial = await resolveInitialLanguage({
            nodeId,
            serverHintLang: bootstrap.language || 'en',
            serverHintCountry: bootstrap.country || null,
            navigatorLang: navigator.language,
        });

        await setLanguage(initial.language, {
            persist: true,
            nodeId,
            country: initial.country || bootstrap.country || null,
        });

        langSelect.value = initial.language;
    })();
</script>
</body>
</html>
