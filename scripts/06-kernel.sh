#!/bin/sh
# 06-kernel.sh
# Builds Linux kernel 7.3 with EFISTUB enabled, installs modules and
# kernel image into $LFS staging rootfs.

set -e

LFS="$HOME/lfs"
export LFS

LINUX_VER="7.3"

cd "$LFS/sources"
tar -xf "linux-${LINUX_VER}.tar.xz"
cd "linux-${LINUX_VER}"

echo "==> Generating default config"
make mrproper
make defconfig

echo "==> Enabling EFISTUB"
scripts/config --enable EFI
scripts/config --enable EFI_STUB
scripts/config --enable EFI_MIXED

echo "==> Ensuring fair-scheduling group support is enabled (EEVDF is built into fair_sched_class core, no standalone config option — auto-active since 6.6+)"
scripts/config --enable FAIR_GROUP_SCHED
scripts/config --enable CGROUP_SCHED

echo "==> Resolving config dependencies"
make olddefconfig

echo "==> Building kernel"
make -j"$(nproc)"

echo "==> Installing modules"
make INSTALL_MOD_PATH="$LFS" modules_install

echo "==> Copying kernel image (EFI executable)"
mkdir -pv "$LFS/boot/EFI/BOOT"
cp -v arch/x86/boot/bzImage "$LFS/boot/EFI/BOOT/BOOTX64.EFI"

echo "==> Kernel build complete"
echo "==> NOTE: verify EEVDF is active after boot with: cat /proc/sys/kernel/sched_base_slice_us"
