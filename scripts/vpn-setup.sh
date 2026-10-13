#!/bin/bash
# One-time Surfshark (WireGuard) setup for Omarchy 3 (iwd + systemd-networkd).
#   ./vpn-setup.sh ~/Downloads/<surfshark-config>.conf
#
# Get the config: my.surfshark.com > VPN > Manual setup > Desktop or mobile > WireGuard
#   > "I don't have a key pair" > generate > Locations > pick a server > Download.
# The config holds your private key: it lives only in /etc/wireguard, never in dotfiles.
set -euo pipefail

src=${1:?usage: vpn-setup.sh path/to/surfshark.conf}
[[ -f $src ]] || { echo "No such file: $src" >&2; exit 1; }
grep -q '^\[Interface\]' "$src" || { echo "$src is not a WireGuard config" >&2; exit 1; }

echo "==> Installing wireguard-tools and systemd-resolvconf (DNS through the tunnel)"
sudo pacman -S --needed --noconfirm wireguard-tools systemd-resolvconf

echo "==> Installing config as /etc/wireguard/surfshark.conf"
tmp=$(mktemp)
# Send IPv6 into the tunnel too. Surfshark's tunnel is IPv4-only, so this blocks IPv6
# instead of letting it leak around the VPN on networks (like yours) that hand out IPv6.
sed -E '/^AllowedIPs/ { /::\/0/! s/$/, ::\/0/ }' "$src" > "$tmp"
sudo install -D -m 600 -o root -g root "$tmp" /etc/wireguard/surfshark.conf
rm -f "$tmp"

echo "==> Letting $USER turn the VPN on/off without sudo (polkit rule)"
sudo tee /etc/polkit-1/rules.d/50-surfshark-vpn.rules >/dev/null <<RULES
polkit.addRule(function(action, subject) {
  if (action.id == "org.freedesktop.systemd1.manage-units" &&
      action.lookup("unit") == "wg-quick@surfshark.service" &&
      subject.user == "$USER") {
    var verb = action.lookup("verb");
    if (verb == "start" || verb == "stop" || verb == "restart") return polkit.Result.YES;
  }
});
RULES

echo "==> Done. Test with:  vpn on && vpn status"
echo "    Work Wi-Fi (Staff-WLAN / Guest-WLAN) will turn it on automatically after you log in."
