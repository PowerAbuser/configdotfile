pragma Singleton
import QtQuick
import Quickshell
import "../lib" as Lib

// Stand-in for dhrruvsharma/shell's services/BarLayout.qml: where the bar is,
// so the desktop layers keep their corner pieces clear of it. This shell's
// bar is always on the top edge (top style) or the bottom (taskbar style).
Singleton {
    readonly property bool atTop: Lib.Configuration.barStyle === "top"
    readonly property bool atBottom: !atTop
    readonly property bool atLeft: false
    readonly property bool atRight: false
    readonly property int size: atTop ? Lib.Configuration.barHeight : Lib.Configuration.taskbarExclusiveZone

    readonly property int reserveTop: atTop ? size : 0
    readonly property int reserveBottom: atBottom ? size : 0
    readonly property int reserveLeft: 0
    readonly property int reserveRight: 0

    readonly property int clearTop: atTop ? size + 2 : 0
    readonly property int clearBottom: atBottom ? size + 2 : 0
    readonly property int clearLeft: 0
    readonly property int clearRight: 0
}
