#!/bin/sh
# 04-final-system.sh
# Runs inside chroot to build the final system (LFS Chapter 8).
# Must run AFTER entering chroot with /dev, /proc, /sys, /run mounted.

set -e
export LFS="$HOME/lfs"
export LC_ALL=POSIX
export MAKEFLAGS="-j$(nproc)"

cd "$LFS/sources"

echo "==> M4"
tar -xf m4-*.tar.xz && cd m4-*/
./configure --prefix=/usr
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Ncurses"
tar -xf ncurses-*.tar.gz && cd ncurses-*/
./configure --prefix=/usr \
    --mandir=/usr/share/man --with-manpage-format=normal \
    --with-shared --without-normal --with-cxx-shared \
    --without-debug --without-ada --disable-stripping
make
make TIC_PATH="$(pwd)/progs/tic" DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Bash"
tar -xf bash-*.tar.gz && cd bash-*/
./configure --prefix=/usr --without-bash-malloc
make
make DESTDIR="$LFS" install
ln -sv bash "$LFS/bin/sh"
cd "$LFS/sources"

echo "==> Coreutils"
tar -xf coreutils-*.tar.xz && cd coreutils-*/
./configure --prefix=/usr --enable-install-program=hostname --enable-no-install-program=kill,uptime
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Man-pages"
tar -xf man-pages-*.tar.xz && cd man-pages-*/
rm -v man3/crypt*
make DESTDIR="$LFS" prefix=/usr install
cd "$LFS/sources"

echo "==> Iana-Etc"
tar -xf iana-etc-*.tar.gz && cd iana-etc-*/
cp services protocols /etc
cd "$LFS/sources"

echo "==> Glibc (final)"
tar -xf glibc-*.tar.xz && cd glibc-*/
patch -Np1 -i ../glibc-*-fhs-1.patch 2>/dev/null || true
mkdir -v build && cd build
echo "rootsbindir=/usr/sbin" > configparms
../configure --prefix=/usr \
    --disable-werror \
    --enable-kernel=4.19 \
    --enable-stack-protector=strong \
    --with-headers=/usr/include \
    libc_cv_slibdir=/usr/lib
make
make check || true
touch "$LFS/etc/ld.so.conf"
sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
make DESTDIR="$LFS" install
sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd
echo 'hosts: files dns' > "$LFS/etc/nsswitch.conf"
cd "$LFS/sources"

echo "==> Zlib"
tar -xf zlib-*.tar.gz && cd zlib-*/
./configure --prefix=/usr
make
make DESTDIR="$LFS" install
rm -fv "$LFS/usr/lib/libz.a"
cd "$LFS/sources"

echo "==> Bzip2"
tar -xf bzip2-*.tar.gz && cd bzip2-*/
patch -Np1 -i ../bzip2-*-install_docs.patch 2>/dev/null || true
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
sed -i 's@(PREFIX)/man@(PREFIX)/share/man@g' Makefile
make -f Makefile-libbz2_so
make clean
make
make DESTDIR="$LFS" PREFIX=/usr install
cp -av libbz2.so.* "$LFS/usr/lib"
ln -sv libbz2.so.1.0.8 "$LFS/usr/lib/libbz2.so"
cp -v bzip2-shared /usr/bin/bzip2
for i in /usr/bin/{bzcat,bunzip2}; do ln -sfv bzip2 $i; done
rm -fv "$LFS/usr/lib/libbz2.a"
cd "$LFS/sources"

echo "==> Xz"
tar -xf xz-*.tar.xz && cd xz-*/
./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/xz
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Zstd"
tar -xf zstd-*.tar.gz && cd zstd-*/
make prefix=/usr
make DESTDIR="$LFS" prefix=/usr install
rm -v /usr/lib/libzstd.a
cd "$LFS/sources"

echo "==> Part 1 (Man-pages through Zstd) complete"

echo "==> File"
tar -xf file-*.tar.gz && cd file-*/
./configure --prefix=/usr
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Readline"
tar -xf readline-*.tar.gz && cd readline-*/
sed -i '/MV.*old/d' Makefile.in
sed -i '/{OLDSUFF}/c:' support/shlib-install
./configure --prefix=/usr --disable-static --with-curses --docdir=/usr/share/doc/readline
make SHLIB_LIBS="-lncursesw"
make SHLIB_LIBS="-lncursesw" DESTDIR="$LFS" install
install -v -m644 doc/*.3 "$LFS/usr/share/man/man3"
cd "$LFS/sources"

echo "==> M4"
tar -xf m4-*.tar.xz && cd m4-*/
./configure --prefix=/usr
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Bc"
tar -xf bc-*.tar.xz && cd bc-*/
CC=gcc ./configure --prefix=/usr -G -O3 -r
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Flex"
tar -xf flex-*.tar.gz && cd flex-*/
./configure --prefix=/usr --docdir=/usr/share/doc/flex --disable-static
make
make DESTDIR="$LFS" install
ln -sv flex "$LFS/usr/bin/lex"
cd "$LFS/sources"

