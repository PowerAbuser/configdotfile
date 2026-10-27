#!/usr/bin/env bash
# The desktop theme's lock screen, for hyprlock:
#
#     hyprlock-theme.sh           (reads ~/.cache/quickshell/lock-theme.json)
#
# desktoptheme/DesktopTheme.qml writes that file (the theme's id, fonts,
# accents, corners) on every theme or wallpaper change and runs this. With a
# theme on, it writes ~/.config/hypr/lockscreens/hyprlock-theme.conf, styled
# after that theme's lock screen in dhrruvsharma/shell (its wording, layout,
# type and colours; hyprlock draws no animations or shaders, so each is a
# still of the original), and points ~/.config/hypr/hyprlock.conf at it.
# With none on, hyprlock.conf goes back to the lock screen it pointed at
# before. Unlocking is hyprlock's own, unchanged.
set -u
spec=${LOCK_SPEC:-$HOME/.cache/quickshell/lock-theme.json}
dir=$HOME/.config/hypr/lockscreens
out=${LOCK_OUT:-$dir/hyprlock-theme.conf}
link=${LOCK_LINK:-$HOME/.config/hypr/hyprlock.conf}
keep=${LOCK_KEEP:-$HOME/.cache/quickshell/lock-off-target}   # what hyprlock.conf pointed at before
info=$HOME/.config/quickshell/utils/lock-info.sh
wall=$HOME/.config/hypr/.cache/current_wallpaper.png

j() { jq -r ".$1 // \"$2\"" "$spec" 2>/dev/null || echo "$2"; }
id=$(j id "")

current=$(readlink "$link" 2>/dev/null)
if [[ -z $id ]]; then
    # Theme off: back to the previous lock screen
    target=$(cat "$keep" 2>/dev/null)
    [[ -n $target && -f $target ]] || target=$dir/hyprlock-surface.conf
    [[ $current == "$out" ]] && ln -sfn "$target" "$link"
    exit 0
fi
[[ -n $current && $current != "$out" ]] && echo "$current" > "$keep"

name=$(j name Theme)
ui=$(j ui "Inter")
display=$(j display "$ui")
mono="JetBrainsMono Nerd Font"
acc=$(j accent "#b4befe"); acc2=$(j accent2 "#f5c2e7")
ink=$(j ink "#e5e2e3"); dim=$(j dim "#c8c6c7"); base=$(j base "#131315")
err=$(j error "#ffb4ab")
r=$(j radius 8)
user=$(grep -oP 'PROFILE_NAME\s*=\s*"\K[^"]+' "$HOME/.config/quickshell/config.js" 2>/dev/null || echo "$USER")
host=$(hostname)

