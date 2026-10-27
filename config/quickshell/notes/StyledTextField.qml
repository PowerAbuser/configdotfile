import QtQuick
import QtQuick.Controls
import "../lib" as Lib

// Stand-in for the upstream components/StyledTextField.qml: a TextField
// with the shell's background
TextField {
    id: root

    property real radius: 10
    property int borderWidth: 1
    property color backgroundColor: Lib.Colors.surfaceContainer
    property color borderColor: Lib.Colors.outlineVariant
    property color focusBorderColor: root.borderColor

    color: Lib.Colors.fgSurface
    placeholderTextColor: Lib.Colors.fgSurfaceVariant
    font.family: "Manrope"

    background: Rectangle {
        radius: root.radius
        color: root.backgroundColor
        border.width: root.borderWidth
        border.color: root.activeFocus ? root.focusBorderColor : root.borderColor
    }
}
