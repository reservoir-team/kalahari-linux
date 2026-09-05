#!/bin/sh
# 07-kpk-integrate.sh
# Places kpk (Kalahari Package Keeper) into the $LFS staging rootfs.

set -e

LFS="$HOME/lfs"
export LFS

echo "==> Installing kpk binary"
install -Dvm755 "$LFS/sources/kpk/kpk" "$LFS/usr/bin/kpk"

echo "==> Creating kpk state directories"
mkdir -pv "$LFS/var/lib/kpk/installed"
mkdir -pv "$LFS/var/cache/kpk"

echo "==> kpk integration complete"
