#!/bin/sh
# 01-toolchain.sh
# NOTE: renamed in spirit — no longer compiles a cross-toolchain from
# scratch. Uses the Ubuntu runner's pre-installed GCC/Binutils/Glibc as
# the build environment instead (avoids GNU FTP infrastructure issues
# hit when compiling a full LFS cross-toolchain in CI). Downloads all
# LFS source tarballs needed for later stages (02, 04) using the
# official LFS wget-list + md5sums.

set -e

LFS="$HOME/lfs"
export LFS

mkdir -p "$LFS/sources"
cd "$LFS/sources"

echo "==> Downloading official LFS wget-list and md5sums"
wget -nc "https://www.linuxfromscratch.org/lfs/view/stable/wget-list"
wget -nc "https://www.linuxfromscratch.org/lfs/view/stable/md5sums"

echo "==> Rewriting ftp.gnu.org URLs to use Tsinghua mirror (Asia, generally reliable for CI traffic)"
sed -i 's|https://ftp.gnu.org/gnu/|https://mirrors.tuna.tsinghua.edu.cn/gnu/|g' wget-list

echo "==> Downloading all sources from official list (per-file retry loop)"
failed=0
while IFS= read -r url; do
    fname=$(basename "$url")
    tries=0
    until [ -f "$fname" ] && [ -s "$fname" ]; do
        tries=$((tries + 1))
        if [ "$tries" -gt 10 ]; then
            echo "ERROR: failed to download $fname after 10 tries" >&2
            failed=1
            break
        fi
        echo "==> Downloading $fname (attempt $tries)"
        wget -q --timeout=45 -O "$fname.tmp" "$url" && mv "$fname.tmp" "$fname" || { rm -f "$fname.tmp"; sleep 5; }
    done
done < wget-list

if [ "$failed" -eq 1 ]; then
    echo "ERROR: one or more files failed to download after retries" >&2
    exit 1
fi

echo "==> Verifying checksums against official LFS md5sums"
md5sum -c md5sums

echo "==> Confirming build toolchain (Ubuntu-provided, not compiled)"
gcc --version
ld --version | head -1
ldd --version | head -1

echo "==> Source download and toolchain verification complete"
