#!/bin/sh
# 00-host-prep.sh
# Prepares the CI host with build dependencies for LFS/ALFS build.

set -e

echo "==> Updating package lists"
sudo apt-get update

echo "==> Installing LFS build dependencies"
sudo apt-get install -y \
    build-essential \
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

echo "==> Creating build directories"
mkdir -p "$HOME/lfs/sources"
mkdir -p "$HOME/lfs/tools"
mkdir -p output

echo "==> Host prep complete"
