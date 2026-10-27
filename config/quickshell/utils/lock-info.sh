#!/usr/bin/env bash
# Live text for the themed hyprlock screens (utils/hyprlock-theme.sh):
#     lock-info.sh WHAT
# Each prints one line of Pango markup or text, after the clocks and
# calendars of dhrruvsharma/shell's lock themes.
h=$((10#$(date +%H))); m=$((10#$(date +%M)))
case $1 in
    battery)   cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n1 || echo "--" ;;
    doy)       echo $((10#$(date +%j))) ;;
    # HUD: PRESS ANY KEY, blinking on the second
    blink)     (( $(date +%s) % 2 )) && echo "PRESS ANY KEY" || echo " " ;;
    # Cave Abode: the double-hour (shichen), 子 starting at 23:00
    shichen)
        names=(子 丑 寅 卯 辰 巳 午 未 申 酉 戌 亥)
        en=(Rat Ox Tiger Rabbit Dragon Snake Horse Goat Monkey Rooster Dog Pig)
        i=$(( ((h + 1) % 24) / 2 ))
        echo "${names[$i]}時 · hour of the ${en[$i]}" ;;
    # Cathedral: the canonical hour
    hour)
        if   (( h < 3 ));  then echo "Matins"
        elif (( h < 6 ));  then echo "Lauds"
        elif (( h < 9 ));  then echo "Prime"
        elif (( h < 12 )); then echo "Terce"
        elif (( h < 15 )); then echo "Sext"
        elif (( h < 18 )); then echo "None"
        elif (( h < 21 )); then echo "Vespers"
        else echo "Compline"; fi ;;
    # Broadsheet: the edition on the street
    edition)
        if   (( h < 5 ));  then echo "Late City Final"
        elif (( h < 11 )); then echo "Morning Edition"
        elif (( h < 16 )); then echo "Afternoon Edition"
        elif (( h < 20 )); then echo "Evening Edition"
        else echo "Night Final"; fi ;;
    # Siege: the watch, and the day of the siege (the day of the year)
    watch)
        w=("Midnight watch" "Midnight watch" "Morning watch" "Morning watch" "Morning watch" "Dawn watch"
           "Dawn watch" "Forenoon watch" "Forenoon watch" "Forenoon watch" "Forenoon watch" "Noon watch"
           "Noon watch" "Afternoon watch" "Afternoon watch" "Afternoon watch" "Dog watch" "Dog watch"
           "Evening watch" "Evening watch" "First watch" "First watch" "First watch" "Midnight watch")
        echo "${w[$h]} · day $((10#$(date +%j))) of the siege" ;;
    # Abyss: the deeper the later, sunlit at noon, the trenches at midnight
    depth)
        mins=$(( h * 60 + m )); d=$(( mins > 720 ? 1440 - mins : mins ))   # 0 at midnight .. 720 at noon
        metres=$(( (720 - d) * 11000 / 720 ))
        if   (( metres < 200 ));  then z="Sunlight zone"
        elif (( metres < 1000 )); then z="Twilight zone"
        elif (( metres < 4000 )); then z="Midnight zone"
        elif (( metres < 6000 )); then z="Abyssal zone"
        else z="Hadal zone"; fi
        echo "DEPTH $(printf "%'d" "$metres") m · ${z^^}" ;;
    # Devaloka: the prahar (eight watches of three hours from 6:00)
    prahar)
        p=(प्रथम द्वितीय तृतीय चतुर्थ पञ्चम षष्ठ सप्तम अष्टम)
        i=$(( ((h + 18) % 24) / 3 ))
        echo "${p[$i]} प्रहर" ;;
    # Wasteland: days survived (of the year) without incident
    survival)  echo "DAY $((10#$(date +%j))) · $(( 10#$(date +%j) % 37 )) DAYS WITHOUT INCIDENT" ;;
    # Sekiro: vitality from the battery as a gauge
    vitality)
        b=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n1); b=${b:-100}
        n=$(( b / 10 )); bar=""
        for i in 1 2 3 4 5 6 7 8 9 10; do (( i <= n )) && bar+="━" || bar+="─"; done
        echo "VITALITY ${bar} ${b}%" ;;
    # Wabi-sabi: the month by its old name, and the day
    wafu)
        names=(睦月 如月 弥生 卯月 皐月 水無月 文月 葉月 長月 神無月 霜月 師走)
        echo "${names[$((10#$(date +%m) - 1))]} · $(date +%-d)日" ;;
    *) echo "" ;;
esac
