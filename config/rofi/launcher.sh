#!/usr/bin/env bash

dir="$HOME/.config/rofi"
# follow the hub's dark/light mode (SUPER+R calls this script in both modes)
theme='style-dark'
[[ "$(cat "$HOME/.cache/quickshell/theme_mode" 2>/dev/null)" == "light" ]] && theme='style-light'

# 1. Remove Hyprland Borders (eval: `keyword` is a no-op under the Lua config)
border=$(jq -r '.border_size // 1' "$HOME/.config/quickshell/windowlook.json" 2>/dev/null || echo 1)
hyprctl eval 'hl.config({ general = { border_size = 0 } })' > /dev/null

# 2. Run Rofi
selected=$(rofi \
    -show drun \
    -theme ${dir}/${theme}.rasi \
    -drun-print-desktop \
    -print-to-stdout \
    2>/dev/null)
    
exit_code=$?

# 3. Restore Hyprland Borders
hyprctl eval "hl.config({ general = { border_size = ${border:-1} } })" > /dev/null


# Case 1: ESC or closed the menu (Exit Code 1)
if [ $exit_code -eq 1 ] || [ -z "$selected" ]; then
    exit 0
fi

# Case 2: App is launched (Exit Code 0)
if [ $exit_code -eq 0 ]; then
    if [[ "$selected" == *.desktop ]]; then
        app_id=$(basename "$selected" .desktop)
        gtk-launch "$app_id" > /dev/null 2>&1 &
    fi
    exit 0
fi

# Case 3: Used a Custom Keybind like Shift+Enter
xdg-open "https://www.google.com/search?q=${selected}" > /dev/null 2>&1 &