#!/usr/bin/env bash
# Escape (non-consuming bind): hide the pyprland "music" scratchpad when
# Spotify is the focused window; Esc still reaches whatever app has focus.
[[ "$(hyprctl activewindow -j | jq -r .class)" == "Spotify" ]] && exec /usr/bin/pypr-client toggle music
exit 0
