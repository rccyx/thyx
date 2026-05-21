# Issues

Use [issues](https://github.com/rccyx/thyx/issues) for bug reports, broken installs, distro problems, preview failures, SDDM selection problems, missing runtime packages, QML errors, and clear improvement proposals.

Useful details:

- distro and version
- current display manager
- desktop or compositor
- install or uninstall command used
- installer or uninstaller log from `~/.cache/thyx/`
- output from `./scripts/preview`
- output from `systemctl status sddm --no-pager`
- output from `grep -RIn '^[[:space:]]*Current[[:space:]]*=' /etc/sddm.conf /etc/sddm.conf.d 2>/dev/null || true`
- screenshots when the issue is visual
- exact config changes when the issue involves `theme.conf` or a preset

Vague reports are hard to act on. Reports with logs, commands, and exact system details can usually be fixed.
