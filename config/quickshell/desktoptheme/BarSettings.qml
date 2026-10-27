pragma Singleton
import QtQuick
import Quickshell

// Stand-in for dhrruvsharma/shell's services/BarSettings.qml: the bar's
// colours as their "Default" tone (pills on the wallpaper's container
// surface, the media pill on the background, on_surface text), without the
// customizer's tones, widths or hidden widgets.
Singleton {
    readonly property real fillOpacity: 0.88
    readonly property color fill: Colors.surface_container
    readonly property color ink: Colors.on_surface
    readonly property color pill: Colors.withAlpha(fill, fillOpacity)
    readonly property color group: Colors.withAlpha(Colors.surface_container_high, fillOpacity)
    readonly property color capsule: Colors.withAlpha(Colors.background, fillOpacity)
    readonly property bool outline: false
    readonly property color outlineColor: Colors.withAlpha(ink, 0.3)
    readonly property color highlight: Colors.primary
    readonly property var autoWidths: ({ media: 200 })
    readonly property string overflow: "hover"
    readonly property int scrollPxPerSecond: 50

    function widthOf(id) { return 0 }
    function shown(id) { return true }
}
