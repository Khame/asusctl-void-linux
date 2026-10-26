# asusctl for Void Linux

Packaging of [asusctl](https://github.com/OpenGamingCollective/asusctl) for Void Linux: the `asusd` daemon, command-line tools and an optional KDE Plasma widget. Services run under the native runit supervision tree — no systemd units are installed.

## Why this exists

I built this package for my own laptop: I wanted asusctl on Void Linux, which uses runit instead of systemd, and nothing packaged it that way. It has been running here since then, so I shared it in case someone else finds it useful.

This is a personal project, not an official Void package, and comes with no support commitment. Bug reports and patches are welcome.

## Installation

### Option 1: Signed XBPS repository (recommended)

```sh
# 1. Add the repository
sudo sh -c 'echo "repository=https://khame.github.io/void-packages/" > /etc/xbps.d/10-khame.conf'

# 2. Sync the index; xbps asks to import the repository key — answer Y
sudo xbps-install -S

# 3. Install
sudo xbps-install asusctl
```

The repository key is embedded in the signed index and imported by `xbps` automatically; it is stored as `/var/db/xbps/keys/35:2b:06:7c:52:04:76:b1:4a:de:a0:8b:49:9c:e2:66.plist`. The public key is also published as [`Khame-void-repo.pub`](https://khame.github.io/void-packages/Khame-void-repo.pub) if you want to verify it manually.

Updates arrive through the usual `sudo xbps-install -Su`. Only `x86_64` packages are published.

### Option 2: GitHub Release asset

```sh
# Import the repository key first (Option 1, steps 1-2), then:
sudo xbps-install --binary-package-url https://github.com/Khame/asusctl-void-linux/releases/download/v6.5.0/asusctl-6.5.0.20261024_2.x86_64.xbps
```

Suitable for a one-off install of a specific build. Updates are manual. The release also carries the `.sig2` signature and `Khame-void-repo.pub`; key fingerprint `35:2b:06:7c:52:04:76:b1:4a:de:a0:8b:49:9c:e2:66`.

### Option 3: Build from source

The packaging source lives in [`Khame/void-packages`](https://github.com/Khame/void-packages), not in this documentation repository.

```sh
# 1. Prepare a build tree
git clone --depth=1 https://github.com/void-linux/void-packages.git
cd void-packages
./xbps-src binary-bootstrap

# 2. Copy the asusctl package in
git clone --depth=1 https://github.com/Khame/void-packages.git /tmp/khame-void-packages
cp -a /tmp/khame-void-packages/srcpkgs/asusctl srcpkgs/

# 3. Build and install
./xbps-src pkg asusctl
sudo xbps-install --repository=hostdir/binpkgs asusctl
```

Use this option when you want to modify the template or build for a different revision.

## Enable the service

The runit service is installed at `/etc/sv/asusd`:

```sh
sudo ln -s /etc/sv/asusd /var/service/asusd
sudo sv up asusd
sudo sv status asusd
```

Skip `ln -s` if `/var/service/asusd` already exists. The package creates `/var/log/asusd` for the bundled `svlogd` logger, and an XDG autostart entry launches `asusd-user` when a desktop session starts.

## What the package installs

- `asusd` — system daemon (runit service `asusd`, logging to `/var/log/asusd`)
- `asusctl`, `asusd-user`, `rog-control-center` — CLI and GUI tools
- D-Bus policy, keyboard layouts and notification icons
- KDE Plasma widget `org.voidlinux.plasma.asusctl` (Aura lighting, battery charge limit, keyboard and Aura on/off control)

The upstream `asus-shutdown` helper and its udev rule are not installed: both depend on systemd and do nothing under runit.

Add the widget through Plasma's widget picker after installation. It requires KDE Plasma 6: the package's `INSTALL.msg` lists `plasma-workspace`, `kf6-kirigami` and `plasma5support`. The widget is optional: on GNOME, XFCE, sway or a plain console the daemon and CLI tools work on their own.

## Requirements

- **Kernel:** 6.19 or newer (for `asus-armoury` driver support)
- **Architecture:** `x86_64`
- **Init:** runit (systemd is not supported)

## Tested on

- **ASUS ROG Strix G513QM** — AMD Ryzen 9 5900HX, hybrid graphics (Radeon Vega iGPU + NVIDIA GeForce RTX 3060 Mobile / Max-Q), 16 GB RAM; Void Linux `x86_64` (glibc), kernel 7.3, XBPS 0.60.7, runit, KDE Plasma 6.7.5 on Wayland. `asusd`, `asusctl` and `rog-control-center` are in daily use.
- **Clean Void `x86_64` LXC container** — installation from the signed repository, RSA signature verification and the installed file layout. It has no ASUS WMI device, so `asusd` exits with `MissingFunction("asus-nb-wmi not found")`; that is expected and not a packaging defect.

Only `x86_64` with glibc is built and published; musl is untested.

## Repository layout

- `README.md` — installation and usage (this file)
- `VOID_PACKAGING.md` — maintainer guide: template layout, build and release procedure
- `LICENSE` — MIT for the material authored in this repository

Build files are not duplicated here; `srcpkgs/asusctl/` in [`Khame/void-packages`](https://github.com/Khame/void-packages) is the single source of truth.

## Upstream

- Project: [OpenGamingCollective/asusctl](https://github.com/OpenGamingCollective/asusctl)
- Packaged version: `6.5.0.20261024_2` (commit `13cdaa9ccbc0b519d3c888c1c9d97e00faf91cf9`)
- Upstream license: MPL-2.0

## Author

- **Khame** — `lukasz.linhard@gmail.com`
- Assisted by **AI**
