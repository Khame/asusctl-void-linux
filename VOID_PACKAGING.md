# Void Linux packaging: asusctl maintainer notes

This repository holds the install docs and release notes. The packaging source
is not here. The single copy is `srcpkgs/asusctl/` in
[Khame/void-packages](https://github.com/Khame/void-packages).

Users should read [README.md](README.md) instead.

## Where the files live

| Path (in `Khame/void-packages`) | What it is |
|---|---|
| `srcpkgs/asusctl/template` | the `xbps-src` template: version, checksum, dependencies, `do_install` |
| `srcpkgs/asusctl/files/asusd/run` | runit `run` script for `asusd` |
| `srcpkgs/asusctl/files/asusd-log/run` | `svlogd` logger for `/var/log/asusd` |
| `srcpkgs/asusctl/files/xdg-autostart/asusd-user.desktop` | starts `asusd-user` with the session |
| `srcpkgs/asusctl/files/plasmoid/` | the Plasma widget |
| `srcpkgs/asusctl-plasma` | symlink to the template for the optional Plasma subpackage |
| `srcpkgs/asusctl/REMOVE` | stops package processes before removal |
| `srcpkgs/asusctl/REMOVE.msg` | explains the remaining administrator service link |
| `docs/` | signed packages, `x86_64-repodata`, the public key and the landing page |

## About the template

The template defines `do_build()` as `cargo build --release --locked` and
`do_check()` as `cargo test --workspace --locked`. It does not use
`build_style=gnu-makefile`: the upstream default target only runs that cargo
command, and its version probe uses `grep -P`, which Void's grep does not
support.

Upstream `make install` is not used. It installs systemd units, so `do_install`
places every file by hand.

The version is a git snapshot: `version=6.5.0.20261116` and
`_commit=5346e184d09c5ed46e5dd16cdecedb7608393502`. `distfiles` uses
`${_commit}` and there is no `wrksrc`; `xbps-src` renames the extracted
directory by itself.

`data/asusd.rules` is not installed. It only sets `TAG+="systemd"` and
`ENV{SYSTEMD_WANTS}+="asusd.service asus-shutdown.service"`, both of which
eudev ignores. runit starts `asusd`.

`REMOVE` stops the asusd service, its logger and the session processes before
the package files are removed. It does not remove `/var/service/asusd`, because
that link is created and owned by the administrator. `REMOVE.msg` explains how
to remove the link manually.

`asus-shutdown` is not installed either. It waits for a `PrepareForShutdown`
signal from logind and then calls `systemctl`. Void's `/usr/bin/shutdown` never
sends that signal, so the helper would never run.

runit takes the place of systemd: `/etc/sv/asusd` and `/etc/sv/asusd/log` come
from `files/`. The logger creates `/var/log/asusd` itself, because empty
directories do not survive package creation. The `supervise` symlinks are made
by `runsv` at runtime and are not shipped.

The Plasma widget is in the optional `asusctl-plasma` subpackage. Its runtime
dependencies are declared by that subpackage rather than hidden in a message.

Build dependencies are `pkg-config rust cargo clang cmake gettext git`,
`eudev-libudev-devel dbus-devel pcre2-devel libxkbcommon-devel libzstd-devel`
and `gtk+3-devel`. Check dependencies are `clang21-devel` and `SDL2-devel`:
the bindgen-backed Cargo tests need libclang and the workspace simulator tests
link against SDL2. Runtime dependencies are `dbus` and `eudev`.

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

The package ends up in `hostdir/binpkgs/`. To try the service:

```sh
sudo ln -sfn /etc/sv/asusd /var/service/asusd
sudo sv status asusd
sudo sv down asusd
```

## Publishing a release

1. Compare the upstream version with `version=` in the template. If it has not
   changed, stop here.
2. Update `version=`, `_commit=` and the `distfiles` URL, then let `xbps-src`
   compute the new `checksum=`.
3. Raise `revision=` when you change only the template and the upstream version
   stays the same.
4. Run `xlint srcpkgs/asusctl/template` and fix everything it reports.
5. Build, install and test. Run the check stage with
   `./xbps-src -Q -f pkg asustl`. In this tree, `XBPS_CHECK_PKGS=yes` alone
   does not enable it; check the log for `running do_check`. If you replaced a
   run script, restart the service and its logger separately;
   `sudo sv restart asusd` leaves `asusd/log` running.
6. Sign the packages you just built. Adjust the version and revision in both
   paths. Do not use a bare `asusctl-*` glob: it also matches the plasma
   subpackage and older revisions.

   ```sh
   for pkg in hostdir/binpkgs/asusctl-6.5.0.20261116_12.x86_64.xbps \
              hostdir/binpkgs/asusctl-plasma-6.5.0.20261116_12.x86_64.xbps; do
     xbps-rindex -S --privkey="$HOME/.config/Khame-void-repo-private.pem" \
       --signedby="Khame <khame.dev@protonmail.com>" "$pkg"
   done
   ```

7. Delete the old packages and their signatures from `docs/`, copy both new
   pairs in and rebuild the index. Never pass an `asusctl-*.xbps` glob to
   `xbps-rindex -a`; it also matches the plasma subpackage and old revisions.

   ```sh
   rm -f docs/asusctl-*.xbps docs/asusctl-*.xbps.sig2
   cp hostdir/binpkgs/asusctl-6.5.0.20261116_12.x86_64.xbps \
      hostdir/binpkgs/asusctl-6.5.0.20261116_12.x86_64.xbps.sig2 \
      hostdir/binpkgs/asusctl-plasma-6.5.0.20261116_12.x86_64.xbps \
      hostdir/binpkgs/asusctl-plasma-6.5.0.20261116_12.x86_64.xbps.sig2 docs/
   xbps-rindex -a docs/asusctl-6.5.0.20261116_12.x86_64.xbps
   xbps-rindex -a docs/asusctl-plasma-6.5.0.20261116_12.x86_64.xbps
   xbps-rindex -c docs
   xbps-rindex -s --privkey="$HOME/.config/Khame-void-repo-private.pem" \
     --signedby="Khame <khame.dev@protonmail.com>" docs
   ```

8. Commit and push `Khame/void-packages`. GitHub Pages serves `docs/` from
   `main`, so the repository appears at
   `https://khame.github.io/void-packages/`.
9. Attach the same `.xbps` and `.sig2` files to a release in this repository.
   Update the release notes with the revision, the patch count and both package
   names. Keep the old assets if you want a rollback. Update the version
   numbers in `README.md`.

Packages are signed with the Khame repository RSA key. The private key stays
outside both repositories, for example at
`~/.config/Khame-void-repo-private.pem` with mode `600`. The public key is
copied to `docs/Khame-void-repo.pub` and `xbps-rindex -s` embeds it in the
index. Nobody has to put a `.pem` into `/var/db/xbps/keys/`: `xbps` imports the
key from the index on the first `xbps-install -S` and stores it as
`<fingerprint>.plist`, currently
`35:2b:06:7c:52:04:76:b1:4a:de:a0:8b:49:9c:e2:66.plist`. I never support
`allow-unsigned`.

`x86_64-repodata` has no signature of its own. `xbps` checks each package
against the imported key. Only x86_64 is published.

Three things I keep tripping over:

- Empty directories do not survive `.xbps` creation, so `vmkdir var/log/asusd`
  does nothing. Create the directory in the run script.
- Building the same `version` and `revision` again needs
  `./xbps-src -f pkg asusctl`. Without `-f` the old package is reused.
- `asusctl-*` also matches `asusctl-plasma-*`. Be explicit when signing,
  copying or adding packages to the index.

There is no CI on these repositories. Releases are built by hand.

## Author and license

Khame ([@Khame](https://github.com/Khame)),
[khame.dev@protonmail.com](mailto:khame.dev@protonmail.com)

MIT for the material written here. Upstream asusctl is MPL-2.0.
