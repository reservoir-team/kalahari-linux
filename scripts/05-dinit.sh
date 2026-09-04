#!/bin/sh
# 05-dinit.sh
# Builds and integrates dinit as the init system, inside chroot.

set -e

DINIT_VER="0.19.1"

cd /sources
wget -nc "https://github.com/davmac314/dinit/archive/refs/tags/v${DINIT_VER}.tar.gz" -O "dinit-${DINIT_VER}.tar.gz"
tar -xf "dinit-${DINIT_VER}.tar.gz"
cd "dinit-${DINIT_VER}"

echo "==> Building dinit"
make -j"$(nproc)"

echo "==> Installing dinit"
make install

echo "==> Setting dinit as PID 1"
ln -sfv /usr/sbin/dinit /sbin/init

echo "==> Installing dinit service files"
mkdir -pv /etc/dinit.d
cp -rv /sources/configs/dinit.d/* /etc/dinit.d/

echo "==> Installing helper scripts"
mkdir -pv /usr/lib/kalahari
cp -v /sources/configs/scripts/early-mounts.sh /usr/lib/kalahari/early-mounts.sh
chmod +x /usr/lib/kalahari/early-mounts.sh

echo "==> Installing iwd config"
mkdir -pv /etc/iwd
cp -v /sources/configs/network/main.conf /etc/iwd/main.conf

echo "==> dinit build & integration complete"
