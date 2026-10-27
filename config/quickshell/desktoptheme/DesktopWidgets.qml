pragma Singleton
pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Io
import QtQuick

// Stand-in for dhrruvsharma/shell's services/DesktopWidgets.qml, with just
// the clock, the music player and the system monitor (no jokes, no
// visualizer). Which are on and where they sit (fractions of the free
// space, dragged into place) are kept in desktopwidgets.json next to
// shell.qml. Settings > Desktop theme switches them.
Singleton {
    id: root

    readonly property var widgets: [
        { id: "clock", name: "Clock", description: "The theme's own clock face", x: 0.03, y: 0.08 },
        { id: "music", name: "Media", description: "Now playing, with controls", x: 0.97, y: 0.08 },
        { id: "sysmon", name: "System", description: "CPU, temperatures, memory and disk", x: 0.97, y: 0.6 }
    ]
    readonly property var defaults: ({ clock: true, music: true, sysmon: true })

    function info(id) { return widgets.find(w => w.id === id); }
    function enabled(id) {
        const v = adapter.on[id];
        return v === undefined ? (defaults[id] ?? false) : v;
    }
    function setEnabled(id, on) {
        const next = Object.assign({}, adapter.on);
        next[id] = on;
        adapter.on = next;
    }
    function toggle(id) { setEnabled(id, !enabled(id)); }
    function pos(id) {
        const p = adapter.positions[id];
        const w = info(id);
        return p ? p : { x: w ? w.x : 0, y: w ? w.y : 0 };
    }
    function setPos(id, x, y) {
        const next = Object.assign({}, adapter.positions);
        next[id] = { x: Math.max(0, Math.min(1, x)), y: Math.max(0, Math.min(1, y)) };
        adapter.positions = next;
    }
    function resetPositions() { adapter.positions = ({}); }

    // The screen they sit on (its name), "" for the first one
    readonly property alias screenName: adapter.screen
    function setScreen(name) { adapter.screen = name; }

    Timer { id: writeTimer; interval: 150; onTriggered: file.writeAdapter() }

    FileView {
        id: file
        path: Qt.resolvedUrl("../desktopwidgets.json").toString().replace("file://", "")
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onAdapterUpdated: writeTimer.restart()
        adapter: JsonAdapter {
            id: adapter
            property var on: ({})
            property var positions: ({})
            property string screen: ""
        }
    }
}
