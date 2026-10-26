# asusctl for Void Linux

Packaging for [asusctl](https://github.com/OpenGamingCollective/asusctl), including the `asusd` system daemon, command-line tools, and a KDE Plasma widget. This package uses Void's runit service management; it does not install a systemd service.

## 📦 Two package variants

This repository provides **two installable package variants** via Void subpackages:

### `asusctl` (bez widgetu Plasma - domyślny)
Mniejsza paczka – tylko daemon `asusd` i narzędzia CLI, działa na wszystkich systemach.

### `asusctl-plasma` (z widgetem Plasma)
Dodatkowa subpakejka – zawiera widget KDE Plasma, wymaga środowiska KDE.

## Szybka instalacja (jedna komenda)

### Opcja 1: Z Release'ów (najszybsza - nie trzeba dodawać repo)

```sh
# Importuj klucz podpisujący repozytorium (robisz raz)
sudo sh -c 'curl -sL https://khame.github.io/void-packages/Khame-void-repo.pub -o /var/db/xbps/keys/Khame-void-repo.pem'

# Dodaj repozytorium Khame
sudo sh -c 'echo "repository=https://khame.github.io/void-packages/" > /etc/xbps.d/10-khame.conf'

# Zainstaluj paczkę z Release'ów (bez budowania!)
sudo xbps-install --binary-package-url https://github.com/Khame/asusctl-void-linux/releases/download/v6.5.0/asusctl-6.5.0.git20261024_1.x86_64.xbps
```

Po tym asusctl jest zainstalowany i gotowy do użycia.

### Opcja 2: Z dodanego repozytorium

```sh
# Po wykonaniu kroków z Opcji 1:
sudo xbps-install asusctl
# Lub z widgetem: sudo xbps-install asusctl asusctl-plasma
```

## Requirements

- **Kernel:** 6.19 or newer (for `asus-armoury` driver support)
- **Architecture:** x86_64
- **Init:** runit (no systemd)

## Install (binary)

The published Khame XBPS repository provides the binary package for `x86_64`. First add the repository:

```sh
# Importuj klucz podpisujący repozytorium (robisz raz)
sudo sh -c 'curl -sL https://khame.github.io/void-packages/Khame-void-repo.pub -o /var/db/xbps/keys/Khame-void-repo.pem'

# Dodaj repozytorium Khame
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
   sudo xbps-install --repository=hostdir/binpkgs asusctl
   ```

## Upstream

- Project: [OpenGamingCollective/asusctl](https://github.com/OpenGamingCollective/asusctl)
- License: MPL-2.0
- Current packaged version: `6.5.0.git20261024` (latest commit from main branch)

## Author

- **Khame** — `lukasz.linhard@gmail.com`
- Assisted by **AI**
PL_POLISH:
# asusctl dla Void Linux

Pakowanie dla [asusctl](https://github.com/OpenGamingCollective/asusctl), w tym `asusd` systemowego daemona, narzędzi linii poleceń oraz widgetu KDE Plasma. Pakiet wykorzystuje usługi runit Void, nie instaluje usług systemd.

## 📦 Dwa warianty pakietów

To repozytorium udostępnia **dwu warianty instalowalne** poprzez subpakejki Void:

### `asusctl` (bez widgetu Plasma - domyślny)
Mniejszy pakiet – tylko `asusd` daemon i narzędzia CLI, działa na wszystkich systemach.

### `asusctl-plasma` (z widgetem Plasma)
Dodatkowa subpakejka – zawiera widget KDE Plasma, wymaga środowiska KDE.

## Szybka instalacja (jedna komenda)

### Opcja 1: Z Release'ów (najszybsza - nie trzeba dodawać repo)

```sh
# Importuj klucz podpisujący repozytorium (robisz raz)
sudo sh -c 'curl -sL https://khame.github.io/void-packages/Khame-void-repo.pub -o /var/db/xbps/keys/Khame-void-repo.pem'

# Dodaj repozytorium Khame
sudo sh -c 'echo "repository=https://khame.github.io/void-packages/" > /etc/xbps.d/10-khame.conf'

# Zainstaluj paczkę z Release'ów (bez budowania!)
sudo xbps-install --binary-package-url https://github.com/Khame/asusctl-void-linux/releases/download/v6.5.0/asusctl-6.5.0.git20261024_1.x86_64.xbps
```

Po tym asusctl jest zainstalowany i gotowy do użycia.

### Opcja 2: Z dodanego repozytorium

```sh
# Po wykonaniu kroków z Opcji 1:
sudo xbps-install asusctl
# Lub z widgetem: sudo xbps-install asusctl asusctl-plasma
```

## Requirements

- **Jądro:** 6.19 lub nowsze (obsługa sterownika `asus-armoury`)
- **Architektura:** x86_64
- **Inicjalizacja:** runit (bez systemd)

## Instalacja (binarna)

Opublikowane repozytorium Khame XBPS udostępnia pakiet binarny dla `x86_64`. Najpierw dodaj repozytorium:

```sh
# Importuj klucz podpisujący repozytorium (robisz raz)
sudo sh -c 'curl -sL https://khame.github.io/void-packages/Khame-void-repo.pub -o /var/db/xbps/keys/Khame-void-repo.pem'

# Dodaj repozytorium Khame
sudo sh -c 'echo "repository=https://khame.github.io/void-packages/" > /etc/xbps.d/10-khame.conf`
```

Następnie instaluj:

```sh
sudo xbps-install asusctl
```

Lub z Release'ów (bez dodawania repozytorium):

```sh
sudo xbps-install --binary-package-url https://github.com/Khame/asusctl-void-linux/releases/download/v6.5.0/asusctl-6.5.0.git20261024_1.x86_64.xbps
```

## GitHub Releases

Zapisany pakiet binarny podpisany cyfrowo jest dostępny jako asset Release:

- **Tag:** `v6.5.0`
- **Pakiet:** `asusctl-6.5.0.git20261024_1.x86_64.xbps` (15.8 MB)
- **Download:** https://github.com/Khame/asusctl-void-linux/releases/tag/v6.5.0

Repozytorium jest **podpisane RSA**. Najpierw zainstaluj klucz publicny wykonując instrukcje powyżej.

## Włącz usługę systemową

Usługa jest instalowana w `/etc/sv/asusd`. Włącz ją pod runit raz, a następnie uruchom i sprawdź:

```sh
sudo ln -s /etc/sv/asusd /var/service/asusd
sudo sv up asusd
sudo sv status asusd
```

Jeśli `/var/service/asusd` już istnieje, pominij polecenie `ln -s`. Pakiet zawiera również wpis autostartu XDG dla `asusd-user`; środowiska graficzne honorujące XDG autostart uruchomią go przy logowaniu użytkownika.

## Widget KDE Plasma

Widget Plasma **nie jest** domyślnie zawarty w paczce `asusctl` (zeby paczka była lżejsza i działała na każdym systemie). Aby go włączyć, zainstaluj subpakejkę:

```sh
sudo xbps-install asusctl asusctl-plasma
```

Po instalacji widgetu dodaj **ASUS Control (asusctl)** do panelu lub pulpitu poprzez przełącznik widgetów w Plasma 6. Widget udostępnia:
- Sterowanie profilami oświetlenia Aura
- Limit ładowania baterii
- Sterowanie klawiaturą
- Włącz/Wyłącz Aura

> **Bez widgetu** paczka `asusctl` nadal pełni funkcję: daemon `asusd` działa w tle, a narzędzia CLI (`asusctl`, `asusd-user`) są dostępne z wiersza poleceń na każdym środowisku.

## Budowa z źródeł

To repozytorium zawiera **tylko szablony pakowania** (template + pliki), niepełne drzewo budowania Void Linux `void-packages`. Aby budować z źródeł:

1. Sklonuj upstream void-packages:
   ```sh
   git clone --depth=1 https://github.com/void-linux/void-packages.git
   cd void-packages
   ./xbps-src binary-bootstrap
   ```

2. Skopiuj ten pakiet do drzewa void-packages:
   ```sh
   git clone --depth=1 https://github.com/Khame/asusctl-void-linux.git /tmp/khame-asusctl
   cp -a /tmp/khame-ausctl/srcpkgs/asusctl /path/to/void-packages/srcpkgs/
   ```

3. Buduj i instaluj:
   ```sh
   ./xbps-src pkg asusctl
   sudo xbps-install --repository=hostdir/binpkgs asusctl
   ```

## Źródło pochodzące

- Project: [OpenGamingCollective/asusctl](https://github.com/OpenGamingCollective/asusctl)
- Licencja: MPL-2.0
- Obecnie pakowana wersja: `6.5.0.git20261024` (najnowszy commit z gałęzi main)

## Autor

- **Khame** — `lukasz.linhard@gmail.com`
- Wspierany przez **AI**
