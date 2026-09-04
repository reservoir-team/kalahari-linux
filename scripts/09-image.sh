#!/bin/sh
# 09-image.sh
# Builds a bootable ISO from the completed rootfs using EFISTUB
# (no GRUB/Limine — kernel itself is the EFI executable).

set -e

LFS="$HOME/lfs"
OUTPUT_DIR="output"
ISO_NAME="kalahari-linux.iso"
EFI_BOOT_DIR="$LFS/boot/EFI/BOOT"

mkdir -pv "$OUTPUT_DIR"

echo "==> Verifying EFISTUB kernel image exists"
if [ ! -f "$EFI_BOOT_DIR/BOOTX64.EFI" ]; then
    echo "ERROR: $EFI_BOOT_DIR/BOOTX64.EFI not found. Did 06-kernel.sh run?"
    exit 1
fi

echo "==> Creating EFI boot partition image (FAT)"
EFI_IMG="$LFS/efiboot.img"
dd if=/dev/zero of="$EFI_IMG" bs=1M count=64
mkfs.vfat "$EFI_IMG"

mkdir -pv /tmp/efimnt
mount -o loop "$EFI_IMG" /tmp/efimnt
mkdir -pv /tmp/efimnt/EFI/BOOT
cp -v "$EFI_BOOT_DIR/BOOTX64.EFI" /tmp/efimnt/EFI/BOOT/BOOTX64.EFI
umount /tmp/efimnt

echo "==> Building ISO with xorriso"
xorriso -as mkisofs \
    -iso-level 3 \
    -full-iso9660-filenames \
    -volid "KALAHARI" \
    -eltorito-alt-boot \
    -e efiboot.img \
    -no-emul-boot \
    -isohybrid-gpt-basdat \
    -output "$OUTPUT_DIR/$ISO_NAME" \
    "$LFS"

echo "==> ISO created at $OUTPUT_DIR/$ISO_NAME"
