#!/usr/bin/env bash
# Swatches for Settings > Colour: what each matugen scheme kind makes of the
# current wallpaper in the current mode, without applying anything.
# Prints one JSON object {"scheme-vibrant": ["#prim","#sec","#ter","#surf"], ...}
# Cached per wallpaper, mtime and mode in ~/.cache/quickshell/swatches/.
MATUGEN=$(command -v matugen || echo "$HOME/.cargo/bin/matugen")
img=$(readlink -f "$HOME/.config/hypr/.cache/current_wallpaper.png")
[[ -f $img && -x $MATUGEN ]] || { echo '{}'; exit 0; }
mode=$(cat "$HOME/.cache/quickshell/theme_mode" 2>/dev/null | tr -d '[:space:]')
[[ $mode == light ]] || mode=dark

cache=$HOME/.cache/quickshell/swatches
key=$(printf '%s %s %s' "$img" "$(stat -c %Y "$img")" "$mode" | md5sum | cut -c1-16)
mkdir -p "$cache"
[[ -s $cache/$key.json ]] && { cat "$cache/$key.json"; exit 0; }

out="{"
first=1
for t in tonal-spot content expressive fidelity fruit-salad monochrome neutral rainbow vibrant; do
    sw=$(nice -n 19 "$MATUGEN" image "$img" --dry-run -j hex -m "$mode" -t "scheme-$t" \
            --source-color-index 0 2>/dev/null |
         jq -c '[.colors.primary.default.color, .colors.secondary.default.color,
                 .colors.tertiary.default.color, .colors.surface_container.default.color]' 2>/dev/null)
    [[ -n $sw ]] || continue
    (( first )) || out+=","
    out+="\"scheme-$t\":$sw"; first=0
done
out+="}"
echo "$out" | tee "$cache/$key.json"