# rgba(rrggbbaa) from "#rrggbb" and an alpha 0..1
c() { local h=${1#\#}; printf 'rgba(%s%02x)' "${h:0:6}" "$(awk -v a="${2:-1}" 'BEGIN{printf "%d", a*255+0.5}')"; }
# Pango colour inside config text: '#' starts a comment there, so it's doubled
pc() { printf '##%s' "${1#\#}"; }

# A label: text font size colour x y halign valign
label() {
    cat <<EOF
label {
    monitor =
    text = $1
    font_family = $2
    font_size = $3
    color = $4
    position = $5, $6
    halign = $7
    valign = $8
    shadow_passes = 0
    zindex = 2
}

EOF
}

# The password field: width radius placeholder fail font x y halign valign
field() {
    cat <<EOF
input-field {
    monitor =
    size = $1, 44
    rounding = $2
    outline_thickness = 2
    dots_size = 0.2
    dots_spacing = 0.35
    dots_center = true
    dots_rounding = $([[ $2 == 0 ]] && echo 0 || echo -1)
    outer_color = $(c "$acc" 0.85)
    inner_color = $(c "$base" 0.72)
    font_color = $(c "$ink")
    check_color = $(c "$acc2")
    fail_color = $(c "$err")
    capslock_color = $(c "$acc2")
    font_family = $5
    placeholder_text = <span foreground="$(pc "$dim")">$3</span>
    fail_text = <span foreground="$(pc "$err")">$4</span>
    hide_input = false
    fade_on_empty = false
    position = $6, $7
    halign = $8
    valign = $9
    zindex = 3
}

EOF
}

# Background: the wallpaper, blurred and dimmed, then a tint of the theme's base
backdrop() {   # blur brightness tint-alpha [tint colour]
    cat <<EOF
general {
    hide_cursor = true
}

background {
    monitor =
    path = $wall
    blur_passes = $1
    blur_size = 7
    brightness = $2
    contrast = 0.95
    vibrancy = 0.15
    zindex = -2
}

shape {
    monitor =
    size = 100%, 100%
    color = $(c "${4:-$base}" "$3")
    zindex = -1
}

EOF
}

# The profile picture, cut to the theme's shape with its frame drawn on:
#     avatar SIZE X Y HALIGN VALIGN
# Rendered once per theme, colours and picture into ~/.cache/quickshell/
# lock-avatar (the name changes with them, so hyprlock never shows a stale
# one). The picture is lib/usersettings.json's profileImageOverride, or
# profile.jpg. Nothing is drawn if there's no picture or ImageMagick.
avatar() {
    local src
    src=$(jq -r '.profileImageOverride // empty' "$HOME/.config/quickshell/lib/usersettings.json" 2>/dev/null)
    src=${src/#\~/$HOME}
    [[ -f $src ]] || src=$HOME/.config/quickshell/profile.jpg
    [[ -f $src ]] && command -v magick >/dev/null || return 0

    local cache=$HOME/.cache/quickshell/lock-avatar
    local key file
    key=$(printf '%s ' "$id" "$acc" "$acc2" "$ink" "$base" "$src" "$(stat -c %Y "$src")" v1 | md5sum | cut -c1-12)
    file=$cache/$id-$key.png
    if [[ ! -s $file ]]; then
        mkdir -p "$cache"
        rm -f "${cache:?}/$id"-*.png
        avatar_render "$src" "$file" || return 0
    fi
    cat <<EOF
image {
    monitor =
    path = $file
    size = $1
    rounding = 0
    border_size = 0
    position = $2, $3
    halign = $4
    valign = $5
    shadow_passes = 0
    zindex = 2
}

EOF
}

# Marks round the picture's centre, as one MVG string:
#     spokes R1 R2 STEP [OFFSET]   lines from radius R1 to R2 every STEP degrees
#     beads R DOT STEP [OFFSET]    dots of radius DOT on radius R
spokes() { awk -v a="$1" -v b="$2" -v s="$3" -v o="${4:-0}" 'BEGIN { for (d = o; d < 360 + o; d += s) {
    t = d * 3.14159265 / 180; printf "line %.1f,%.1f %.1f,%.1f ", 180 + a * sin(t), 180 - a * cos(t), 180 + b * sin(t), 180 - b * cos(t) } }'; }
beads() { awk -v r="$1" -v e="$2" -v s="$3" -v o="${4:-0}" 'BEGIN { for (d = o; d < 360 + o; d += s) {
    t = d * 3.14159265 / 180; x = 180 + r * sin(t); y = 180 - r * cos(t); printf "circle %.1f,%.1f %.1f,%.1f ", x, y, x + e, y } }'; }

# "#rrggbbaa" for ImageMagick from "#rrggbb" and an alpha 0..1
mc() { printf '#%s%02x' "${1:1:6}" "$(awk -v a="$2" 'BEGIN{printf "%d", a*255+0.5}')"; }

# The 360px picture: effect, shape mask, frame
avatar_render() {
    local src=$1 dst=$2 a=$acc a2=$acc2 k=$ink b=$base
    local fx=() mask frame=() y
    local sq="rectangle 10,10 350,350"
    case $id in
    hud)   # a cartridge label: two corners clipped
        mask="polygon 60,10 350,10 350,300 300,350 10,350 10,60"
        fx=(-modulate 100,115)
        frame=(-stroke "$a" -strokewidth 8 -draw "$mask"
               -stroke "$a2" -strokewidth 3 -draw "line 300,26 334,26" -draw "line 26,334 60,334") ;;
    terminal)   # a phosphor monitor: green-screen with scanlines
        mask=$sq
        fx=(-colorspace gray -contrast-stretch 1% +level-colors "#000000","$a")
        local lines=""
        for ((y = 12; y < 350; y += 4)); do lines+="line 10,$y 350,$y "; done
        frame=(-stroke "#00000070" -strokewidth 1.5 -draw "$lines"
               -stroke "$a" -strokewidth 4 -draw "$mask") ;;
    cosmos)   # a planet with its orbit and a moon
        mask="circle 180,180 180,30"
        frame=(-stroke "$a" -strokewidth 4 -draw "$mask"
               -stroke "$(mc "$a2" 0.8)" -strokewidth 2 -draw "circle 180,180 180,12"
               -stroke none -fill "$a2" -draw "circle 299,61 299,69") ;;
    zen)   # glass: a quiet circle
        mask="circle 180,180 180,15"
        fx=(-modulate 100,80)
        frame=(-stroke "$(mc "$k" 0.55)" -strokewidth 2 -draw "$mask") ;;
    xianxia)   # a cinnabar seal: thick outer square, thin inner
        mask="rectangle 36,36 324,324"
        fx=(-modulate 100,85)
        frame=(-stroke "#c23a2b" -strokewidth 16 -draw "rectangle 16,16 344,344"
               -stroke "#c23a2b" -strokewidth 3 -draw "$mask") ;;
    cyberpunk)   # an ID chip, duotone, its edge doubled out of register
        mask="polygon 60,14 300,14 346,60 346,300 300,346 60,346 14,300 14,60"
        fx=(-colorspace gray -contrast-stretch 1% +level-colors "#0a0014","$a")
        frame=(-stroke "$a2" -strokewidth 3 -draw "translate 6,-6 $mask"
               -stroke "$a" -strokewidth 4 -draw "$mask") ;;
    wabisabi)   # a pebble, in sepia, the brush going round twice
        mask="path 'M 160,22 C 262,0 354,60 348,170 C 342,282 296,354 184,344 C 80,336 8,300 14,196 C 20,100 64,42 160,22 Z'"
        fx=(-sepia-tone 75% -modulate 100,70)
        frame=(-stroke "$(mc "$k" 0.75)" -strokewidth 4 -draw "$mask"
               -stroke "$(mc "$k" 0.35)" -strokewidth 2 -draw "translate 4,3 $mask") ;;
    artdeco)   # stepped corners in gold, with an inner rule
        mask="polygon 10,58 34,58 34,34 58,34 58,10 302,10 302,34 326,34 326,58 350,58 350,302 326,302 326,326 302,326 302,350 58,350 58,326 34,326 34,302 10,302"
        fx=(-colorspace gray -contrast-stretch 1% +level-colors "#1a1208","$a")
        frame=(-stroke "$a" -strokewidth 5 -draw "$mask"
               -stroke "$(mc "$a" 0.75)" -strokewidth 1.5 -draw "rectangle 48,48 312,312") ;;
    gothic)   # a lancet window of stained glass in a double moulding, with its lead
        mask="path 'M 10,350 L 10,176 A 230,230 0 0 1 180,10 A 230,230 0 0 1 350,176 L 350,350 Z'"
        fx=(-modulate 100,150 -posterize 7)
        frame=(-stroke "$(mc "$a" 0.7)" -strokewidth 3 -draw "line 180,96 180,350" -draw "line 10,236 350,236"
               -stroke "$a" -strokewidth 8 -draw "$mask"
               -stroke "$a2" -strokewidth 2 -draw "path 'M 28,350 L 28,182 A 210,210 0 0 1 180,32 A 210,210 0 0 1 332,182 L 332,350'") ;;
    newspaper)   # a halftone photo between rules
        mask="rectangle 22,22 338,338"
        fx=(-colorspace gray -contrast-stretch 2% -ordered-dither h6x6a +level-colors "$k","$b")
        frame=(-stroke "$k" -strokewidth 3 -draw "$mask"
               -stroke "$k" -strokewidth 1 -draw "rectangle 9,9 351,351") ;;
    wasteland)   # a riveted steel plate, sun-bleached
        mask="roundrectangle 10,10 350,350 10,10"
        fx=(-modulate 95,30 -fill "#6b5a3a" -colorize 30% -contrast-stretch 1%)
        frame=(-stroke "$a2" -strokewidth 8 -draw "$mask"
               -stroke "$b" -strokewidth 2 -fill "$(mc "$k" 0.85)"
               -draw "circle 34,34 34,42" -draw "circle 326,34 326,42"
               -draw "circle 34,326 34,334" -draw "circle 326,326 326,334") ;;
    observatory)   # a brass astrolabe: a graduated ring round the plate
        mask="circle 180,180 180,40"
        fx=(-sepia-tone 65% -modulate 100,90)
        frame=(-stroke "$a" -strokewidth 3 -draw "$mask" -draw "circle 180,180 180,10"
               -stroke "$a" -strokewidth 1.5 -draw "$(spokes 160 170 6)" -strokewidth 3 -draw "$(spokes 146 170 30)") ;;
    abyss)   # a porthole: thick ring, eight bolts
        mask="circle 180,180 180,46"
        fx=(-modulate 85,60 -fill "#0a5060" -colorize 30%)
        frame=(-stroke "$(mc "$a" 0.85)" -strokewidth 30 -draw "circle 180,180 180,24"
               -stroke "$(mc "$k" 0.8)" -strokewidth 2 -draw "$mask" -draw "circle 180,180 180,9"
               -stroke "$b" -strokewidth 2 -fill "$a2" -draw "$(beads 156 8 45 22.5)") ;;
    devaloka)   # a marigold garland
        mask="circle 180,180 180,30"
        fx=(-modulate 100,110)
        frame=(-stroke "$a" -strokewidth 4 -draw "$mask"
               -stroke none -fill "$a" -draw "$(beads 166 7 12)") ;;
    siege)   # a heraldic shield
        mask="path 'M 10,10 H 350 V 170 Q 350,300 180,350 Q 10,300 10,170 Z'"
        fx=(-modulate 100,85)
        frame=(-stroke "$a" -strokewidth 8 -draw "$mask"
               -stroke "$a2" -strokewidth 2 -draw "path 'M 26,26 H 334 V 170 Q 334,288 180,332 Q 26,288 26,170 Z'") ;;
    sekiro)   # a tapered emblem, ink-wash grey with a red edge
        mask="polygon 60,10 300,10 350,180 300,350 60,350 10,180"
        fx=(-colorspace gray -contrast-stretch 1%)
        frame=(-stroke "$a" -strokewidth 5 -draw "$mask") ;;
    *)
        mask="circle 180,180 180,20"
        frame=(-stroke "$a" -strokewidth 4 -draw "$mask") ;;
    esac
    magick \( "$src" -auto-orient -resize 360x360^ -gravity center -extent 360x360 +gravity "${fx[@]}" \) \
        \( -size 360x360 xc:black -fill white -stroke none -draw "$mask" \) \
        -alpha off -compose CopyOpacity -composite -compose over \
        -fill none "${frame[@]}" "PNG32:$dst"
}

