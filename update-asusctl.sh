#!/usr/bin/env bash
#
# update-asusctl.sh — Automated update for asusctl Void Linux package
#
# Usage: ./update-asusctl.sh
#
# This script:
# 1. Checks for the latest version from upstream GitHub
# 2. Bootstraps void-packages chroot if needed
# 3. Builds the package with xbps-src
# 4. Verifies the build
# 5. Installs the package (or pushes to GitHub Release)
#

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$(dirname "$REPO_DIR")"

# --- Step 1: Detect latest version from upstream ---
echo "=== Step 1: Checking latest upstream version ==="
LATEST_COMMIT=$(curl -sL \
  "https://api.github.com/repos/OpenGamingCollective/asusctl/commits/main" \
  -H "Accept: application/vnd.github.v3+json" | \
  python3 -c "import sys,json; d=json.load(sys.stdin); print(d['sha'][:12])" 2>/dev/null || echo "unknown")

echo "Latest upstream commit: $LATEST_COMMIT"

# Extract version from the template
CURRENT_VERSION=$(grep '^pkgname=' "$REPO_DIR/srcpkgs/asusctl/template" | cut -d= -f2)
echo "Current template version: $CURRENT_VERSION"

# --- Step 2: Bootstrap void-packages if needed ---
echo ""
echo "=== Step 2: Bootstrap void-packages chroot ==="
if [ ! -d "$SRC_DIR/void-packages" ]; then
  echo "Cloning void-packages..."
  git clone --depth=1 https://github.com/void-linux/void-packages.git "$SRC_DIR/void-packages"
fi
cd "$SRC_DIR/void-packages"
if [ ! -f hostdir/binpkgs/* ]; then
  echo "Bootstrapping xbps-src..."
  ./xbps-src binary-bootstrap
fi

# --- Step 3: Copy package template and build ---
echo ""
echo "=== Step 3: Building asusctl ==="
cp -a "$REPO_DIR/srcpkgs/asusctl" void-packages/srcpkgs/
cd void-packages
./xbps-src pkg asusctl

# --- Step 4: Verify ---
echo ""
echo "=== Step 4: Verifying build ==="
./xbps-src check asusctl

# --- Step 5: Install ---
echo ""
echo "=== Step 5: Installing asusctl ==="
sudo xbps-install --repository=hostdir/binpkgs asusctl

echo ""
echo "=== Done! asusctl has been built and installed. ==="
echo "Enable the runit service:"
echo "  sudo ln -s /etc/sv/asusd /var/service/asusd"
echo "  sudo sv up asusd"