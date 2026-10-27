pragma Singleton
import QtQuick
import Quickshell
import "../lib" as Lib

// Stand-in for dhrruvsharma/shell's services/System.qml: what the desktop
// system widget reads, from utils/vitals.sh every 2 s while a widget uses it.
// cpu, ram and disk are percentages, temp (CPU) and gpuTemp °C.
Singleton {
    id: root
    property int users: 0
    readonly property var v: poll.value || ({})
    readonly property real cpu: Number(v.cpu) || 0
    readonly property real ram: Number(v.mem) || 0
    readonly property real disk: Number(v.disk) || 0
    readonly property real temp: Number(v.temp) || 0
    readonly property real gpuTemp: Number(v.gpu) || 0
    readonly property string uptime: v.uptime || ""

    Lib.CommandPoll {
        id: poll
        running: root.users > 0
        interval: 2000
        command: [Qt.resolvedUrl("../utils/vitals.sh").toString().replace("file://", "")]
        parse: function(o) { try { return JSON.parse(String(o).trim()) } catch (e) { return poll.value } }
    }
}
