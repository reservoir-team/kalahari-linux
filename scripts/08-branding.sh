#!/bin/sh
# 08-branding.sh
# Applies Kalahari branding (fastfetch config, logo, os-release), inside chroot.

set -e

echo "==> Installing fastfetch config"
mkdir -pv /etc/fastfetch
cp -v /sources/configs/fastfetch/config.jsonc /etc/fastfetch/config.jsonc
cp -v /sources/configs/fastfetch/kalahari.txt /etc/fastfetch/kalahari.txt

echo "==> Installing logo/icon assets"
mkdir -pv /usr/share/kalahari
cp -v /sources/assets/icon.svg /usr/share/kalahari/icon.svg

echo "==> Writing /etc/os-release"
cat > /etc/os-release << EOF
NAME="Kalahari Linux"
ID=kalahari
PRETTY_NAME="Kalahari Linux"
VERSION="0.1.0"
HOME_URL="https://github.com/reservoir-team/kalahari-linux"
EOF

echo "==> Branding complete"
