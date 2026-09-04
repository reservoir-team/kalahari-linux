#!/bin/sh
# 07-kpk-integrate.sh
# Places kpk (Kalahari Package Keeper) into the rootfs, runs inside chroot.

set -e

echo "==> Installing kpk binary"
install -Dvm755 /sources/kpk/kpk /usr/bin/kpk

echo "==> Creating kpk state directories"
mkdir -pv /var/lib/kpk/installed
mkdir -pv /var/cache/kpk

echo "==> kpk integration complete"
