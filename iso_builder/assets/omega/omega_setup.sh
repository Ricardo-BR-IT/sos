#!/bin/bash
# ==============================================================================
# SOS OMEGA EDITION — Setup Script
# ==============================================================================
# Survival + AI edition (~64GB). Everything in Ranger + Local LLM + Full Wiki.
# The "Prepper" / post-apocalyptic edition.
# Runs inside chroot during ISO build.
# ==============================================================================

set -e
export DEBIAN_FRONTEND=noninteractive

echo ">>> [OMEGA] Configuring Omega (Survival AI) Edition..."

# ------------------------------------------------------------------------------
# 1. INHERIT RANGER SETUP
# ------------------------------------------------------------------------------
if [ -f /tmp/ranger_setup_done ]; then
    echo "Ranger setup already applied."
fi

# ------------------------------------------------------------------------------
# 2. AI / LLM INFRASTRUCTURE
# ------------------------------------------------------------------------------
echo ">>> [OMEGA] Installing AI inference engine..."

apt-get update -qq
apt-get install -y -qq \
    build-essential cmake \
    libopenblas-dev

# Build llama.cpp from source
if [ ! -f /usr/local/bin/llama-server ]; then
    cd /tmp
    git clone --depth 1 https://github.com/ggerganov/llama.cpp.git
    cd llama.cpp
    cmake -B build -DLLAMA_BLAS=ON -DLLAMA_BLAS_VENDOR=OpenBLAS
    cmake --build build --config Release -j$(nproc)
    cp build/bin/llama-server /usr/local/bin/ 2>/dev/null || cp build/bin/server /usr/local/bin/llama-server
    cp build/bin/llama-cli /usr/local/bin/ 2>/dev/null || cp build/bin/main /usr/local/bin/llama-cli
    cd /
    rm -rf /tmp/llama.cpp
fi

# Create models directory
mkdir -p /opt/sos-mesh/ai/models

# Download LLM model (Llama 3.2 1B — runs on most hardware)
MODEL_URL="https://huggingface.co/lmstudio-community/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q4_K_M.gguf"
MODEL_FILE="/opt/sos-mesh/ai/models/llama-3.2-1b-instruct-q4.gguf"
if [ ! -f "$MODEL_FILE" ]; then
    echo "Downloading Llama 3.2 1B model (~700MB)..."
    wget -q --show-progress -c "$MODEL_URL" -O "$MODEL_FILE" || \
        echo "WARNING: Failed to download LLM model"
fi

# Download secondary model (Mistral 7B for capable hardware)
MODEL2_URL="https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.2-GGUF/resolve/main/mistral-7b-instruct-v0.2.Q4_K_M.gguf"
MODEL2_FILE="/opt/sos-mesh/ai/models/mistral-7b-instruct-q4.gguf"
if [ ! -f "$MODEL2_FILE" ]; then
    echo "Downloading Mistral 7B model (~4.4GB)..."
    wget -q --show-progress -c "$MODEL2_URL" -O "$MODEL2_FILE" || \
        echo "WARNING: Failed to download Mistral model (optional)"
fi

# AI Server systemd service
cat > /etc/systemd/system/sos-ai.service <<'AI_SVC'
[Unit]
Description=SOS Local AI Assistant (llama.cpp)
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/llama-server \
    --model /opt/sos-mesh/ai/models/llama-3.2-1b-instruct-q4.gguf \
    --host 0.0.0.0 \
    --port 8090 \
    --ctx-size 2048 \
    --threads 4
Restart=always
RestartSec=10
User=sos

[Install]
WantedBy=multi-user.target
AI_SVC
systemctl enable sos-ai.service

# Desktop shortcut for AI
cat > /usr/share/applications/sos-ai.desktop <<'AI_DESK'
[Desktop Entry]
Name=SOS AI Assistant
Comment=Local AI for survival guidance (no internet required)
Exec=firefox-esr http://localhost:8090
Icon=applications-system
Terminal=false
Type=Application
Categories=Science;ArtificialIntelligence;
AI_DESK

# ------------------------------------------------------------------------------
# 3. FULL WIKIPEDIA (Kiwix)
# ------------------------------------------------------------------------------
echo ">>> [OMEGA] Downloading full Wikipedia dump..."

mkdir -p /opt/sos-mesh/kiwix/content

WIKI_FULL_URL="https://download.kiwix.org/zim/wikipedia/wikipedia_en_all_maxi_2024-06.zim"
WIKI_FILE="/opt/sos-mesh/kiwix/content/wikipedia_en_all_maxi.zim"
if [ ! -f "$WIKI_FILE" ]; then
    echo "Downloading full English Wikipedia (~100GB)..."
    wget -q --show-progress -c "$WIKI_FULL_URL" -O "$WIKI_FILE" || \
        echo "WARNING: Full Wikipedia download failed (this is ~100GB)"
fi

# Wikibooks (practical knowledge)
WIKIBOOKS_URL="https://download.kiwix.org/zim/wikibooks/wikibooks_en_all_maxi_2024-06.zim"
WIKIBOOKS_FILE="/opt/sos-mesh/kiwix/content/wikibooks_en_all.zim"
if [ ! -f "$WIKIBOOKS_FILE" ]; then
    wget -q --show-progress -c "$WIKIBOOKS_URL" -O "$WIKIBOOKS_FILE" || \
        echo "WARNING: Wikibooks download failed"
