#!/usr/bin/env bash
# Night light: night-light.sh on | off | toggle
# Writes ~/.cache/quickshell/night_light (the hub's toggle and ThemeOSD read
# it) and applies the shader live (on) or reloads Hyprland (off). confs/decoration.lua reapplies it on every
# Hyprland reload from the same file.
state=$HOME/.cache/quickshell/night_light
shader=$HOME/.config/hypr/shaders/night_light.frag
cur=$(cat "$state" 2>/dev/null | tr -d "[:space:]")
case $1 in
    on|off) next=$1 ;;
    *) [[ $cur == on ]] && next=off || next=on ;;
esac
mkdir -p "$(dirname "$state")"
echo "$next" > "$state.tmp" && mv -f "$state.tmp" "$state"
if [[ $next == on ]]; then
    hyprctl eval "hl.config({ decoration = { screen_shader = \"$shader\" } })" >/dev/null
else
    # A reload puts back whatever shader the desktop theme sets (or none)
    "$HOME/.config/hypr/scripts/safe-reload.sh" >/dev/null
fi
