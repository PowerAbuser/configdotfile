#!/usr/bin/env bash
# Regenerate the colour scheme from the wallpaper with matugen:
#
#     matugen-apply.sh [IMAGE]
#
# IMAGE defaults to the current wallpaper (~/.config/hypr/.cache/current_wallpaper.png).
# The mode follows the hub's dark/light (~/.cache/quickshell/theme_mode); the
# scheme kind and contrast come from Settings > Colour (palette.json next to
# shell.qml). matugen writes the files listed in ~/.config/matugen/config.toml;
# this script then points kitty, rofi and dunst at them.
#
# Called by hypr/scripts/set-current-wallpaper.sh and utils/theme-mode.sh.
# Exits non-zero when matugen is missing or fails, so callers can fall back.

set -u
MATUGEN=$(command -v matugen || echo "$HOME/.cargo/bin/matugen")
[[ -x $MATUGEN ]] || { echo "matugen-apply: matugen not installed" >&2; exit 1; }

img=${1:-$(readlink -f "$HOME/.config/hypr/.cache/current_wallpaper.png")}
[[ -f $img ]] || { echo "matugen-apply: no image '$img'" >&2; exit 1; }

mode=$(tr -d '[:space:]' < "$HOME/.cache/quickshell/theme_mode" 2>/dev/null)
[[ $mode == light ]] || mode=dark

opts=(-m "$mode")
palette=$HOME/.config/quickshell/palette.json
if [[ -f $palette ]] && command -v jq >/dev/null; then
    type=$(jq -r '.scheme // empty' "$palette" 2>/dev/null)
    contrast=$(jq -r '.contrast // empty' "$palette" 2>/dev/null)
    [[ $type == scheme-* ]] && opts+=(-t "$type")
    [[ $contrast =~ ^-?[0-9]+(\.[0-9]+)?$ ]] && opts+=(--contrast "$contrast")
fi

# One run at a time: a wallpaper pick and a mode switch can land together.
# Daemons started below get `9>&-` so they don't keep the lock held.
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/matugen-apply.lock"
flock -w 30 9 || { echo "matugen-apply: lock busy" >&2; exit 1; }

# Niced: a big image takes most of a second on every core
nice -n 19 "$MATUGEN" image "$img" --source-color-index 0 -q "${opts[@]}" 9>&- || exit 1

# kitty and rofi read the generated files through these links
ln -sf "$HOME/.config/kitty/colors/matugen.conf" "$HOME/.config/kitty/theme.conf"
ln -sf "$HOME/.config/rofi/colors/Matugen.rasi" "$HOME/.config/rofi/themes/rofi-colors.rasi"

# dunst: icons and frame width follow the mode, as dunstrc_dark/_light did
dunst_src=$HOME/.config/dunst/dunstrc_matugen
if [[ -f $dunst_src ]]; then
    if [[ $mode == light ]]; then icons=Papirus-Light; frame=2; else icons=Papirus-Dark; frame=1; fi
    sed -e "s|@ICONS@|$icons|g" -e "s|^\(\s*frame_width = \).*|\1$frame|" \
        "$dunst_src" > "$HOME/.config/dunst/dunstrc"
    if systemctl --user is-active --quiet dunst.service; then
        systemctl --user restart dunst.service 9>&-
    elif pgrep -x dunst >/dev/null; then
        killall dunst 2>/dev/null; sleep 0.2
        setsid dunst >/dev/null 2>&1 9>&- &
    fi
fi
exit 0
