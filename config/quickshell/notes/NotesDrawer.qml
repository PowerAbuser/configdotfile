// Ported from github.com/dhrruvsharma/shell (GPL-3.0-or-later), modules/notes/.
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import "../lib" as Lib

Item {
    id: root
    property bool opened: false

    implicitHeight: opened ? 600 : 0
    implicitWidth: drawerWidth
    property int drawerWidth: 900
    // Hidden once fully closed: a collapsed but visible drawer still went on
    // laying out and repainting its notes.
    visible: opened || implicitHeight > 0

    // Theme accent as a real color (so we can derive translucent tints from it).
    readonly property color accent: Lib.Colors.primary

    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    focus: true

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 500
            easing.type: Easing.OutCubic
            property: "implicitHeight"
        }
    }

    Popout {
        id: popoutBackground
        anchors.fill: parent
        clip: true
        alignment: 4
        radius: 32
        color: Lib.Colors.surfaceContainerLowest

        Rectangle {
            anchors.fill: parent
            radius: popoutBackground.radius
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.05) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        Rectangle {
            width: 120
            height: 3
            anchors.top: parent.top
            anchors.topMargin: -1.5
            anchors.horizontalCenter: parent.horizontalCenter
            radius: 1.5
            color: Lib.Colors.primary
            opacity: 0.6
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            Card {
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                radius: 20
                opacity: 0.8

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: "transparent"
                    border.width: 1
                    border.color: Qt.rgba(255, 255, 255, 0.05)
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 16

                    StyledText {
                        text: "Quick Notes"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item { Layout.fillWidth: true }

                    // Sort order toggle button
                    Button {
                        id: sortBtn
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        Layout.alignment: Qt.AlignVCenter
                        flat: true

                        contentItem: StyledText {
                            text: Notes.sortDescending ? "↓" : "↑"
                            font.pixelSize: 18
                            font.weight: Font.Bold
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 18
                            color: sortBtn.hovered
                                ? Lib.Colors.surfaceContainerHighest
                                : "transparent"
                            border.width: sortBtn.hovered ? 1 : 0
                            border.color: Lib.Colors.outlineVariant
                        }

                        onClicked: Notes.toggleSortOrder()

                        ToolTip {
                            text: Notes.sortDescending ? "Sort: Newest first" : "Sort: Oldest first"
                            delay: 300
                            visible: parent.hovered
                            background: Card {
                                radius: 6
                                color: Lib.Colors.surfaceContainerHighest
                            }
                        }
                    }

                    Rectangle {
                        Layout.preferredHeight: 36
                        Layout.preferredWidth: Math.max(36, countText.contentWidth + 24)
                        Layout.alignment: Qt.AlignVCenter
                        radius: 18
                        color: Lib.Colors.primaryContainer
                        opacity: Notes.getNotesForCategory(
                            Notes.currentCategory).length > 0 ? 1 : 0.4

                        Behavior on opacity {
                            NumberAnimation { duration: 200 }
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: parent.radius
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.18) }
                                GradientStop { position: 1.0; color: "transparent" }
                            }
                        }

                        StyledText {
                            id: countText
                            anchors.centerIn: parent
                            text: Notes.getNotesForCategory(
                                Notes.currentCategory).length
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            color: Lib.Colors.onPrimaryContainer
                        }
                    }

                    Button {
                        id: addCategoryBtn
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        Layout.alignment: Qt.AlignVCenter
                        flat: true

                        contentItem: StyledText {
                            text: "+"
                            font.pixelSize: 20
                            font.weight: Font.Bold
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: Lib.Colors.onPrimary
                        }

                        background: Rectangle {
                            radius: 18
                            color: addCategoryBtn.hovered
                                ? Qt.darker(Lib.Colors.primaryContainer, 1.2)
                                : Lib.Colors.primaryContainer

                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                color: "transparent"
                                border.width: 1
                                border.color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.3)
                            }

                            Behavior on color {
                                ColorAnimation { duration: 200 }
                            }
                        }

                        onClicked: categoryDialog.open()

                        ToolTip {
                            text: "Add new category"
                            delay: 300
                            visible: parent.hovered
                            background: Card {
                                radius: 6
                                color: Lib.Colors.surfaceContainerHighest
                            }
                        }
                    }
                }
            }

            Card {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                opacity: 0.6

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 4
                    ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                    ScrollBar.horizontal.policy: ScrollBar.AsNeeded
                    clip: true

                    RowLayout {
                        spacing: 8
                        height: parent.height

                        Repeater {
                            model: Notes.categories

                            delegate: Item {
                                id: categoryItem
                                Layout.preferredHeight: 36
                                Layout.alignment: Qt.AlignVCenter
                                Layout.preferredWidth: categoryTab.width

                                property bool isCurrent: Notes.currentCategory === modelData
                                property bool isDefault: modelData === "notes"

                                Rectangle {
                                    id: categoryTab
                                    width: Math.min(
                                        categoryContent.implicitWidth + 24,
                                        categoryItem.isDefault ? categoryContent.implicitWidth + 24 : 160
                                    )
                                    height: 36

                                    radius: 18
                                    color: categoryItem.isCurrent
                                        ? Lib.Colors.primary
                                        : mouseArea.containsMouse
                                            ? Lib.Colors.surfaceContainerHighest
                                            : Lib.Colors.surfaceContainer

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: parent.radius
                                        color: "transparent"
                                        border.width: categoryItem.isCurrent ? 2 : 0
                                        border.color: Lib.Colors.primary
                                        opacity: 0.5
                                    }

                                    scale: mouseArea.containsMouse ? 1.05 : 1.0
                                    z: mouseArea.containsMouse ? 1 : 0
                                    Behavior on scale {
                                        NumberAnimation { duration: 150 }
                                    }
                                    Behavior on color {
                                        ColorAnimation { duration: 200 }
                                    }

                                    MouseArea {
                                        id: mouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: Notes.setCurrentCategory(modelData)
                                    }

                                    RowLayout {
                                        id: categoryContent
                                        anchors.fill: parent
                                        anchors.leftMargin: 12
                                        anchors.rightMargin: categoryItem.isDefault ? 12 : 4
                                        spacing: 6

                                        StyledText {
                                            id: categoryText
                                            text: modelData.charAt(0).toUpperCase() + modelData.slice(1)
                                            Layout.alignment: Qt.AlignVCenter
                                            color: categoryItem.isCurrent
                                                ? Lib.Colors.onPrimary
                                                : Lib.Colors.onSurface
                                            font.pixelSize: 13
                                            font.weight: Font.Medium
                                            elide: Text.ElideRight
                                            Layout.maximumWidth: categoryItem.isDefault ? 120 : 80
                                        }

                                        // Command indicator
                                        Rectangle {
                                            visible: !!(Notes.categoryCommands[modelData] &&
                                                Notes.categoryCommands[modelData] !== "")
                                            Layout.preferredWidth: 16
                                            Layout.preferredHeight: 16
                                            Layout.alignment: Qt.AlignVCenter
                                            radius: 8
                                            color: Lib.Colors.primary
                                            opacity: 0.7

                                            StyledText {
                                                anchors.centerIn: parent
                                                text: "⌘"
                                                font.pixelSize: 10
                                                font.bold: true
                                                color: Lib.Colors.onPrimary
                                            }

                                            ToolTip {
                                                text: "Command: " + Notes.categoryCommands[modelData]
                                                delay: 500
                                                visible: parent.hovered ? true : false
                                                background: Card {
                                                    radius: 6
                                                }
                                            }
                                        }

                                        // Keep-open indicator
                                        Rectangle {
                                            visible: Notes.categoryKeepOpen[modelData] === true
                                            Layout.preferredWidth: 16
                                            Layout.preferredHeight: 16
                                            Layout.alignment: Qt.AlignVCenter
                                            radius: 8
                                            color: Lib.Colors.secondary
                                            opacity: 0.7

                                            StyledText {
                                                anchors.centerIn: parent
                                                text: "🔓"
                                                font.pixelSize: 10
                                                color: Lib.Colors.onSecondary
                                            }

                                            ToolTip {
                                                text: "Terminal stays open after command"
                                                delay: 500
                                                visible: parent.hovered ? true : false
                                                background: Card {
                                                    radius: 6
                                                }
                                            }
                                        }

                                        // Buttons container for non-default categories
                                        RowLayout {
                                            visible: !categoryItem.isDefault
                                            spacing: 2
                                            Layout.alignment: Qt.AlignVCenter
                                            Layout.rightMargin: 4

                                            // Settings button
                                            Button {
                                                Layout.preferredWidth: 20
                                                Layout.preferredHeight: 20
                                                flat: true
                                                opacity: mouseArea.containsMouse ? 1 : 0.6

                                                contentItem: StyledText {
                                                    text: "⚙"
                                                    font.pixelSize: 12
                                                    horizontalAlignment: Text.AlignHCenter
                                                    verticalAlignment: Text.AlignVCenter
                                                    color: categoryItem.isCurrent
                                                        ? Lib.Colors.onPrimary
                                                        : Lib.Colors.onSurface
                                                }

                                                background: Rectangle {
                                                    radius: 10
                                                    color: parent.hovered
                                                        ? Qt.rgba(255, 255, 255, 0.2)
                                                        : "transparent"
                                                }

                                                onClicked: {
                                                    commandDialog.categoryName = modelData
                                                    commandDialog.commandText = Notes.categoryCommands[modelData] || ""
                                                    commandDialog.keepOpen = Notes.categoryKeepOpen[modelData] || false
                                                    commandDialog.open()
                                                }

                                                ToolTip {
                                                    text: "Configure category"
                                                    delay: 500
                                                    visible: parent.hovered
                                                    background: Card {
                                                        radius: 6
                                                        color: Lib.Colors.surfaceContainerHighest
                                                    }
                                                }
                                            }

                                            // Delete button
                                            Button {
                                                Layout.preferredWidth: 20
                                                Layout.preferredHeight: 20
                                                flat: true
                                                opacity: mouseArea.containsMouse ? 1 : 0.6

                                                contentItem: StyledText {
                                                    text: "×"
                                                    font.pixelSize: 16
                                                    font.weight: Font.Bold
                                                    horizontalAlignment: Text.AlignHCenter
                                                    verticalAlignment: Text.AlignVCenter
                                                    color: categoryItem.isCurrent
                                                        ? Lib.Colors.onPrimary
                                                        : Lib.Colors.onSurface
                                                }

                                                background: Rectangle {
                                                    radius: 10
                                                    color: parent.hovered
                                                        ? Qt.rgba(255, 255, 255, 0.2)
                                                        : "transparent"
                                                }

                                                onClicked: Notes.removeCategory(modelData)

                                                ToolTip {
                                                    text: "Remove category"
                                                    delay: 500
                                                    visible: parent.hovered
                                                    background: Card {
                                                        radius: 6
                                                        color: Lib.Colors.surfaceContainerHighest
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Card {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 20

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: "transparent"
                    border.width: 1
                    border.color: Qt.rgba(255, 255, 255, 0.05)
                }

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 1
                    clip: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    ScrollBar.vertical: ScrollBar {
                        id: notesVBar
                        policy: ScrollBar.AsNeeded
                        width: 8
                        contentItem: Rectangle {
                            implicitWidth: 6
                            radius: 3
                            color: Lib.Colors.outlineVariant
                            opacity: notesVBar.pressed ? 0.9 : (notesVBar.hovered ? 0.7 : 0.35)
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                        }
                        background: Rectangle { color: "transparent" }
                    }

                    ColumnLayout {
                        width: parent.width - 20
                        spacing: 12

                        // Empty state when the current category has no notes
                        Item {
                            Layout.fillWidth: true
                            Layout.topMargin: 72
                            visible: Notes.getNotesForCategory(
                                Notes.currentCategory).length === 0
                            implicitHeight: visible ? emptyCol.implicitHeight : 0

                            ColumnLayout {
                                id: emptyCol
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 6

                                Text {
                                    text: "📝"
                                    font.pixelSize: 38
                                    opacity: 0.5
                                    Layout.alignment: Qt.AlignHCenter
                                }
                                StyledText {
                                    text: "No notes here yet"
                                    font.pixelSize: 15
                                    font.weight: Font.DemiBold
                                    opacity: 0.85
                                    Layout.alignment: Qt.AlignHCenter
                                }
                                StyledText {
                                    text: "Jot something down using the field below"
                                    color: Lib.Colors.onSurfaceVariant
                                    font.pixelSize: 12
                                    opacity: 0.7
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }
                        }

                        Repeater {
                            model: Notes.getNotesForCategory(
                                Notes.currentCategory)

                            delegate: Rectangle {
                                id: noteCard
                                Layout.fillWidth: true
                                Layout.minimumHeight: 72
                                Layout.preferredHeight: isEditing ? 180 : Math.max(noteContentColumn.implicitHeight + 40, 72)

                                property bool isEditing: false
                                property var originalNote: modelData

                                radius: 16
                                color: Lib.Colors.surfaceContainerHigh

                                Rectangle {
                                    anchors.fill: parent
                                    radius: parent.radius
                                    color: "transparent"
                                    border.width: 1
                                    border.color: noteMouseArea.containsMouse && !isEditing
                                        ? Lib.Colors.primary
                                        : isEditing
                                            ? Lib.Colors.secondary
                                            : Qt.rgba(255, 255, 255, 0.05)
                                    opacity: noteMouseArea.containsMouse && !isEditing ? 0.3 : 0.1
                                }

                                // left accent strip
                                Rectangle {
                                    width: 3
                                    radius: 1.5
                                    anchors.left: parent.left
                                    anchors.leftMargin: 7
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    anchors.topMargin: 16
                                    anchors.bottomMargin: 16
                                    visible: !noteCard.isEditing
                                    color: Lib.Colors.primary
                                    opacity: noteMouseArea.containsMouse ? 0.85 : 0.3
                                    Behavior on opacity { NumberAnimation { duration: 200 } }
                                }

                                scale: noteMouseArea.containsMouse && !isEditing ? 1.02 : 1.0
                                z: noteMouseArea.containsMouse && !isEditing ? 1 : 0

                                Behavior on scale {
                                    NumberAnimation { duration: 200 }
                                }

                                MouseArea {
                                    id: noteMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: isEditing ? Qt.ArrowCursor : Qt.PointingHandCursor
                                    onClicked: {
                                        if (!isEditing) {
                                            Notes.executeNote(modelData)
                                            root.opened = false
                                        }
                                    }
                                }

                                // Edit mode UI - completely redesigned with proper layout
                                Loader {
                                    id: editLoader
                                    active: isEditing
                                    anchors.fill: parent
                                    anchors.margins: 16

                                    sourceComponent: Item {
                                        property alias mainInput: mainInputField
                                        property alias subtextInput: subtextInputField
                                        property var card: noteCard

                                        ColumnLayout {
                                            anchors.fill: parent
                                            spacing: 12

                                            TextField {
                                                id: mainInputField
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 36
                                                text: originalNote.text
                                                placeholderText: "Main text (required)..."
                                                font.pixelSize: 14
                                                color: Lib.Colors.onSurface
                                                background: Card {
                                                    radius: 8
                                                }

                                                onAccepted: card.saveEdit()
                                            }

                                            TextField {
                                                id: subtextInputField
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 36
                                                text: originalNote.subtext || ""
                                                placeholderText: "Subtext (optional)..."
                                                font.pixelSize: 13
                                                color: Lib.Colors.onSurfaceVariant
                                                background: Card {
                                                    radius: 8
                                                }

                                                onAccepted: card.saveEdit()
                                            }

                                            // Button row at the bottom
                                            RowLayout {
                                                Layout.fillWidth: true
                                                Layout.alignment: Qt.AlignBottom
                                                spacing: 8

                                                Item { Layout.fillWidth: true } // Spacer

                                                Button {
                                                    text: "Cancel"
                                                    Layout.preferredWidth: 80
                                                    Layout.preferredHeight: 32

                                                    contentItem: StyledText {
                                                        text: "Cancel"
                                                        font.pixelSize: 12
                                                        horizontalAlignment: Text.AlignHCenter
                                                        verticalAlignment: Text.AlignVCenter
                                                        color: Lib.Colors.onSurfaceVariant
                                                    }

                                                    background: Card {
                                                        color: parent.hovered
                                                            ? Lib.Colors.surfaceContainerHighest
                                                            : "transparent"
                                                    }

                                                    onClicked: card.isEditing = false
                                                }

                                                Button {
                                                    text: "Save"
                                                    Layout.preferredWidth: 80
                                                    Layout.preferredHeight: 32
                                                    enabled: mainInputField.text.trim().length > 0

                                                    contentItem: StyledText {
                                                        text: "Save"
                                                        font.pixelSize: 12
                                                        font.weight: Font.Medium
                                                        horizontalAlignment: Text.AlignHCenter
                                                        verticalAlignment: Text.AlignVCenter
                                                        color: Lib.Colors.onPrimary
                                                    }

                                                    background: Rectangle {
                                                        radius: 16
                                                        color: parent.hovered && parent.enabled
                                                            ? Qt.darker(Lib.Colors.primary, 1.2)
                                                            : Lib.Colors.primary
                                                        opacity: parent.enabled ? 1 : 0.4
                                                    }

                                                    onClicked: card.saveEdit()
                                                }
                                            }
                                        }
                                    }
                                }

                                // Normal view mode
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 20
                                    spacing: 16
                                    visible: !isEditing

                                    ColumnLayout {
                                        id: noteContentColumn
                                        spacing: 6
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignVCenter

                                        // Main text (bold and slightly larger)
                                        StyledText {
                                            id: mainText
                                            text: modelData.text
                                            Layout.fillWidth: true
                                            wrapMode: Text.Wrap
                                            font.pixelSize: 15
                                            lineHeight: 1.4
                                            font.weight: Font.Medium
                                        }

                                        // Subtext (optional, smaller and muted)
                                        StyledText {
                                            visible: modelData.subtext && modelData.subtext.trim() !== ""
                                            text: modelData.subtext
                                            Layout.fillWidth: true
                                            wrapMode: Text.Wrap
                                            color: Lib.Colors.onSurfaceVariant
                                            font.pixelSize: 12
                                            lineHeight: 1.4
                                            font.weight: Font.Normal
                                            leftPadding: 8
                                        }

                                        // Command hint with keep-open status
                                        StyledText {
                                            visible: !!(Notes.categoryCommands[modelData.category] &&
                                                Notes.categoryCommands[modelData.category] !== "")
                                            text: {
                                                var cmd = Notes.categoryCommands[modelData.category]
                                                if (!cmd || cmd === "") return ""
                                                var base = "▶ Click to run: " +
                                                    cmd.replace(/\$text/g, modelData.text).replace(/\$note/g, modelData.text)
                                                base += Notes.categoryKeepOpen[modelData.category]
                                                    ? " (terminal stays open)"
                                                    : " (terminal closes)"
                                                return base
                                            }
                                            font.pixelSize: 10
                                            color: Lib.Colors.primary
                                            opacity: 0.7
                                            Layout.fillWidth: true
                                            wrapMode: Text.Wrap
                                            leftPadding: 8
                                        }
                                    }

                                    // Action buttons container - fixed layout
                                    RowLayout {
                                        Layout.alignment: Qt.AlignTop | Qt.AlignRight
                                        spacing: 4

                                        Button {
                                            id: editBtn
                                            Layout.preferredWidth: 32
                                            Layout.preferredHeight: 32
                                            flat: true
                                            opacity: noteMouseArea.containsMouse ? 1 : 0.4

                                            contentItem: StyledText {
                                                text: "✎"
                                                font.pixelSize: 16
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }

                                            background: Rectangle {
                                                radius: 16
                                                color: editBtn.hovered
                                                    ? Lib.Colors.surfaceContainerHighest
                                                    : "transparent"
                                                border.width: 1
                                                border.color: editBtn.hovered
                                                    ? Lib.Colors.outlineVariant
                                                    : "transparent"
                                            }

                                            onClicked: {
                                                noteCard.isEditing = true
                                            }

                                            ToolTip {
                                                text: "Edit note"
                                                delay: 300
                                                visible: parent.hovered
                                                background: Card {
                                                    radius: 6
                                                    color: Lib.Colors.surfaceContainerHighest
                                                }
                                            }
                                        }

                                        Button {
                                            id: copyBtn
                                            Layout.preferredWidth: 32
                                            Layout.preferredHeight: 32
                                            flat: true
                                            opacity: noteMouseArea.containsMouse ? 1 : 0.5

                                            property bool copied: false

                                            contentItem: StyledText {
                                                text: copyBtn.copied ? "✓" : "⎘"
                                                font.pixelSize: 16
                                                font.family: "monospace"
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                                color: copyBtn.copied
                                                    ? Lib.Colors.primary
                                                    : Lib.Colors.onSurface
                                            }

                                            background: Rectangle {
                                                radius: 16
                                                color: copyBtn.hovered
                                                    ? copyBtn.copied
                                                        ? Lib.Colors.primaryContainer
                                                        : Lib.Colors.surfaceContainerHighest
                                                    : "transparent"
                                                border.width: 1
                                                border.color: copyBtn.hovered
                                                    ? copyBtn.copied
                                                        ? Lib.Colors.primary
                                                        : Lib.Colors.outlineVariant
                                                    : "transparent"
                                            }

                                            onClicked: {
                                                // Copy both main text and subtext if present
                                                var textToCopy = modelData.text
                                                if (modelData.subtext && modelData.subtext.trim() !== "") {
                                                    textToCopy += "\n\n" + modelData.subtext
                                                }
                                                Notes.copy(textToCopy)
                                                copyBtn.copied = true
                                                copyTimer.start()
                                            }

                                            Timer {
                                                id: copyTimer
                                                interval: 1500
                                                onTriggered: copyBtn.copied = false
                                            }

                                            ToolTip {
                                                text: copyBtn.copied ? "Copied!" : "Copy to clipboard"
                                                delay: 300
                                                visible: parent.hovered
                                                background: Card {
                                                    radius: 6
                                                    color: Lib.Colors.surfaceContainerHighest
                                                }
                                            }
                                        }

                                        Button {
                                            id: deleteBtn
                                            Layout.preferredWidth: 32
                                            Layout.preferredHeight: 32
                                            flat: true
                                            opacity: noteMouseArea.containsMouse ? 1 : 0.4

                                            contentItem: StyledText {
                                                text: "🗑"
                                                font.pixelSize: 16
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }

                                            background: Rectangle {
                                                radius: 16
                                                color: deleteBtn.hovered
                                                    ? Lib.Colors.errorContainer
                                                    : "transparent"
                                                border.width: 1
                                                border.color: deleteBtn.hovered
                                                    ? Lib.Colors.error
                                                    : "transparent"
                                            }

                                            onClicked: {
                                                var index = Notes.findNoteIndex(modelData.id)
                                                if (index !== -1) {
                                                    Notes.remove(index)
                                                }
                                            }

                                            ToolTip {
                                                text: "Delete note"
                                                delay: 300
                                                visible: parent.hovered
                                                background: Card {
                                                    radius: 6
                                                    color: Lib.Colors.surfaceContainerHighest
                                                }
                                            }
                                        }
                                    }
                                }

                                function saveEdit() {
                                    if (!editLoader.active) return

                                    var mainText = editLoader.item.mainInput.text.trim()
                                    if (mainText.length === 0) return

                                    var subText = editLoader.item.subtextInput.text

                                    var index = Notes.findNoteIndex(originalNote.id)
                                    if (index !== -1) {
                                        Notes.updateNote(
                                            index,
                                            mainText,
                                            subText,
                                            originalNote.category
                                        )
                                    }
                                    isEditing = false
                                }
                            }
                        }
                    }
                }
            }

            // Input area with main text and subtext fields
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                radius: 20
                color: Lib.Colors.surfaceContainerHigh
                border.color: (mainInput.activeFocus || subtextInput.activeFocus)
                    ? Lib.Colors.primary
                    : Lib.Colors.outlineVariant
                border.width: 2

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: "transparent"
                    border.width: 1
                    border.color: Qt.rgba(0, 0, 0, 0.1)
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    // Main text input (required)
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        TextField {
                            id: mainInput
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            placeholderText: "Main text (required)..."
                            font.pixelSize: 14
                            placeholderTextColor: Lib.Colors.onSurfaceVariant
                            color: Lib.Colors.onSurface
                            background: Rectangle {
                                color: "transparent"
                                border.width: 0
                            }

                            onAccepted: addNote()
                        }

                        // Character count for main text
                        StyledText {
                            text: mainInput.text.length + "/200"
                            color: mainInput.text.length > 200
                                ? Lib.Colors.error
                                : Lib.Colors.onSurfaceVariant
                            font.pixelSize: 11
                            visible: mainInput.text.length > 0
                        }
                    }

                    // Subtext input (optional)
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        TextField {
                            id: subtextInput
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            placeholderText: "Subtext (optional details)..."
                            font.pixelSize: 13
                            placeholderTextColor: Lib.Colors.onSurfaceVariant
                            color: Lib.Colors.onSurfaceVariant
                            background: Rectangle {
                                color: "transparent"
                                border.width: 0
                                border.color: "transparent"
                            }

                            onAccepted: addNote()
                        }

                        // Character count for subtext
                        StyledText {
                            text: subtextInput.text.length + "/500"
                            color: subtextInput.text.length > 500
                                ? Lib.Colors.error
                                : Lib.Colors.onSurfaceVariant
                            font.pixelSize: 11
                            visible: subtextInput.text.length > 0
                        }
                    }

                    // Send button row
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignRight
                        Layout.topMargin: 10
                        spacing: 8

                        // Clear button
                        Button {
                            Layout.preferredWidth: 60
                            Layout.preferredHeight: 32
                            visible: mainInput.text.length > 0 || subtextInput.text.length > 0

                            contentItem: StyledText {
                                text: "Clear"
                                font.pixelSize: 12
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                color: Lib.Colors.onSurfaceVariant
                            }

                            background: Card {
                                color: parent.hovered
                                    ? Lib.Colors.surfaceContainerHighest
                                    : "transparent"
                            }

                            onClicked: {
                                mainInput.text = ""
                                subtextInput.text = ""
                            }
                        }

                        Button {
                            id: sendButton
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 32
                            enabled: mainInput.text.trim().length > 0 && mainInput.text.length <= 200
                            opacity: enabled ? 1 : 0.4

                            contentItem: StyledText {
                                text: "Add Note ↑"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                color: Lib.Colors.onPrimary
                            }

                            background: Rectangle {
                                radius: 16
                                color: sendButton.hovered && sendButton.enabled
                                    ? Qt.darker(Lib.Colors.primaryContainer, 1.2)
                                    : Lib.Colors.primaryContainer

                                Rectangle {
                                    anchors.fill: parent
                                    radius: parent.radius
                                    color: "transparent"
                                    border.width: 2
                                    border.color: Lib.Colors.primary
                                    opacity: 0.3
                                }

                                Behavior on color {
                                    ColorAnimation { duration: 200 }
                                }
                            }

                            onClicked: addNote()
                        }
                    }
                }
            }
        }
    }

    // Function to add note with main text and subtext
    function addNote() {
        if (mainInput.text.trim().length === 0) return
        if (mainInput.text.length > 200) return
        if (subtextInput.text.length > 500) return

        Notes.add(mainInput.text, Notes.currentCategory, subtextInput.text)
        mainInput.text = ""
        subtextInput.text = ""
    }

    // A peek (opened on hover) stays while it's in use.
    // Hover and presses, for NotesWindow's peek
    signal peekHover(bool hovered)
    signal peekPressed()
    PeekWatch {
        target: "notes"
        onPeekHover: hovered => root.peekHover(hovered)
        onPeekPressed: root.peekPressed()
    }

    CreateCategory{
        id: categoryDialog
    }

    ConfigureCategory{
        id: commandDialog
    }
}