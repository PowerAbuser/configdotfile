#!/usr/bin/env bash
# Lock the screen with hyprlock, and once it's unlocked, credit the unlock
# to the lock-screen XP (utils/lock-xp.py, desktoptheme/LockStats.qml):
#
#     lock.sh        (a no-op if hyprlock is already up)
#
# Everything that locks goes through here: hypridle's lock_cmd, the power
# menu's Lock and Sleep, and the hub's Lock button.
pidof hyprlock >/dev/null && exit 0
locked=$(date +%s%3N)
hyprlock "$@" || exit $?
exec "$(dirname "$(readlink -f "$0")")/lock-xp.py" "$locked" "$(date +%s%3N)"
