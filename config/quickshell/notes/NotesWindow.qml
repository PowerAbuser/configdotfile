import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

// The notes drawer (NotesDrawer.qml, ported from dhrruvsharma/shell) on one
// screen. It rises from the bottom centre:
//   - the notesToggle shortcut (SUPER+ALT+N) opens it on the focused screen
//     (it no longer opens when the pointer reaches the bottom edge)
//   - SUPER+ALT+N again, Escape or a click outside closes it
Scope {
    id: root

    required property var screen
    property bool opened: false
    // Opened by the shortcut or clicked into: stays until closed
    property bool pinned: false
    property bool hovered: false

    function open(pin) {
        root.pinned = pin
        root.opened = true
        // A peek the pointer never moves onto closes again
        if (!pin) leaveTimer.restart()
    }
    function close() { root.opened = false; root.pinned = false }

    Timer {
        id: leaveTimer
        interval: 450
        onTriggered: if (!root.pinned && !root.hovered) root.close()
    }

    GlobalShortcut {
        name: "notesToggle"
        description: "Toggle the notes drawer"
        onPressed: {
            var mon = Hyprland.focusedMonitor
            if (!mon || mon.name !== root.screen.name) return
            if (root.opened) root.close(); else root.open(true)
        }
    }

    PanelWindow {
        id: win
        screen: root.screen
        visible: root.opened || drawer.implicitHeight > 0
        anchors { top: true; bottom: true; left: true; right: true }
        exclusiveZone: 0
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "notes-drawer"
        WlrLayershell.keyboardFocus: root.opened ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

        // A peek only takes input over the drawer, so the desktop stays usable;
        // pinned, the rest of the screen catches the click that closes it
        mask: Region {
            x: root.pinned ? 0 : drawer.x
            y: root.pinned ? 0 : drawer.y
            width: root.pinned ? win.width : drawer.width
            height: root.pinned ? win.height : drawer.height
        }

        MouseArea {
            anchors.fill: parent
            onPressed: root.close()
        }

        Item {
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: root.close()

            NotesDrawer {
                id: drawer
                opened: root.opened
                onPeekHover: h => {
                    root.hovered = h
                    if (!h) leaveTimer.restart()
                }
                onPeekPressed: root.pinned = true
            }
        }
    }
}
