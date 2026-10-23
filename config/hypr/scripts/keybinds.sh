#!/bin/bash

if pidof rofi > /dev/null; then
  pkill rofi
fi

KEYBINDS_CONF="$HOME/.config/hypr/confs/keybinds.conf"

if [[ ! -f "$KEYBINDS_CONF" ]]; then
    notify-send "Keybinds conf not found" "$KEYBINDS_CONF"
    exit 1
fi

parse_keybinds() {
    declare -A vars

    while IFS= read -r line; do
        [[ -z "${line//[[:space:]]/}" ]] && continue
        [[ "$line" =~ ^[[:space:]]*# ]] && continue

        # Capture variable definitions ($name = value)
        if [[ "$line" =~ ^[[:space:]]*\$([A-Za-z_-]+)[[:space:]]*=[[:space:]]*(.+)$ ]]; then
            local varname="\$${BASH_REMATCH[1]}"
            local varval="${BASH_REMATCH[2]}"
            varval="${varval%"${varval##*[! ]}"}"  # rtrim
            for k in "${!vars[@]}"; do varval="${varval//$k/${vars[$k]}}"; done
            vars["$varname"]="$varval"
            continue
        fi

        # Only keyboard binds — skip bindm (mouse drag)
        [[ ! "$line" =~ ^[[:space:]]*bind[el]*[[:space:]]*= ]] && continue

        # Extract inline comment as description
        local desc=""
        if [[ "$line" =~ ' #'(.+)$ ]]; then
            desc="${BASH_REMATCH[1]## }"
            line="${line%' #'*}"
        fi

        # Strip "bind... = " prefix
        local rest="${line#*=}"
        rest="${rest## }"

        local mod key type
        mod=$(cut  -d',' -f1 <<< "$rest" | tr -d '[:space:]')
        key=$(cut  -d',' -f2 <<< "$rest" | tr -d '[:space:]')
        type=$(cut -d',' -f3 <<< "$rest" | tr -d '[:space:]')
        local args
        args=$(cut -d',' -f4- <<< "$rest" | sed 's/^[[:space:]]*//')

        # Substitute known variables in mod
        for k in "${!vars[@]}"; do mod="${mod//$k/${vars[$k]}}"; done
        mod="${mod//\$/}"  # strip leftover $ from undefined vars like $ALT, $CONTROL

        # Build ordered display string: SUPER + CTRL + SHIFT + ALT
        local dm=""
        [[ "$mod" =~ SUPER   ]] && dm+="SUPER + "
        [[ "$mod" =~ CTRL|CONTROL ]] && dm+="CTRL + "
        [[ "$mod" =~ SHIFT   ]] && dm+="SHIFT + "
        [[ "$mod" =~ ALT     ]] && dm+="ALT + "
        dm="${dm% + }"

        if [[ -z "$desc" ]]; then
            case "$type" in
                exec)
                    # Substitute vars in args to get a readable command name
                    local cmd="$args"
                    for k in "${!vars[@]}"; do cmd="${cmd//$k/${vars[$k]}}"; done
                    local base
                    base=$(awk '{print $1}' <<< "$cmd" | xargs basename 2>/dev/null | sed 's/\.sh$//')
                    desc="Run: $base"
                    ;;
                killactive)                desc="Kill active window" ;;
                exit)                      desc="Exit Hyprland" ;;
                togglefloating)            desc="Toggle floating" ;;
                fullscreen)                desc="Toggle fullscreen" ;;
                pseudo)                    desc="Toggle pseudo tiling" ;;
                togglesplit)               desc="Toggle split" ;;
                togglegroup)               desc="Toggle group" ;;
                cyclenext)                 desc="Cycle next window" ;;
                bringactivetotop)          desc="Bring active to top" ;;
                workspace)                 desc="Workspace: $args" ;;
                movetoworkspace)           desc="Move to workspace: $args" ;;
                movetoworkspacesilent)     desc="Move to workspace (silent): $args" ;;
                movefocus)                 desc="Focus: $args" ;;
                movewindow)                desc="Move window: $args" ;;
                togglespecialworkspace)    desc="Toggle special workspace: $args" ;;
                splitratio)                desc="Adjust split ratio" ;;
                workspaceopt)              desc="Workspace option: $args" ;;
                *)                         desc="$type $args" ;;
            esac
        fi

        if [[ -n "$dm" ]]; then
            printf "%s + %s | %s\n" "$dm" "$key" "$desc"
        else
            printf "%s | %s\n" "$key" "$desc"
        fi
    done < "$KEYBINDS_CONF"
}

formatted=$(parse_keybinds | sed 's/ | /  󰶻  /g')

keybinds=$(echo -e "$formatted" | rofi -dmenu -markup -theme ~/.config/rofi/themes/rofi-keybinds.rasi -p "Keybinds")

if [[ -z "$keybinds" ]]; then
    echo ">< No keybind selected."
    exit 1
fi
