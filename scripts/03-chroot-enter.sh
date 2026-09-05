#!/bin/sh
# 03-chroot-enter.sh
# NOTE: no longer chroots. Just creates the minimal rootfs skeleton at
# $LFS as a staging directory. All subsequent scripts (04-08) install
# into this staging dir via DESTDIR/--prefix while running directly on
# the CI host (using the host's own toolchain).

set -e

LFS="$HOME/lfs"
export LFS

echo "==> Creating rootfs skeleton at $LFS"
mkdir -pv "$LFS"/{etc,var,usr,tmp,root,dev,proc,sys,run}
mkdir -pv "$LFS"/usr/{bin,sbin,lib,lib64,include,share}
mkdir -pv "$LFS"/usr/share/{man,doc,info}
mkdir -pv "$LFS"/usr/share/man/man{1,2,3,4,5,6,7,8}
for i in bin lib sbin; do
    ln -sfv usr/$i "$LFS/$i"
done
mkdir -pv "$LFS/etc/opt"
mkdir -pv "$LFS/opt"
install -dv -m 0750 "$LFS/root"
install -dv -m 1777 "$LFS/tmp" "$LFS/var/tmp"

echo "==> Rootfs skeleton ready at $LFS"
