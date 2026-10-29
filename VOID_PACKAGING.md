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
| `docs/` | signed packages, `x86_64-repodata`, the public key and the landing page |

## About the template

`build_style=gnu-makefile` with `make_build_target="all"`.

Upstream `make install` is not used. It installs systemd units, so `do_install`
places every file by hand.

The version is a git snapshot: `version=6.5.0.20261024` and
`_commit=13cdaa9ccbc0b519d3c888c1c9d97e00faf91cf9`. `distfiles` uses
`${_commit}` and there is no `wrksrc`; `xbps-src` renames the extracted
directory by itself.

`data/asusd.rules` is not installed. It only sets `TAG+="systemd"` and
`ENV{SYSTEMD_WANTS}+="asusd.service asus-shutdown.service"`, both of which
eudev ignores. runit starts `asusd`.

`asus-shutdown` is not installed either. It waits for a `PrepareForShutdown`
signal from logind and then calls `systemctl`. Void's `/usr/bin/shutdown` never
sends that signal, so the helper would never run.

runit takes the place of systemd: `/etc/sv/asusd` and `/etc/sv/asusd/log` come
from `files/`. The logger creates `/var/log/asusd` itself, because empty
directories do not survive package creation. The `supervise` symlinks are made
by `runsv` at runtime and are not shipped.

The Plasma widget is part of the main package. Its runtime requirements are in
`srcpkgs/asusctl/INSTALL.msg`, not in `optdepends`. `xbps-src` has no
`optdepends` variable and ignores it without a warning.

Build dependencies are `pkg-config rust cargo clang cmake gettext git`,
`eudev-libudev-devel dbus-devel pcre2-devel libxkbcommon-devel libzstd-devel`
and `gtk+3-devel`. Runtime dependencies are `dbus` and `eudev`.

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
5. Build, install and test. If you replaced a run script, restart the service
   and its logger separately; `sudo sv restart asusd` leaves `asusd/log`
   running.
6. Sign the package you just built:

   ```sh
   pkg=$(ls -t hostdir/binpkgs/asusctl-*.xbps | head -1)
   xbps-rindex -S --privkey="$HOME/.config/Khame-void-repo-private.pem" \
     --signedby="Khame <khame.dev@protonmail.com>" "$pkg"
   ```

7. Delete the old package and its signature from `docs/`, copy the new pair in
   and rebuild the index. Never pass a `asusctl-*.xbps` glob to
   `xbps-rindex -a`; it also matches the old package and may register that
   version instead.

   ```sh
   rm -f docs/asusctl-*.xbps docs/asusctl-*.xbps.sig2
   cp "$pkg" "$pkg.sig2" docs/
   xbps-rindex -a "docs/$(basename "$pkg")"
   xbps-rindex -s --privkey="$HOME/.config/Khame-void-repo-private.pem" \
     --signedby="Khame <khame.dev@protonmail.com>" docs
   ```

8. Commit and push `Khame/void-packages`. GitHub Pages serves `docs/` from
   `main`, so the repository appears at
   `https://khame.github.io/void-packages/`.
9. Attach the same `.xbps` to a release in this repository and update the
   version numbers in `README.md`.

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

Two things I keep tripping over:

- Empty directories do not survive `.xbps` creation, so `vmkdir var/log/asusd`
  does nothing. Create the directory in the run script.
- Building the same `version` and `revision` again needs
  `./xbps-src -f pkg asusctl`. Without `-f` the old package is reused.

There is no CI on these repositories. Releases are built by hand.

## Author and license

Khame ([@Khame](https://github.com/Khame)),
[khame.dev@protonmail.com](mailto:khame.dev@protonmail.com)

MIT for the material written here. Upstream asusctl is MPL-2.0.
