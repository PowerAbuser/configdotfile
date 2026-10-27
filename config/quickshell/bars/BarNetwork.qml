import QtQuick
import "../lib" as Lib
import "../desktoptheme" as DT

// Network pill (after dhrruvsharma/shell's bar Network): the Wi-Fi network,
// or Ethernet, or Offline, from nmcli.
DT.BarPill {
    id: root
    property bool active: true
    horizontalPadding: 20
    maxWidth: 200
    interactive: true
    cursorShape: Qt.PointingHandCursor
    readonly property var state: poll.value || ({ kind: "", name: "" })
    text: (state.kind === "ethernet" ? DT.Icons.networkEthernet
           : state.kind === "wifi" ? DT.Icons.networkWifiConnected
           : DT.Icons.networkWifiDisconnected)
        + "  " + (state.kind === "" ? "Offline" : state.kind === "ethernet" ? "Ethernet" : state.name)

    Lib.CommandPoll {
        id: poll
        running: root.active && root.visible
        interval: 5000
        // The first connected device: "wifi:Home" or "ethernet:Wired connection 1"
        command: ["bash", "-c", "nmcli -t -f TYPE,STATE,CONNECTION dev 2>/dev/null | awk -F: '$2==\"connected\" && ($1==\"wifi\"||$1==\"ethernet\"){print $1\":\"$3; exit}'"]
        parse: function(o) {
            const s = String(o).trim()
            const i = s.indexOf(":")
            return i < 0 ? ({ kind: "", name: "" }) : ({ kind: s.slice(0, i), name: s.slice(i + 1) })
        }
    }
}
