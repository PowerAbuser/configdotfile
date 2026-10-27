import QtQuick
import Quickshell
import "../desktoptheme" as DT

// Clock pill (after dhrruvsharma/shell's bar Clock), in 24-hour time. It's
// also the hub's button: TopBar toggles the hub on click. Tinted like
// upstream's while its panel (here the hub) is open.
DT.BarPill {
    id: root
    property bool active: false
    interactive: true
    cursorShape: Qt.PointingHandCursor
    text: Qt.formatDateTime(clock.date, "ddd d MMM  •  HH:mm")
    color: root.active ? DT.Colors.primary_container : DT.BarSettings.pill
    textColor: root.active ? DT.Colors.on_primary_container : DT.BarSettings.ink
    Behavior on color { ColorAnimation { duration: 180; easing.type: Easing.OutCubic } }
    Behavior on textColor { ColorAnimation { duration: 180; easing.type: Easing.OutCubic } }

    SystemClock { id: clock; precision: SystemClock.Minutes }
}
