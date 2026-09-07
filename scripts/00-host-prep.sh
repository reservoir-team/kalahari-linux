#!/bin/sh
# 00-host-prep.sh
# Prepares the CI host with build dependencies for LFS/ALFS build.

set -e

echo "==> Updating and upgrading system packages"
sudo apt-get update
sudo apt-get upgrade -y

echo "==> Installing LFS build dependencies"
sudo apt-get install -y \
    build-essential \
    linux-libc-dev \
    bison \
    gawk \
    texinfo \
    wget \
    curl \
    xz-utils \
    bzip2 \
    zstd \
    rsync \
    python3 \
    git \
    xorriso \
    dosfstools \
    mtools \
    cpio \
    jq

echo "==> Ensuring asm/*.h headers are findable at /usr/include/asm (glibc build needs this)"
sudo ln -sf /usr/include/x86_64-linux-gnu/asm /usr/include/asm

echo "==> Symlinking core libc files to /usr/lib (needed when -L/usr/lib is passed explicitly, e.g. by GMP-dependent configure scripts)"
sudo ln -sf /usr/lib/x86_64-linux-gnu/libc.so.6 /usr/lib/libc.so.6
sudo ln -sf /usr/lib/x86_64-linux-gnu/libc_nonshared.a /usr/lib/libc_nonshared.a
sudo ln -sf /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 /usr/lib/ld-linux-x86-64.so.2

echo "==> Creating build directories"
mkdir -p "$HOME/lfs/sources"
mkdir -p "$HOME/lfs/tools"
mkdir -p output

echo "==> Host prep complete"
