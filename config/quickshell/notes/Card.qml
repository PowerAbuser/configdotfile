import QtQuick
import "../lib" as Lib
import "../desktoptheme" as DT

// Stand-in for the upstream components/Card.qml: the bordered surface for
// grouped content, without the desktop-theme reshaping.
Rectangle {
    radius: DT.DesktopTheme.rad(16)
    color: Lib.Colors.surfaceContainer
    border.width: 1
    border.color: Lib.Accent.line
}
