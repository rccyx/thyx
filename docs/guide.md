# Guide

Thyx is an SDDM login theme.

It controls the graphical login screen before the desktop starts. After login, SDDM hands control to the selected desktop session and Thyx leaves the screen.

This guide starts from the Linux login stack itself, then explains exactly what this repo does, why the files go where they go, how SDDM chooses a theme, how preview works, how uninstall works, and how to recover from a broken login screen.

## The Linux login stack

A Linux machine can boot into different kinds of login surfaces.

The simplest one is a TTY. A TTY is the plain text login screen shown by the kernel and system services. It asks for a username and password in a terminal-like screen. It works without a graphical desktop, without Wayland, without X11, and without a display manager.

A graphical desktop needs more though. Something has to show the login UI, authenticate the user, list available desktop sessions, and start the chosen session. That program is called a display manager.

A display manager is the login manager for a graphical Linux system.

Common display managers:

| display manager | common use                                                                      |
| --------------- | ------------------------------------------------------------------------------- |
| `sddm`          | Qt/QML login manager used by KDE Plasma and many Wayland or custom Linux setups |
| `gdm3`          | GNOME’s login manager                                                           |
| `lightdm`       | older lightweight login manager used by some distros and desktop setups         |
| `ly`            | terminal-style display manager                                                  |
| `greetd`        | small login daemon often paired with custom greeters                            |
| `xdm`           | old X11 display manager                                                         |

GNOME, KDE Plasma, LXQt, XFCE, Hyprland, Sway, and i3 are the sessions that start after login. The display manager is the thing that gets you into one of those sessions:

```text
boot
  -> systemd starts display-manager.service
  -> display manager starts
  -> greeter appears
  -> user authenticates
  -> selected desktop session starts
  -> login theme disappears
```

Thyx lives only in the greeter part of that chain.

## What SDDM is

SDDM means Simple Desktop Display Manager.

It's a display manager. It owns the graphical login screen. It starts before the desktop session, shows the login UI, talks to PAM for authentication, then launches the selected session.

SDDM is built on Qt. Its themes are written in QML.

That's why this is a QML project. SDDM loads the theme directory, reads the theme metadata, loads the main QML file, and renders that QML as the login screen.

## What's QML?

QML is Qt’s declarative UI language.

A QML file describes a UI tree: windows, rectangles, text, buttons, images, videos, animations, layouts, and behavior. In SDDM themes, QML is the login screen interface.

When SDDM loads a theme, the important pieces are:

| file               | role                                                      |
| ------------------ | --------------------------------------------------------- |
| `metadata.desktop` | tells SDDM the theme name, main QML file, and config file |
| `theme.conf`       | theme configuration values                                |
| `src/Main.qml`     | main login screen UI                                      |
| `assets/`          | images, icons, videos, and other visual files             |
| `fonts/`           | bundled fonts installed into the system font path         |

The QML runs inside the SDDM greeter environment. That environment has its own constraints. It needs system readable files, system readable fonts, and the Qt runtime modules installed at the system level.

## Where Thyx Comes In

Thyx is an SDDM theme, simply the login screen UI. Loaded before the desktop starts, and disappears after login.

Installed here:

```bash
/usr/share/sddm/themes/thyx
```

SDDM themes live under `/usr/share/sddm/themes` because SDDM is a system service. It starts before a normal user session exists, so it reads from system locations rather than from a user’s home directory.

## What Thyx needs

Thyx needs SDDM, an SDDM greeter binary, Qt/QML runtime modules, fontconfig, rsync, and normal Unix tools used by the installer.

## Check the active display manager

Run:

```bash
cat /etc/X11/default-display-manager 2>/dev/null || true
systemctl status display-manager --no-pager
```

A system using SDDM usually shows this (or similar path with `/sddm`):

```text
/usr/bin/sddm
```

or a systemd status pointing to:

```text
sddm.service
```

When using GNOME with gdm3, you'll see:

```text
/usr/sbin/gdm3
```

LightDM may shows:

```text
/usr/sbin/lightdm
```

If SDDM is not the active display manager, Thyx can still be installed, but it will not appear on the real login screen until SDDM is active. So, you might want to:

## Switch to SDDM

This is on Debian or Ubuntu, but it's the same across distros:

Install SDDM:

```bash
sudo apt install sddm
```

Choose SDDM as the active display manager:

```bash
sudo dpkg-reconfigure sddm
```

To switch back to GNOME’s login manager:

```bash
sudo dpkg-reconfigure gdm3
```

To check the active display manager again:

```bash
cat /etc/X11/default-display-manager 2>/dev/null || true
systemctl status display-manager --no-pager
```

## How SDDM chooses a theme

SDDM reads configuration files.

The two important locations are:

```bash
/etc/sddm.conf
/etc/sddm.conf.d/*.conf
```

Theme selection is controlled by this config section:

```ini
[Theme]
Current=theme-name
```

For Thyx, the value is:

```ini
[Theme]
Current=thyx
```

The value after `Current=` must match an installed theme directory under:

```bash
/usr/share/sddm/themes
```

So this config:

```ini
[Theme]
Current=thyx
```

points SDDM at:

```bash
/usr/share/sddm/themes/thyx
```

The theme directory must contain valid SDDM theme metadata and the QML files referenced by that metadata.

## Why Thyx uses `zzzzzz-thyx.conf`

SDDM can read more than one config file.

A system may have:

```bash
/etc/sddm.conf
/etc/sddm.conf.d/kde_settings.conf
/etc/sddm.conf.d/some-distro-theme.conf
/etc/sddm.conf.d/zzzzzz-thyx.conf
```

If more than one file sets:

```ini
[Theme]
Current=...
```

then the effective value is the one that wins after SDDM reads the config files.

Thyx writes:

```bash
/etc/sddm.conf.d/zzzzzz-thyx.conf
```

with:

```ini
[Theme]
Current=thyx
```

The name starts with `zzzzzz` so it sorts late in `/etc/sddm.conf.d`. It makes the Thyx selector win over earlier distro or desktop drop-ins without asking the user to manually delete them.

The file is also easy to recognize and easy to remove.

## Inspect the theme selection

Show every SDDM theme selection line:

```bash
grep -RIn '^[[:space:]]*Current[[:space:]]*=' /etc/sddm.conf /etc/sddm.conf.d 2>/dev/null || true
```

Show the Thyx drop-in:

```bash
cat /etc/sddm.conf.d/zzzzzz-thyx.conf
```

Expected content:

```ini
[Theme]
Current=thyx
```

Show installed SDDM themes:

```bash
ls -1 /usr/share/sddm/themes
```

The value in `Current=` must be one of those directory names.

## What the installer does

Run the installer from the repository root:

```bash
./scripts/install
```

For non-interactive install:

```bash
./scripts/install --yes
```

The installer does this:

```text
find the Thyx repository
create a log file
validate metadata.desktop
check required commands and runtime dependencies
print an install plan
ask for confirmation
authenticate sudo
stage the theme into a temporary directory
copy the staged theme into /usr/share/sddm/themes/thyx
install bundled fonts
write the SDDM drop-in
enable sddm.service
verify the installed result
print a safe preview command
```

The installer asks for sudo because it writes into:

```bash
/usr/share/sddm/themes
/usr/local/share/fonts
/etc/sddm.conf.d
```

Those are system paths.

## What "atomic install" means

The installer doesn't copy files directly into the live theme directory one by one.

It first creates a staging directory:

```bash
/usr/share/sddm/themes/.thyx.stage.<timestamp>
```

Then it copies the repo into that staging directory.

Then it validates the staged copy.

Then it moves the staged directory into the final path:

```bash
/usr/share/sddm/themes/thyx
```

If an older install exists, it is temporarily moved into a backup path:

```bash
/usr/share/sddm/themes/.thyx.bak.<timestamp>
```

If activation fails, the backup can be restored.

## Files Thyx touches

| path                                           | owner          | purpose                             |
| ---------------------------------------------- | -------------- | ----------------------------------- |
| `/usr/share/sddm/themes/thyx`                  | Thyx installer | installed SDDM theme                |
| `/usr/share/sddm/themes/thyx/metadata.desktop` | Thyx installer | tells SDDM how to load the theme    |
| `/usr/share/sddm/themes/thyx/theme.conf`       | Thyx installer | theme configuration                 |
| `/usr/share/sddm/themes/thyx/src/Main.qml`     | Thyx installer | main QML UI                         |
| `/usr/share/sddm/themes/.thyx.stage.*`         | Thyx installer | temporary install staging directory |
| `/usr/share/sddm/themes/.thyx.bak.*`           | Thyx installer | temporary backup during activation  |
| `/usr/local/share/fonts/thyx`                  | Thyx installer | bundled fonts installed for SDDM    |
| `/etc/sddm.conf.d/zzzzzz-thyx.conf`            | Thyx installer | SDDM theme selector                 |
| `~/.cache/thyx/thyx-install-*.log`             | Thyx installer | install logs                        |
| `~/.cache/thyx/thyx-uninstall-*.log`           | Thyx installer | uninstall logs                      |

