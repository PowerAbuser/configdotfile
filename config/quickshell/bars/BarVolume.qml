import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import "../desktoptheme" as DT

// Volume pill (after dhrruvsharma/shell's bar Volume): the default output's
// volume. Scroll to change it, click to mute, right-click for pavucontrol.
DT.BarPill {
    id: root
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real vol: sink && sink.audio ? sink.audio.volume : 0
    readonly property bool muted: sink && sink.audio ? sink.audio.muted : false
    horizontalPadding: 20
    maxWidth: 160
    interactive: true
    cursorShape: Qt.PointingHandCursor
    text: (muted ? DT.Icons.volumeMuted
           : vol <= 0 ? DT.Icons.volumeZero
           : vol < 0.34 ? DT.Icons.volumeLow
           : vol < 0.67 ? DT.Icons.volumeMedium : DT.Icons.volumeHigh)
        + " " + Math.round(vol * 100) + "%"

    PwObjectTracker { objects: [root.sink] }

    onClicked: if (root.sink && root.sink.audio) root.sink.audio.muted = !root.sink.audio.muted

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: Quickshell.execDetached(["pavucontrol"])
        onWheel: wheel => {
            if (!root.sink || !root.sink.audio) return
            const step = wheel.angleDelta.y > 0 ? 0.05 : -0.05
            root.sink.audio.volume = Math.max(0, Math.min(1.5, root.vol + step))
        }
    }
}
