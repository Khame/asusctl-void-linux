# asusctl for Void Linux

Packaging for [asusctl](https://github.com/OpenGamingCollective/asusctl), including the `asusd` system daemon, command-line tools, and a KDE Plasma widget. This package uses Void's runit service management; it does not install a systemd service.

## 📦 Two package variants

This repository provides **two installable package variants** via Void subpackages:

### `asusctl` (bez widgetu Plasma - domyślny)
- **Mniejsza paczka** – tylko daemon `asusd` i narzędzia CLI
- **Działa na wszystkich środowiskach** – GNOME, XFCE, sway, itp.
- **Brak zależności KDE** – `depends="dbus eudec"`
- Instaluj: `sudo xbps-install asusctl`

### `asusctl-plasma` (z widgetem Plasma)
- **Dodatkowa subpakejka** – zawiera widget KDE Plasma
- **Wymaga KDE** – `depends="plasma-workspace kirigami2"`
- Instaluj równolegle: `sudo xbps-install asusctl asusctl-plasma`

> **Uwaga:** Domyślnie paczka `asusctl` nie zawiera widgetu Plasma, aby była lżejsza i działała na każdym systemie. Widget można dodać instalując subpakejkę `asusctl-plasma`.

## Requirements

- **Kernel:** 6.19 or newer (for `asus-armoury` driver support)
- **Architecture:** x86_64
- **Init:** runit (no systemd)

## Install (binary)

The published Khame XBPS repository provides the binary package for `x86_64`. First add the repository:

```sh
git clone --depth=1 https://github.com/Khame/asusctl-void-linux.git
cd asusctl-void-linux
# To install binary from repo (after repo is set up):
sudo xbps-install asusctl
```

> **Wariant z widgetem Plasma:**
> ```sh
> sudo xbps-install asusctl asusctl-plasma
> ```

Or install from GitHub Releases (no need to add repository manually):

```sh
sudo xbps-install --binary-package-url https://github.com/Khame/asusctl-void-linux/releases/download/v6.5.0/asusctl-6.5.0.git20261024_1.x86_64.xbps
```

## GitHub Releases

A signed binary package is available as a GitHub Release asset:

- **Tag:** `v6.5.0`
- **Package:** `asusctl-6.5.0.git20261024_1.x86_64.xbps` (15.8 MB)
- **Download:** https://github.com/Khame/asusctl-void-linux/releases/tag/v6.5.0

The repository is **RSA-signed**. Install the public key first:

```sh
sudo sh -c 'curl -sL https://khame.github.io/void-packages/Khame-void-repo.pub -o /var/db/xbps/keys/Khame-void-repo.pem'
```

Then add the repository and install:

```sh
sudo sh -c 'echo "repository=https://khame.github.io/void-packages/" > /etc/xbps.d/10-khame.conf'
sudo xbps-install -S
sudo xbps-install asusctl
```

## GitHub Actions CI

This repository does not include automatic GitHub Actions CI because the Personal Access Token used for deployment lacks the `workflow` scope required to create/modify `.github/workflows/` files. To enable CI:

1. Generate a new token at GitHub with `workflow` scope
2. Add it as a repository secret `GH_TOKEN`
3. The workflow will auto-bootstrap `void-packages`, build `asusctl` with `xbps-src`, and run verification

For now, use the manual installation methods above.

## Enable the system service

The service is installed at `/etc/sv/asusd`. Enable it under runit once, then start and check it:

```sh
sudo ln -s /etc/sv/asusd /var/service/asusd
sudo sv up asusd
sudo sv status asusd
```

If `/var/service/asusd` already exists, skip the `ln -s` command. The package also installs an XDG autostart entry for `asusd-user`; desktop environments that honor XDG autostart launch it when the user logs in.

## KDE Plasma widget

The plasma widget is **not included** in the main `asusctl` package by default (zeby paczka była lżejsza i działała na każdym systemie). Aby go włączyć, zainstaluj subpakejkę:

```sh
sudo xbps-install asusctl asusctl-plasma
```

Po instalacji widgetu dodaj **ASUS Control (asusctl)** do panelu lub pulpitu przez wyłącznik widgetów w Plasma 6. Widget udostępnia:
- Sterowanie profilami oświetlenia Aura
- Limit ładowania baterii
- Sterowanie klawiaturą
- Włącz/Wyłącz Aura

> **Bez widgetu** paczka `asusctl` nadal pełni funkcję: daemon `asusd` działa w tle, a narzędzia CLI (`asusctl`, `asusd-user`) są dostępne z wiersza poleceń na każdym środowisku.

## Build from source

This repository contains **only packaging templates** (template + files), not the full `void-packages` build tree. To build from source:

1. Clone upstream void-packages:
   ```sh
   git clone --depth=1 https://github.com/void-linux/void-packages.git
   cd void-packages
   ./xbps-src binary-bootstrap
   ```

2. Copy this package into the void-packages tree:
   ```sh
   git clone --depth=1 https://github.com/Khame/asusctl-void-linux.git /tmp/khame-asusctl
   cp -a /tmp/khame-ausctl/srcpkgs/asusctl /path/to/void-packages/srcpkgs/
   ```

3. Build and install:
   ```sh
   ./xbps-src pkg asusctl
   # Lub zbuduj subpakejkę widgetu:
   ./xbps-src pkg asusctl-plasma
   sudo xbps-install --repository=hostdir/binpkgs asusctl
   # Lub z widgetem: sudo xbps-install --repository=hostdir/binpkgs 'asusctl asusctl-plasma'
   ```

## Upstream

- Project: [OpenGamingCollective/asusctl](https://github.com/OpenGamingCollective/asusctl)
- License: MPL-2.0
- Current packaged version: `6.5.0.git20261024` (latest commit from main branch)

## Author

- **Khame** — `lukasz.linhard@gmail.com`
- Assisted by **AI**