clock() { echo "cmd[update:1000] date +%H:%M"; }
date_line() { echo "cmd[update:60000] date +'$1'"; }

{
echo "# Generated by quickshell/utils/hyprlock-theme.sh for the $name desktop theme."
echo "# Do not edit: it's rewritten on every theme and wallpaper change."
echo

case $id in
hud)   # Arcade: PRESS ANY KEY, the stage clock, your player card
    backdrop 2 0.55 0.45
    avatar 100 60 95 left bottom
    label "<span letter_spacing='4000'>STAGE $(date +%-j)</span>" "Orbitron" 14 "$(c "$acc")" 60 -60 left top
    label "$(clock)" "Orbitron" 120 "$(c "$ink")" 0 140 center center
    label "cmd[update:1000] $info blink" "Orbitron" 18 "$(c "$acc")" 0 20 center center
    label "cmd[update:60000] echo \"PLAYER  $user  ·  LV 1  ·  ROOKIE\"" "$mono" 13 "$(c "$dim")" 60 60 left bottom
    label "cmd[update:30000] echo \"HP $($info battery)%\"" "$mono" 13 "$(c "$acc2")" -60 60 right bottom
    field 320 0 "INSERT PASSCODE" "ACCESS DENIED" "Orbitron" 0 -120 center center ;;