The current installer selects Thyx through the owned drop-in. It doesn't need to rewrite every SDDM config file on the machine.

## Why fonts are installed system wide

The login screen appears before the user desktop session starts.

At that point, SDDM cannot rely on a user's desktop font setup, shell environment, user font cache, or session-specific configuration.

So bundled fonts go into:

```bash
/usr/local/share/fonts/thyx
```

Then the installer refreshes the font cache:

```bash
fc-cache -f
```

That makes the fonts visible to SDDM’s greeter process.

Check installed font files:

```bash
ls -la /usr/local/share/fonts/thyx
```

Check the font cache:

```bash
fc-list | grep -i "Plus Jakarta Sans" || true
fc-list | grep -i "Inter" || true
```

The family name used in QML or `theme.conf` should match the family name reported by `fc-list`.
installer enables SDDM

## Preview safely

Preview mode runs the greeter in test mode.

It doesn't log out the user, doesn't restart SDDM, nor does it change the active display manager. It opens the login UI as a test window.

Preview the installed theme:

```bash
QT_QPA_PLATFORM=xcb sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/thyx
```

If the system has only the generic greeter name:

```bash
QT_QPA_PLATFORM=xcb sddm-greeter --test-mode --theme /usr/share/sddm/themes/thyx
```

The repository also has a preview helper, you can run:

```bash
bash ./scripts/preview
```

## Uninstall Thyx

Run:

```bash
./scripts/uninstall
```

For non-interactive uninstall:

```bash
./scripts/uninstall --yes
```

The uninstaller removes Thyx’s owned SDDM selection files, removes the installed theme files, removes installed fonts, refreshes font cache when needed, and verifies that the effective SDDM theme no longer resolves to `thyx`.

It removes:

```bash
/etc/sddm.conf.d/zzzzzz-thyx.conf
/usr/share/sddm/themes/thyx
/usr/share/sddm/themes/.thyx.stage.*
/usr/share/sddm/themes/.thyx.bak.*
/usr/local/share/fonts/thyx
```

It also removes other Thyx-named SDDM drop-ins under:

```bash
/etc/sddm.conf.d
```

That handles old Thyx selector files from earlier installer versions.

## Recovery protocol

A broken login theme is recoverable from a TTY.

### 1. Switch to a TTY

Try:

```text
Ctrl + Alt + F2
Ctrl + Alt + F3
Ctrl + Alt + F4
```

Some laptops require:

```text
Ctrl + Alt + Fn + F2
```

Log in with the normal Linux username and password.

### 2. List installed SDDM themes

```bash
ls -1 /usr/share/sddm/themes
```

Pick a real theme from that list.

A common fallback is:

```text
breeze
```

### 3. Remove the Thyx selector

```bash
sudo rm -f /etc/sddm.conf.d/zzzzzz-thyx.conf
```

This removes the last-wins Thyx override.

### 4. Set SDDM to a fallback theme

Create or edit:

```bash
sudo nano /etc/sddm.conf
```

Set:

```ini
[Theme]
Current=breeze
```

Make sure to use a theme name that exists under:

```bash
/usr/share/sddm/themes
```

### 5. Restart the display manager

```bash
sudo systemctl restart display-manager
```

If that fails:

```bash
sudo reboot
```

## Disable SDDM

Disable SDDM:

```bash
sudo systemctl disable --now sddm
```

On Debian or Ubuntu, switch to another display manager:

```bash
sudo dpkg-reconfigure gdm3
sudo systemctl enable --now gdm3
```

## Log/Debug commands

Latest install log:

```bash
tail -200 "$(ls -1t ~/.cache/thyx/thyx-install-*.log | head -n 1)"
```

Latest uninstall log:

```bash
tail -200 "$(ls -1t ~/.cache/thyx/thyx-uninstall-*.log | head -n 1)"
```

Installed theme files:

```bash
find /usr/share/sddm/themes/thyx -maxdepth 3 -type f | sort
```

SDDM status:

```bash
systemctl status sddm --no-pager
```

Current boot logs for SDDM:

```bash
journalctl -u sddm -b --no-pager
```
