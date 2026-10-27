// Ported from github.com/dhrruvsharma/shell (GPL-3.0-or-later), modules/notes/.
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import "../lib" as Lib

Dialog {
    id: commandDialog
    title: "Configure Category"
    modal: true

    property string categoryName: ""
    property string commandText: ""
    property bool keepOpen: false

    x: (root.width - width) / 2
    y: (root.height - height) / 2
    width: 500
    height: 380  // Increased height to accommodate new option
    parent: root

    background: Card {
        radius: 28
        color: Lib.Colors.surfaceContainerLowest

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.width: 1
            border.color: Qt.rgba(151, 204, 249, 0.1)
        }
    }

    header: Rectangle {
        height: 64
        radius: 28
        color: Lib.Colors.surfaceContainerLowest

        Rectangle {
            width: 48
            height: 4
            anchors.top: parent.top
            anchors.topMargin: 12
            anchors.horizontalCenter: parent.horizontalCenter
            radius: 2
            color: Lib.Colors.outlineVariant
            opacity: 0.3
        }

        StyledText {
            anchors.centerIn: parent
            text: "Configure: " + commandDialog.categoryName
            font.pixelSize: 20
            font.weight: Font.Bold
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 12

        StyledText {
            text: "Enter command to execute when clicking notes in this category.\nUse $text or $note as placeholder for the main note content."
            color: Lib.Colors.fgSurfaceVariant
            font.pixelSize: 12
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        StyledTextField {
            id: commandInput
            Layout.fillWidth: true
            text: commandDialog.commandText
            placeholderText: "e.g., ani-cli $text"
            font.pixelSize: 14
            focus: true
            radius: 14
            borderWidth: 2
            backgroundColor: Lib.Colors.surfaceContainerHigh
            focusBorderColor: Lib.Colors.primary
        }

        // Keep terminal open option
        Card {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            radius: 12

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                StyledText {
                    text: "Keep terminal open after execution:"
                    font.pixelSize: 13
                    Layout.fillWidth: true
                }

                Switch {
                    id: keepOpenSwitch
                    checked: commandDialog.keepOpen
                    Layout.alignment: Qt.AlignRight

                    indicator: Rectangle {
                        implicitWidth: 48
                        implicitHeight: 24
                        x: keepOpenSwitch.leftPadding
                        y: parent.height / 2 - height / 2
                        radius: 12
                        color: keepOpenSwitch.checked
                            ? Lib.Colors.primary
                            : Lib.Colors.surfaceContainerHighest
                        border.color: keepOpenSwitch.checked
                            ? Lib.Colors.primary
                            : Lib.Colors.outlineVariant
                        border.width: 1

                        Rectangle {
                            x: keepOpenSwitch.checked ? parent.width - width : 0
                            y: (parent.height - height) / 2
                            width: 20
                            height: 20
                            radius: 10
                            color: Lib.Colors.fgPrimary
                            border.color: keepOpenSwitch.checked
                                ? Lib.Colors.primary
                                : Lib.Colors.outlineVariant
                            border.width: 1

                            Behavior on x {
                                NumberAnimation { duration: 200 }
                            }
                        }
                    }
                }
            }

            ToolTip {
                text: "When enabled, terminal stays open after command (for SSH, interactive apps).\nWhen disabled, terminal closes after command (for launching apps)."
                delay: 500
                visible: !!parent.hovered
                width: 300
                background: Card {
                    radius: 6
                    color: Lib.Colors.surfaceContainerHighest
                }
            }
        }

        // Example preview
        Card {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            radius: 10
            visible: commandInput.text.trim().length > 0

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4

                StyledText {
                    text: "Preview:"
                    color: Lib.Colors.fgSurfaceVariant
                    font.pixelSize: 11
                    font.bold: true
                }

                StyledText {
                    text: commandInput.text.replace(/\$text/g, "example").replace(/\$note/g, "example")
                    color: Lib.Colors.primary
                    font.pixelSize: 12
                    font.bold: true
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                }
            }
        }

        // Buttons at bottom with proper spacing
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 8
            spacing: 8

            Button {
                text: "Clear"
                Layout.fillWidth: true
                Layout.preferredHeight: 44

                background: Card {
                    radius: 12
                    color: parent.hovered
                        ? Lib.Colors.surfaceContainerHigh
                        : "transparent"
                }

                contentItem: StyledText {
                    text: parent.text
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    commandInput.text = ""
                    keepOpenSwitch.checked = false
                }
            }

            Button {
                text: "Cancel"
                Layout.fillWidth: true
                Layout.preferredHeight: 44

                background: Card {
                    radius: 12
                    color: parent.hovered
                        ? Lib.Colors.surfaceContainerHigh
                        : "transparent"
                }

                contentItem: StyledText {
                    text: parent.text
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    commandDialog.close()
                }
            }

            Button {
                text: "Save"
                Layout.fillWidth: true
                Layout.preferredHeight: 44

                background: Rectangle {
                    radius: 12
                    color: parent.hovered
                        ? Qt.darker(Lib.Colors.primaryContainer, 1.2)
                        : Lib.Colors.primaryContainer
                    border.width: 2
                    border.color: Lib.Colors.primary
                    opacity: 0.3
                }

                contentItem: StyledText {
                    text: parent.text
                    color: Lib.Colors.fgPrimaryContainer
                    font.pixelSize: 14
                    font.weight: Font.Bold
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    Notes.setCategoryCommand(commandDialog.categoryName, commandInput.text)
                    Notes.setCategoryKeepOpen(commandDialog.categoryName, keepOpenSwitch.checked)
                    commandDialog.close()
                }
            }
        }
    }
}