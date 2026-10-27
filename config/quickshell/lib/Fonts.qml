pragma Singleton
import QtQuick
import Quickshell
import "../desktoptheme" as DT

// The shell's text face: Manrope, or the desktop theme's panel type while
// one is on (DesktopTheme.font: its uiFont when the bar face is too
// decorative to read in panels). For code that used theme.js's static
// textFont; ThemeEngine.textFont reads this too.
Singleton {
    readonly property string text: DT.DesktopTheme.enabled && DT.DesktopTheme.font ? DT.DesktopTheme.font : "Manrope"
}
