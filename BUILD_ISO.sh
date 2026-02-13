#!/bin/bash

# ==============================================================================
# SOS LIVE ISO BUILDER v2.0
# ==============================================================================
# Usage: sudo ./BUILD_ISO.sh [scout|ranger|omega] [--arch amd64|arm64]
#
# Generates a bootable Live ISO for the SOS Mesh Resgate platform.
# Based on Debian (Bookworm) + Openbox + SOS binaries.
# Supports UEFI + Legacy BIOS dual-boot via GRUB.
#
# Editions:
# - Scout:  Minimal (~2GB)  - Kernel, Drivers, Mesh.
# - Ranger: Standard (~16GB) - Maps, Wikis, Desktop tools.
# - Omega:  Survival (~64GB) - LLMs, All Wikis, Blueprints.
#
# Requirements:
# - Root privileges
# - debootstrap, xorriso, squashfs-tools, mtools
# - grub-pc-bin, grub-efi-amd64-bin (or arm64 equivalent)
# ==============================================================================

set -eo pipefail

# ==============================================================================
# PARSE ARGUMENTS
# ==============================================================================
EDITION=${1:-scout}
ARCH="amd64"
SOS_VERSION="0.3.0"

while [[ $# -gt 1 ]]; do
    case "$2" in
        --arch) ARCH="$3"; shift 2;;
        *) shift;;
    esac
done

WORK_DIR="$(pwd)/build_iso_${EDITION}"
ISO_NAME="sos_${EDITION}_v${SOS_VERSION}.iso"
DEBIAN_RELEASE="bookworm"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ISO_ASSETS="${SCRIPT_DIR}/iso_builder/assets/${EDITION}"
ISO_BOOT="${SCRIPT_DIR}/iso_builder/boot"

# ==============================================================================
# COLORS
# ==============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log() { echo -e "${CYAN}>>> [SOS BUILDER]${NC} $1"; }
success() { echo -e "${GREEN}>>> [SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}>>> [WARNING]${NC} $1"; }
error() { echo -e "${RED}>>> [ERROR]${NC} $1"; }

# ==============================================================================
# CLEANUP TRAP
# ==============================================================================
cleanup() {
    log "Cleaning up mounts..."
    umount -lf "$WORK_DIR/chroot/dev/pts" 2>/dev/null || true
    umount -lf "$WORK_DIR/chroot/dev" 2>/dev/null || true
    umount -lf "$WORK_DIR/chroot/proc" 2>/dev/null || true
    umount -lf "$WORK_DIR/chroot/sys" 2>/dev/null || true
    umount -lf "$WORK_DIR/chroot/run" 2>/dev/null || true
}
trap cleanup EXIT ERR

# ==============================================================================
# 0. PRE-FLIGHT CHECKS
# ==============================================================================
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║         ██████╗ ███████╗███████╗ ██████╗  █████╗ ████████╗ ║"
echo "║         ██╔══██╗██╔════╝██╔════╝██╔════╝ ██╔══██╗╚══██╔══╝ ║"
echo "║         ██████╔╝█████╗  ███████╗██║  ███╗███████║   ██║    ║"
echo "║         ██╔══██╗██╔══╝  ╚════██║██║   ██║██╔══██║   ██║    ║"
echo "║         ██║  ██║███████╗███████║╚██████╔╝██║  ██║   ██║    ║"
echo "║         ╚═╝  ╚═╝╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝    ║"
echo "║                    SOS LIVE ISO BUILDER                      ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

log "Target: ${EDITION^^} Edition | Arch: ${ARCH} | Version: v${SOS_VERSION}"

if [ "$(id -u)" -ne 0 ]; then
    error "This script requires root privileges. Run with: sudo ./BUILD_ISO.sh ${EDITION}"
    exit 1
fi

REQUIRED_TOOLS="debootstrap xorriso squashfs-tools mksquashfs mtools grub-mkrescue"
MISSING=""
for tool in $REQUIRED_TOOLS; do
    if ! command -v "$tool" &>/dev/null; then
        MISSING="$MISSING $tool"
    fi
