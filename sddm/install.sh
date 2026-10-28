#!/usr/bin/env bash
# One-time root setup for the SDDM login screen: sudo ./install.sh [preset]
#
# Gives you two files inside sddm-astronaut-theme, so the shell can change
# the login screen from then on without root:
#   Themes/qs-active.conf         the theme's config; Settings > Login screen
#                                 writes a preset into it (sddm-preset.sh)
#   Backgrounds/qs-wallpaper.jpg  its background; the wallpaper picker's
#                                 "login screen" switch copies wallpapers there
#                                 (sddm-wallpaper.sh)
# and copies the shell's theme fonts where the greeter can see them. Both
# scripts live in config/quickshell/utils; the presets in
# config/quickshell/sddm/presets. Starts on PRESET (default hud) with the
# wallpaper on screen.
set -euo pipefail

THEME=/usr/share/sddm/themes/sddm-astronaut-theme
preset=${1:-hud}

[[ $EUID -eq 0 ]] || { echo "run with sudo" >&2; exit 1; }
[[ -d $THEME ]] || { echo "sddm-astronaut-theme isn't installed at $THEME" >&2; exit 1; }
user=${SUDO_USER:?run with sudo from your own account}
user_home=$(getent passwd "$user" | cut -d: -f6)
utils=$user_home/.config/quickshell/utils

for f in Themes/qs-active.conf Backgrounds/qs-wallpaper.jpg; do
    [[ -f $THEME/$f ]] || install -m 644 /dev/null "$THEME/$f"
    chown "$user" "$THEME/$f"
done

# The greeter runs as the sddm user and can't see ~/.local/share/fonts.
if [[ -d $user_home/.local/share/fonts/quickshell-themes ]]; then
    mkdir -p /usr/local/share/fonts/quickshell-themes
    cp -u "$user_home"/.local/share/fonts/quickshell-themes/* /usr/local/share/fonts/quickshell-themes/
    fc-cache -f /usr/local/share/fonts >/dev/null
fi

sed -i 's|^ConfigFile=.*|ConfigFile=Themes/qs-active.conf|' "$THEME/metadata.desktop"

sudo -u "$user" "$utils/sddm-preset.sh" "$preset"
current=$(readlink -f "$user_home/.config/hypr/.cache/current_wallpaper.png" || true)
if [[ -f $current ]]; then
    sudo -u "$user" "$utils/sddm-wallpaper.sh" "$current" || echo "couldn't copy the wallpaper on screen" >&2
fi
echo "Login screen set up with the $preset preset. Change it in Settings > Login screen."
