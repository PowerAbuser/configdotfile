#!/usr/bin/env bash
# `hyprctl reload`, but only if the Lua config runs clean first
# (check-config.lua). Hyprland 0.56 can crash drawing its config-error
# overlay, so a broken file must never reach a reload. Everything that
# reloads on its own (desktop theme, matugen, night light, dark/light) uses
# this; on a failed check it notifies instead.
dir=$(dirname "$0")
if err=$(cd "$HOME/.config/hypr" && lua "$dir/check-config.lua" 2>&1); then
    exec hyprctl reload "$@"
fi
echo "$err" >&2
command -v notify-send >/dev/null && notify-send -u critical "Hyprland reload skipped" "$err"
exit 1