terminal)   # Mainframe: the phosphor console's lockdown log and login prompt
    backdrop 3 0.35 0.8
    avatar 120 560 -135 left center
    label "[  <span foreground='$(pc "$acc")'>OK</span>  ] Stopped target Graphical Session." "Iosevka Nerd Font" 15 "$(c "$dim")" 80 -80 left top
    label "[  <span foreground='$(pc "$acc")'>OK</span>  ] Locked session for user $user." "Iosevka Nerd Font" 15 "$(c "$dim")" 80 -108 left top
    label "[  <span foreground='$(pc "$acc")'>OK</span>  ] Reached target Session Lock." "Iosevka Nerd Font" 15 "$(c "$dim")" 80 -136 left top
    label "cmd[update:1000] echo \"$user@$host:~\$ date\"; date '+%a %d %b %Y %H:%M:%S'" "Iosevka Nerd Font" 15 "$(c "$ink")" 80 -186 left top
    label "$(clock)" "Iosevka Nerd Font" 110 "$(c "$acc")" 80 40 left center
    label "$host login: $user" "Iosevka Nerd Font" 18 "$(c "$ink")" 80 -110 left center
    label "Password:" "Iosevka Nerd Font" 18 "$(c "$ink")" 80 -160 left center
    field 300 0 "" "Login incorrect" "Iosevka Nerd Font" 210 -160 left center ;;

