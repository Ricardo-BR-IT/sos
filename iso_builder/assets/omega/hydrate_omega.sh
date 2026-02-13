#!/bin/bash
# ==============================================================================
# SOS HYDRATE: OMEGA
# ==============================================================================
# Downloads and installs Omega assets (LLM AI, Full Wiki, Blueprints).
# Usage: ./hydrate_omega.sh [--target /mnt/target]
# ==============================================================================

TARGET_DIR=""
while [[ $# -gt 1 ]]; do
    case "$1" in
        --target) TARGET_DIR="$2"; shift 2;;
        *) shift;;
    esac
done

# Run Ranger hydration first
bash $(dirname "$0")/../ranger/hydrate_ranger.sh --target "$TARGET_DIR"

echo ">>> [HYDRATE] Installing OMEGA Edition Pack..."

# 1. Install Build Tools & AI Deps
apt-get install -y -qq build-essential cmake libopenblas-dev

# 2. Compile llama.cpp (Skipped if downloading binary from repo)
# In production, we'd download a pre-compiled binary.
wget -c "https://github.com/ggerganov/llama.cpp/releases/download/b3000/llama-b3000-bin-linux-x64.zip" -O /tmp/llama.zip
unzip /tmp/llama.zip -d "$TARGET_DIR/usr/local/bin/"

# 3. Download Models
mkdir -p "$TARGET_DIR/opt/sos-mesh/ai/models"
echo "Downloading Llama 3.2 1B..."
wget -c "https://huggingface.co/lmstudio-community/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q4_K_M.gguf" \
    -O "$TARGET_DIR/opt/sos-mesh/ai/models/llama-3.2-1b-instruct-q4.gguf"

# 4. Download Full Wikipedia (Big file!)
echo "Downloading Full Wikipedia (~100GB)..."
wget -c "https://download.kiwix.org/zim/wikipedia/wikipedia_en_all_maxi_2024-06.zim" \
    -O "$TARGET_DIR/opt/sos-mesh/kiwix/content/wikipedia_full.zim"

# 5. Enable AI Service
if [ -z "$TARGET_DIR" ]; then
    systemctl enable sos-ai
fi

echo ">>> [HYDRATE] Omega Pack Installed."
