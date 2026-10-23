#!/usr/bin/env bash
# Area screenshot for the hub's camera button: slurp a region, grim it, open
# it in swappy (same flow as ~/.config/hypr/scripts/screenshot.sh).
set -u
dir="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$dir"
tmp="$(mktemp --suffix=.png)"
trap 'rm -f "$tmp"' EXIT

# let the hub close before selecting
sleep 0.3
area="$(slurp)" || exit 0
grim -g "$area" "$tmp" || exit 1
swappy -f "$tmp" -o "$dir/screenshot_$(date +%y%m%d_%H%M%S).png"