cosmos)   # Astral: deep space, light-years from home
    backdrop 4 0.45 0.55
    avatar 150 0 350 center center
    label "$(clock)" "$ui" 128 "$(c "$ink")" 0 160 center center
    label "$(date_line '%A · %-d %B')" "$ui" 20 "$(c "$acc")" 0 40 center center
    label "✦  light-years from home  ✦" "$ui" 14 "$(c "$dim")" 0 -10 center center
    field 300 -1 "chart a course" "lost in the void" "$ui" 0 -110 center center ;;

zen)   # Still: minimal glass
    backdrop 5 0.6 0.3
    avatar 140 0 340 center center
    label "$(clock)" "$ui" 140 "$(c "$ink")" 0 140 center center
    label "$(date_line '%A, %-d %B')" "$ui" 18 "$(c "$dim")" 0 20 center center
    field 280 -1 "breathe" "again, slowly" "$ui" 0 -90 center center ;;

xianxia)   # Cave Abode: the 封 seal, the double-hour, closed-door cultivation
    backdrop 3 0.45 0.55
    avatar 130 120 300 left center
    label "封" "Noto Serif CJK JP" 180 "$(c "#c23a2b" 0.9)" -140 0 right center
    label "$(clock)" "Noto Serif" 110 "$(c "$ink")" 120 120 left center
    label "cmd[update:60000] $info shichen" "Noto Serif CJK JP" 20 "$(c "$acc")" 120 10 left center
    label "閉關修煉 · closed-door cultivation" "Noto Serif CJK JP" 15 "$(c "$dim")" 120 -30 left center
    field 300 3 "speak the formation" "qi deviation" "Noto Serif" 120 -120 left center ;;

cyberpunk)   # Black ICE: attack barriers in the neon rain
    backdrop 2 0.4 0.5
    avatar 150 0 350 center center
    label "攻性防壁" "Noto Serif CJK JP" 26 "$(c "$acc2")" 60 -60 left top
    label "<span letter_spacing='3000'>BLACK ICE ACTIVE</span>" "$mono" 13 "$(c "$acc")" 60 -104 left top
    label "$(clock)" "Fragile Bombers" 130 "$(c "$acc")" 0 150 center center
    label "$(date_line '%a %d.%m.%Y')" "$mono" 16 "$(c "$acc2")" 0 30 center center
    label "TRACE ░░░░░░░░░░ 0%" "$mono" 13 "$(c "$dim")" -60 60 right bottom
    field 340 0 "JACK IN" "TRACE DETECTED" "$mono" 0 -110 center center ;;

