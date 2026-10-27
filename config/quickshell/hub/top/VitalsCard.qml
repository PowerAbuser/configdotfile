import QtQuick
import QtQuick.Layouts
import "../../lib" as Lib
import "../../theme.js" as Theme

// Machine: CPU, memory, temperature and disk as meters, and the uptime.
// After the Vitals section of dhrruvsharma/shell's control center.
Lib.TopCard {
    id: root
    property bool active: true

    readonly property var stats: vitals.value || ({ cpu: 0, mem: 0, temp: 0, disk: 0, uptime: "" })

    Lib.CommandPoll {
        id: vitals
        running: root.active && root.visible
        interval: 2500
        command: [Qt.resolvedUrl("../../utils/vitals.sh").toString().replace("file://", "")]
        parse: function(o) {
            try { return JSON.parse(String(o).trim()) } catch (e) { return vitals.value }
        }
    }

    // Past these the meter turns orange, then red
    function levelColor(key, v) {
        var warn = key === "temp" ? 75 : 80
        var crit = key === "temp" ? 90 : 95
        if (v >= crit) return Lib.Colors.red
        if (v >= warn) return Lib.Colors.orange
        return root.theme ? root.theme.accent : Lib.Colors.primary
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Machine"
                color: root.theme ? root.theme.textPrimary : Lib.Colors.onSurface
                font.family: Theme.textFont; font.pixelSize: 13; font.weight: 700
            }
            Item { Layout.fillWidth: true }
            Text {
                text: root.stats.uptime ? "up " + root.stats.uptime : ""
                color: root.theme ? root.theme.textSecondary : Lib.Colors.onSurfaceVariant
                font.family: "DM Mono"; font.pixelSize: 11
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 14
            rowSpacing: 10

            Repeater {
                model: [
                    { key: "cpu",  label: "CPU",    unit: "%" },
                    { key: "mem",  label: "Memory", unit: "%" },
                    { key: "temp", label: "Temp",   unit: "°C" },
                    { key: "disk", label: "Disk",   unit: "%" }
                ]

                ColumnLayout {
                    id: cell
                    required property var modelData
                    readonly property real stat: Number(root.stats[modelData.key]) || 0
                    Layout.fillWidth: true
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: cell.modelData.label
                            color: root.theme ? root.theme.textSecondary : Lib.Colors.onSurfaceVariant
                            font.family: Theme.textFont; font.pixelSize: 11; font.weight: 600
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: Math.round(cell.stat) + cell.modelData.unit
                            color: root.theme ? root.theme.textPrimary : Lib.Colors.onSurface
                            font.family: "DM Mono"; font.pixelSize: 11
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 6
                        radius: 3
                        color: root.theme ? root.theme.bgItem : Lib.Colors.surfaceContainerHighest

                        Rectangle {
                            height: parent.height
                            radius: parent.radius
                            width: parent.width * Math.max(0, Math.min(1, cell.stat / 100))
                            color: root.levelColor(cell.modelData.key, cell.stat)
                            Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                    }
                }
            }
        }
    }
}