echo "==> Binutils (final)"
tar -xf binutils-*.tar.xz && cd binutils-*/
mkdir -v build && cd build
../configure --prefix=/usr \
    --sysconfdir=/etc \
    --enable-gold \
    --enable-ld=default \
    --enable-plugins \
    --enable-shared \
    --disable-werror \
    --enable-64-bit-bfd \
    --with-system-zlib
make tooldir=/usr
make DESTDIR="$LFS" tooldir=/usr install
rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a
cd "$LFS/sources"

echo "==> GMP"
tar -xf gmp-*.tar.xz && cd gmp-*/
./configure --prefix=/usr --enable-cxx --disable-static --docdir=/usr/share/doc/gmp
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> MPFR"
tar -xf mpfr-*.tar.xz && cd mpfr-*/
./configure --prefix=/usr --disable-static --enable-thread-safe --docdir=/usr/share/doc/mpfr
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> MPC"
tar -xf mpc-*.tar.gz && cd mpc-*/
./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/mpc
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Part 2 (File through MPC) complete"

echo "==> Attr + Acl (installed via apt on host, copied into chroot rootfs — savannah unreachable from CI)"
for lib in libattr.so* libacl.so*; do
    find /usr/lib/x86_64-linux-gnu /lib/x86_64-linux-gnu -name "$lib" 2>/dev/null -exec cp -av {} /usr/lib/ \;
done
for bin in getfattr setfattr getfacl setfacl chacl; do
    command -v "$bin" >/dev/null 2>&1 && cp -av "$(command -v "$bin")" /usr/bin/
done

echo "==> Libcap"
tar -xf libcap-*.tar.xz && cd libcap-*/
sed -i '/install -m.*STA/d' libcap/Makefile
make prefix=/usr lib=lib
make DESTDIR="$LFS" prefix=/usr lib=lib install
cd "$LFS/sources"

echo "==> Shadow"
tar -xf shadow-*.tar.xz && cd shadow-*/
sed -i 's/#ENCRYPT_METHOD DES/ENCRYPT_METHOD YESCRYPT/' etc/login.defs
sed -i 's@#\(SHA_CRYPT_..._ROUNDS\)@\1@' etc/login.defs
sed -i -e 's:#USE_PAM.*:USE_PAM yes:' etc/login.defs
touch "$LFS/usr/bin/passwd"
./configure --sysconfdir=/etc --disable-static --with-{b,y}crypt --without-libbsd --with-group-name-max-length=32
make
make DESTDIR="$LFS" exec_prefix=/usr install
make -C man DESTDIR="$LFS" install-man
mkdir -p /etc/default
sed -i '/MAIL_CHECK_ENAB/{s/yes/no/}' "$LFS/etc/login.defs"
cd "$LFS/sources"

echo "==> GCC (final)"
tar -xf gcc-*.tar.xz && cd gcc-*/
sed '/thread_header =/s/@.*@/gthr-posix.h/' -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in
mkdir -v build && cd build
../configure --prefix=/usr \
    LD=ld \
    --enable-languages=c,c++ \
    --enable-default-pie \
    --enable-default-ssp \
    --disable-multilib \
    --disable-bootstrap \
    --disable-fixincludes \
    --with-system-zlib
make
make DESTDIR="$LFS" install
ln -sfv gcc /usr/bin/cc
cd "$LFS/sources"

echo "==> Pkg-config"
tar -xf pkg-config-*.tar.gz && cd pkg-config-*/
./configure --prefix=/usr --with-internal-glib --disable-host-tool --docdir=/usr/share/doc/pkg-config
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Ncurses (final, with widechar already built earlier if needed)"
tar -xf ncurses-*.tar.gz && cd ncurses-*/
./configure --prefix=/usr --mandir=/usr/share/man \
    --with-shared --without-debug --without-normal --with-cxx-shared \
    --enable-pc-files --with-pkg-config-libdir=/usr/lib/pkgconfig
make
make DESTDIR="$LFS" install
for lib in ncurses form panel menu ; do
    rm -vf /usr/lib/lib${lib}.a
    ln -sfv lib${lib}w.so /usr/lib/lib${lib}.so
