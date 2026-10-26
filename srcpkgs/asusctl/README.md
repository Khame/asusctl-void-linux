# asusctl for Void Linux

Packaging for [asusctl](https://github.com/OpenGamingCollective/asusctl), including the `asusd` system daemon, command-line tools, and a KDE Plasma widget. This package uses Void's runit service management; it does not install a systemd service.

## 📦 Three installation options

This repository provides **three ways** to install `asusctl`, depending on your preference:

### Option 1: From Void repository (recommended - easiest ongoing use)

```sh
# 1. Import the repository signing key (do this once)
sudo sh -c 'curl -sL https://khame.github.io/void-packages/Khame-void-repo.pub -o /var/db/xbps/keys/Khame-void-repo.pem'

# 2. Add the Khame repository
sudo sh -c 'echo "repository=https://khame.github.io/void-packages/" > /etc/xbps.d/10-khame.conf'

# 3. Install from repository (now you can use: sudo xbps-install asusctl)
# You can also update later with: sudo xbps-install -Su
# Or with widget: sudo xbps-install asusctl asusctl-plasma
```

**Advantage:** After configuration, installation is identical to other packages from the Void repository. You can update the package with the command `sudo xbps-install -Su`.

### Option 2: From GitHub Releases (single command, no repo setup)

```sh
# Install the binary package directly from Release (one command, no need to add repo)
sudo xbps-install --binary-package-url https://github.com/Khame/asusctl-void-linux/releases/download/v6.5.0/asusctl-6.5.0.git20261024_1.x86_64.xbps
```

**Advantage:** Does not require reconfiguring the system repository. Convenience for one-time installation.

### Option 3: From source (using void-packages)

```sh
# Build and install from source (full build from void-packages)
git clone --depth=1 https://github.com/void-linux/void-packages.git
cd void-packages
./xbps-src binary-bootstrap

git clone --depth=1 https://github.com/Khame/asusctl-void-linux.git /tmp/khame-asusctl
cp -a /tmp/khame-asusctl/srcpkgs/asusctl /path/to/void-packages/srcpkgs/

./xbps-src pkg asusctl
sudo xbps-install --repository=hostdir/binpkgs asusctl
```

**Advantage:** You have full control over the build process and can modify the template. Disadvantage: Longer installation time and necessity of having a build environment.

## Requirements

- **Kernel:** 6.19 or newer (for `asus-armoury` driver support)
- **Architecture:** x86_64
- **Init:** runit (no systemd)

## Install (binary)

The published Khame XBPS repository provides the binary package for `x86_64`. First add the repository:

```sh
# Import the repository signing key (do this once)
sudo sh -c 'curl -sL https://khame.github.io/void-packages/Khame-void-repo.pub -o /var/db/xbps/keys/Khame-void-repo.pem'

# Add the Khame repository
sudo sh -c 'echo "repository=https://khame.github.io/void-packages/" > /etc/xbps.d/10-khame.conf'
```

Then install:

```sh
sudo xbps-install asusctl
```

Or install from GitHub Releases (no need to add repository manually):

```sh
sudo xbps-install --binary-package-url https://github.com/Khame/asusctl-void-linux/releases/download/v6.5.0/asusctl-6.5.0.git20261024_1.x86_64.xbps
```

## GitHub Releases

A signed binary package is available as a GitHub Release asset:

- **Tag:** `v6.5.0`
- **Package:** `asusctl-6.5.0.git20261024_1.x86_64.xbps` (15.8 MB)
- **Download:** https://github.com/Khame/asusctl-void-linux/releases/tag/v6.5.0

The repository is **RSA-signed**. First install the public key following the instructions above.

## Enable the system service

The service is installed at `/etc/sv/asusd`. Enable it under runit once, then start and check it:

```sh
sudo ln -s /etc/sv/asusd /var/service/asusd
sudo sv up asusd
sudo sv status asusd
```

If `/var/service/asusd` already exists, skip the `ln -s` command. The package also installs an XDG autostart entry for `asusd-user`; desktop environments that honor XDG autostart launch it when the user logs in.

## KDE Plasma widget

The plasma widget is **not included** in the main `asusctl` package by default (to keep the package lighter and working on any system). To enable it, install the subpackage:

```sh
sudo xbps-install asusctl asusctl-plasma
```

After installing the widget, add **ASUS Control (asusctl)** to the panel or desktop through Plasma 6's widget picker. The widget provides:
- Aura lighting control
- Battery charge limit control
- Keyboard control
- Aura on/off control

> **Without the widget** the `asusctl` package still functions: the `asusd` daemon runs in the background, and CLI tools (`asusctl`, `asusd-user`) are available from the command line on any desktop environment.

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
   cp -a /tmp/khame-asusctl/srcpkgs/asusctl /path/to/void-packages/srcpkgs/
   ```

3. Build and install:
   ```sh
   ./xbps-src pkg asusctl
   sudo xbps-install --repository=hostdir/binpkgs asusctl
   ```

## Upstream

- Project: [OpenGamingCollective/asusctl](https://github.com/OpenGamingCollective/asusctl)
- License: MPL-2.0
- Current packaged version: `6.5.0.git20261024` (latest commit from main branch)

## Author

- **Khame** — `lukasz.linhard@gmail.com`
- Assisted by **AI**