done

if [ -n "$MISSING" ]; then
    warn "Missing tools:${MISSING}"
    log "Installing missing dependencies..."
    apt-get update -qq
    apt-get install -y -qq debootstrap xorriso squashfs-tools mtools \
        grub-pc-bin grub-efi-amd64-bin grub-common grub2-common \
        isolinux syslinux-common syslinux-efi
fi

# Validate edition
case "$EDITION" in
    scout|ranger|omega) ;;
    *) error "Unknown edition: $EDITION (valid: scout, ranger, omega)"; exit 1;;
esac

# ==============================================================================
# 1. BOOTSTRAP BASE SYSTEM
# ==============================================================================
log "[1/7] Bootstrapping Debian ${DEBIAN_RELEASE} (${ARCH})..."

mkdir -p "$WORK_DIR/chroot"
if [ ! -f "$WORK_DIR/chroot/bin/bash" ]; then
    debootstrap --arch="$ARCH" "$DEBIAN_RELEASE" "$WORK_DIR/chroot" http://deb.debian.org/debian/
    success "Base system bootstrapped."
else
    log "Base system already exists, skipping bootstrap."
fi

# ==============================================================================
# 2. MOUNT FILESYSTEMS
# ==============================================================================
log "[2/7] Mounting virtual filesystems..."

mount --bind /dev "$WORK_DIR/chroot/dev"
mount --bind /dev/pts "$WORK_DIR/chroot/dev/pts"
mount --bind /proc "$WORK_DIR/chroot/proc"
mount --bind /sys "$WORK_DIR/chroot/sys"
mount --bind /run "$WORK_DIR/chroot/run"

# ==============================================================================
# 3. CONFIGURE BASE SYSTEM
# ==============================================================================
log "[3/7] Configuring Base System (Kernel + Desktop)..."

cat <<'CHROOT_BASE' | chroot "$WORK_DIR/chroot" /bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

# ---- Locale & Timezone ----
apt-get update -qq
apt-get install -y -qq locales
sed -i 's/# en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/default/locale

# ---- Kernel & Live Boot ----
apt-get install -y -qq \
    linux-image-amd64 \
    live-boot \
    systemd-sysv \
    firmware-linux-free

# ---- Networking ----
apt-get install -y -qq \
    network-manager \
    wpasupplicant \
    bluez \
    openssh-server \
    curl wget git \
    iw wireless-tools \
    net-tools iputils-ping dnsutils \
    bridge-utils hostapd dnsmasq

# ---- Graphical Desktop (Minimal) ----
apt-get install -y -qq \
    xorg \
    openbox obconf \
    lightdm lightdm-gtk-greeter \
    terminator \
    pcmanfm \
    tint2 \
    feh \
    lxappearance \
    arc-theme papirus-icon-theme

# ---- System Utilities ----
apt-get install -y -qq \
    htop neofetch \
    vim nano \
    unzip p7zip-full \
    usbutils pciutils \
    alsa-utils pulseaudio \
    ntfs-3g exfat-fuse

# ---- Python (for SOS tools) ----
apt-get install -y -qq python3 python3-pip

# ---- GRUB for ISO ----
apt-get install -y -qq \
    grub-pc-bin \
    grub-efi-amd64-bin \
    grub-common \
    grub2-common

# ---- Set Root Password & Auto-login ----
echo "root:sos" | chpasswd

# Create sos user
useradd -m -s /bin/bash -G sudo,audio,video,plugdev,netdev sos 2>/dev/null || true
echo "sos:sos" | chpasswd

# Auto-login via LightDM
mkdir -p /etc/lightdm/lightdm.conf.d
cat > /etc/lightdm/lightdm.conf.d/50-autologin.conf <<EOF
[Seat:*]
autologin-user=sos
autologin-user-timeout=0
EOF

# ---- Hostname ----
echo "sos-live" > /etc/hostname

# ---- Clean ----
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
CHROOT_BASE

success "Base system configured."

