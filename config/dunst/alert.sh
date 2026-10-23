#!/bin/bash
# Usage: ./alert.sh "appname" "summary" "body" "icon" "urgency"
# Only critical notifications make a sound (swaync never played any).

URGENCY="$5"

case "$URGENCY" in
    "CRITICAL")
        paplay ~/.config/hypr/sounds/error.wav
        ;;
esac
