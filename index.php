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
    <title>SOS Command Portal</title>
    <link rel="manifest" href="manifest.json">
    <link rel="stylesheet" href="assets/css/portal.css">
</head>
<body data-bootstrap="<?= $bootstrapJson ?>">
<div class="page">
    <header class="topbar">
        <div class="brand">
            <div class="eyebrow">SOS / OPS MATRIX</div>
            <h1 data-i18n="hero_title">Emergency Network Control Center</h1>
            <p data-i18n="hero_subtitle">This portal consolidates app builds, transport matrix, version records, and community preparedness playbooks.</p>
        </div>
        <div class="topbar-controls">
            <label class="pill" for="langSelect"><span data-i18n="lang_label">Language</span></label>
            <select id="langSelect" class="select-control">
                <option value="en">English</option>
                <option value="pt">Português</option>
                <option value="es">Español</option>
                <option value="fr">Français</option>
                <option value="de">Deutsch</option>
                <option value="ar">العربية</option>
                <option value="ru">Русский</option>
                <option value="zh">中文</option>
            </select>
        </div>
    </header>

    <div class="layout">
        <section class="panel">
            <h2 data-i18n="app_name">SOS Command Portal</h2>
            <p class="panel-subtitle" data-i18n="app_tagline">Crisis-ready operations, downloads, and preparedness in one place.</p>

            <div class="hero-grid">
                <article class="stat">
                    <div class="label" data-i18n="status_api">API status</div>
                    <div class="value"><span id="apiDot" class="dot"></span> <span id="apiStatusText" data-i18n="loading">Loading...</span></div>
                </article>
                <article class="stat">
                    <div class="label" data-i18n="status_manifest">Artifact manifest</div>
                    <div class="value"><span id="manifestDot" class="dot"></span> <span id="manifestStatusText" data-i18n="loading">Loading...</span></div>
                </article>
                <article class="stat">
                    <div class="label" data-i18n="status_node">Node ID</div>
                    <div class="value" id="nodeValue">--</div>
                </article>
                <article class="stat">
                    <div class="label" data-i18n="status_country">Detected country</div>
                    <div class="value" id="countryValue">--</div>
                </article>
            </div>

            <div class="section">
                <h3 data-i18n="downloads_title">App Catalog and Downloads</h3>
                <p data-i18n="downloads_subtitle">Edition bundles are generated locally and published with SHA-256 checksums.</p>
                <div class="action-row">
                    <button class="btn" id="refreshBtn" data-i18n="downloads_refresh">Refresh data</button>
                </div>
                <div class="download-toolbar">
                    <div id="downloadFilters" class="download-filters"></div>
                </div>
                <p class="panel-subtitle"><span data-i18n="downloads_last_update">Last update</span>: <strong id="manifestTimestamp">--</strong></p>
                <div id="downloadsList" class="download-list"></div>
            </div>

            <div class="section">
                <h3 data-i18n="matrix_title">Technology Matrix</h3>
                <p data-i18n="matrix_subtitle">Live matrix data from assets/data/matrix.json with implementation status per platform.</p>
                <div class="table-wrap">
                    <table class="matrix-table">
                        <thead>
                        <tr>
                            <th data-i18n="matrix_platform">Platform</th>
                            <th data-i18n="matrix_version">Version</th>
                            <th data-i18n="matrix_protocol">Protocol</th>
                            <th data-i18n="matrix_capabilities">Capabilities</th>
                            <th data-i18n="matrix_interop">Interop</th>
                            <th data-i18n="matrix_status">Status</th>
                        </tr>
                        </thead>
                        <tbody id="matrixBody"></tbody>
                    </table>
                </div>
            </div>
        </section>

        <aside class="panel">
            <section class="section">
                <h3 data-i18n="versions_title">Versions and Legacy Pages</h3>
                <p data-i18n="versions_subtitle">Manifest timestamp plus direct access to legacy operational pages.</p>
                <p class="panel-subtitle"><span data-i18n="versions_manifest">Manifest generated at</span>: <strong id="versionsManifest">--</strong></p>
                <p class="panel-subtitle" data-i18n="versions_legacy_links">Legacy modules</p>
                <div class="links">
                    <a href="matrix.php" data-i18n="legacy_matrix">Matrix (legacy page)</a>
                    <a href="versions.php" data-i18n="legacy_versions">Versions ledger</a>
                    <a href="firmware.php" data-i18n="legacy_firmware">Firmware foundry</a>
                    <a href="monitor.php" data-i18n="legacy_monitor">Watchtower monitor</a>
                    <a href="prep.php" data-i18n="legacy_prep">Preparation page</a>
                    <a href="profile.php" data-i18n="profile_title">Operator Profile</a>
                </div>
            </section>

            <section class="section">
                <h3 data-i18n="prep_title">Preparedness Guide (FEMA/Ready-Inspired)</h3>
                <p data-i18n="prep_subtitle">Operational steps by scenario for flood, fire, earthquake, storm, evacuation, sheltering, communications, mental health, and recovery.</p>
                <div id="scenarioGrid" class="scenario-grid"></div>
            </section>

            <section class="section">
                <h3 data-i18n="refs_title">Official References</h3>
                <p data-i18n="refs_subtitle">Use these sources for authoritative guidance and updates.</p>
                <div id="refList" class="refs"></div>
            </section>
        </aside>
    </div>

    <p class="footer-note" data-i18n="footer_text">Initial language uses location hints when available. Your preference is stored locally and synced by Node ID.</p>
