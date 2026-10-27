import QtQuick
import Quickshell
import Quickshell.Wayland
import "." as Services
import "../lib" as Lib

// The desktop theme's layer (ThemeLayer, ported from dhrruvsharma/shell) on
// one screen: a click-through surface on the Bottom layer, so it sits over
// the wallpaper (awww draws on Background) and under every window. Hidden
// while no theme is on. Also marks the shell as the one that manages the
// theme's Hyprland side (DesktopTheme.manage).
PanelWindow {
    id: win

    visible: Services.DesktopTheme.enabled
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.namespace: "desktop-theme"
    // Nothing on it takes input
    mask: Region {}

    Component.onCompleted: Services.DesktopTheme.manage = true

    // Broadsheet and Abyss rework the wallpaper itself, so they need it as a
    // texture: the same picture awww shows, reloaded when the scheme changes
    // (a new wallpaper regenerates it)
    property int wallRev: 0
    Connections {
        target: Lib.Colors
        function onPrimaryChanged() { win.wallRev++ }
    }

    Image {
        id: wall
        anchors.fill: parent
        visible: layer.usesWallpaper
        source: layer.usesWallpaper
            ? "file://" + Quickshell.env("HOME") + "/.config/hypr/.cache/current_wallpaper.png?" + win.wallRev
            : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        sourceSize: Qt.size(win.width, win.height)
    }

    Services.ThemeLayer {
        id: layer
        anchors.fill: parent
        wallpaper: wall
    }
}
