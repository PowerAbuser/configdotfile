#!/bin/bash

# Kill already running processes
_ps=(
  swaync
  rofi
  wayabr
)
for _prs in "${_ps[@]}"; do
  if pidof "${_prs}" &>/dev/null; then
    pkill "${_prs}"
  fi
done

sleep 0.3
swaync &
waybar &

sleep 1
hyprctl reload

exit 0