done
rm -vf /usr/lib/libcursesw.so
ln -sfv libncursesw.so /usr/lib/libcursesw.so
ln -sfv libncurses.so /usr/lib/libcurses.so
cd "$LFS/sources"

echo "==> Sed"
tar -xf sed-*.tar.xz && cd sed-*/
./configure --prefix=/usr
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Psmisc"
tar -xf psmisc-*.tar.xz && cd psmisc-*/
./configure --prefix=/usr
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Gettext"
tar -xf gettext-*.tar.xz && cd gettext-*/
./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/gettext
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Bison"
tar -xf bison-*.tar.xz && cd bison-*/
./configure --prefix=/usr --docdir=/usr/share/doc/bison
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Part 3 (Attr through Bison) complete"

echo "==> Grep"
tar -xf grep-*.tar.xz && cd grep-*/
./configure --prefix=/usr
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Bash (final)"
tar -xf bash-*.tar.gz && cd bash-*/
./configure --prefix=/usr --without-bash-malloc --with-installed-readline
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Libtool"
tar -xf libtool-*.tar.xz && cd libtool-*/
./configure --prefix=/usr
make
make DESTDIR="$LFS" install
rm -fv "$LFS/usr/lib/libltdl.a"
cd "$LFS/sources"

echo "==> GDBM"
tar -xf gdbm-*.tar.gz && cd gdbm-*/
./configure --prefix=/usr --disable-static --enable-libgdbm-compat
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Gperf"
tar -xf gperf-*.tar.gz && cd gperf-*/
./configure --prefix=/usr --docdir=/usr/share/doc/gperf
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Expat"
tar -xf expat-*.tar.xz && cd expat-*/
./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/expat
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Inetutils"
tar -xf inetutils-*.tar.xz && cd inetutils-*/
./configure --prefix=/usr --bindir=/usr/bin --localstatedir=/var --disable-logger \
    --disable-whois --disable-rcp --disable-rexec --disable-rlogin \
    --disable-rsh --disable-servers
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Less"
tar -xf less-*.tar.gz && cd less-*/
./configure --prefix=/usr --sysconfdir=/etc
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Perl"
tar -xf perl-*.tar.xz && cd perl-*/
sh Configure -des -Dprefix=/usr -Dvendorprefix=/usr \
    -Dprivlib=/usr/lib/perl5/5.40/core_perl \
    -Darchlib=/usr/lib/perl5/5.40/core_perl \
    -Dsitelib=/usr/lib/perl5/5.40/site_perl \
    -Dsitearch=/usr/lib/perl5/5.40/site_perl \
    -Dvendorlib=/usr/lib/perl5/5.40/vendor_perl \
    -Dvendorarch=/usr/lib/perl5/5.40/vendor_perl \
    -Dman1dir=/usr/share/man/man1 \
    -Dman3dir=/usr/share/man/man3 \
    -Dpager="/usr/bin/less -isR" \
    -Duseshrplib \
    -Dusethreads
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Autoconf"
tar -xf autoconf-*.tar.xz && cd autoconf-*/
./configure --prefix=/usr
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Automake"
tar -xf automake-*.tar.xz && cd automake-*/
./configure --prefix=/usr --docdir=/usr/share/doc/automake
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> OpenSSL"
tar -xf openssl-*.tar.gz && cd openssl-*/
./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib shared zlib-dynamic
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Part 4 (Grep through OpenSSL) complete"

echo "==> Kmod"
tar -xf kmod-*.tar.xz && cd kmod-*/
./configure --prefix=/usr --sysconfdir=/etc --with-openssl --with-xz --with-zstd --disable-manpages
make
make DESTDIR="$LFS" install
for target in depmod insmod modinfo modprobe rmmod; do
    ln -sfv ../bin/kmod /usr/sbin/$target
done
cd "$LFS/sources"

echo "==> Elfutils"
tar -xf elfutils-*.tar.bz2 && cd elfutils-*/
./configure --prefix=/usr --disable-debuginfod --enable-libdebuginfod=dummy
make
make -C libelf DESTDIR="$LFS" install
mkdir -pv "$LFS/usr/lib/pkgconfig"
install -vm644 config/libelf.pc "$LFS/usr/lib/pkgconfig"
rm -v /usr/lib/libelf.a
cd "$LFS/sources"

echo "==> Libffi"
tar -xf libffi-*.tar.gz && cd libffi-*/
./configure --prefix=/usr --disable-static --with-gcc-arch=native
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Python3"
tar -xf Python-*.tar.xz && cd Python-*/
./configure --prefix=/usr --enable-shared --with-system-expat \
    --enable-optimizations
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Coreutils (final)"
tar -xf coreutils-*.tar.xz && cd coreutils-*/
./configure --prefix=/usr --enable-no-install-program=kill,uptime
make
make DESTDIR="$LFS" install
mv -v /usr/bin/chroot /usr/sbin
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8
cd "$LFS/sources"

