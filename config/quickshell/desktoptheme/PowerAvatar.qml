import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io

// Your picture (lib/usersettings.json's profileImageOverride, or
// profile.jpg), cut to a rounded square (a circle
// by default). A plain wash stands in until it loads, or if there is none.
Item {
    id: avatar

    property real radius: width / 2
    property color placeholder: Qt.rgba(1, 1, 1, 0.12)
    readonly property bool ready: img.status === Image.Ready

    property string _picture: ""

    FileView {
        path: Quickshell.env("HOME") + "/.config/quickshell/lib/usersettings.json"
        printErrors: false
        onLoaded: {
            let p = "";
            try {
                p = JSON.parse(text()).profileImageOverride || "";
            } catch (e) {}
            avatar._picture = p ? p.replace(/^~/, Quickshell.env("HOME")) : Quickshell.env("HOME") + "/.config/quickshell/profile.jpg";
        }
        onLoadFailed: avatar._picture = Quickshell.env("HOME") + "/.config/quickshell/profile.jpg"
    }

    Rectangle {
        id: mask
        anchors.fill: parent
        radius: avatar.radius
        visible: false
        layer.enabled: true
    }

    Image {
        id: img
        anchors.fill: parent
        source: avatar._picture ? "file://" + avatar._picture : ""
        sourceSize: Qt.size(avatar.width * 2, avatar.height * 2)
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        visible: false
    }

    MultiEffect {
        anchors.fill: parent
        source: img
        visible: avatar.ready
        maskEnabled: true
        maskSource: mask
        maskThresholdMin: 0.5
        maskSpreadAtMin: 1.0
    }

    Rectangle {
        anchors.fill: parent
        visible: !avatar.ready
        radius: avatar.radius
        color: avatar.placeholder
    }
}
