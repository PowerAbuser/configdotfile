#!/usr/bin/env bash
# Show a wallpaper with awww, the way Settings > Wallpaper says:
#
#     wallpaper-show.sh [FILE]     (no FILE: the current wallpaper again)
#
# ~/.config/quickshell/wallpaper.json (all optional):
#   mode        cover | contain | stretch | center | tile        (cover)
#   gravity     where cover crops from: center, top, bottom, left, right,
#               top-left ... (center)
#   fill        the colour around contain / center: "#rrggbb", or "auto"
#               for the wallpaper scheme's darkest surface (auto)
#   filter      Lanczos3 | CatmullRom | Mitchell | Bilinear | Nearest
#   transition  an awww transition type (grow), "none" for an instant change
#   duration    seconds (1)
#   tileScale   tile size, percent of the image's own (100)
# Tile isn't an awww mode: each screen gets the picture repeated at its
# resolution (ImageMagick), cached in ~/.cache/quickshell/wallpaper-tiles.
#
# Only shows it: set-wallpaper.sh also records it and regenerates colours.
set -u
cfg=$HOME/.config/quickshell/wallpaper.json
img=${1:-$(readlink -f "$HOME/.config/hypr/.cache/current_wallpaper.png")}
[[ -f $img ]] || { echo "wallpaper-show: no such file: $img" >&2; exit 1; }

get() { jq -r --arg d "$2" ".$1 // \$d | tostring" "$cfg" 2>/dev/null || echo "$2"; }
mode=$(get mode cover)
gravity=$(get gravity center)
fill=$(get fill auto)
filter=$(get filter Lanczos3)
transition=$(get transition grow)
duration=$(get duration 1)
tileScale=$(get tileScale 100)

if [[ $fill == auto ]]; then
    fill=$(jq -r '.surface_container_lowest // "#000000"' "$HOME/.config/quickshell/colors/Colors.json" 2>/dev/null)
fi
fill=${fill#\#}
[[ $fill =~ ^[0-9a-fA-F]{6}$ ]] || fill=000000

pgrep -x awww-daemon >/dev/null || { setsid awww-daemon >/dev/null 2>&1 & sleep 0.3; }

common=(--filter "$filter" --fill-color "${fill}ff" --transition-fps 60
        --transition-bezier ".43,1.19,1,.4")
if [[ $transition == none ]]; then
    common+=(--transition-type none)
else
    common+=(--transition-type "$transition" --transition-duration "$duration")
fi

case $mode in
    contain) exec awww img "$img" --resize fit "${common[@]}" ;;
    stretch) exec awww img "$img" --resize stretch "${common[@]}" ;;
    center)  exec awww img "$img" --resize no "${common[@]}" ;;
    tile)
        cache=$HOME/.cache/quickshell/wallpaper-tiles
        mkdir -p "$cache"
        key=$(printf '%s %s %s' "$img" "$(stat -c %Y "$img")" "$tileScale" | md5sum | cut -c1-12)
        status=0
        while read -r name w h; do
            out=$cache/$key-${w}x$h.png
            if [[ ! -s $out ]]; then
                # Scale one tile, then repeat it across the screen
                magick "$img" -resize "${tileScale}%" -write mpr:t +delete \
                    -size "${w}x$h" tile:mpr:t "$out" || { status=1; continue; }
            fi
            awww img -o "$name" "$out" --resize no "${common[@]}" || status=1
        done < <(hyprctl monitors -j | jq -r '.[] | "\(.name) \(.width) \(.height)"')
        exit $status ;;
    *)       exec awww img "$img" --resize crop --crop-gravity "$gravity" "${common[@]}" ;;
esac
