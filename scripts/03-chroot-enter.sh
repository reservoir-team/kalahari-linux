#!/bin/sh
# 03-chroot-enter.sh
# Mounts virtual kernel filesystems into $LFS and enters chroot.
# Everything after this point (04, 05, 06, 07, 08) is meant to run
# INSIDE the chroot environment this script creates.

set -e

LFS="$HOME/lfs"

echo "==> Creating minimal rootfs skeleton"
mkdir -pv "$LFS"/{etc,var,usr,tmp,root,dev,proc,sys,run}
mkdir -pv "$LFS"/usr/{bin,sbin,lib,lib64,include,share}
mkdir -pv "$LFS"/usr/share/{man,doc,info}
mkdir -pv "$LFS"/usr/share/man/man{1,2,3,4,5,6,7,8}
for i in bin lib sbin; do
    ln -sfv usr/$i "$LFS/$i"
done
case $(uname -m) in
    x86_64) mkdir -pv "$LFS/lib64" ;;
esac
mkdir -pv "$LFS/etc/opt"
mkdir -pv "$LFS/opt"
install -dv -m 0750 "$LFS/root"
install -dv -m 1777 "$LFS/tmp" "$LFS/var/tmp"

echo "==> Mounting virtual kernel filesystems"
mount -v --bind /dev "$LFS/dev"
mount -v --bind /dev/pts "$LFS/dev/pts"
mount -vt proc proc "$LFS/proc"
mount -vt sysfs sysfs "$LFS/sys"
mount -vt tmpfs tmpfs "$LFS/run"

if [ -h "$LFS/dev/shm" ]; then
    mkdir -pv "$LFS$(realpath /dev/shm)"
else
    mount -vt tmpfs -o nosuid,nodev tmpfs "$LFS/dev/shm"
fi

echo "==> Copying build scripts and sources into chroot"
mkdir -pv "$LFS/sources"
cp -rv scripts "$LFS/sources/"
cp -rv configs "$LFS/sources/"
cp -rv assets "$LFS/sources/"
cp -rv kpk "$LFS/sources/" 2>/dev/null || true

echo "==> Entering chroot"
chroot "$LFS" /usr/bin/env -i \
    HOME=/root \
    TERM="$TERM" \
    PS1='(kalahari chroot) \u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin \
    /bin/bash -c "
        cd /sources
        sh scripts/04-final-system.sh
        sh scripts/05-dinit.sh
        sh scripts/06-kernel.sh
        sh scripts/07-kpk-integrate.sh
        sh scripts/08-branding.sh
    "

echo "==> Chroot build steps complete, unmounting"
umount -v "$LFS/dev/pts"
umount -v "$LFS/dev"
umount -v "$LFS/proc"
umount -v "$LFS/sys"
umount -v "$LFS/run"

echo "==> chroot-enter complete"
