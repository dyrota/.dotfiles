# dotfiles

Omarchy (Hyprland) setup for a Framework 16. Each top-level folder mirrors `$HOME`
(GNU stow layout), e.g. `hypr/.config/hypr/monitors.conf` -> `~/.config/hypr/monitors.conf`.

```bash
git clone git@github.com:dyrota/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles && stow hypr waybar uwsm bin systemd   # or copy the files by hand
systemctl --user daemon-reload && systemctl --user enable --now captive-portal.service
scripts/omarchy-debloat.sh --dry-run                    # then without --dry-run
```

| Folder | What |
|---|---|
| `hypr/` | Hyprland: monitors (dual MSI by serial, workspaces 1-3 / 4-6), bindings, input, look |
| `waybar/` | Top bar; each monitor shows its own workspaces |
| `uwsm/` | Session env, incl. `AQ_NO_ATOMIC=1` workaround for aquamarine 0.15.0 (remove once fixed) |
| `bin/` | `captive-portal`: opens Wi-Fi login pages, which Omarchy doesn't detect |
| `systemd/` | `captive-portal.service`: runs it whenever wlan0 gets an address |
| `scripts/omarchy-debloat.sh` | Removes unused preinstalls (apps, web apps, their keybindings); re-runnable |
