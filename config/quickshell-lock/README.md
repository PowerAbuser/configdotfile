# quickshell-lock

The lock screen, vendored from [dhrruvsharma/shell](https://github.com/dhrruvsharma/shell)
(GPL-3.0, see `LICENSE`) at the commit in `.upstream-rev`. It runs as its own
Quickshell instance, started by `~/.config/quickshell/utils/lock.sh`:

    qs -p ~/.config/quickshell-lock/Lock.qml

Try a theme without locking (PAM is never touched, any passcode unlocks):

    QS_LOCK_THEME=arcade qs -p ~/.config/quickshell-lock/LockPreview.qml

Only the files these themes need were copied: `arcade` (HUD), `terminal`
(Mainframe) and `zen` (Still). The lock follows the desktop theme
(`desktoptheme.json`'s `matchLock`); a desktop theme whose lock isn't here
gets `arcade`. Otherwise `../quickshell/lockscreen.json` picks.

Changes from upstream:

- `services/LockScreen.qml` and `modules/lock/ThemeHost.qml` list only the
  three themes above.
- `LockContext.suspend()` turns the screens off (suspend is masked here).

Upstream's paths that differ from this config are linked by `lock.sh` before
each lock: `~/.cache/current_wallpaper` and `~/.cache/current_avatar`.
