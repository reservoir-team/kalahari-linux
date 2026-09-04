#!/bin/sh
# 01-toolchain.sh
# Builds the cross toolchain (LFS Chapter 5): binutils pass1, gcc pass1,
# Linux API headers, glibc, libstdc++ pass1.

set -e

LFS="$HOME/lfs"
LFS_TGT="x86_64-lfs-linux-gnu"
export LFS LFS_TGT
export PATH="$LFS/tools/bin:$PATH"

BINUTILS_VER="2.42"
GCC_VER="13.2.0"
GLIBC_VER="2.39"
LINUX_VER="7.3"

cd "$LFS/sources"

echo "==> Downloading official LFS wget-list and md5sums"
wget -nc "https://www.linuxfromscratch.org/lfs/view/stable/wget-list"
wget -nc "https://www.linuxfromscratch.org/lfs/view/stable/md5sums"

echo "==> Rewriting ftp.gnu.org URLs to use ftpmirror.gnu.org (auto-selects a working mirror)"
sed -i 's|https://ftp.gnu.org/gnu/|https://ftpmirror.gnu.org/|g' wget-list

echo "==> Downloading all sources from official list (per-file retry loop)"
failed=0
while IFS= read -r url; do
    fname=$(basename "$url")
    tries=0
    until [ -f "$fname" ] && [ -s "$fname" ]; do
        tries=$((tries + 1))
        if [ "$tries" -gt 5 ]; then
            echo "ERROR: failed to download $fname after 5 tries" >&2
            failed=1
            break
        fi
        echo "==> Downloading $fname (attempt $tries)"
        wget -q --timeout=30 -O "$fname.tmp" "$url" && mv "$fname.tmp" "$fname" || rm -f "$fname.tmp"
    done
done < wget-list

if [ "$failed" -eq 1 ]; then
    echo "ERROR: one or more files failed to download after retries" >&2
    exit 1
fi

echo "==> All files downloaded, verifying count"
expected=$(wc -l < wget-list)
actual=$(find . -maxdepth 1 -type f ! -name "wget-list" ! -name "md5sums" | wc -l)
echo "Expected: $expected files (approx, patches URL not always counted the same), Found: $actual"

echo "==> Verifying checksums against official LFS md5sums"
md5sum -c md5sums

echo "==> Building Binutils (pass 1)"
tar -xf "binutils-${BINUTILS_VER}.tar.xz"
cd "binutils-${BINUTILS_VER}"
mkdir -v build && cd build
../configure --prefix="$LFS/tools" \
    --with-sysroot="$LFS" \
    --target="$LFS_TGT" \
    --disable-nls \
    --enable-gprofng=no \
    --disable-werror
make -j"$(nproc)"
make install
cd "$LFS/sources"

echo "==> Building GCC (pass 1)"
tar -xf "gcc-${GCC_VER}.tar.xz"
cd "gcc-${GCC_VER}"
tar -xf "../mpfr-*.tar.xz" 2>/dev/null || true
mkdir -v build && cd build
../configure \
    --target="$LFS_TGT" \
    --prefix="$LFS/tools" \
    --with-glibc-version=2.39 \
    --with-sysroot="$LFS" \
    --with-newlib \
    --without-headers \
    --enable-default-pie \
    --enable-default-ssp \
    --disable-nls \
    --disable-shared \
    --disable-multilib \
    --disable-threads \
    --disable-libatomic \
    --disable-libgomp \
    --disable-libquadmath \
    --disable-libssp \
    --disable-libvtv \
    --disable-libstdcxx \
    --enable-languages=c,c++
make -j"$(nproc)"
make install
cd "$LFS/sources"

echo "==> Installing Linux API Headers"
tar -xf "linux-${LINUX_VER}.tar.xz"
cd "linux-${LINUX_VER}"
make mrproper
make headers
find usr/include -type f ! -name '*.h' -delete
mkdir -pv "$LFS/usr/include"
cp -rv usr/include/* "$LFS/usr/include/"
cd "$LFS/sources"

echo "==> Building Glibc"
tar -xf "glibc-${GLIBC_VER}.tar.xz"
cd "glibc-${GLIBC_VER}"
mkdir -v build && cd build
echo "rootsbindir=/usr/sbin" > configparms
../configure \
    --prefix=/usr \
    --host="$LFS_TGT" \
    --build="$(../scripts/config.guess)" \
    --enable-kernel=4.19 \
    --with-headers="$LFS/usr/include" \
    libc_cv_slibdir=/usr/lib
make -j"$(nproc)"
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Toolchain (pass 1) build complete"
