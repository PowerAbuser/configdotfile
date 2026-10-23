#!/bin/bash
# SUPER+W: random wallpaper from ~/.config/hypr/Wallpapers

scrDir="$HOME/.config/hypr/scripts"
wallDir="$HOME/.config/hypr/Wallpapers"

PICS=($(find "${wallDir}" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \)))
[ ${#PICS[@]} -eq 0 ] && { notify-send "No wallpapers in ${wallDir}"; exit 1; }
wallpaper=${PICS[ $RANDOM % ${#PICS[@]} ]}

# Transition config
FPS=60
TYPE="random"
DURATION=1
BEZIER=".43,1.19,1,.4"
SWWW_PARAMS="--transition-fps $FPS --transition-type $TYPE --transition-duration $DURATION --transition-bezier $BEZIER"

notify-send -i "${wallpaper}" "Changing wallpaper" -t 1500
awww-daemon &
awww img "${wallpaper}" $SWWW_PARAMS

sleep 0.5
"$scrDir/set-current-wallpaper.sh" "$wallpaper"
