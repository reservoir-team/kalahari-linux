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

echo "==> Creating build directories"
mkdir -p "$HOME/lfs/sources"
mkdir -p "$HOME/lfs/tools"
mkdir -p output

echo "==> Host prep complete"
