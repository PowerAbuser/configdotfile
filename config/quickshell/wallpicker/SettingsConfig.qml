pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../lib" as Lib

// Stand-in for dhrruvsharma/shell's settings/SettingsConfig.qml: just the
// wallpaper picker's settings, kept in wallpicker.json next to shell.qml.
// The folder defaults to the hub's wallpaper folder; Wallhaven downloads go
// there too. No API key by default (it only unlocks NSFW results).
Singleton {
    id: root

    property alias wallpaperDir: adapter.wallpaperDir
    property alias wallpaperCommand: adapter.wallpaperCommand
    property alias wallpaperLivePreview: adapter.wallpaperLivePreview
    property alias wallpaperAnimateChoice: adapter.wallpaperAnimateChoice
    property alias sddmWallpaper: adapter.sddmWallpaper
    property alias wallhavenApiKey: adapter.wallhavenApiKey
    property alias wallhavenCategories: adapter.wallhavenCategories
    property alias wallhavenPurity: adapter.wallhavenPurity
    property alias wallhavenSorting: adapter.wallhavenSorting
    property alias wallhavenOrder: adapter.wallhavenOrder
    property alias wallhavenTopRange: adapter.wallhavenTopRange
    property alias wallhavenAtleast: adapter.wallhavenAtleast
    property alias wallhavenRatios: adapter.wallhavenRatios

    Timer { id: writeTimer; interval: 200; onTriggered: file.writeAdapter() }

    FileView {
        id: file
        path: Qt.resolvedUrl("../wallpicker.json").toString().replace("file://", "")
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onAdapterUpdated: writeTimer.restart()

        adapter: JsonAdapter {
            id: adapter
            property string wallpaperDir: Lib.Configuration.wallpaperDir
            // "" = utils/set-wallpaper.sh (awww + matugen)
            property string wallpaperCommand: ""
            property bool wallpaperLivePreview: false
            property bool wallpaperAnimateChoice: true
            // Also copy each wallpaper to the SDDM login screen
            // (set-current-wallpaper.sh reads this from wallpicker.json)
            property bool sddmWallpaper: false
            property string wallhavenApiKey: ""
            property string wallhavenCategories: "111"
            property string wallhavenPurity: "100"
            property string wallhavenSorting: "toplist"
            property string wallhavenOrder: "desc"
            property string wallhavenTopRange: "1M"
            property string wallhavenAtleast: ""
            property string wallhavenRatios: ""
        }
    }
}
