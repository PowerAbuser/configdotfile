import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

// The power menu (PowerMenu, the desktop theme's own scene) on one screen.
// The powerMenu shortcut (SUPER+X, ALT+F4) opens it on the focused screen,
// or closes it. The window shows only once the menu has grabbed the
// desktop, which its first frame is drawn from.
Scope {
    id: root

    required property var screen

    function toggle() { menu.toggle() }
    readonly property alias menu: menu

    GlobalShortcut {
        name: "powerMenu"
        description: "Power menu"
        onPressed: {
            const mon = Hyprland.focusedMonitor
            if (mon && mon.name === root.screen.name) menu.toggle()
            else menu.close()
        }
    }

    PanelWindow {
        id: win
        screen: root.screen
        // From the phase, not menu.visible: an item in a hidden window reads
        // as hidden, so that would never show the window again once closed.
        readonly property bool shown: menu.phase !== "closed" && menu.phase !== "capturing"
        visible: shown
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "power-menu"
        WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        PowerMenu {
            id: menu
            screen: root.screen
            focus: true
        }
    }
}