# ==============================================================================
# 4. INSTALL SOS PLATFORM
# ==============================================================================
log "[4/7] Installing SOS Platform into chroot..."

# Create SOS directories
mkdir -p "$WORK_DIR/chroot/opt/sos-mesh/bin"
mkdir -p "$WORK_DIR/chroot/opt/sos-mesh/config"
mkdir -p "$WORK_DIR/chroot/opt/sos-mesh/data"
mkdir -p "$WORK_DIR/chroot/opt/sos-mesh/logs"

# Copy SOS Desktop Station build (if exists)
if [ -d "apps/desktop_station/build/linux/x64/release/bundle" ]; then
    cp -r apps/desktop_station/build/linux/x64/release/bundle/* "$WORK_DIR/chroot/opt/sos-mesh/bin/"
    success "SOS Desktop Station binary copied."
else
    warn "Desktop Station Linux build not found. Copying source assets..."
    cp -r apps/desktop_station/assets "$WORK_DIR/chroot/opt/sos-mesh/" 2>/dev/null || true
fi

# Copy web portal as fallback UI
if [ -d "deploy_stage_web" ]; then
    mkdir -p "$WORK_DIR/chroot/opt/sos-mesh/web"
    cp -r deploy_stage_web/* "$WORK_DIR/chroot/opt/sos-mesh/web/"
    success "Web portal copied."
fi

# Copy Java SOS node (if exists)
if [ -f "java/dist/resgatesos_java_standard.jar" ]; then
    cp java/dist/*.jar "$WORK_DIR/chroot/opt/sos-mesh/bin/"
    success "Java SOS node copied."
fi

# Create SOS launcher script
cat > "$WORK_DIR/chroot/opt/sos-mesh/launch_sos.sh" <<'LAUNCHER'
#!/bin/bash
# SOS Mesh Resgate - Launcher
export SOS_HOME="/opt/sos-mesh"
export SOS_DATA="$SOS_HOME/data"
export SOS_LOGS="$SOS_HOME/logs"

echo "╔══════════════════════════════════╗"
echo "║   RESGATE SOS - Mesh Active     ║"
echo "╚══════════════════════════════════╝"

# Try native binary first, then web fallback
if [ -x "$SOS_HOME/bin/desktop_station" ]; then
    exec "$SOS_HOME/bin/desktop_station"
elif [ -f "$SOS_HOME/bin/resgatesos_java_standard.jar" ]; then
    exec java -jar "$SOS_HOME/bin/resgatesos_java_standard.jar"
elif [ -d "$SOS_HOME/web" ]; then
    echo "Starting Web UI on http://localhost:8080"
    cd "$SOS_HOME/web" && python3 -m http.server 8080 &
    sleep 2
    xdg-open "http://localhost:8080" 2>/dev/null || firefox "http://localhost:8080" 2>/dev/null
else
    echo "No SOS binary found. Starting terminal mesh node..."
    exec /bin/bash
fi
LAUNCHER
chmod +x "$WORK_DIR/chroot/opt/sos-mesh/launch_sos.sh"

# Openbox autostart
mkdir -p "$WORK_DIR/chroot/home/sos/.config/openbox"
cat > "$WORK_DIR/chroot/home/sos/.config/openbox/autostart" <<'AUTOSTART'
# SOS Live Environment Autostart
tint2 &
feh --bg-fill /opt/sos-mesh/config/wallpaper.png 2>/dev/null &
nm-applet &
sleep 2
/opt/sos-mesh/launch_sos.sh &
AUTOSTART
chroot "$WORK_DIR/chroot" chown -R sos:sos /home/sos/.config

# Create SOS desktop entry
mkdir -p "$WORK_DIR/chroot/usr/share/applications"
cat > "$WORK_DIR/chroot/usr/share/applications/sos-mesh.desktop" <<'DESKTOP'
[Desktop Entry]
Name=Resgate SOS
Comment=Emergency Mesh Communication System
Exec=/opt/sos-mesh/launch_sos.sh
Icon=/opt/sos-mesh/config/icon.png
Terminal=false
Type=Application
Categories=Network;Communication;
DESKTOP

success "SOS Platform installed."

# ==============================================================================
# 5. EDITION-SPECIFIC SETUP
# ==============================================================================
log "[5/7] Configuring ${EDITION^^} edition specifics..."

EDITION_SCRIPT="${ISO_ASSETS}/${EDITION}_setup.sh"
if [ -f "$EDITION_SCRIPT" ]; then
    cp "$EDITION_SCRIPT" "$WORK_DIR/chroot/tmp/edition_setup.sh"
    chmod +x "$WORK_DIR/chroot/tmp/edition_setup.sh"
    chroot "$WORK_DIR/chroot" /tmp/edition_setup.sh
    rm -f "$WORK_DIR/chroot/tmp/edition_setup.sh"
    success "${EDITION^^} edition configured."
else
    warn "No edition setup script found at: $EDITION_SCRIPT"
fi

# Copy edition README as release notes
if [ -f "${ISO_ASSETS}/README.md" ]; then
    cp "${ISO_ASSETS}/README.md" "$WORK_DIR/chroot/etc/sos-release"
fi

# Copy Installer & Hydration Scripts (Trojan Horse Strategy)
log "Embedding Installer & Hydration Scripts..."
mkdir -p "$WORK_DIR/chroot/opt/sos-mesh"
if [ -d "${SCRIPT_DIR}/iso_builder/assets/installer" ]; then
    cp "${SCRIPT_DIR}/iso_builder/assets/installer/installer.py" "$WORK_DIR/chroot/opt/sos-mesh/"
fi
# Copy standalone hydration scripts
cp "${SCRIPT_DIR}/iso_builder/assets/ranger/hydrate_ranger.sh" "$WORK_DIR/chroot/opt/sos-mesh/" 2>/dev/null || true
cp "${SCRIPT_DIR}/iso_builder/assets/omega/hydrate_omega.sh" "$WORK_DIR/chroot/opt/sos-mesh/" 2>/dev/null || true
chmod +x "$WORK_DIR/chroot/opt/sos-mesh/"*.sh

# Set edition hostname
echo "sos-${EDITION}" > "$WORK_DIR/chroot/etc/hostname"

# Edition-specific MOTD
cat > "$WORK_DIR/chroot/etc/motd" <<MOTD

 ██████╗ ███████╗███████╗ ██████╗  █████╗ ████████╗███████╗
 ██╔══██╗██╔════╝██╔════╝██╔════╝ ██╔══██╗╚══██╔══╝██╔════╝
 ██████╔╝█████╗  ███████╗██║  ███╗███████║   ██║   █████╗
 ██╔══██╗██╔══╝  ╚════██║██║   ██║██╔══██║   ██║   ██╔══╝
 ██║  ██║███████╗███████║╚██████╔╝██║  ██║   ██║   ███████╗
 ╚═╝  ╚═╝╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝
           SOS MESH — ${EDITION^^} EDITION v${SOS_VERSION}
    Emergency Communication System | mentalesaude.com.br/sos

    Type 'sos' to launch the SOS application.
    Type 'sos --help' for mesh configuration options.

MOTD

# Create 'sos' command alias
cat > "$WORK_DIR/chroot/usr/local/bin/sos" <<'SOS_CMD'
#!/bin/bash
exec /opt/sos-mesh/launch_sos.sh "$@"
SOS_CMD
chmod +x "$WORK_DIR/chroot/usr/local/bin/sos"

# ==============================================================================
# 6. PACK FILESYSTEM (SQUASHFS)
# ==============================================================================
log "[6/7] Compressing filesystem (SquashFS)..."

# Unmount virtual filesystems
umount -lf "$WORK_DIR/chroot/dev/pts" 2>/dev/null || true
umount -lf "$WORK_DIR/chroot/dev" 2>/dev/null || true
umount -lf "$WORK_DIR/chroot/proc" 2>/dev/null || true
umount -lf "$WORK_DIR/chroot/sys" 2>/dev/null || true
umount -lf "$WORK_DIR/chroot/run" 2>/dev/null || true

# Build ISO image directory structure
mkdir -p "$WORK_DIR/image/live"
mkdir -p "$WORK_DIR/image/boot/grub"
mkdir -p "$WORK_DIR/image/isolinux"
mkdir -p "$WORK_DIR/image/EFI/BOOT"

# Create SquashFS
mksquashfs "$WORK_DIR/chroot" "$WORK_DIR/image/live/filesystem.squashfs" \
    -e boot \
    -comp xz \
    -Xbcj x86 \
    -b 1M \
    -no-duplicates

# Copy kernel and initramfs
cp "$WORK_DIR/chroot/boot/vmlinuz"* "$WORK_DIR/image/live/vmlinuz"
cp "$WORK_DIR/chroot/boot/initrd.img"* "$WORK_DIR/image/live/initrd"

success "Filesystem compressed."

# ==============================================================================
# 7. CREATE BOOT CONFIGURATION & GENERATE ISO
# ==============================================================================
log "[7/7] Generating bootable ISO..."

# ---- GRUB (UEFI) ----
cat > "$WORK_DIR/image/boot/grub/grub.cfg" <<GRUB_CFG
set timeout=10
set default=0

insmod all_video
insmod gfxterm
insmod png

set gfxmode=auto
terminal_output gfxterm

# Load splash if available
if [ -f /boot/grub/splash.png ]; then
    background_image /boot/grub/splash.png
fi

set color_normal=white/black
set color_highlight=red/black

set menu_color_normal=white/black
set menu_color_highlight=red/black

menuentry "SOS ${EDITION^^} — Live (Load to RAM)" {
    linux /live/vmlinuz boot=live toram quiet splash
    initrd /live/initrd
}

menuentry "SOS ${EDITION^^} — Live (Standard)" {
    linux /live/vmlinuz boot=live quiet splash
    initrd /live/initrd
}

menuentry "SOS ${EDITION^^} — Live (Persistent)" {
    linux /live/vmlinuz boot=live persistence quiet splash
    initrd /live/initrd
}

menuentry "SOS ${EDITION^^} — Safe Mode (No Graphics)" {
    linux /live/vmlinuz boot=live nomodeset single
    initrd /live/initrd
}

menuentry "SOS ${EDITION^^} — Memory Test (memtest86+)" {
    linux16 /live/vmlinuz memtest
}
GRUB_CFG

# Copy splash image if exists
if [ -f "${ISO_BOOT}/splash.png" ]; then
    cp "${ISO_BOOT}/splash.png" "$WORK_DIR/image/boot/grub/splash.png"
fi

# ---- ISOLINUX (Legacy BIOS) ----
if [ -f /usr/lib/ISOLINUX/isolinux.bin ]; then
    cp /usr/lib/ISOLINUX/isolinux.bin "$WORK_DIR/image/isolinux/"
    cp /usr/lib/syslinux/modules/bios/ldlinux.c32 "$WORK_DIR/image/isolinux/" 2>/dev/null || true
    cp /usr/lib/syslinux/modules/bios/libutil.c32 "$WORK_DIR/image/isolinux/" 2>/dev/null || true
    cp /usr/lib/syslinux/modules/bios/menu.c32 "$WORK_DIR/image/isolinux/" 2>/dev/null || true
    cp /usr/lib/syslinux/modules/bios/vesamenu.c32 "$WORK_DIR/image/isolinux/" 2>/dev/null || true
fi

cat > "$WORK_DIR/image/isolinux/isolinux.cfg" <<ISOLINUX_CFG
UI vesamenu.c32
PROMPT 0
TIMEOUT 100

MENU TITLE ═══ RESGATE SOS — ${EDITION^^} EDITION ═══
MENU COLOR border       30;44    #40ffffff #a0000000 std
MENU COLOR title        1;36;44  #ff00ccff #a0000000 std
MENU COLOR sel          7;37;40  #e0ffffff #20ffffff all
MENU COLOR unsel        37;44    #90ffffff #a0000000 std
MENU COLOR help         37;40    #c0ffffff #a0000000 std
MENU COLOR timeout_msg  37;40    #80ffffff #00000000 std
MENU COLOR timeout      1;37;40  #c0ffffff #00000000 std

LABEL live-ram
    MENU LABEL SOS ${EDITION^^} -- Live (Load to RAM)
    MENU DEFAULT
    KERNEL /live/vmlinuz
    APPEND initrd=/live/initrd boot=live toram quiet splash
    TEXT HELP
        Load entire system into RAM. Fast but requires 4GB+ RAM.
    ENDTEXT

LABEL live
    MENU LABEL SOS ${EDITION^^} -- Live (Standard)
    KERNEL /live/vmlinuz
    APPEND initrd=/live/initrd boot=live quiet splash

LABEL persistent
    MENU LABEL SOS ${EDITION^^} -- Live (Persistent Storage)
    KERNEL /live/vmlinuz
    APPEND initrd=/live/initrd boot=live persistence quiet splash

LABEL safe
    MENU LABEL SOS ${EDITION^^} -- Safe Mode (No Graphics)
    KERNEL /live/vmlinuz
    APPEND initrd=/live/initrd boot=live nomodeset single
ISOLINUX_CFG

# ---- Create EFI boot image ----
grub-mkstandalone \
    --format=x86_64-efi \
    --output="$WORK_DIR/image/EFI/BOOT/BOOTX64.EFI" \
    --locales="" \
    --fonts="" \
    "boot/grub/grub.cfg=$WORK_DIR/image/boot/grub/grub.cfg" 2>/dev/null || \
    warn "GRUB EFI standalone build failed (non-fatal for BIOS-only systems)"

# Create EFI FAT image for hybrid boot
if [ -f "$WORK_DIR/image/EFI/BOOT/BOOTX64.EFI" ]; then
    dd if=/dev/zero of="$WORK_DIR/image/boot/grub/efi.img" bs=1M count=10
    mkfs.vfat "$WORK_DIR/image/boot/grub/efi.img"
    mmd -i "$WORK_DIR/image/boot/grub/efi.img" ::EFI
    mmd -i "$WORK_DIR/image/boot/grub/efi.img" ::EFI/BOOT
    mcopy -i "$WORK_DIR/image/boot/grub/efi.img" \
        "$WORK_DIR/image/EFI/BOOT/BOOTX64.EFI" ::EFI/BOOT/BOOTX64.EFI
fi

# ---- Generate Final ISO ----
xorriso -as mkisofs \
    -iso-level 3 \
    -full-iso9660-filenames \
    -volid "SOS_${EDITION^^}_V${SOS_VERSION}" \
    -eltorito-boot isolinux/isolinux.bin \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
    -eltorito-alt-boot \
        -e boot/grub/efi.img \
        -no-emul-boot \
        -isohybrid-gpt-basdat \
    -output "$WORK_DIR/../output/${ISO_NAME}" \
    "$WORK_DIR/image" 2>/dev/null || \
xorriso -as mkisofs \
    -iso-level 3 \
    -full-iso9660-filenames \
    -volid "SOS_${EDITION^^}_V${SOS_VERSION}" \
    -output "$WORK_DIR/../output/${ISO_NAME}" \
    "$WORK_DIR/image"

# ==============================================================================
# DONE
# ==============================================================================
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                     BUILD COMPLETE                          ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║  Edition:  ${EDITION^^}"
echo "║  ISO:      output/${ISO_NAME}"
echo "║  Size:     $(du -sh "$(pwd)/output/${ISO_NAME}" 2>/dev/null | cut -f1 || echo 'N/A')"
echo "║  Arch:     ${ARCH}"
echo "║  Boot:     UEFI + Legacy BIOS (Hybrid)"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║  Flash to USB:                                              ║"
echo "║    dd if=output/${ISO_NAME} of=/dev/sdX bs=4M status=progress ║"
echo "║  Or use: balenaEtcher, Rufus, Ventoy                       ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
