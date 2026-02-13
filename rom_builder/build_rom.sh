#!/bin/bash
# ==============================================================================
# SOS-ROM GSI BUILDER
# ==============================================================================
# Builds a custom Android GSI (Generic System Image) with SOS Mesh baked in.
# Based on phhusson/treble_experimentations methodology.
#
# Requirements:
#   - Ubuntu 20.04+ (or Docker)
#   - ~100GB disk, 16GB+ RAM
#   - repo tool, git, curl
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="${SCRIPT_DIR}/build"
OUT_DIR="${SCRIPT_DIR}/output"
ARCH="${1:-arm64}"  # arm64 or arm

log() { echo ">>> [SOS-ROM] $1"; }

# 1. DOWNLOAD AOSP SOURCE (Minimal)
setup_source() {
    log "Setting up AOSP source tree (minimal GSI)..."
    mkdir -p "$WORK_DIR"
    cd "$WORK_DIR"

    if [ ! -d ".repo" ]; then
        repo init -u https://android.googlesource.com/platform/manifest \
            -b android-14.0.0_r1 \
            --depth=1 \
            --groups=default,-mts,-test
        
        # Add phhusson's GSI patches
        git clone https://github.com/phhusson/treble_experimentations.git patches
    fi

    repo sync -c -j$(nproc) --no-tags --no-clone-bundle
}

# 2. APPLY SOS OVERLAY
apply_overlay() {
    log "Applying SOS Mesh overlay..."

    OVERLAY_DIR="${SCRIPT_DIR}/overlay"

    # Copy SOS system apps
    mkdir -p "$WORK_DIR/packages/apps/SOSMesh"
    cp -r "${SCRIPT_DIR}/../apps/mobile_app/" "$WORK_DIR/packages/apps/SOSMesh/"

    # Copy SOS system config
    mkdir -p "$WORK_DIR/device/sos/mesh/overlay/frameworks/base/core/res/res/values"
    
    # Enable IP forwarding by default
    cat > "$WORK_DIR/device/sos/mesh/sos_mesh.mk" << 'MEOF'
# SOS Mesh Device Configuration
PRODUCT_NAME := sos_mesh
PRODUCT_DEVICE := sos_mesh
PRODUCT_BRAND := SOS
PRODUCT_MODEL := SOS Mesh Node
PRODUCT_MANUFACTURER := SOS-Resgate

# Include WireGuard kernel module
PRODUCT_PACKAGES += \
    wireguard-tools \
    wg-quick

# Include SOS Mesh Services
PRODUCT_PACKAGES += \
    SOSMeshService \
    SOSDashboard

# Network: Enable forwarding & tethering
PRODUCT_PROPERTY_OVERRIDES += \
    net.ipv4.ip_forward=1 \
    net.ipv6.conf.all.forwarding=1 \
    ro.tether.denied=false \
    persist.sys.sos.mesh=1 \
    persist.sys.sos.gateway=1

# Boot animation
PRODUCT_COPY_FILES += \
    device/sos/mesh/bootanimation.zip:system/media/bootanimation.zip
MEOF

    # System properties for mesh auto-start
    cat > "$WORK_DIR/device/sos/mesh/system.prop" << 'SEOF'
# SOS Mesh Node Properties
ro.sos.edition=mesh_node
ro.sos.version=2.0
persist.sys.sos.auto_mesh=true
persist.sys.sos.auto_vpn=true
persist.sys.sos.beacon=true
persist.sys.sos.gateway.mode=auto
SEOF
}

# 3. BUILD GSI
build_gsi() {
    log "Building GSI for $ARCH..."
    cd "$WORK_DIR"

    source build/envsetup.sh

    if [ "$ARCH" = "arm64" ]; then
        lunch treble_arm64_bvS-userdebug
    else
        lunch treble_arm_bvS-userdebug
    fi

    make systemimage -j$(nproc)

    # Package as flashable ZIP (OTA-style)
    mkdir -p "$OUT_DIR"
    
    IMG_FILE="out/target/product/tdgsi_${ARCH}_ab/system.img"
    
    if [ -f "$IMG_FILE" ]; then
        cp "$IMG_FILE" "$OUT_DIR/sos-rom-${ARCH}.img"
        log "Raw image: $OUT_DIR/sos-rom-${ARCH}.img"
        
        # Create OTA-style flashable ZIP
        create_ota_zip "$ARCH"
    else
        log "ERROR: Build failed. Image not found."
        exit 1
    fi
}

# 4. CREATE OTA ZIP (for self-install from phone)
create_ota_zip() {
    local arch=$1
    local zip_dir="$WORK_DIR/ota_package"
    
    log "Creating OTA-style flashable ZIP..."
    
    mkdir -p "$zip_dir/META-INF/com/google/android"
    
    # Updater script (for TWRP/Recovery)
    cat > "$zip_dir/META-INF/com/google/android/updater-script" << 'UEOF'
ui_print("=======================================");
ui_print("  SOS RESGATE — Mesh Node ROM v2.0");
ui_print("  Transforming device into SOS Node...");
ui_print("=======================================");
ui_print(" ");

# Unmount system
unmount("/system");

# Flash system image
ui_print("Flashing SOS-ROM system image...");
block_image_update("/dev/block/bootdevice/by-name/system",
    package_extract_file("system.transfer.list"),
    "system.new.dat.br",
    "system.patch.dat");

# Mount and configure
mount("ext4", "EMMC", "/dev/block/bootdevice/by-name/system", "/system");

# Set permissions
set_perm_recursive(0, 0, 0755, 0644, "/system");

# Enable mesh on first boot
write("/system/etc/sos_first_boot", "1");

unmount("/system");

ui_print(" ");
ui_print("SOS-ROM installed successfully!");
ui_print("Reboot to activate Mesh Node.");
UEOF

    # Update binary (use standard TWRP update-binary)
    cat > "$zip_dir/META-INF/com/google/android/update-binary" << 'BEOF'
#!/sbin/sh
# Minimal update-binary for TWRP
OUTFD=$(ps | grep -v "grep" | grep -oE "update_binary [0-9]+ ([0-9]+)" | cut -d" " -f3)
[ -z "$OUTFD" ] && OUTFD=/proc/self/fd/$2

ui_print() { echo "ui_print $1" > $OUTFD; echo "ui_print" > $OUTFD; }

ZIPFILE="$3"
TMPDIR=/tmp/sos-rom

ui_print "SOS-ROM Installer starting..."
mkdir -p $TMPDIR
cd $TMPDIR
unzip -o "$ZIPFILE"

ui_print "Flashing system partition..."
dd if=$TMPDIR/system.img of=/dev/block/bootdevice/by-name/system bs=4M

ui_print "Setting up first boot..."
mount /system 2>/dev/null
echo "1" > /system/etc/sos_first_boot
umount /system 2>/dev/null

ui_print "Done! Reboot your device."
exit 0
BEOF
    chmod +x "$zip_dir/META-INF/com/google/android/update-binary"

    # Copy system image
    cp "$OUT_DIR/sos-rom-${arch}.img" "$zip_dir/system.img"

    # Create ZIP
    cd "$zip_dir"
    zip -r "$OUT_DIR/sos-rom-${arch}-ota.zip" . -x "*.DS_Store"
    
    log "OTA ZIP created: $OUT_DIR/sos-rom-${arch}-ota.zip"
}

# MAIN
log "SOS-ROM Builder v2.0 — Architecture: $ARCH"
setup_source
apply_overlay
build_gsi
log "BUILD COMPLETE!"
