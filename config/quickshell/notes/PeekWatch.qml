import QtQuick

// Stand-in for the upstream components/PeekWatch.qml: reports hover and
// presses on the drawer to NotesWindow, so a peek (opened by hovering the
// bottom edge) stays while the pointer is on it and pins once clicked into.
Item {
    id: watch

    property string target: ""
    property Item area: parent
    signal peekHover(bool hovered)
    signal peekPressed()

    anchors.fill: parent
    z: 1000

    MouseArea {
        anchors.fill: parent
        onPressed: mouse => {
            watch.peekPressed()
            mouse.accepted = false
        }
    }

    HoverHandler {
        parent: watch.area
        onHoveredChanged: watch.peekHover(hovered)
    }
}
