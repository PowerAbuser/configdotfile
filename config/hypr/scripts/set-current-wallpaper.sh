#!/usr/bin/env bash
# Record <image> as the current wallpaper, after it has been applied:
#   .cache/current_wallpaper.png  (startup.sh and hyprlock read this link)
#   .cache/.wallpaper             (its name, for wallcache.sh)
#   wallcache.sh                  (thumb / blur / quad caches)
# Shared by the hub's Wallpapers panel, WallpaperSelect.sh and Wallpaper.sh.
# usage: set-current-wallpaper.sh <image>

img="$1"
[ -f "$img" ] || { echo "set-current-wallpaper: no such file: $img" >&2; exit 1; }

cacheDir="$HOME/.config/hypr/.cache"
mkdir -p "$cacheDir"

ln -sf "$img" "$cacheDir/current_wallpaper.png"
name="$(basename "$img")"
echo "${name%.*}" >"$cacheDir/.wallpaper"

"$HOME/.config/hypr/scripts/wallcache.sh"
