/**
 * SOS Global Deployment System v6.0
 * Handles Rebranding, Multi-Edition Compilation, and Production Upload
 * FINAL: Corrected Windows Build Paths
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const CONFIG = {
    NAME: "SOS",
    VERSION: "1.0.0-LEGEND",
    BUILD_ID: "20260201-FINAL",
    SOURCE_DIR: "c:/site/mentalesaude/www/ricardo/sos",
    DEPLOY_DIR: "c:/site/mentalesaude/www/ricardo/sos/deploy_stage",
    DOWNLOAD_DIR: "c:/site/mentalesaude/www/ricardo/sos/deploy_stage/downloads",
    TEMP_BUILD_DIR: "c:/site/mentalesaude/www/ricardo/sos/temp_build_artifacts",

    PATHS: {
        WIN_BINARY_DIR: "c:/site/mentalesaude/www/ricardo/sos/apps/desktop_station/build/windows/x64/runner/Release",
        MOBILE_SOURCE: "c:/site/mentalesaude/www/ricardo/sos/apps/mobile_app",
        KERNEL_SOURCE: "c:/site/mentalesaude/www/ricardo/sos/packages/sos_kernel",
        WEB_BUILD: "c:/site/mentalesaude/www/ricardo/sos/deploy_stage/app"
    }
};

const EDITIONS = [
    {
        id: 'master',
        name: 'SOS Master Ultra Plus',
        platforms: ['Windows'],
        color: 'gold',
        content: {
            'Windows': {
                type: 'hybrid',
                binPath: CONFIG.PATHS.WIN_BINARY_DIR,
                srcPath: CONFIG.PATHS.MOBILE_SOURCE,
                extraAuth: true // Ghost Key
            }
        }
    },
    {
        id: 'lite',
        name: 'SOS Lite',
        platforms: ['Android', 'Web'],
        color: 'green',
        content: { 'Android': { type: 'source', path: CONFIG.PATHS.MOBILE_SOURCE }, 'Web': { type: 'build', path: CONFIG.PATHS.WEB_BUILD } }
    },
    {
        id: 'pro',
        name: 'SOS Pro',
        platforms: ['Android', 'Windows', 'iOS'],
        color: 'blue',
        content: {
            'Android': { type: 'source', path: CONFIG.PATHS.MOBILE_SOURCE },
            'Windows': { type: 'binary', path: CONFIG.PATHS.WIN_BINARY_DIR },
            'iOS': { type: 'source', path: CONFIG.PATHS.MOBILE_SOURCE }
        }
    },
    {
        id: 'ghost',
        name: 'SOS Ghost',
        platforms: ['Linux', 'Windows', 'Tactical-HW'],
        color: 'red',
        content: {
            'Linux': { type: 'source', path: CONFIG.PATHS.KERNEL_SOURCE },
            'Windows': { type: 'binary', path: CONFIG.PATHS.WIN_BINARY_DIR, extraAuth: true },
            'Tactical-HW': { type: 'source', path: CONFIG.PATHS.KERNEL_SOURCE }
        }
    }
];

function ensureDir(dir) {
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
}

function createReadMe(edition, platform) {
    return `
==========================================================================
   ${CONFIG.NAME} - ${edition.name} [Platform: ${platform}]
   Version: ${CONFIG.VERSION}
   Build ID: ${CONFIG.BUILD_ID}
==========================================================================

[NOTES]
This package contains the configured release for your platform.
- Windows: Contains 'desktop_station.exe' and dependencies. No installation required.
- Android: Contains Full Source Code (APK generation requires local SDK).

[SUPPORT]
Contact Mesh Control via the dashboard.
    `.trim();
}

async function buildAll() {
    console.log(`===================================================`);
    console.log(`🚀 ${CONFIG.NAME} GLOBAL BUILD SYSTEM - V6.0 (FINAL)`);
    console.log(`===================================================`);

    ensureDir(CONFIG.DOWNLOAD_DIR);
    ensureDir(CONFIG.TEMP_BUILD_DIR);

    for (const edition of EDITIONS) {
        console.log(`\n📦 Packaging [${edition.name}]...`);

        for (const platform of edition.platforms) {
            const fileName = `${CONFIG.NAME.toLowerCase()}_${edition.id}_${platform.toLowerCase().replace('-', '_')}.zip`;
            const filePath = path.join(CONFIG.DOWNLOAD_DIR, fileName);
            const tempDir = path.join(CONFIG.TEMP_BUILD_DIR, `${edition.id}_${platform}`);
            const contentConfig = edition.content[platform];

            ensureDir(tempDir);

            if (contentConfig) {
                if (contentConfig.type === 'hybrid') {
                    console.log(`   💎 Staging MASTER HYBRID Content...`);
                    try {
                        execSync(`robocopy "${contentConfig.binPath}" "${tempDir}" /E /NFL /NDL /NJH /NJS /NC /NS /NP`, { stdio: 'ignore' });
                        execSync(`robocopy "${contentConfig.srcPath}" "${path.join(tempDir, 'devtools_android_src')}" /E /XD node_modules .dart_tool build .git /NFL /NDL /NJH /NJS /NC /NS /NP`, { stdio: 'ignore' });
                    } catch (e) { }
                    if (contentConfig.extraAuth) fs.writeFileSync(path.join(tempDir, 'ghost_protocol.key'), 'MASTER-ULTRA-PLUS-KEY-001');

                } else if (contentConfig.type === 'binary') {
                    console.log(`   💿 Staging BINARIES for ${platform}...`);
                    try {
                        execSync(`robocopy "${contentConfig.path}" "${tempDir}" /E /NFL /NDL /NJH /NJS`, { stdio: 'ignore' });
                    } catch (e) { }
                    if (contentConfig.extraAuth) fs.writeFileSync(path.join(tempDir, 'ghost_protocol.key'), 'GHOST-MODE-ACTIVE-99821');
                } else {
                    console.log(`   📂 Staging SOURCE for ${platform}...`);
                    try {
                        execSync(`robocopy "${contentConfig.path}" "${path.join(tempDir, 'src')}" /E /XD node_modules .dart_tool build .git /NFL /NDL /NJH /NJS`, { stdio: 'ignore' });
                    } catch (e) { }
                }
            }

            fs.writeFileSync(path.join(tempDir, 'README.txt'), createReadMe(edition, platform));

            console.log(`   ⚙️ Compressing ${fileName}...`);
            try {
                if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
                const cmd = `powershell -Command "Compress-Archive -Path '${tempDir}\\*' -DestinationPath '${filePath}' -Force"`;
                execSync(cmd, { stdio: 'inherit' });
                console.log(`   ✅ Created Package: ${fileName}`);
            } catch (e) {
                console.error(`   ❌ Compression failed:`, e.message);
            }
        }
    }

    try {
        console.log(`\n🧹 Cleanup...`);
        fs.rmSync(CONFIG.TEMP_BUILD_DIR, { recursive: true, force: true });
    } catch (e) { }

    console.log(`\n✨ Deployment generation complete.`);
}

buildAll();