wabisabi)   # Ensō: washi, sumi and the old calendar
    backdrop 3 0.55 0.5
    avatar 120 0 425 center center
    label "◯" "Noto Serif CJK JP" 330 "$(c "$ink" 0.18)" 0 90 center center
    label "$(clock)" "Noto Serif CJK JP" 96 "$(c "$ink")" 0 110 center center
    label "cmd[update:60000] $info wafu" "Noto Serif CJK JP" 18 "$(c "$acc")" 0 -20 center center
    label "侘寂" "Noto Serif CJK JP" 14 "$(c "$dim")" -60 60 right bottom
    field 280 14 "一期一会" "ひび" "Noto Serif CJK JP" 0 -230 center center ;;

artdeco)   # Express Elevator: black lacquer and gold
    backdrop 3 0.4 0.7
    avatar 140 0 330 center center
    label "<span letter_spacing='6000'>EXPRESS ELEVATOR</span>" "Josefin Sans" 16 "$(c "$acc")" 0 -70 center top
    label "$(clock)" "Poiret One" 130 "$(c "$acc")" 0 140 center center
    label "<span letter_spacing='3000'>FLOOR 1   ◆ ◇ ◇ ◇ ◇</span>" "Josefin Sans" 15 "$(c "$ink")" 0 20 center center
    label "$(date_line '%A %-d %B %Y')" "Josefin Sans" 14 "$(c "$dim")" 0 -20 center center
    field 320 0 "GOING UP" "WRONG FLOOR" "Josefin Sans" 0 -120 center center ;;

gothic)   # Rose Window: the cathedral at the canonical hour
    backdrop 3 0.4 0.65
    avatar 150 0 345 center center
    label "cmd[update:60000] $info hour" "Grenze Gotisch" 90 "$(c "$acc")" 0 180 center center
    label "$(clock)" "Alegreya" 60 "$(c "$ink")" 0 60 center center
    label "✠  the doors are shut for the night  ✠" "Alegreya" 16 "$(c "$dim")" 0 0 center center
    field 300 3 "speak, and enter" "a pane is cracked" "Alegreya" 0 -100 center center ;;

newspaper)   # Extra! Extra!: the front page
    backdrop 2 0.6 0.9 "#ece6d6"
    paper="#1c1b19"; ink=$paper; dim="#4a4640"; base="#ece6d6"
    avatar 180 -770 70 center center
    label "<i>Pictured: $user, at the desk.</i>" "Old Standard TT" 11 "$(c "$dim")" -770 -60 center center
    label "The Daily ${user^}" "UnifrakturMaguntia" 76 "$(c "$paper")" 0 -60 center top
    label "cmd[update:60000] echo \"VOL. \$(date +%Y)  ·  No. \$(date +%-j)  ·  \$(date '+%A, %B %-d, %Y' | tr a-z A-Z)  ·  \$($info edition | tr a-z A-Z)\"" "Old Standard TT" 12 "$(c "$paper")" 0 -170 center top
    label "LOCAL USER STEPS AWAY FROM DESK" "Old Standard TT" 46 "$(c "$paper")" 0 120 center center
    label "<i>Machine waits patiently; sources say a password will be required</i>" "Old Standard TT" 18 "$(c "$dim")" 0 50 center center
    label "$(clock)" "Old Standard TT" 28 "$(c "$paper")" 0 0 center center
    field 320 0 "Sign in to read on" "CORRECTION" "Old Standard TT" 0 -100 center center ;;

wasteland)   # Blast Door: the bunker after the fall
    backdrop 2 0.45 0.6
    avatar 140 0 350 center center
    label "<span letter_spacing='4000'>▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚</span>" "$mono" 18 "$(c "$acc2" 0.8)" 0 -60 center top
    label "BLAST DOOR SEALED" "Big Shoulders Stencil" 40 "$(c "$acc2")" 0 230 center center
    label "$(clock)" "Big Shoulders Stencil" 140 "$(c "$ink")" 0 100 center center
    label "cmd[update:60000] $info survival" "Barlow Semi Condensed" 18 "$(c "$dim")" 0 -10 center center
    field 320 1 "ENTER ACCESS CODE" "RADIATION RISING" "Barlow Semi Condensed" 0 -100 center center ;;

