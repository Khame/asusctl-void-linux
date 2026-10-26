# Void Linux Packaging — asusctl Maintainer Guide

This repository holds installation documentation and release notes for the `asusctl` package. It contains no packaging source: the template and service files live in [`Khame/void-packages`](https://github.com/Khame/void-packages) under `srcpkgs/asusctl/`, which is the single source of truth.

For user-facing installation instructions see [README.md](README.md).

## Package layout

| Path (in `Khame/void-packages`) | Purpose |
|---|---|
| `srcpkgs/asusctl/template` | `xbps-src` template: version, checksums, dependency lists, `do_install` |
| `srcpkgs/asusctl/files/asusd/run` | runit `run` script for `asusd` |
| `srcpkgs/asusctl/files/asusd-log/run` | `svlogd` logger for `/var/log/asusd` |
| `srcpkgs/asusctl/files/xdg-autostart/asusd-user.desktop` | session autostart for `asusd-user` |
| `srcpkgs/asusctl/files/plasmoid/` | KDE Plasma widget (QML) |
| `docs/hostdir/binpkgs/` | published signed binaries and repository metadata |

## Template characteristics

- `build_style=gnu-makefile` with `make_build_target="all"`.
- Upstream `make install` is not used, because it installs systemd units. All files are placed explicitly in `do_install`.
- `post_patch` removes the `systemctl` callout from `data/asusd.rules`; runit has no such command and udev logs errors on every hotplug otherwise.
- runit replaces systemd: `/etc/sv/asusd` and `/etc/sv/asusd/log` are installed from `files/`.
- The Plasma widget ships inside the main package. `plasma-workspace` and `kirigami2` are `optdepends`, so non-KDE systems do not pull them in.
- `vmkdir var/log/asusd` in `do_install` gives `svlogd` a writable directory.

Build dependencies: `pkg-config rust cargo clang cmake gettext git`, plus `eudev-libudev-devel dbus-devel pcre2-devel libxkbcommon-devel libzstd-devel gtk+3-devel`. Runtime dependencies are `dbus eudev`.

## Building locally

```sh
git clone --depth=1 https://github.com/void-linux/void-packages.git
cd void-packages
./xbps-src binary-bootstrap

git clone --depth=1 https://github.com/Khame/void-packages.git /tmp/khame-void-packages
cp -a /tmp/khame-void-packages/srcpkgs/asusctl srcpkgs/

./xbps-src pkg asusctl
./xbps-src check asusctl
sudo xbps-install --repository=hostdir/binpkgs asusctl
```

The built package appears in `hostdir/binpkgs/`. Testing the service before publishing:

```sh
sudo ln -sfn /etc/sv/asusd /var/service/asusd
sudo sv status asusd
sudo sv down asusd
```

## Releasing a new version

1. Check the upstream version and compare it with `version=` in the template. Do nothing if it is unchanged.
2. Update `version=`, point `distfiles=` at the new commit or tag archive URL and let `xbps-src` compute the new `checksum=`.
3. Increase `revision=` for template-only changes that keep the same upstream version.
4. Build, install and test locally.
5. Copy the resulting `.xbps` and `.sig2` files into `docs/hostdir/binpkgs/`, regenerate `repodata`, and publish from `Khame/void-packages`.
6. Attach the same `.xbps` to a GitHub Release in this repository and update the version references in `README.md`.

Packages are signed with the Khame repository RSA key; the private key is kept outside both repositories. The public key is published at `https://khame.github.io/void-packages/Khame-void-repo.pub` and must be imported by users before installation. Unsigned installation (`allow-unsigned`) is never supported.

No CI runs on these repositories; releases are built and published manually.

## Author and license

- **Khame** — `lukasz.linhard@gmail.com`
- Assisted by **AI**
- MIT for the material authored in this repository; upstream asusctl is MPL-2.0.
