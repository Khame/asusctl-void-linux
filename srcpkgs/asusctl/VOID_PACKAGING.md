# Void Linux Packaging — asusctl Maintainer Guide

This repository contains **Void Linux `xbps-src` packaging** for `asusctl` maintained by **Khame + AI**.

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

3. **Build the package:**
   ```sh
   ./xbps-src pkg asusctl
   ```

4. **Verify and install:**
   ```sh
   ./xbps-src check asusctl
   sudo xbps-install --repository=hostdir/binpkgs asusctl
   ```

## Requirements

- **Kernel:** 6.19 or newer (for `asus-armoury` driver support)
- **Architecture:** x86_64
- **Init:** runit (no systemd)
- **Dependencies:** dbus, eudev (runtime); pkg-config, rust, cargo, clang, cmake, gettext, git (build)

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