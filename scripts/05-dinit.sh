#!/bin/sh
# 05-dinit.sh
# Builds and integrates dinit as the init system. Installs into $LFS
# staging rootfs (no chroot — runs directly on the CI host).

set -e

LFS="$HOME/lfs"
export LFS

DINIT_VER="0.19.1"

cd "$LFS/sources"
wget -nc "https://github.com/davmac314/dinit/archive/refs/tags/v${DINIT_VER}.tar.gz" -O "dinit-${DINIT_VER}.tar.gz"
tar -xf "dinit-${DINIT_VER}.tar.gz"
cd "dinit-${DINIT_VER}"

echo "==> Building dinit"
make -j"$(nproc)"

echo "==> Installing dinit"
make DESTDIR="$LFS" install

echo "==> Setting dinit as PID 1"
mkdir -pv "$LFS/sbin"
ln -sfv /usr/sbin/dinit "$LFS/sbin/init"

echo "==> Installing dinit service files"
mkdir -pv "$LFS/etc/dinit.d"
cp -rv "$LFS/sources/configs/dinit.d/"* "$LFS/etc/dinit.d/"

echo "==> Installing helper scripts"
mkdir -pv "$LFS/usr/lib/kalahari"
cp -v "$LFS/sources/configs/scripts/early-mounts.sh" "$LFS/usr/lib/kalahari/early-mounts.sh"
chmod +x "$LFS/usr/lib/kalahari/early-mounts.sh"

echo "==> Installing iwd config"
mkdir -pv "$LFS/etc/iwd"
cp -v "$LFS/sources/configs/network/main.conf" "$LFS/etc/iwd/main.conf"

echo "==> dinit build & integration complete"
