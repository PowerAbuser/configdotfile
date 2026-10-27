#!/usr/bin/env bash
# Set the wallpaper: set-wallpaper.sh FILE
# wallpaper-show.sh draws it with awww (mode, fill and transition from
# Settings > Wallpaper), then set-current-wallpaper.sh records it (hyprlock,
# startup, thumbnails) and regenerates the colour scheme with matugen. Used
# by the wallpaper picker, the hub's Wallpapers panel and SUPER+W.
img=$1
[[ -f $img ]] || { echo "set-wallpaper: no such file: $img" >&2; exit 1; }
# The fill around a contained / centred picture can be the new wallpaper's
# own darkest surface: its scheme has to exist before it's drawn
cfg=$HOME/.config/quickshell/wallpaper.json
mode=$(jq -r '.mode // "cover"' "$cfg" 2>/dev/null)
fill=$(jq -r '.fill // "auto"' "$cfg" 2>/dev/null)
if [[ ($mode == contain || $mode == center) && ${fill:-auto} == auto ]]; then
    "$(dirname "$0")/matugen-apply.sh" "$img"
fi
"$(dirname "$0")/wallpaper-show.sh" "$img" || exit 1
exec "$HOME/.config/hypr/scripts/set-current-wallpaper.sh" "$img"
