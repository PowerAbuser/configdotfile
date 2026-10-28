#!/usr/bin/env bash
# Dress the SDDM login screen in a preset: sddm-preset.sh PRESET
# Merges sddm/presets/PRESET.conf over sddm-astronaut-theme's stock config
# into Themes/qs-active.conf, which the theme reads. That file is created
# once, owned by you, by `sudo ~/repos/configdotfile/sddm/install.sh`, so no
# root is needed here. Its first line records the preset, for Settings.
# The background is always Backgrounds/qs-wallpaper.jpg (sddm-wallpaper.sh).
theme=/usr/share/sddm/themes/sddm-astronaut-theme
target=$theme/Themes/qs-active.conf
preset=$1
src=$(dirname "$0")/../sddm/presets/$preset.conf
[[ -f $src ]] || { echo "sddm-preset: no preset: $preset" >&2; exit 1; }
[[ -w $target ]] || { echo "sddm-preset: $target isn't writable; run sudo ~/repos/configdotfile/sddm/install.sh once" >&2; exit 1; }

# Preset keys replace the stock ones; keys the stock config lacks are added.
overrides=$(grep -E '^[A-Za-z]+=' "$src")
overrides+=$'\n''Background="Backgrounds/qs-wallpaper.jpg"'$'\n''BackgroundPlaceholder=""'
merged=$(awk -v ov="$overrides" '
    BEGIN { n = split(ov, l, "\n"); for (i = 1; i <= n; i++) { k = l[i]; sub(/=.*/, "", k); v[k] = l[i]; order[i] = k } }
    { k = $0; sub(/=.*/, "", k) }
    (k in v) && !(k in done) { print v[k]; done[k] = 1; next }
    { print }
    END { for (i = 1; i <= n; i++) if (!(order[i] in done)) print v[order[i]] }
' "$theme/Themes/astronaut.conf") || exit 1
# Overwrite in place: the file keeps its owner
printf '# qs-preset=%s\n%s\n' "$preset" "$merged" > "$target"
