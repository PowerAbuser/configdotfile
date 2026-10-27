pragma Singleton
import QtQuick
import Quickshell
import "../desktoptheme" as DT

// The accent for panels that don't take a ThemeEngine: the desktop theme's
// toned accent while one is on, the wallpaper's primary otherwise, and
// whichever of dark or light text reads on it (as ThemeEngine.textOnAccent).
Singleton {
    readonly property bool themed: DT.DesktopTheme.enabled
    readonly property color main: themed ? DT.DesktopTheme.accent : Colors.primary
    readonly property color ink: !themed ? Colors.fgPrimary
        : (main.hslLightness > 0.55 ? Colors.surfaceContainerLowest : Colors.fgSurface)
    // The theme's hairline when it draws one
    readonly property color line: themed && DT.DesktopTheme.look.border
        ? DT.DesktopTheme.borderColor(DT.DesktopTheme.look) : Colors.outlineVariant
}
