pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../lib" as Lib

// Stand-in for dhrruvsharma/shell's services/Scheme.qml: the matugen options
// a wallpaper is set with, so the swatch cards show the scheme it will give.
// Kind and contrast from Settings > Colour (palette.json), the mode from the
// hub's dark/light.
Singleton {
    id: root

    property string scheme: "scheme-tonal-spot"
    property real contrast: 0
    readonly property string mode: Lib.ThemeState.isDarkMode ? "dark" : "light"

    FileView {
        path: Qt.resolvedUrl("../palette.json").toString().replace("file://", "")
        watchChanges: true
        preload: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: {
            try {
                const p = JSON.parse(text())
                root.scheme = String(p.scheme || "scheme-tonal-spot")
                root.contrast = Number(p.contrast || 0)
            } catch (e) {}
        }
    }
}
