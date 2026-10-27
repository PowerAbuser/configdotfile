import QtQuick
import "../lib" as Lib

// Stand-in for the upstream components/Popout.qml bubble: a surface that
// rises from the bottom edge, rounded on top and square where it meets the
// screen. `alignment` is accepted for compatibility and ignored.
Rectangle {
    property int alignment: 0
    default property alias content: wrapper.data

    color: Lib.Colors.surfaceContainerLowest
    bottomLeftRadius: 0
    bottomRightRadius: 0
    border.width: 1
    border.color: Lib.Colors.alpha(Lib.Colors.outlineVariant, 0.6)

    Item {
        id: wrapper
        anchors.fill: parent
    }
}
