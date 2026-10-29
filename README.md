# asusctl for Void Linux

asusctl packaged for Void Linux: the `asusd` daemon, its command line tools and
the optional KDE Plasma widget. Everything runs under runit. The package
installs no systemd units.

## Why this exists

I wanted asusctl on my own laptop and Void runs runit, so the upstream units
were no use. Nobody packaged it that way, so I built it, fixed the parts that
broke here, and published it in case someone else needs the same thing.

It is a personal project, not an official Void package, and there is no
support promise behind it. Bug reports and patches are welcome anyway.

## Install

### Signed XBPS repository

```sh
# add the repository
sudo sh -c 'echo "repository=https://khame.github.io/void-packages/" > /etc/xbps.d/10-khame.conf'

# sync the index, answer Y when xbps asks to import the key
sudo xbps-install -S

sudo xbps-install asusctl
```

The key sits inside the signed index, so xbps imports it without an extra
step. It ends up as
`/var/db/xbps/keys/35:2b:06:7c:52:04:76:b1:4a:de:a0:8b:49:9c:e2:66.plist`.
The same key is published as
[Khame-void-repo.pub](https://khame.github.io/void-packages/Khame-void-repo.pub)
if you want to compare it yourself.

Updates come with `sudo xbps-install -Su`. Only x86_64 is built.

### Release asset

Import the key first, then:

```sh
sudo xbps-install --binary-package-url https://github.com/Khame/asusctl-void-linux/releases/download/v6.5.0/asusctl-6.5.0.20261024_9.x86_64.xbps
```

This is for one install. Updates are manual. The release also has the `.sig2`
file and the public key, fingerprint
`35:2b:06:7c:52:04:76:b1:4a:de:a0:8b:49:9c:e2:66`.

### From source

The package lives in
[Khame/void-packages](https://github.com/Khame/void-packages), not here.

```sh
git clone --depth=1 https://github.com/void-linux/void-packages.git
cd void-packages
./xbps-src binary-bootstrap

git clone --depth=1 https://github.com/Khame/void-packages.git /tmp/khame-void-packages
cp -a /tmp/khame-void-packages/srcpkgs/asusctl srcpkgs/

./xbps-src pkg asusctl
sudo xbps-install --repository=hostdir/binpkgs asusctl
```

Do this when you want to change the template or build another revision.

## Start the service

```sh
sudo ln -s /etc/sv/asusd /var/service/asusd
sudo sv up asusd
sudo sv status asusd
```

Skip the symlink if `/var/service/asusd` already exists. The package creates
`/var/log/asusd` for the bundled `svlogd`, and an XDG autostart entry starts
`asusd-user` with the desktop session.

## What gets installed

`asusd` as a runit service with logs in `/var/log/asusd`, the `asusctl`,
`asusd-user` and `rog-control-center` binaries, the D-Bus policy, keyboard
layouts, notification icons, and the Plasma widget
`org.voidlinux.plasma.asusctl`.

The widget covers Aura lighting, the battery charge limit and switching the
keyboard and Aura off. It needs Plasma 6; `INSTALL.msg` lists
`plasma-workspace`, `kf6-kirigami` and `plasma5support`. Without KDE the daemon
and the CLI work on their own, so GNOME, XFCE, sway and a plain console are
fine.

Upstream's `asus-shutdown` helper and its udev rule are left out. Both expect
systemd and do nothing here.

## Patches

Revision 9 carries six patches on top of upstream `13cdaa9`. I needed all of
them on this laptop.

1. Upstream never registers the Aura logind `PrepareForSleep` handler, so the
   keyboard stayed dark after suspend and hibernate. The patch registers it.
2. `asusd-user` created its blocking D-Bus proxies inside the Tokio runtime and
   panicked at start with `Cannot start a runtime from within a runtime`.
3. The sleep handler reloaded the config and wiped fields that only exist at
   runtime. Every later colour or mode change then failed with "The Aura effect
   is not supported" until `asusd` restarted. The same reload also saved a
   transient `Off` written by desktop power management over the brightness I
   had picked.
4. `asusd-user` always ran a 30 Hz Aura loop against `/xyz/ljones/Aura`, an
   object only per-key keyboards have, so every login logged
   `Unknown object '/xyz/ljones/Aura'`.
5. `reload()` at startup restored the effect but not the brightness, so
   `asusctl leds get` and the GUI reported `Off` on a lit keyboard.
6. elogind can send `PrepareForSleep(false)` more than once for one wake. The
   handler ran twice and reloaded the keyboard twice. The patch ignores an
   identical signal received within two seconds.

Revision 7 fixed the packaging side: layouts go to
`/usr/share/rog-gui/layouts/` where `asusd-user` looks for them,
`aura_support.ron` is installed, and the session daemon runs through a wrapper
that keeps its log in `~/.local/state/asusd/asusd-user.log`.

Why each patch exists, how to check it, and what to look at when a new upstream
release appears:
[PATCHES.md](https://github.com/Khame/void-packages/blob/main/srcpkgs/asusctl/PATCHES.md).
I have not sent anything upstream.

## Requirements

Kernel 6.19 or newer for the `asus-armoury` driver, x86_64, runit. systemd is
not supported.

## Tested on

ASUS ROG Strix G513QM: Ryzen 9 5900HX, Radeon Vega plus RTX 3060 Mobile, 16 GB
RAM. Void x86_64 with glibc, kernel 7.3, XBPS 0.60.7, runit, Plasma 6.7.5 on
Wayland. `asusd`, `asusctl` and `rog-control-center` run here every day.

I also installed it in a clean Void x86_64 LXC container to check the
repository, the signature and the file layout. A container has no ASUS WMI
device, so `asusd` exits with `MissingFunction("asus-nb-wmi not found")`. That
is expected.

musl is untested.

## Repository layout

- `README.md`: this file
- `VOID_PACKAGING.md`: how the template is put together, how a release is built
- `LICENSE`: MIT for what I wrote here

The build files are not copied here. The single copy is
[`srcpkgs/asusctl/`](https://github.com/Khame/void-packages/tree/main/srcpkgs/asusctl).

## Upstream

Project: [OpenGamingCollective/asusctl](https://github.com/OpenGamingCollective/asusctl)

Packaged version: `6.5.0.20261024_9`, commit
`13cdaa9ccbc0b519d3c888c1c9d97e00faf91cf9`

License: MPL-2.0

## Author

Khame ([@Khame](https://github.com/Khame)),
[khame.dev@protonmail.com](mailto:khame.dev@protonmail.com)
