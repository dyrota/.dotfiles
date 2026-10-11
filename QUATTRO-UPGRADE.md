# Omarchy 3.8 -> 4 (Quattro) upgrade checklist

Quattro stops reading `~/.config/hypr/*.conf`, replaces Waybar/Walker/Mako/hypridle/hyprlock
with one Quickshell process (`~/.config/omarchy/shell.json`), and swaps iwd for
NetworkManager. Nothing below is ported automatically. Guide:
https://omarchylinux.org/upgrade/3-to-4-quattro/

## Before

- [ ] Save Wi-Fi passwords (Quattro doesn't migrate iwd profiles):
      `sudo grep -H Passphrase /var/lib/iwd/*.psk` -> password manager
- [ ] Push all project repos; commit + push this repo
- [ ] Snapshot: `sudo snapper -c root create -d pre-quattro` and confirm with `sudo snapper list`
- [ ] Have a wired connection or phone hotspot ready (Wi-Fi stack changes on reboot)
- [ ] Update > Omarchy (latest 3.x), reboot, check everything still works

## Upgrade

- [ ] `omarchy upgrade to quattro`, then reboot. If it prints "Upgrade incomplete - do NOT reboot", re-run it.
- Rollback: pick the `pre-quattro` snapshot in the Limine boot menu.

## After: port these customizations

| What | 3.x file (in this repo) | Quattro target |
|---|---|---|
| Dual MSI monitors by serial, 1080p@60, left/right; laptop 2560x1600@165 x1.6 | `hypr/monitors.conf` | `~/.config/hypr/monitors.lua` (`hl.monitor`) |
| Workspaces 1-5 left MSI, 6-10 right MSI (bar labels 10 as "10") | `hypr/monitors.conf` | `monitors.lua` / `hyprland.lua` workspace rules |
| Each monitor's bar shows only its workspaces | `waybar/config.jsonc` | `~/.config/omarchy/shell.json` |
| `AQ_NO_ATOMIC=1` (aquamarine 0.15.0 bug); first test WITHOUT it | `uwsm/env` | keep in uwsm env if still needed |
| Obsidian launched with `-disable-gpu --enable-wayland-ime` | `hypr/bindings.conf` | `bindings.lua` |
| Debloat: removed apps' keybindings | `scripts/omarchy-debloat.sh` | update script for `bindings.lua` |
| Key repeat delay 600ms, `kb_layout = us` | `hypr/input.conf` | `input.lua` |
| On AC power: no screensaver, lock or screen-off | `hypr/hypridle.conf` | `shell.json` idle settings |
| Fingerprint unlock on lock screen | `hypr/hyprlock.conf` | `shell.json` lock settings |
| Ghostty as default terminal | `terminals/.config/xdg-terminals.list` | check it survived |
| Captive portal helper | `bin/`, `systemd/` | should keep working (watches wlan0); NetworkManager also detects portals |
| Wi-Fi networks | (passwords saved above) | `nmcli dev wifi connect <ssid> password <pw>` |

## Checks

```
hyprctl monitors all              # both MSIs 1920x1080@60, right order
hyprctl workspaces                # 1-3 / 4-6 on the right monitors
hyprctl binds -j | grep -i obsidian
nmcli connection show             # Wi-Fi profiles
find ~/.config -name '*.omarchy-upgrade-to-quattro.*.bak'
```
Known upstream bugs: custom monitors/bindings silently ignored (#6911, #6933), shell.json reset (#8357), Wi-Fi profiles lost (#8996).
