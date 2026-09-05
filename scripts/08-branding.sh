#!/bin/sh
# 08-branding.sh
# Applies Kalahari branding into the $LFS staging rootfs.

set -e

LFS="$HOME/lfs"
export LFS

echo "==> Installing fastfetch config"
mkdir -pv "$LFS/etc/fastfetch"
cp -v "$LFS/sources/configs/fastfetch/config.jsonc" "$LFS/etc/fastfetch/config.jsonc"
cp -v "$LFS/sources/configs/fastfetch/kalahari.txt" "$LFS/etc/fastfetch/kalahari.txt"

echo "==> Installing logo/icon assets"
mkdir -pv "$LFS/usr/share/kalahari"
cp -v "$LFS/sources/assets/icon.svg" "$LFS/usr/share/kalahari/icon.svg"

echo "==> Writing /etc/os-release"
cat > "$LFS/etc/os-release" << EOF
NAME="Kalahari Linux"
ID=kalahari
PRETTY_NAME="Kalahari Linux"
VERSION="0.1.0"
HOME_URL="https://github.com/reservoir-team/kalahari-linux"
EOF

echo "==> Branding complete"
