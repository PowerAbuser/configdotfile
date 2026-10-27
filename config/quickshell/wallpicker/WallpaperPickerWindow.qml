import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

// The wallpaper picker (Wallpaper.qml, the swatch deck ported from
// dhrruvsharma/shell, with its Wallhaven tab) on one screen. The
// wallpaperPicker shortcut (SUPER+SHIFT+W) opens it on the focused screen;
// Esc, or choosing a wallpaper, closes it. It's loaded only while open.
Scope {
    id: root

    required property var screen

    function toggle() {
        if (!loader.active) {
            loader.active = true
            return  // opened by onLoaded
        }
        const picker = loader.item
        if (!picker.visible || picker.closing) picker.open(); else picker.close()
    }

    GlobalShortcut {
        name: "wallpaperPicker"
        description: "Wallpaper picker"
        onPressed: {
            const mon = Hyprland.focusedMonitor
            if (mon && mon.name === root.screen.name) root.toggle()
        }
    }

    // Unload once it's put away, unless it was opened again meanwhile
    Timer {
        id: unloadTimer
        interval: 600
        onTriggered: if (loader.item && !loader.item.visible) loader.active = false
    }

    PanelWindow {
        id: win
        screen: root.screen
        visible: loader.active
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "wallpaper-picker"
        WlrLayershell.keyboardFocus: loader.active ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        Loader {
            id: loader
            active: false
            anchors.fill: parent
            focus: true
            sourceComponent: Wallpaper { focus: true }
            onLoaded: item.open()
        }

        Connections {
            target: loader.item
            function onVisibleChanged() {
                if (loader.item && !loader.item.visible) unloadTimer.restart()
            }
        }
    }
}
