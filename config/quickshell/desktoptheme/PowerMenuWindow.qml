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
        visible: menu.visible
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "power-menu"
        WlrLayershell.keyboardFocus: menu.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        PowerMenu {
            id: menu
            focus: true
        }
    }
}
