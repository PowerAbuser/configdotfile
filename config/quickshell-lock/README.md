# quickshell-lock

The lock screen, vendored from [dhrruvsharma/shell](https://github.com/dhrruvsharma/shell)
(GPL-3.0, see `LICENSE`) at the commit in `.upstream-rev`. It runs as its own
Quickshell instance, started by `~/.config/quickshell/utils/lock.sh`:

    qs -p ~/.config/quickshell-lock/Lock.qml

Try a theme without locking (PAM is never touched, any passcode unlocks):

    QS_LOCK_THEME=arcade qs -p ~/.config/quickshell-lock/LockPreview.qml

Only the lock and what it needs were copied, with all 16 upstream themes
(ids in `services/LockScreen.qml`). The lock follows the desktop theme
(`desktoptheme.json`'s `matchLock`); otherwise `../quickshell/lockscreen.json`
picks (`active`, `shuffle`).

The one change from upstream: `LockContext.suspend()` turns the screens off,
as suspend is masked here.

Upstream's paths that differ from this config are linked by `lock.sh` before
each lock: `~/.cache/current_wallpaper` and `~/.cache/current_avatar`.
