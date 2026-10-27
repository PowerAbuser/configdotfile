import QtQuick
import "../lib" as Lib
import "../desktoptheme" as DT

// Bluetooth pill (after dhrruvsharma/shell's bar Bluetooth): the connected
// device, or On / Off. Polls bluetoothctl: Quickshell.Bluetooth finds no
// adapter on this machine although BlueZ has one.
DT.BarPill {
    id: root
    property bool active: true
    horizontalPadding: 20
    maxWidth: 200
    interactive: true
    cursorShape: Qt.PointingHandCursor
    text: DT.Icons.bluetooth + " " + (poll.value || "…")

    Lib.CommandPoll {
        id: poll
        running: root.active && root.visible
        interval: 4000
        command: ["bash", "-c", "bluetoothctl show 2>/dev/null | grep -q 'Powered: yes' || { echo Off; exit; }; "
            + "d=$(bluetoothctl devices Connected 2>/dev/null | head -n1 | cut -d' ' -f3-); echo \"${d:-On}\""]
    }
}
