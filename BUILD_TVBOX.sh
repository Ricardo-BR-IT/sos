#!/bin/bash
# ==============================================================================
# SOS-BOX ARM BUILDER (TVBOX EDITION)
# ==============================================================================
# Focus: Headless Mesh Gateway for Amlogic/Rockchip devices.
# ==============================================================================

set -e

# Configuration
DISTRO="bookworm"
ARCH="arm64" 
WORK_DIR="./build_tvbox"
OUTPUT_DIR="./output"
IMG_FILENAME="sos-box-arm64.img"
IMG_SIZE="1500" # MB

log() { echo ">>> [SOS-BOX BUILDER] $1"; }

# 1. PREP IMAGE FILE
log "Creating image file (${IMG_SIZE}MB)..."
mkdir -p "$OUTPUT_DIR"
dd if=/dev/zero of="$OUTPUT_DIR/$IMG_FILENAME" bs=1M count=$IMG_SIZE

# 2. PARTITIONING
log "Partitioning image..."
parted -s "$OUTPUT_DIR/$IMG_FILENAME" mklabel msdos
parted -s "$OUTPUT_DIR/$IMG_FILENAME" mkpart primary fat32 1MiB 128MiB
parted -s "$OUTPUT_DIR/$IMG_FILENAME" mkpart primary ext4 128MiB 100%

# 3. SETUP LOOP DEVICE
log "Setting up loop devices..."
LOOP_DEV=$(sudo losetup -fP --show "$OUTPUT_DIR/$IMG_FILENAME")
BOOT_DEV="${LOOP_DEV}p1"
ROOT_DEV="${LOOP_DEV}p2"

trap "sudo losetup -d $LOOP_DEV" EXIT

# 4. FORMATTING
log "Formatting partitions..."
sudo mkfs.vfat -F 32 -n SOS_BOOT "$BOOT_DEV"
sudo mkfs.ext4 -F -L SOS_ROOT "$ROOT_DEV"

# 5. BOOTSTRAP
log "Bootstrapping Debian $DISTRO ($ARCH)..."
mkdir -p "$WORK_DIR/rootfs"
sudo mount "$ROOT_DEV" "$WORK_DIR/rootfs"
trap "sudo umount $WORK_DIR/rootfs ; sudo losetup -d $LOOP_DEV" EXIT

sudo debootstrap --arch=$ARCH --foreign $DISTRO "$WORK_DIR/rootfs" http://deb.debian.org/debian/

# 6. CONFIGURE GUEST (QEMU)
log "Setting up QEMU for cross-build..."
sudo cp /usr/bin/qemu-aarch64-static "$WORK_DIR/rootfs/usr/bin/"
sudo chroot "$WORK_DIR/rootfs" /debootstrap/debootstrap --second-stage

# 7. INSTALL TVBOX SPECIALIZED PACKAGES
log "Installing SOS Mesh & Gateway packages..."
sudo chroot "$WORK_DIR/rootfs" apt-get update
sudo chroot "$WORK_DIR/rootfs" apt-get install -y \
    network-manager \
    hostapd \
    dnsmasq \
    iptables \
    bluez \
    socat \
    iproute2 \
    wireless-tools

# 8. COPY SOS LOGIC
log "Copying SOS specific logic..."
sudo mkdir -p "$WORK_DIR/rootfs/opt/sos-mesh"
sudo cp iso_builder/assets/scout/scout_setup.sh "$WORK_DIR/rootfs/opt/sos-mesh/tvbox_setup.sh"
# Run the setup (modified for TVBox if needed)
sudo chroot "$WORK_DIR/rootfs" /bin/bash /opt/sos-mesh/tvbox_setup.sh

log "SUCCESS! ARM Image created at $OUTPUT_DIR/$IMG_FILENAME"
