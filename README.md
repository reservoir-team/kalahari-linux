# Kalahari Linux

A desert-themed Linux distribution built from scratch, LFS/ALFS-style.

## Overview

- **Kernel:** vanilla Linux 7.3, EEVDF scheduler (built into fair_sched_class since 6.6+, no special config needed)
- **Boot method:** EFISTUB (kernel is a direct EFI executable — no GRUB/Limine)
- **Init system:** [dinit](https://github.com/davmac314/dinit)
- **Networking:** iwd + dhcpcd
- **Package manager:** [kpk](kpk/) (Kalahari Package Keeper) — a POSIX shell package manager, fetches from [kpk-packages](https://github.com/reservoir-team/kpk-packages)
- **Architecture:** x86_64
- **Build system:** GitHub Actions CI, custom LFS/ALFS-style build scripts (compiles final-system packages using the CI runner's toolchain)

## Building

Kalahari Linux is built entirely through GitHub Actions. See [`.github/workflows/build.yml`](.github/workflows/build.yml) for the full build pipeline:

1. **Host prep** — update/upgrade the runner and install build dependencies
2. **Download sources** — fetch all LFS source tarballs via the official LFS `wget-list`/`md5sums`
3. **Temporary system** — build core utilities needed before entering chroot
4. **Chroot & final system** — build the ~70-package LFS final system (Chapter 8 equivalent), dinit, kernel, kpk integration, and branding, all inside a chroot
5. **Image** — assemble a bootable ISO using EFISTUB (no bootloader chain)

Build artifacts (the ISO) are uploaded automatically on each successful build — check the [Actions tab](../../actions) for the latest.

## kpk — Kalahari Package Keeper

`kpk` is a POSIX shell package manager, using package-first command ordering:

```sh
kpk hello install   # install a package
kpk hello remove    # remove a package
kpk hello search    # search for a package
kpk all update       # refresh the package index
```
Packages are .kpk.tar.zst archives (a .kpkmeta file plus categorized folders — binary/, man/, lib/, etc.) built and published by the kpk-packages repo's own CI pipeline. See kpk/ for the client script.

## Status
Early development. The build pipeline is under active iteration — source downloads and the final system build are being debugged in CI. kpk and the kpk-packages pipeline are validated and working end-to-end.

## License
GPLv3 — see [LICENSE](LICENSE)
