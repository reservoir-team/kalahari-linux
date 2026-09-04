#!/bin/sh
# 02-tempsystem.sh
# Builds the temporary system (LFS Chapter 6): rebuilds toolchain against
# the target, then builds core temp utilities needed before chroot.

set -e

LFS="$HOME/lfs"
LFS_TGT="x86_64-lfs-linux-gnu"
export LFS LFS_TGT
export PATH="$LFS/tools/bin:$PATH"

cd "$LFS/sources"

echo "==> Building Libstdc++ (pass 1, against glibc)"
cd "gcc-13.2.0/build"
../libstdc++-v3/configure \
    --host="$LFS_TGT" \
    --build="$(../config.guess)" \
    --prefix=/usr \
    --disable-multilib \
    --disable-nls \
    --disable-libstdcxx-pch \
    --with-gxx-include-dir="/usr/${LFS_TGT}/include/c++/13.2.0"
make -j"$(nproc)"
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Building M4"
tar -xf m4-*.tar.xz && cd m4-*/
./configure --prefix=/usr --host="$LFS_TGT" --build="$(build-aux/config.guess)"
make -j"$(nproc)"
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Building Ncurses"
tar -xf ncurses-*.tar.gz && cd ncurses-*/
./configure --prefix=/usr --host="$LFS_TGT" --build="$(config.guess)" \
    --mandir=/usr/share/man --with-manpage-format=normal \
    --with-shared --without-normal --with-cxx-shared \
    --without-debug --without-ada --disable-stripping
make -j"$(nproc)"
make DESTDIR="$LFS" TIC_PATH="$(pwd)/progs/tic" install
cd "$LFS/sources"

echo "==> Building Bash"
tar -xf bash-*.tar.gz && cd bash-*/
./configure --prefix=/usr --build="$(support/config.guess)" \
    --host="$LFS_TGT" --without-bash-malloc
make -j"$(nproc)"
make DESTDIR="$LFS" install
ln -sv bash "$LFS/bin/sh"
cd "$LFS/sources"

echo "==> Building Coreutils"
tar -xf coreutils-*.tar.xz && cd coreutils-*/
./configure --prefix=/usr --host="$LFS_TGT" --build="$(build-aux/config.guess)" \
    --enable-install-program=hostname --enable-no-install-program=kill,uptime
make -j"$(nproc)"
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Building Diffutils, File, Findutils, Gawk, Grep, Gzip, Make, Patch, Sed, Tar, Xz"
# NOTE: repeat the same configure/make/install pattern for each package below.
# Left as placeholders — fill in per LFS book section "6.x" for each tool.

echo "==> Temporary system build complete"
