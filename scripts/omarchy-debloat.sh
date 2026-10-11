#!/bin/bash
# Remove Omarchy preinstalls I don't use. Safe to re-run: anything already gone is skipped.
#   omarchy-debloat.sh            remove everything below (asks for sudo for packages)
#   omarchy-debloat.sh --dry-run  show what would be removed, change nothing
#
# Edit the three lists to change what goes. Omarchy updates don't reinstall dropped
# packages, but `omarchy reinstall pkgs` or `omarchy refresh hyprland` would bring them
# back; just re-run this afterwards.

set -euo pipefail

PACKAGES=(
  spotify
  signal-desktop
  libreoffice-fresh
  1password-beta 1password-cli
  typora
)

WEBAPPS=(Basecamp HEY Fizzy ChatGPT Figma)

# Keybindings in ~/.config/hypr/bindings.conf that launch removed apps (matched as regex
# against the line). They get commented out so the keys don't do nothing.
BINDINGS=(
  'spotify'
  'signal-desktop'
  'typora'
  '1password'
  'chatgpt\.com'
  'app\.hey\.com'
)

DRY=false
[[ ${1:-} == --dry-run ]] && DRY=true
run() { if $DRY; then echo "  would run: $*"; else "$@"; fi; }

echo "Packages:"
installed=()
for p in "${PACKAGES[@]}"; do
  if pacman -Q "$p" &>/dev/null; then installed+=("$p"); echo "  remove $p"; else echo "  $p (already gone)"; fi
done
if (( ${#installed[@]} )); then
  run sudo pacman -Rns --noconfirm "${installed[@]}"
fi

echo "Web apps:"
apps=~/.local/share/applications
present=()
for a in "${WEBAPPS[@]}"; do
  if [[ -f $apps/$a.desktop ]]; then present+=("$a"); echo "  remove $a"; else echo "  $a (already gone)"; fi
done
if (( ${#present[@]} )); then
  run omarchy-webapp-remove "${present[@]}"
fi

# Leftover per-user launchers for removed packages (e.g. ~/.local/share/applications/typora.desktop)
for f in $(printf '%s\n' "${PACKAGES[@]/%/.desktop}" "${PACKAGES[@]/%-desktop/.desktop}" | sort -u); do
  [[ -f $apps/$f ]] && { echo "  remove leftover launcher $f"; run rm -f "$apps/$f"; }
done

echo "Keybindings:"
conf=~/.config/hypr/bindings.conf
pattern=$(IFS='|'; echo "${BINDINGS[*]}")
mapfile -t hits < <(grep -nE "^[[:space:]]*bind[a-z]*[[:space:]]*=.*($pattern)" "$conf" || true)
if (( ${#hits[@]} )); then
  printf '  comment out line %s\n' "${hits[@]}"
  if ! $DRY; then
    cp "$conf" "$conf.bak.$(date +%s)"
    sed -i -E "/^[[:space:]]*bind[a-z]*[[:space:]]*=.*($pattern)/s/^/# debloat: /" "$conf"
    hyprctl reload >/dev/null && hyprctl configerrors
  fi
else
  echo "  nothing to change"
fi

$DRY && echo "Dry run: nothing changed." || echo "Done."
