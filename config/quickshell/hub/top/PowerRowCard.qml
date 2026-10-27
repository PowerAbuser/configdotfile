import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../lib" as Lib
import "../../theme.js" as Theme

// Lock, log out, restart, shut down. After the Power row of
// dhrruvsharma/shell's control center. The last three ask for a second
// click (the button turns red and says "Again?") within 3 s.
// There is no sleep button: suspend is masked on this machine, because
// s2idle resumes hard-reset it.
Lib.TopCard {
    id: root
    signal closeRequested()

    property string armed: ""
    Timer { id: disarm; interval: 3000; onTriggered: root.armed = "" }

    readonly property var actions: [
        { id: "lock",     glyph: "󰌾", label: "Lock",     confirm: false, cmd: ["hyprlock"] },
        { id: "logout",   glyph: "󰍃", label: "Log out",  confirm: true,  cmd: ["hyprctl", "dispatch", "hl.dsp.exit()"] },
        { id: "reboot",   glyph: "󰜉", label: "Restart",  confirm: true,  cmd: ["systemctl", "reboot"] },
        { id: "shutdown", glyph: "󰐥", label: "Shut down", confirm: true, cmd: ["systemctl", "poweroff"] }
    ]

    function trigger(a) {
        if (a.confirm && root.armed !== a.id) {
            root.armed = a.id
            disarm.restart()
            return
        }
        root.armed = ""
        root.closeRequested()
        Quickshell.execDetached(a.cmd)
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Repeater {
            model: root.actions

            Rectangle {
                id: btn
                required property var modelData
                readonly property bool isArmed: root.armed === modelData.id
                Layout.fillWidth: true
                implicitHeight: 44
                radius: root.theme ? root.theme.rad(14) : 14
                color: btn.isArmed ? Lib.Colors.error
                     : (mouse.containsMouse ? (root.theme ? root.theme.bgItemHover : Lib.Colors.surfaceBright)
                                            : (root.theme ? root.theme.bgItem : Lib.Colors.surfaceContainerHighest))
                Behavior on color { ColorAnimation { duration: 160 } }

                Column {
                    anchors.centerIn: parent
                    spacing: 1
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: btn.modelData.glyph
                        color: btn.isArmed ? Lib.Colors.fgError : (root.theme ? root.theme.textPrimary : Lib.Colors.fgSurface)
                        font.family: Theme.iconFont; font.pixelSize: 16
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: btn.isArmed ? "Again?" : btn.modelData.label
                        color: btn.isArmed ? Lib.Colors.fgError : (root.theme ? root.theme.textSecondary : Lib.Colors.fgSurfaceVariant)
                        font.family: Lib.Fonts.text; font.pixelSize: 9; font.weight: 600
                    }
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.trigger(btn.modelData)
                }
            }
        }
    }
}