</div>

<script type="module">
    import {
        applyTranslations,
        createOrGetNodeId,
        onLanguageChange,
        resolveInitialLanguage,
        setLanguage,
        t,
    } from './assets/js/modules/i18n.js';

    const bootstrap = JSON.parse(document.body.dataset.bootstrap || '{"language":"en","country":null}');
    const nodeId = createOrGetNodeId();

    const apiDot = document.getElementById('apiDot');
    const apiStatusText = document.getElementById('apiStatusText');
    const manifestDot = document.getElementById('manifestDot');
    const manifestStatusText = document.getElementById('manifestStatusText');

    const nodeValue = document.getElementById('nodeValue');
    const countryValue = document.getElementById('countryValue');
    const langSelect = document.getElementById('langSelect');

    const downloadsList = document.getElementById('downloadsList');
    const downloadFiltersEl = document.getElementById('downloadFilters');
    const manifestTimestamp = document.getElementById('manifestTimestamp');
    const versionsManifest = document.getElementById('versionsManifest');
    const matrixBody = document.getElementById('matrixBody');
    const scenarioGrid = document.getElementById('scenarioGrid');
    const refList = document.getElementById('refList');

    nodeValue.textContent = nodeId;
    countryValue.textContent = bootstrap.country || '--';

    const languageNames = {
        en: 'English',
        pt: 'Portugues',
        es: 'Espanol',
        fr: 'Francais',
        de: 'Deutsch',
        ar: 'العربية',
        ru: 'Русский',
        zh: '中文',
    };

    const scenarioConfig = [
        { title: 'scenario_flood_title', steps: 'scenario_flood_steps' },
        { title: 'scenario_fire_title', steps: 'scenario_fire_steps' },
        { title: 'scenario_quake_title', steps: 'scenario_quake_steps' },
        { title: 'scenario_storm_title', steps: 'scenario_storm_steps' },
        { title: 'scenario_evac_title', steps: 'scenario_evac_steps' },
        { title: 'scenario_shelter_title', steps: 'scenario_shelter_steps' },
        { title: 'scenario_comms_title', steps: 'scenario_comms_steps' },
        { title: 'scenario_mental_title', steps: 'scenario_mental_steps' },
        { title: 'scenario_recovery_title', steps: 'scenario_recovery_steps' },
    ];

    const referenceConfig = [
        { key: 'ref_fema_allhazards', url: 'https://www.fema.gov/emergency-managers/practitioners' },
        { key: 'ref_ready_plan', url: 'https://www.ready.gov/plan' },
        { key: 'ref_ready_kit', url: 'https://www.ready.gov/kit' },
        { key: 'ref_ready_flood', url: 'https://www.ready.gov/floods' },
        { key: 'ref_ready_fire', url: 'https://www.ready.gov/wildfires' },
        { key: 'ref_ready_quake', url: 'https://www.ready.gov/earthquakes' },
        { key: 'ref_988', url: 'https://988lifeline.org/' },
    ];

    let manifestCache = null;
    let matrixCache = [];
    let activeDownloadFilter = 'recommended';

    function formatBytes(bytes) {
        if (!Number.isFinite(bytes) || bytes <= 0) return '0 B';
        const units = ['B', 'KB', 'MB', 'GB'];
        const exp = Math.min(Math.floor(Math.log(bytes) / Math.log(1024)), units.length - 1);
        const value = bytes / Math.pow(1024, exp);
        return `${value.toFixed(exp === 0 ? 0 : 2)} ${units[exp]}`;
    }

    function updateStatus(target, label, ok) {
        target.classList.remove('ok', 'fail');
        target.classList.add(ok ? 'ok' : 'fail');
        label.textContent = ok ? t('status_online', 'ONLINE') : t('status_offline', 'OFFLINE');
    }

    async function getJson(url) {
        const response = await fetch(url, { cache: 'no-store' });
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}`);
        }
        return response.json();
    }

    function editionLabel(edition) {
        switch (edition) {
            case 'mini':
                return t('download_section_mini', 'Mini edition');
            case 'standard':
                return t('download_section_standard', 'Standard edition');
            case 'server':
                return t('download_section_server', 'Server edition');
            case 'java':
                return t('download_section_java', 'Java');
            default:
                return edition;
        }
    }

    const downloadKindMeta = {
        desktop: {
            rank: 10,
            labelKey: 'download_windows_portable',
            labelFallback: 'Desktop Windows (Portable ZIP)',
            badgeKey: 'download_badge_windows',
            badgeFallback: 'Windows',
        },
        mobile: {
            rank: 20,
            labelKey: 'download_android_mobile',
            labelFallback: 'Android Mobile',
            badgeKey: 'download_badge_android',
            badgeFallback: 'Android',
        },
        tv: {
            rank: 30,
            labelKey: 'download_android_tv',
            labelFallback: 'Android TV',
            badgeKey: 'download_badge_tv',
            badgeFallback: 'TV',
        },
        wear: {
            rank: 40,
            labelKey: 'download_android_wear',
            labelFallback: 'Wearables',
            badgeKey: 'download_badge_wear',
            badgeFallback: 'Wear',
        },
        java: {
            rank: 50,
            labelKey: 'download_java_runtime',
            labelFallback: 'Java Runtime',
            badgeKey: 'download_badge_java',
            badgeFallback: 'Java',
        },
    };

    const downloadFilterMeta = {
        all: {
            kinds: new Set(['desktop', 'mobile', 'tv', 'wear', 'java']),
            labelKey: 'download_filter_all',
            labelFallback: 'All packages',
        },
        recommended: {
            kinds: new Set(['desktop', 'mobile']),
            labelKey: 'download_filter_recommended',
            labelFallback: 'Recommended',
        },
        desktop: {
            kinds: new Set(['desktop']),
            labelKey: 'download_filter_desktop',
            labelFallback: 'Desktop',
        },
        android: {
            kinds: new Set(['mobile', 'tv', 'wear']),
            labelKey: 'download_filter_android',
            labelFallback: 'Android',
        },
        mobile: {
            kinds: new Set(['mobile']),
            labelKey: 'download_filter_mobile',
            labelFallback: 'Mobile',
        },
        tv: {
            kinds: new Set(['tv']),
            labelKey: 'download_filter_tv',
            labelFallback: 'TV',
        },
        wear: {
            kinds: new Set(['wear']),
            labelKey: 'download_filter_wear',
            labelFallback: 'Wear',
        },
        java: {
            kinds: new Set(['java']),
            labelKey: 'download_filter_java',
            labelFallback: 'Java',
        },
    };

    const downloadFilterOrder = ['all', 'recommended', 'desktop', 'android', 'mobile', 'tv', 'wear', 'java'];

    function artifactMatchesFilter(artifact, filterId) {
        const filter = downloadFilterMeta[filterId] || downloadFilterMeta.all;
        return filter.kinds.has(artifact.kind);
    }

    function renderDownloadFilters(artifacts) {
        if (!downloadFiltersEl) {
            return;
        }

        if (!Array.isArray(artifacts) || artifacts.length === 0) {
            downloadFiltersEl.innerHTML = '';
            activeDownloadFilter = 'all';
            return;
        }

        const counts = {};
        downloadFilterOrder.forEach((filterId) => {
            counts[filterId] = 0;
        });

        artifacts.forEach((artifact) => {
            downloadFilterOrder.forEach((filterId) => {
                if (artifactMatchesFilter(artifact, filterId)) {
                    counts[filterId] += 1;
                }
            });
        });

        const enabledFilters = downloadFilterOrder.filter((filterId) => filterId === 'all' || counts[filterId] > 0);
        if (!enabledFilters.includes(activeDownloadFilter)) {
            activeDownloadFilter = enabledFilters.includes('recommended') ? 'recommended' : 'all';
        }

        downloadFiltersEl.innerHTML = '';
        enabledFilters.forEach((filterId) => {
            const meta = downloadFilterMeta[filterId];
            const button = document.createElement('button');
            button.type = 'button';
            button.className = `download-filter ${activeDownloadFilter === filterId ? 'active' : ''}`;
            button.textContent = `${t(meta.labelKey, meta.labelFallback)} (${counts[filterId]})`;
            button.addEventListener('click', () => {
                activeDownloadFilter = filterId;
                renderDownloads();
            });
            downloadFiltersEl.appendChild(button);
        });
    }

    function classifyArtifact(artifact) {
        const path = String(artifact.path || '');
        const parts = path.split('/').filter(Boolean);
        if (parts.length < 2) {
            return null;
        }

        const edition = parts[0];
        const fileName = parts[parts.length - 1];
        const lower = fileName.toLowerCase();

        if (!(lower.endsWith('.apk') || lower.endsWith('.zip') || lower.endsWith('.jar'))) {
            return null;
        }

        let kind = null;
        if (edition === 'java' || lower.endsWith('.jar')) {
            kind = 'java';
        } else if (/^desktop-.*windows-portable\.zip$/i.test(fileName)) {
            kind = 'desktop';
        } else if (/^mobile-.*\.apk$/i.test(fileName)) {
            kind = 'mobile';
        } else if (/^tv-.*\.apk$/i.test(fileName)) {
            kind = 'tv';
        } else if (/^wear-.*\.apk$/i.test(fileName)) {
            kind = 'wear';
        } else {
            return null;
        }

        return {
            path,
            edition,
            fileName,
            size: Number(artifact.size || 0),
            kind,
            rank: downloadKindMeta[kind].rank,
        };
    }

    function resolveDownloadMeta(artifact) {
        const base = downloadKindMeta[artifact.kind];
        if (!base) {
            return null;
        }

        if (artifact.kind === 'java' && /-java-portable\.zip$/i.test(artifact.fileName)) {
            return {
                ...base,
                labelKey: 'download_java_portable',
                labelFallback: 'Java Portable Bundle (ZIP)',
            };
        }

        return base;
    }

    function renderDownloads() {
        const manifest = manifestCache;
        downloadsList.innerHTML = '';

        if (!manifest || !Array.isArray(manifest.artifacts) || manifest.artifacts.length === 0) {
            downloadsList.innerHTML = `<div class="download-card">${t('downloads_empty', 'No artifacts found in manifest.')}</div>`;
            if (downloadFiltersEl) {
                downloadFiltersEl.innerHTML = '';
            }
            manifestTimestamp.textContent = '--';
            versionsManifest.textContent = '--';
            return;
        }

        manifestTimestamp.textContent = manifest.generatedAt || '--';
        versionsManifest.textContent = manifest.generatedAt || '--';

        const grouped = { mini: [], standard: [], server: [], java: [] };
        let packageCount = 0;
        const allPackages = [];
        for (const artifact of manifest.artifacts) {
            const classified = classifyArtifact(artifact);
            if (!classified) {
                continue;
            }
            if (grouped[classified.edition]) {
                grouped[classified.edition].push(classified);
                packageCount += 1;
                allPackages.push(classified);
            }
        }

        if (packageCount === 0) {
            downloadsList.innerHTML = `<div class="download-card">${t('downloads_empty', 'No artifacts found in manifest.')}</div>`;
            if (downloadFiltersEl) {
                downloadFiltersEl.innerHTML = '';
            }
            return;
        }

        renderDownloadFilters(allPackages);

        const order = ['mini', 'standard', 'server', 'java'];
        let filteredCount = 0;
        order.forEach((edition) => {
            const artifacts = grouped[edition].filter((artifact) => artifactMatchesFilter(artifact, activeDownloadFilter));
            if (!artifacts || artifacts.length === 0) {
                return;
            }

            filteredCount += artifacts.length;
            artifacts.sort((a, b) => (a.rank - b.rank) || a.fileName.localeCompare(b.fileName));

            const card = document.createElement('article');
            card.className = 'download-card';
            card.innerHTML = `
                <h4>${editionLabel(edition)}</h4>
                <p class="download-caption">${t('downloads_release_only', 'Only final install packages are listed in this catalog.')}</p>
            `;

            const list = document.createElement('div');
            list.className = 'download-items';
            artifacts.forEach((artifact) => {
                const meta = resolveDownloadMeta(artifact);
                if (!meta) {
                    return;
                }
                const size = formatBytes(artifact.size);
                const item = document.createElement('article');
                item.className = 'download-item';
                item.innerHTML = `
                    <div class="download-item-main">
                        <a class="download-link" href="downloads/${artifact.path}" download>${t(meta.labelKey, meta.labelFallback)}</a>
                        <div class="download-file">${artifact.fileName}</div>
                    </div>
                    <div class="download-item-side">
                        <span class="download-pill">${t(meta.badgeKey, meta.badgeFallback)}</span>
                        <span class="download-size">${size}</span>
                    </div>
                `;
                list.appendChild(item);
            });

            card.appendChild(list);
            downloadsList.appendChild(card);
        });

        if (filteredCount === 0) {
            downloadsList.innerHTML = `<div class="download-card">${t('downloads_filter_empty', 'No packages available for this filter.')}</div>`;
        }
    }

    function renderMatrix() {
        matrixBody.innerHTML = '';

        if (!Array.isArray(matrixCache) || matrixCache.length === 0) {
            const tr = document.createElement('tr');
            tr.innerHTML = `<td colspan="6">${t('manifest_unavailable', 'Manifest unavailable')}</td>`;
            matrixBody.appendChild(tr);
            return;
        }

        matrixCache.forEach((row) => {
            const statusRaw = String(row.status || '').toLowerCase();
            const badgeClass = statusRaw === 'active' ? 'active' : (statusRaw === 'legacy' ? 'legacy' : 'dev');
            const statusKey = statusRaw === 'active' ? 'status_active' : (statusRaw === 'legacy' ? 'status_legacy' : 'status_dev');
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${row.platform || '--'}</td>
                <td>${row.version || '--'}</td>
                <td>${row.protocol || '--'}</td>
                <td>${Array.isArray(row.capabilities) ? row.capabilities.join(', ') : '--'}</td>
                <td>${Array.isArray(row.interop) ? row.interop.join(', ') : '--'}</td>
                <td><span class="badge ${badgeClass}">${t(statusKey, row.status || '--')}</span></td>
            `;
            matrixBody.appendChild(tr);
        });
    }

    function renderScenarios() {
        scenarioGrid.innerHTML = '';

        scenarioConfig.forEach((entry) => {
            const card = document.createElement('article');
            card.className = 'scenario-card';
            const title = t(entry.title, entry.title);
            const steps = String(t(entry.steps, '')).split('|').filter(Boolean);
            const listItems = steps.map((step) => `<li>${step}</li>`).join('');
            card.innerHTML = `<h4>${title}</h4><ol>${listItems}</ol>`;
            scenarioGrid.appendChild(card);
        });
    }

    function renderReferences() {
        refList.innerHTML = '';

        referenceConfig.forEach((entry) => {
            const link = document.createElement('a');
            link.href = entry.url;
            link.target = '_blank';
            link.rel = 'noopener noreferrer';
            link.textContent = t(entry.key, entry.key);
            refList.appendChild(link);
        });
    }

    async function refreshAll() {
        try {
            await getJson('api/status.php');
            updateStatus(apiDot, apiStatusText, true);
        } catch (_) {
            updateStatus(apiDot, apiStatusText, false);
        }

        try {
            manifestCache = await getJson('downloads/manifest.json');
            updateStatus(manifestDot, manifestStatusText, true);
        } catch (_) {
            manifestCache = null;
            updateStatus(manifestDot, manifestStatusText, false);
        }

        try {
            matrixCache = await getJson('assets/data/matrix.json');
        } catch (_) {
            matrixCache = [];
        }

        renderDownloads();
        renderMatrix();
        renderScenarios();
        renderReferences();
    }

    function applyLanguageOptionLabels() {
        for (const option of langSelect.options) {
            option.textContent = languageNames[option.value] || option.value;
        }
    }

    document.getElementById('refreshBtn').addEventListener('click', refreshAll);

    langSelect.addEventListener('change', async (event) => {
        const value = event.target.value;
        await setLanguage(value, {
            persist: true,
            nodeId,
            country: bootstrap.country || null,
        });
    });

    onLanguageChange((lang) => {
        langSelect.value = lang;
        applyTranslations(document);
        applyLanguageOptionLabels();
        renderDownloads();
        renderMatrix();
        renderScenarios();
        renderReferences();
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
        applyLanguageOptionLabels();

        await refreshAll();
    })();
</script>
</body>
</html>
