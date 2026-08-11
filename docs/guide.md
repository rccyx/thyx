# Guide

This guide covers the Linux login stack. It shows you exactly what this repo does, why the files go where they go, how SDDM picks a theme, how to preview it, uninstall it, and fix your system if your login screen breaks.

## The Linux login stack

Your machine can boot into a few different login environments.

The simplest setup is a TTY. This is the plain text login screen your kernel and system services throw up. It asks for your username and password in a basic terminal screen. It runs completely independent of a graphical desktop, Wayland, X11, or a display manager.

A graphical desktop setup needs more. You need something to show the actual login UI, authenticate you, list your desktop sessions, and kick off the one you choose. That program is called a display manager.

Here are the common display managers you'll run into:

| display manager | common use                                                      |
| --------------- | --------------------------------------------------------------- |
| `sddm`          | Qt/QML login manager for KDE Plasma, Wayland, and custom setups |
| `gdm3`          | GNOME's default login manager                                   |
| `lightdm`       | Lightweight login manager for older or minimal setups           |
| `ly`            | TTY style terminal display manager                              |
| `greetd`        | Minimal login daemon that works with custom greeters            |
| `xdm`           | Legacy display manager for X11                                  |

Environments like GNOME, KDE Plasma, LXQt, XFCE, Hyprland, Sway, and i3 are the sessions that launch after you log in. The display manager is just the gatekeeper that gets you into them:

```text
boot
  -> systemd starts display-manager.service
  -> display manager starts
  -> greeter appears
  -> user authenticates
  -> selected desktop session starts
  -> login theme disappears
```

This theme only handles the greeter part of this chain.

## What's SDDM?