observatory)   # Astrolabe: a night at the old observatory
    backdrop 3 0.4 0.6
    avatar 150 0 355 center center
    label "The Observatory" "IM FELL English SC" 34 "$(c "$acc")" 0 230 center center
    label "$(clock)" "EB Garamond" 120 "$(c "$ink")" 0 110 center center
    label "cmd[update:1800000] $HOME/.config/hypr/scripts/lock-moon.sh" "EB Garamond" 18 "$(c "$dim")" 0 0 center center
    label "<i>clear skies, $user</i>" "EB Garamond" 16 "$(c "$acc2")" 0 -40 center center
    field 300 8 "sight the stars" "clouded over" "EB Garamond" 0 -120 center center ;;

abyss)   # Bathysphere: as deep as the hour
    backdrop 3 0.35 0.65
    avatar 140 0 300 center center
    label "<span letter_spacing='4000'>BATHYSPHERE SEALED</span>" "B612" 15 "$(c "$acc2")" 0 -70 center top
    label "$(clock)" "B612" 120 "$(c "$acc")" 0 120 center center
    label "cmd[update:60000] $info depth" "B612 Mono" 16 "$(c "$ink")" 0 10 center center
    label "SONAR  ·  ))) " "B612 Mono" 13 "$(c "$dim")" 60 60 left bottom
    field 320 14 "PING" "LEAK DETECTED" "B612" 0 -100 center center ;;

devaloka)   # Samudra Manthan: the realm of the devas in marigold
    backdrop 3 0.45 0.55
    avatar 150 0 365 center center
    label "॥ ॐ ॥" "Tiro Devanagari Sanskrit" 34 "$(c "$acc")" 0 240 center center
    label "$(clock)" "Eczar" 120 "$(c "$ink")" 0 120 center center
    label "cmd[update:60000] $info prahar" "Tiro Devanagari Sanskrit" 22 "$(c "$acc")" 0 10 center center
    label "$(date_line '%A, %-d %B')" "Eczar" 15 "$(c "$dim")" 0 -30 center center
    field 300 6 "churn the ocean" "the rope slips" "Eczar" 0 -120 center center ;;

siege)   # Portcullis: holding the gate
    backdrop 3 0.4 0.65
    avatar 150 0 370 center center
    label "THE GATE IS SHUT" "Germania One" 44 "$(c "$acc")" 0 230 center center
    label "$(clock)" "Texturina" 110 "$(c "$ink")" 0 110 center center
    label "cmd[update:60000] $info watch" "Texturina" 18 "$(c "$dim")" 0 0 center center
    field 320 0 "speak the watchword" "a false watchword" "Texturina" 0 -110 center center ;;

sekiro)   # Deathblow: Ashina by night
    backdrop 3 0.35 0.6
    avatar 100 60 140 left bottom
    label "忍殺" "Zen Old Mincho" 120 "$(c "$acc")" -120 60 right center
    label "$(clock)" "Zen Old Mincho" 110 "$(c "$ink")" 120 100 left center
    label "Sculptor's Idol  ·  Ashina Reservoir" "Zen Old Mincho" 16 "$(c "$dim")" 120 0 left center
    label "cmd[update:30000] $info vitality" "$mono" 13 "$(c "$acc")" 60 90 left bottom
    label "● ●   RESURRECTION" "$mono" 13 "$(c "$acc2")" 60 60 left bottom
    field 320 0 "rest" "death" "Zen Old Mincho" 120 -100 left center ;;

*)   # A theme without a preset: its type and colours on a plain layout
    backdrop 3 0.5 0.5
    avatar 140 0 320 center center
    label "$(clock)" "$display" 120 "$(c "$ink")" 0 120 center center
    label "$(date_line '%A, %-d %B')" "$ui" 18 "$(c "$acc")" 0 10 center center
    field 300 "$r" "password" "try again" "$ui" 0 -100 center center ;;
esac
} > "$out.tmp" && mv -f "$out.tmp" "$out"

ln -sfn "$out" "$link"
