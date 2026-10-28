#!/usr/bin/env bash
# Lock the screen with the Quickshell lock (~/.config/quickshell-lock, vendored
# from dhrruvsharma/shell), falling back to hyprlock if it can't start:
#
#     lock.sh        (a no-op if a lock is already up)
#
# Everything that locks goes through here: hypridle's lock_cmd, the power
# menu's Lock and Sleep, and the hub's Lock button.
#
# XP is upstream's: the Quickshell lock credits each unlock itself
# (quickshell-lock/services/LockStats.qml). A hyprlock unlock earns none.
lockqml=$HOME/.config/quickshell-lock/Lock.qml

pgrep -f "quickshell-lock/Lock.qml" >/dev/null && exit 0
pidof hyprlock >/dev/null && exit 0

# The lock themes read the wallpaper and avatar from upstream's paths
ln -sfn "$HOME/.config/hypr/.cache/current_wallpaper.png" "$HOME/.cache/current_wallpaper"
avatar=$(jq -r '.profileImageOverride // empty' "$HOME/.config/quickshell/lib/usersettings.json" 2>/dev/null)
avatar=${avatar/#\~/$HOME}
[[ -n $avatar && -f $avatar ]] || avatar=$HOME/.config/quickshell/profile.jpg
ln -sfn "$avatar" "$HOME/.cache/current_avatar"

if [[ -f $lockqml ]]; then
    # Exits 0 on unlock (or if the compositor refused the lock because
    # another locker holds it); anything else means it failed or crashed.
    qs -p "$lockqml"
    status=$?
    [[ $status -eq 0 ]] && exit 0
    echo "lock.sh: quickshell lock exited with $status, falling back to hyprlock" >&2
fi

# Fallback. With misc:allow_session_lock_restore on, hyprlock can also take
# over a session lock left behind by a crashed Quickshell lock.
exec hyprlock "$@"