echo "==> Diffutils"
tar -xf diffutils-*.tar.xz && cd diffutils-*/
./configure --prefix=/usr
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Gawk"
tar -xf gawk-*.tar.xz && cd gawk-*/
sed -i 's/extras//' Makefile.in
./configure --prefix=/usr
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Findutils"
tar -xf findutils-*.tar.xz && cd findutils-*/
./configure --prefix=/usr --localstatedir=/var/lib/locate
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Groff"
tar -xf groff-*.tar.gz && cd groff-*/
PAGE=A4 ./configure --prefix=/usr
make -j1
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Part 5 (Kmod through Groff) complete"

echo "==> Gzip"
tar -xf gzip-*.tar.xz && cd gzip-*/
./configure --prefix=/usr
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> IPRoute2"
tar -xf iproute2-*.tar.xz && cd iproute2-*/
sed -i /ARPD/d Makefile
rm -fv man/man8/arpd.8
make NETNS_RUN_DIR=/run/netns
make DESTDIR="$LFS" SBINDIR=/usr/sbin install
cd "$LFS/sources"

echo "==> Kbd"
tar -xf kbd-*.tar.xz && cd kbd-*/
sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in
./configure --prefix=/usr --disable-vlock
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Libpipeline + Man-db (installed via apt on host, copied into chroot rootfs — savannah unreachable from CI)"
find /usr/lib/x86_64-linux-gnu /lib/x86_64-linux-gnu -name "libpipeline.so*" 2>/dev/null -exec cp -av {} /usr/lib/ \;
command -v man >/dev/null 2>&1 && cp -av "$(command -v man)" /usr/bin/
command -v mandb >/dev/null 2>&1 && cp -av "$(command -v mandb)" /usr/bin/
mkdir -pv "$LFS/etc/man_db.conf.d"
cp -av /etc/man_db.conf "$LFS/etc/man_db.conf" 2>/dev/null || true

echo "==> Make"
tar -xf make-*.tar.gz && cd make-*/
./configure --prefix=/usr
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Patch"
tar -xf patch-*.tar.xz && cd patch-*/
./configure --prefix=/usr
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Tar"
tar -xf tar-*.tar.xz && cd tar-*/
./configure --prefix=/usr
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Texinfo"
tar -xf texinfo-*.tar.xz && cd texinfo-*/
./configure --prefix=/usr
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Vim"
tar -xf vim-*.tar.gz && cd vim-*/
echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
./configure --prefix=/usr
make
make DESTDIR="$LFS" install
ln -sv vim "$LFS/usr/bin/vi"
for L in "$LFS"/usr/share/man/{,*/}man1/vim.1; do
    [ -e "$L" ] || continue
    ln -sv vim.1 "$(dirname "$L")/vi.1"
done
cat > "$LFS/etc/vimrc" << EOF
set nocompatible
set backspace=2
syntax on
set mouse=
inoremap <C-U> <C-G>u<C-U>
EOF
cd "$LFS/sources"

echo "==> Eudev"
tar -xf eudev-*.tar.gz && cd eudev-*/
./configure --prefix=/usr --bindir=/usr/sbin --sbindir=/usr/sbin \
    --libdir=/usr/lib --sysconfdir=/etc --enable-manpages --disable-static

echo "==> Oniguruma (jq dependency)"
tar -xf onig-*.tar.gz && cd onig-*/
./configure --prefix=/usr --disable-static
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> jq"
tar -xf jq-*.tar.gz && cd jq-*/
./configure --prefix=/usr --disable-static --disable-maintainer-mode
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> jq (kpk dependency) installed"

echo "==> Dhcpcd"
tar -xf dhcpcd-*.tar.xz && cd dhcpcd-*/
./configure --prefix=/usr --sysconfdir=/etc --libexecdir=/usr/lib/dhcpcd \
    --dbdir=/var/lib/dhcpcd --rundir=/run
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Iwd (requires ell library first)"
tar -xf ell-*.tar.gz && cd ell-*/
./configure --prefix=/usr --disable-static
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

tar -xf iwd-*.tar.xz && cd iwd-*/
./configure --prefix=/usr --libexecdir=/usr/lib --localstatedir=/var \
    --enable-external-ell=no
make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Networking tools (iwd + dhcpcd) installed"

make
make DESTDIR="$LFS" install
cd "$LFS/sources"

echo "==> Final system (Chapter 8) build complete"
