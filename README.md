# Kalahari Linux

A desert-themed desktop operating system built on the [Managarm](https://managarm.org) microkernel.

## Overview

- **Kernel:** Managarm (microkernel)
- **Libc:** mlibc
- **Init system:** systemd (Managarm's official default)
- **Package manager:** [kpk](kpk/) (Kalahari Package Keeper) — a frontend wrapping [xbps](https://github.com/void-linux/xbps)
- **Architecture:** x86_64
- **Build system:** [xbstrap](https://github.com/managarm/xbstrap), via GitHub Actions CI

## Building

Kalahari Linux is built entirely through GitHub Actions. See [`.github/workflows/build.yml`](.github/workflows/build.yml) for the full build pipeline:

1. Install `xbstrap`, `y4` (Managarm's YAML preprocessor), and static `xbps` tools
2. Clone [`bootstrap-managarm`](https://github.com/managarm/bootstrap-managarm) and download the official Managarm buildenv
3. Run `xbstrap` to install the cross-toolchain, kernel, mlibc, and system packages
4. Build a bootable disk image via `xbstrap run make-image`

Build artifacts (disk images) are uploaded automatically on each successful build — check the [Actions tab](../../actions) for the latest.

## kpk — Kalahari Package Keeper

`kpk` is a simple shell wrapper around `xbps`, using package-first command ordering:

```sh
kpk firefox install   # install a package
kpk firefox remove    # remove a package
kpk firefox search    # search for a package
kpk firefox update    # update a package
kpk all update         # update all packages
```
See **kpk/** for the script.

## Status

Early development. The build pipeline produces a working disk image; OS customization (branding, default desktop environment, kpk integration) is ongoing.

## License

GPLv3 — see [LICENSE](LICENSE)
