#!/usr/bin/env bash
# Copy a wallpaper to the login screen: sddm-wallpaper.sh FILE
# Writes a 1440p JPEG over the SDDM theme's qs-wallpaper.jpg. That file is
# created once, owned by you, by `sudo ~/repos/configdotfile/sddm/install.sh`,
# so no root is needed here. Videos give their first frame, GIFs and WebPs
# their first image. Run by set-current-wallpaper.sh when the picker's
# "login screen" switch is on.
img=$1
target=/usr/share/sddm/themes/sddm-astronaut-theme/Backgrounds/qs-wallpaper.jpg
[[ -f $img ]] || { echo "sddm-wallpaper: no such file: $img" >&2; exit 1; }
[[ -w $target ]] || { echo "sddm-wallpaper: $target isn't writable; run sudo ~/repos/configdotfile/sddm/install.sh once" >&2; exit 1; }

tmp=$(mktemp --suffix=.jpg) || exit 1
trap 'rm -f "$tmp"' EXIT
case ${img,,} in
    *.mp4|*.webm|*.mkv|*.mov|*.m4v)
        ffmpeg -loglevel error -y -i "$img" -frames:v 1 -vf "scale='min(2560,iw)':-2" -q:v 3 "$tmp" ;;
    *)
        magick "$img[0]" -auto-orient -resize '2560x1440>' -quality 90 "$tmp" ;;
esac || { echo "sddm-wallpaper: couldn't convert $img" >&2; exit 1; }
# Overwrite in place: the file keeps its owner and the theme's path
cat "$tmp" > "$target"