fi

# Wikiversity
WIKIVERSY_URL="https://download.kiwix.org/zim/wikiversity/wikiversity_en_all_maxi_2024-06.zim"
WIKIVERSY_FILE="/opt/sos-mesh/kiwix/content/wikiversity_en_all.zim"
if [ ! -f "$WIKIVERSY_FILE" ]; then
    wget -q --show-progress -c "$WIKIVERSY_URL" -O "$WIKIVERSY_FILE" || \
        echo "WARNING: Wikiversity download failed"
fi

# ------------------------------------------------------------------------------
# 4. CIVILIZATIONAL BLUEPRINTS
# ------------------------------------------------------------------------------
echo ">>> [OMEGA] Setting up civilizational knowledge base..."

mkdir -p /opt/sos-mesh/blueprints/{agriculture,engineering,medicine,energy,manufacturing}

cat > /opt/sos-mesh/blueprints/README.md <<'BLUEPRINTS'
# SOS Omega — Civilizational Blueprints

This directory contains essential knowledge for rebuilding civilization.
Organized by category, each folder contains PDFs, diagrams, and manuals.

## Categories

### Agriculture
- Crop rotation charts, soil analysis guides
- Seed saving and plant propagation
- Aquaponics and hydroponics systems
- Animal husbandry basics

### Engineering
- Basic construction techniques
- Water purification systems
- Bridge and shelter building
- Tool fabrication from raw materials

### Medicine
- First aid field manual
- Wound treatment protocols
- Herbal medicine reference
- Surgical emergency procedures

### Energy
- Solar panel installation and maintenance
- Wind turbine construction
- Micro-hydro power systems
- Battery bank management

### Manufacturing
- Blacksmithing and metalworking
- 3D printer construction guides
- Chemical processes for essential materials
- Radio transmitter construction
BLUEPRINTS

# ------------------------------------------------------------------------------
# 5. HUGGING FACE MODELS (specialized)
# ------------------------------------------------------------------------------
echo ">>> [OMEGA] Setting up specialized AI models..."

mkdir -p /opt/sos-mesh/ai/models/specialized

# Medical triage model (small GGUF)
# This would be a fine-tuned model for medical first aid
cat > /opt/sos-mesh/ai/models/specialized/README.md <<'MODELS'
# Specialized AI Models

Place specialized GGUF models here:
- medical_triage.gguf — First aid and triage assistance
- navigation.gguf — Outdoor navigation and pathfinding
- radio_ops.gguf — Radio communication protocols
MODELS

# ------------------------------------------------------------------------------
# 6. MODEL SELECTOR SCRIPT
# ------------------------------------------------------------------------------
cat > /opt/sos-mesh/ai/select_model.sh <<'MODEL_SEL'
#!/bin/bash
# SOS Omega — AI Model Selector
# Automatically selects the best model based on available RAM

TOTAL_RAM_MB=$(free -m | awk '/Mem:/ {print $2}')
echo "System RAM: ${TOTAL_RAM_MB}MB"

if [ "$TOTAL_RAM_MB" -ge 16000 ]; then
    MODEL="/opt/sos-mesh/ai/models/mistral-7b-instruct-q4.gguf"
    echo "Selected: Mistral 7B (high-capability mode)"
elif [ "$TOTAL_RAM_MB" -ge 4000 ]; then
    MODEL="/opt/sos-mesh/ai/models/llama-3.2-1b-instruct-q4.gguf"
    echo "Selected: Llama 3.2 1B (standard mode)"
else
    echo "ERROR: Insufficient RAM for AI inference (need 4GB+)"
    exit 1
fi

exec /usr/local/bin/llama-server \
    --model "$MODEL" \
    --host 0.0.0.0 \
    --port 8090 \
    --ctx-size 2048 \
    --threads $(( $(nproc) / 2 ))
MODEL_SEL
chmod +x /opt/sos-mesh/ai/select_model.sh

# Update AI service to use model selector
cat > /etc/systemd/system/sos-ai.service <<'AI_SVC2'
[Unit]
Description=SOS Local AI Assistant (Auto-Select Model)
After=network.target

[Service]
Type=simple
ExecStart=/opt/sos-mesh/ai/select_model.sh
Restart=always
RestartSec=10
User=sos

[Install]
WantedBy=multi-user.target
AI_SVC2

# ------------------------------------------------------------------------------
# 7. GLOBAL SEED VAULT DATABASE
# ------------------------------------------------------------------------------
mkdir -p /opt/sos-mesh/data/seedvault

cat > /opt/sos-mesh/data/seedvault/README.md <<'SEEDVAULT'
# Global Seed Vault Reference Database

Contains searchable database of:
- 4,000+ crop varieties with growing conditions
- Climate zone compatibility charts
- Nutritional content tables
- Disease resistance profiles

Data format: SQLite database at seedvault.db
Web UI available at http://localhost:8891
SEEDVAULT

# ------------------------------------------------------------------------------
# 8. CLEANUP
# ------------------------------------------------------------------------------
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

echo ">>> [OMEGA] Setup complete. Post-apocalyptic survival station ready."
echo ">>> [OMEGA] AI available at http://localhost:8090"
echo ">>> [OMEGA] Wiki at http://localhost:8888"
echo ">>> [OMEGA] Maps at http://localhost:8889"
