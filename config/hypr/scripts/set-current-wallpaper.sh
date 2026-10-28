#!/usr/bin/env bash
# Record <image> as the current wallpaper, after it has been applied:
#   .cache/current_wallpaper.png  (startup.sh and hyprlock read this link)
#   .cache/.wallpaper             (its name, for wallcache.sh)
#   wallcache.sh                  (thumb / blur / quad caches)
# Shared by the hub's Wallpapers panel, WallpaperSelect.sh and Wallpaper.sh.
#   matugen-apply.sh           (colour scheme from it)
# usage: set-current-wallpaper.sh <image>

img="$1"
[ -f "$img" ] || { echo "set-current-wallpaper: no such file: $img" >&2; exit 1; }

cacheDir="$HOME/.config/hypr/.cache"
mkdir -p "$cacheDir"

ln -sf "$img" "$cacheDir/current_wallpaper.png"
name="$(basename "$img")"
echo "${name%.*}" >"$cacheDir/.wallpaper"

"$HOME/.config/hypr/scripts/wallcache.sh"

# Colour scheme from the new wallpaper (backgrounded: matugen takes ~1 s)
setsid "$HOME/.config/quickshell/utils/matugen-apply.sh" "$img" >/dev/null 2>&1 &

# The login screen too, when the picker's switch is on
if [[ $(jq -r '.sddmWallpaper // false' "$HOME/.config/quickshell/wallpicker.json" 2>/dev/null) == true ]]; then
    setsid "$HOME/.config/quickshell/utils/sddm-wallpaper.sh" "$img" >/dev/null 2>&1 &
fi
