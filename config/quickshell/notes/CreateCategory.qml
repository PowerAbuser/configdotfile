// Ported from github.com/dhrruvsharma/shell (GPL-3.0-or-later), modules/notes/.
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import "../lib" as Lib

Dialog {
    id: categoryDialog
    title: "Create New Category"
    modal: true

    x: (root.width - width) / 2
    y: (root.height - height) / 2
    width: 400
    height: 220
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
            text: categoryDialog.title
            font.pixelSize: 20
            font.weight: Font.Bold
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 24

        StyledTextField {
            id: categoryInput
            Layout.fillWidth: true
            placeholderText: "Enter category name..."
            font.pixelSize: 14
            focus: true
            radius: 14
            borderWidth: 2
            backgroundColor: Lib.Colors.surfaceContainerHigh
            focusBorderColor: Lib.Colors.primary

            onAccepted: {
                if (text.trim().length > 0) {
                    Notes.addCategory(text.trim())
                    categoryDialog.close()
                    text = ""
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Button {
                text: "Cancel"
                Layout.fillWidth: true
                Layout.preferredHeight: 48

                background: Card {
                    radius: 14
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
                    categoryDialog.close()
                    categoryInput.text = ""
                }
            }

            Button {
                text: "Create"
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                enabled: categoryInput.text.trim().length > 0

                background: Rectangle {
                    radius: 14
                    color: parent.hovered && parent.enabled
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
                    if (categoryInput.text.trim().length > 0) {
                        Notes.addCategory(categoryInput.text.trim())
                        categoryDialog.close()
                        categoryInput.text = ""
                    }
                }
            }
        }
    }
}