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
| `docs/` | published signed binaries, `x86_64-repodata`, repository public key and landing page |

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
5. Sign the package, rebuild the index and sign the repository:

   ```sh
   xbps-rindex -S --privkey="$HOME/.config/Khame-void-repo-private.pem" \
     --signedby="Khame <lukasz.linhard@gmail.com>" hostdir/binpkgs/asusctl-*.xbps
   cp hostdir/binpkgs/asusctl-*.xbps hostdir/binpkgs/asusctl-*.xbps.sig2 docs/
   xbps-rindex -a docs/asusctl-*.xbps
   xbps-rindex -s --privkey="$HOME/.config/Khame-void-repo-private.pem" \
     --signedby="Khame <lukasz.linhard@gmail.com>" docs
   ```

6. Remove the previous package version from `docs/` so the index lists one version only.
7. Commit and push `Khame/void-packages`. GitHub Pages serves the `docs/` directory of `main`, so the repository is published at `https://khame.github.io/void-packages/`.
8. Attach the same `.xbps` to a GitHub Release in this repository and update the version references in `README.md`.

Packages are signed with the Khame repository RSA key. The private key is kept outside both repositories, for example at `~/.config/Khame-void-repo-private.pem` with mode `600`. The public key must be copied to `docs/Khame-void-repo.pub`; users import it as `/var/db/xbps/keys/Khame-void-repo.pem` before installing. Unsigned installation (`allow-unsigned`) is never supported.

The repository index (`x86_64-repodata`) carries no separate signature: `xbps` verifies each package against the imported public key. Only the `x86_64` architecture is published.

Two packaging traps worth remembering:

- Empty directories do not survive `.xbps` creation, so `vmkdir var/log/asusd` has no effect. Create runtime directories in the runit run script instead.
- Reusing the same `version` and `revision` requires `./xbps-src -f pkg asusctl`; without `-f` the previous package is reused.

No CI runs on these repositories; releases are built and published manually.

## Author and license

- **Khame** — `lukasz.linhard@gmail.com`
- Assisted by **AI**
- MIT for the material authored in this repository; upstream asusctl is MPL-2.0.