[SDDM](https://github.com/sddm/sddm) stands for Simple Desktop Display Manager.

It owns your graphical login screen. It spins up before your desktop session, displays the UI, talks to [PAM](https://en.wikipedia.org/wiki/Linux_PAM) to check your password, and boots up your chosen session.

Because SDDM is built on Qt, its themes are written in QML. SDDM grabs the theme folder, reads the metadata, loads the main QML file, that links to the other QML files, and renders it directly as your login screen.

## So what's QML?

QML is the declarative UI language for Qt.

A QML file maps out your UI layout. It builds the windows, rectangles, text, buttons, images, videos, animations, and behaviors.

When SDDM runs a theme, these are the core files it'll need:

| file               | role                                                      |
| ------------------ | --------------------------------------------------------- |
| `metadata.desktop` | Tells SDDM the theme name, main QML file, and config file |
| `theme.conf`       | Theme settings and configuration values                   |
| `Main.qml`         | Main login screen interface code                          |

This QML code executes inside the SDDM greeter environment. It needs system-readable files, system-wide fonts, and the proper Qt runtime modules installed on your machine.

## Where the theme installs and what it needs

Installed here:

```bash
/usr/share/sddm/themes/thyx
```

SDDM themes must be in `/usr/share/sddm/themes` because SDDM is a system service. It starts up before any user session exists, so it reads files exclusively from system-wide folders.

To run it, you need SDDM, the SDDM greeter binary, Qt/QML runtime modules, the font you chose to use, a link in the QML to the icons you use, and a link to the background image.

The biggest problem is using the right QT/QML runtime dependencies for your distro, that's why this project ships with automatic installers for the most used distros among Linux users.

## Check the active display manager

Run these commands to see what is currently running:

```bash
cat /etc/X11/default-display-manager 2>/dev/null || true
systemctl status display-manager --no-pager
```

If your system uses SDDM, you'll see this path:

```text
/usr/bin/sddm
```

You might also see a systemd status line pointing to `sddm.service`.

If you run GNOME with gdm3, you'll see `/usr/sbin/gdm3`.
If you use LightDM, you'll see `/usr/sbin/lightdm`.

If SDDM is inactive on your system, you can still install the theme. It displays on your real login screen once you activate SDDM.

## Switch to SDDM

**Note:** This guide uses Debian and Ubuntu commands, but the process applies across most distros.

Install SDDM:

```bash
sudo apt install sddm
```

Set SDDM as your active display manager:

```bash
sudo dpkg-reconfigure sddm
```

To switch back to GNOME's login manager later:

```bash
sudo dpkg-reconfigure gdm3
```

## How SDDM chooses a theme

SDDM pulls its configuration from `/etc/sddm.conf`.

Your active theme is set under this configuration block:

```ini
[Theme]
Current=thyx
```

Whatever name you put after `Current=` has to match an actual theme folder inside `/usr/share/sddm/themes`.

The installer script writes your chosen theme directly to `/etc/sddm.conf`. If that file is already there, the installer makes one stable backup at `/etc/sddm.conf.thyx-back`. Repeated installations overwrite that exact backup file to keep your system clean of timestamped backups.

Check your current theme setup:

```bash
grep -nE '^\[Theme\]|^[[:space:]]*Current[[:space:]]*=' /etc/sddm.conf 2>/dev/null || true
```

View all your installed SDDM themes:

```bash
ls -1 /usr/share/sddm/themes
```

## What the installer does

Run the installer from the root of the repository:

```bash
./package/install
```

It will ask you to confirm the plan it just laid out.

Run it without prompts (auto accept):

```bash
./package/install --yes
```

The script automates the entire deployment:

- Locates the repository and creates a local log file.
- Validates the configuration metadata and QML files.
- Detects your Linux distribution and installs any missing runtime packages.
- Creates a staging path at `/usr/share/sddm/themes/.thyx.stage`.
- Uses rsync to copy the repository into the staging directory and strips out development files (`.git/`, `.github/`, `justfile`, etc.).
- Moves any existing installation to `/usr/share/sddm/themes/.thyx.previous` for safekeeping.
- Deploys the staged theme to the final `/usr/share/sddm/themes/thyx` path.
- Installs the bundled fonts and rebuilds your system font cache.
- Writes the theme name to `/etc/sddm.conf` and enables the systemd `sddm.service`.
- Outputs a safe preview command for you to test.

The atuo setup requires sudo rights because it writes to system paths.

## File surface during install

| path                                           | purpose                                   |
| ---------------------------------------------- | ----------------------------------------- |
| `/usr/share/sddm/themes/thyx`                  | Active SDDM theme folder                  |
| `/usr/share/sddm/themes/thyx/metadata.desktop` | Configuration metadata for SDDM           |
| `/usr/share/sddm/themes/thyx/theme.conf`       | Theme configuration settings              |
| `/usr/share/sddm/themes/thyx/src/Main.qml`     | Core QML interface code                   |
| `/usr/share/sddm/themes/.thyx.stage`           | Temporary staging area for installs       |
| `/usr/share/sddm/themes/.thyx.previous`        | Temporary fallback folder during upgrades |
| `/usr/local/share/fonts/thyx`                  | Bundled system fonts for the login screen |
| `/etc/sddm.conf`                               | Main SDDM configuration file              |
| `/etc/sddm.conf.thyx-back`                     | Stable backup of your original config     |
| `~/.cache/thyx/thyx-install-*.log`             | Detailed installation logs                |
| `~/.cache/thyx/thyx-uninstall-*.log`           | Detailed uninstallation logs              |

## Why fonts are installed system wide

Your login screen fires up before your user session starts. SDDM lacks access to your local desktop font configuration, shell environment, or user font cache.

The installer places the bundled fonts directly into this system folder:

```bash
/usr/local/share/fonts/thyx
```

Under `thyx` so when you [uninstall](#uninstall-the-theme), it won't leave heavy fonts in your system or pollute the rest.

It rebuilds your system font cache immediately after:

```bash
fc-cache -f
```

Check your installed font files:

```bash
ls -la /usr/local/share/fonts/thyx
```

Verify them in your system font cache:

```bash
fc-list | grep -i "Plus Jakarta Sans" || true
fc-list | grep -i "Inter" || true
```

The family name you write in your QML files has to match the exact family name that `fc-list` outputs.

## Uninstall the theme

Run the uninstaller:

```bash
./package/uninstall
```

Run a silent uninstall without prompts:

```bash
./package/uninstall --yes
```

The uninstaller restores `/etc/sddm.conf.thyx-back` if that backup file exists on your disk. Without a backup, it simply deletes the `Current=thyx` line from `/etc/sddm.conf`.

Also wipes the theme directories, removes the bundled fonts, and updates the font cache.

## Recovery protocol

You can recover a broken login screen using a TTY.

### 1. Switch to a TTY

Hit these keys on your keyboard:

```text
Ctrl + Alt + F2
```

Use `F3` or `F4` if `F2` is occupied. Some laptops require the `Fn` key as well. Log in using your standard username and password.

### 2. List installed SDDM themes

See your available options:

```bash
ls -1 /usr/share/sddm/themes
```

Pick a working theme from the list. The default fallback is usually `breeze`.

### 3. Restore the previous SDDM config

If you have a backup of your original config, restore it:

```bash
sudo test -f /etc/sddm.conf.thyx-back && sudo cp /etc/sddm.conf.thyx-back /etc/sddm.conf
```

### 4. Or set SDDM to a fallback theme manually

Open the configuration file:

```bash
sudo nano /etc/sddm.conf
```

Set your active theme to your fallback choice:

```ini
[Theme]
Current=breeze
```

### 5. Restart the display manager

Apply the changes:

```bash
sudo systemctl restart display-manager
```

If that command hangs or fails, reboot the machine:

```bash
sudo reboot
```

## Disable SDDM

Stop and disable SDDM immediately:

```bash
sudo systemctl disable --now sddm
```

To hand things back to another display manager on Debian or Ubuntu:

```bash
sudo dpkg-reconfigure gdm3
sudo systemctl enable --now gdm3
```

## Log and debug commands

If something fails, just view your last 200 lines of installation logs:

```bash
tail -200 "$(ls -1t ~/.cache/thyx/thyx-install-*.log | head -n 1)"
```

View your last 200 lines of uninstall logs:

```bash
tail -200 "$(ls -1t ~/.cache/thyx/thyx-uninstall-*.log | head -n 1)"
```

List your installed theme files:

```bash
find /usr/share/sddm/themes/thyx -maxdepth 3 -type f | sort
```

Check the running status of SDDM:

```bash
systemctl status sddm --no-pager
```

View the boot logs specifically for SDDM:

```bash
journalctl -u sddm -b --no-pager
```
