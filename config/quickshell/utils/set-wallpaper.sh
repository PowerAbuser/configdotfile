#!/usr/bin/env bash
# Set the wallpaper: set-wallpaper.sh FILE
# awww draws it (with the same transition as hypr/scripts/Wallpaper.sh), then
# set-current-wallpaper.sh records it (hyprlock, startup, thumbnails) and
# regenerates the colour scheme with matugen. Used by the wallpaper picker
# (wallpicker/WallpaperEngine.qml).
img=$1
[[ -f $img ]] || { echo "set-wallpaper: no such file: $img" >&2; exit 1; }
pgrep -x awww-daemon >/dev/null || { setsid awww-daemon >/dev/null 2>&1 & sleep 0.3; }
awww img "$img" --transition-fps 60 --transition-type grow --transition-duration 1 \
    --transition-bezier ".43,1.19,1,.4" || exit 1
exec "$HOME/.config/hypr/scripts/set-current-wallpaper.sh" "$img"
