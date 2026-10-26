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
- The version is a git snapshot: `version=6.5.0.20261024` plus `_commit=13cdaa9ccbc0b519d3c888c1c9d97e00faf91cf9`. `distfiles` uses `${_commit}` and no `wrksrc` is needed; `xbps-src` renames the extracted top-level directory to `$wrksrc` automatically.
- `data/asusd.rules` is not installed. Its only actions are `TAG+="systemd"` and `ENV{SYSTEMD_WANTS}+="asusd.service asus-shutdown.service"`; eudev ignores both, and `asusd` is started by runit.
- `asus-shutdown` is not installed. It blocks on a `PrepareForShutdown` signal from logind and calls `systemctl`; runit's `/usr/bin/shutdown` never sends that signal, so the helper would never apply its deferred GPU settings.
- runit replaces systemd: `/etc/sv/asusd` and `/etc/sv/asusd/log` are installed from `files/`. The logger creates `/var/log/asusd` itself because empty directories do not survive package creation.
- The Plasma widget ships inside the main package. Runtime requirements are in `srcpkgs/asusctl/INSTALL.msg`, not in `optdepends`: `xbps-src` does not support an `optdepends` variable and silently ignores it.

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
2. Update `version=`, `_commit=`, point `distfiles=` at the new commit or tag archive URL and let `xbps-src` compute the new `checksum=`.
3. Increase `revision=` for template-only changes that keep the same upstream version.
4. Run `xlint srcpkgs/asusctl/template` and fix every warning before building.
5. Build, install and test locally. After replacing a run script, restart the service and its logger separately: `sudo sv restart asusd` does not restart `asusd/log`.
6. Pick the package that was just built and sign it:

   ```sh
   pkg=$(ls -t hostdir/binpkgs/asusctl-*.xbps | head -1)
   xbps-rindex -S --privkey="$HOME/.config/Khame-void-repo-private.pem" \
     --signedby="Khame <lukasz.linhard@gmail.com>" "$pkg"
   ```

7. Remove the previous package and signature from `docs/`, copy the new pair and rebuild the index. Do not pass a `asusctl-*.xbps` glob to `xbps-rindex -a`: it would also match the old package and could register that version instead.

   ```sh
   rm -f docs/asusctl-*.xbps docs/asusctl-*.xbps.sig2
   cp "$pkg" "$pkg.sig2" docs/
   xbps-rindex -a "docs/$(basename "$pkg")"
   xbps-rindex -s --privkey="$HOME/.config/Khame-void-repo-private.pem" \
     --signedby="Khame <lukasz.linhard@gmail.com>" docs
   ```

8. Commit and push `Khame/void-packages`. GitHub Pages serves the `docs/` directory of `main`, so the repository is published at `https://khame.github.io/void-packages/`.
9. Attach the same `.xbps` to a GitHub Release in this repository and update the version references in `README.md`.

Packages are signed with the Khame repository RSA key. The private key is kept outside both repositories, for example at `~/.config/Khame-void-repo-private.pem` with mode `600`. The public key is copied to `docs/Khame-void-repo.pub` for manual verification, and `xbps-rindex -s` embeds it in the repository index. Users do not place a `.pem` in `/var/db/xbps/keys/` manually: `xbps` imports the key from the index on the first `xbps-install -S` and stores it as `<fingerprint>.plist` (currently `35:2b:06:7c:52:04:76:b1:4a:de:a0:8b:49:9c:e2:66.plist`). Unsigned installation (`allow-unsigned`) is never supported.

The repository index (`x86_64-repodata`) carries no separate signature: `xbps` verifies each package against the imported public key. Only the `x86_64` architecture is published.

Two packaging traps worth remembering:

- Empty directories do not survive `.xbps` creation, so `vmkdir var/log/asusd` has no effect. Create runtime directories in the runit run script instead.
- Reusing the same `version` and `revision` requires `./xbps-src -f pkg asusctl`; without `-f` the previous package is reused.

No CI runs on these repositories; releases are built and published manually.

## Author and license

- **Khame** — `lukasz.linhard@gmail.com`
- Assisted by **AI**
- MIT for the material authored in this repository; upstream asusctl is MPL-2.0.
