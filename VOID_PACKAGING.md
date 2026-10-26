# Void Linux Packaging — asusctl Maintainer Guide

This repository contains **Void Linux `xbps-src` packaging** for `asusctl` maintained by **Khame + AI**.

## 📦 Two package variants (subpackages)

This packaging supports **two installable variants** using Void Linux subpackages:

### Main package: `asusctl` (without Plasma widget)
| Description | Install |
|---------|---------|
| `asusctl` | ASUS ROG control daemon, CLI and optional KDE widget (runit, no systemd) | [README](README.md) |

**Characteristics:**
- Smaller package size (no QML/widget files)
- Works on all graphical environments (GNOME, XFCE, sway, etc.)
- No KDE dependencies in `depends` (only `dbus eudec`)
- `optdepends` contains information about the Plasma widget as optional

**Building:**
```sh
./xbps-src pkg asusctl
# or
sudo xbps-install asusctl
```

### Subpackage: `asusctl-plasma` (with Plasma widget)
| Description | Install |
|---------|---------|
| `asusctl-plasma` | ASUS ROG control daemon Plasma (KDE) | - |

**Characteristics:**
- Contains QML widget, icons and KDE panel integration
- Requires KDE environment: `plasma-workspace`, `kirigami2`
- Installs in parallel with the main package:
  ```sh
  sudo xbps-install asusctl asusctl-plasma
  ```

**Building the subpackage:**
```sh
./xbps-src pkg asusctl-plasma
```

## Package

| Description | Install |
|---------|---------|
| `asusctl` | ASUS ROG control daemon, CLI and KDE widget (runit, no systemd) | [README](README.md) |

## Upstream source

- **Project:** [OpenGamingCollective/asusctl](https://github.com/OpenGamingCollective/asusctl)
- **Current version:** `6.5.0.git20261024` (latest commit from main branch)
- **Source:** tar.gz snapshot from GitHub commit `13cdaa9ccbc0b519d3c888c1c9d97e00faf91cf9`

This repository contains **only Void Linux packaging** (template + service files + README). Original source code, documentation and README are maintained upstream.

## Building

1. **Setup void-packages bootstrap:**
   ```sh
   git clone --depth=1 https://github.com/void-linux/void-packages.git
   cd void-packages
   ./xbps-src binary-bootstrap
   ```

2. **Copy package template:**
   ```sh
   git clone --depth=1 https://github.com/Khame/asusctl-void-linux.git /tmp/khame-asusctl
   cp -a /tmp/khame-asusctl/srcpkgs/asusctl /path/to/void-packages/srcpkgs/
   ```

3. **Build the main package (without widget):**
   ```sh
   ./xbps-src pkg asusctl
   ```

4. **Build subpackage with widget (optional):**
   ```sh
   ./xbps-src pkg asusctl-plasma
   ```

5. **Verify and install:**
   ```sh
   ./xbps-src check asusctl
   sudo xbps-install --repository=hostdir/binpkgs asusctl
   # or with widget: sudo xbps-install asusctl asusctl-plasma
   ```

## Requirements

- **Kernel:** 6.19 or newer (for `asus-armoury` driver support)
- **Architecture:** x86_64
- **Init:** runit (no systemd)
- **Dependencies:** dbus, eudev (runtime); pkg-config, rust, cargo, clang, cmake, gettext, git (build)

**Optdepends:** `plasma-workspace: KDE widget for asusd control`, `kirigami2: KDE widget for asusd control`

## Author / Packager

- **Khame** — `lukasz.linhard@gmail.com`
- Assisted by **AI**

## License

MIT — this repository's authored material. Upstream software governed by its own license.

## Binary repository and Releases

Signed binary packages are published via **GitHub Releases** (`v6.5.0`):

```sh
# Install from Release asset:
sudo xbps-install --binary-package-url \
  https://github.com/Khame/asusctl-void-linux/releases/download/v6.5.0/asusctl-6.5.0.git20261024_1.x86_64.xbps

# Or add the signed repository (see README for key instructions):
sudo sh -c 'echo "repository=https://khame.github.io/void-packages/" > /etc/xbps.d/10-khame.conf'
sudo xbps-install -S
sudo xbps-install asusctl
```

**Note:** GitHub Actions CI is not automatically enabled because the deployment token lacks the `workflow` scope. To add CI, generate a token with `workflow` scope and configure it as a repository secret `GH_TOKEN`.

## Subpackage maintainance

To add or modify the `asusctl-plasma` subpackage:

1. Edit the file `srcpkgs/asusctl/template`
2. Change the `package="asusctl-plasma"` variable and its dependencies
3. Ensure widget files are located in `srcpkgs/asusctl/files/plasmoid/org.voidlinux.plasma.asusctl/`
4. Test the build: `./xbps-src pkg asusctl-plasma`
