# Issues

Have you read the [Guide?](/docs/guide.md)

Use [issues](https://github.com/rccyx/thyx/issues) for bug reports, broken installs, distro problems, preview failures, SDDM selection problems, missing runtime packages, QML errors, visual breakage, and clear improvement proposals.

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

Also, screenshots are helpful.
