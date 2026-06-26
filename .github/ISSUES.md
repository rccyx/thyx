# Issues

Have you read the [Guide?](https://www.google.com/search?q=/docs/guide.md)

Is it an actual bug? As in, a bug regarding what this greeter system is supposed to do, but doesn't? Like, one of the theme options doesn't actually work. Maybe install/uninstall blows up? Although this goes through extensive testing in CI for the supported distros, so if it works in a reproducible environment in VM runners, it's most likely not the real issue, and the real one is a local state mutation/environmental edge case rather than broken source code. Source code bugs are in maybe a bug in QML, transitions don't work or something. Things like this.

Or is it visual changes like users dropdown menu, hide/show password toggles, another preset etc? If that, the [LICENSE](/LICENSE) allows forking.

So did the installer/uninstaller fail? Any logs? What does `~/.cache/thyx/*.log` say?

Did SDDM already work before installing this? Does it still work with another theme?

Also, what version is SDDM? Is it even active?

```bash
systemctl is-enabled sddm
systemctl is-active sddm
systemctl status sddm --no-pager
```

And what WM/DE?

```bash
echo $XDG_CURRENT_DESKTOP
```

With which Distro you're on?

```bash
cat /etc/os-release
```

Did the installer work cleanly, but the old theme still appears?

```bash
grep -RIn '^[[:space:]]*Current[[:space:]]*=' \
  /etc/sddm.conf \
  /etc/sddm.conf.d \
  /usr/lib/sddm/sddm.conf.d \
  /usr/share/sddm/sddm.conf.d \
  2>/dev/null || true
```

```bash
test -d /usr/share/sddm/themes/thyx && echo "thyx directory exists"
test -f /usr/share/sddm/themes/thyx/Main.qml && echo "Main.qml exists"
test -f /usr/share/sddm/themes/thyx/metadata.desktop && echo "metadata.desktop exists"
```

```bash
sed -n '/^\[Theme\]/,/^\[/p' /etc/sddm.conf 2>/dev/null || true
```

Does preview work, but the real login screen fails?

What the logs show for the preview?

```bash
./scripts/preview
```

```bash
sddm --version 2>/dev/null || sddm-greeter --version 2>/dev/null || true
```
