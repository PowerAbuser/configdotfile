#!/bin/bash

scriDir="$HOME/.config/hypr/scripts"
cache_dir="$HOME/.config/hypr/.cache"
wallCache="$cache_dir/.wallpaper"
wallDIR="$HOME/.config/hypr/Wallpapers"

[[ ! -f "$wallCache" ]] && touch "$wallCache"

# Transition config
FPS=60
TYPE="random"
DURATION=1
BEZIER=".43,1.19,1,.4"
SWWW_PARAMS="--transition-fps $FPS --transition-type $TYPE --transition-duration $DURATION"

# Retrieve image files
PICS=($(ls "${wallDIR}" | grep -E ".jpg$|.jpeg$|.png$|.gif$"))
RANDOM_PIC="${PICS[$((RANDOM % ${#PICS[@]}))]}"
RANDOM_PIC_NAME="${#PICS[@]}. random"

# Rofi command ( style )
rofi_command1="rofi -show -dmenu -config ~/.config/rofi/themes/rofi-wall.rasi"
rofi_command2="rofi -show -dmenu -config ~/.config/rofi/themes/rofi-wall-2.rasi"

menu() {
  for i in "${!PICS[@]}"; do
    # Displaying .gif to indicate animated images
    if [[ -z $(echo "${PICS[$i]}" | grep .gif$) ]]; then
      printf "$(echo "${PICS[$i]}" | cut -d. -f1)\x00icon\x1f${wallDIR}/${PICS[$i]}\n"
    else
      printf "${PICS[$i]}\n"
    fi
  done

  printf "$RANDOM_PIC_NAME\n"
}

case $1 in
thm1)
  choice=$(menu | ${rofi_command1})
  ;;
thm2)
  choice=$(menu | ${rofi_command2})
  ;;
esac

awww-daemon &

# No choice case
if [[ -z $choice ]]; then
  exit 0
fi

# Random choice case
if [ "$choice" = "$RANDOM_PIC_NAME" ]; then
  awww img "${wallDIR}/${RANDOM_PIC}" $SWWW_PARAMS
  "$scriDir/set-current-wallpaper.sh" "${wallDIR}/${RANDOM_PIC}"
  exit 0
fi

# Find the index of the selected file
pic_index=-1
for i in "${!PICS[@]}"; do
  filename=$(basename "${PICS[$i]}")
  if [[ "$filename" == "$choice"* ]]; then
    pic_index=$i
    break
  fi
done

if [[ $pic_index -ne -1 ]]; then
  notify-send -i "${wallDIR}/${PICS[$pic_index]}" "Changing wallpaper" -t 1500
  awww img "${wallDIR}/${PICS[$pic_index]}" $SWWW_PARAMS
  sleep 0.5
  "$scriDir/set-current-wallpaper.sh" "${wallDIR}/${PICS[$pic_index]}"

else
  echo "Image not found."
  exit 1
fi

