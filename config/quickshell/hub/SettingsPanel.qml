import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import "../lib" as Lib
import "../desktoptheme" as DT
import "../wallpicker" as WP

Item {
    id: root
    property QtObject theme: null
    property string profileImagePath: ""
    signal wallpaperRequested()
    signal toastRequested(string msg)
    implicitHeight: flickable.contentHeight + 4

    function hexToHsl(hex) {
        hex = String(hex).replace(/[^0-9a-fA-F]/g, '')
        if (hex.length !== 6) return {h:0,s:50,l:50}
        var r=parseInt(hex.slice(0,2),16)/255, g=parseInt(hex.slice(2,4),16)/255, b=parseInt(hex.slice(4,6),16)/255
        var mx=Math.max(r,g,b), mn=Math.min(r,g,b), h=0, s=0, l=(mx+mn)/2
        if (mx!==mn){var d=mx-mn;s=l>0.5?d/(2-mx-mn):d/(mx+mn);if(mx===r)h=((g-b)/d+(g<b?6:0))/6;else if(mx===g)h=((b-r)/d+2)/6;else h=((r-g)/d+4)/6}
        return {h:Math.round(h*360),s:Math.round(s*100),l:Math.round(l*100)}
    }
    function hslToHex(h,s,l){s/=100;l/=100;var a=s*Math.min(l,1-l);function f(n){var k=(n+h/30)%12,c=l-a*Math.max(Math.min(k-3,9-k,1),-1),v=Math.round(255*c);return(v<16?'0':'')+v.toString(16)}return '#'+f(0)+f(8)+f(4)}
    function validHex(s){return /^#[0-9a-fA-F]{6}$/.test(String(s))}
    function hex6(c){var s=String(c);return s.length===9 ? "#"+s.slice(3) : s}
    function _h2(v){var n=Math.round(Math.max(0,Math.min(1,v))*255);return (n<16?'0':'')+n.toString(16)}
    function flatHex(fg,bg){
        var a=fg.a
        return "#"+_h2(fg.r*a+bg.r*(1-a))+_h2(fg.g*a+bg.g*(1-a))+_h2(fg.b*a+bg.b*(1-a))
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: grid.implicitHeight
        contentWidth: width
        clip: true
        flickDeceleration: 160; maximumFlickVelocity: 1800; boundsBehavior: Flickable.StopAtBounds
        WheelHandler {
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: (ev) => {
                var base=wAnim.running?wAnim.to:flickable.contentY
                var step=Math.abs(ev.angleDelta.y)*1.1+24
                var newY=Math.max(0,Math.min(base+(ev.angleDelta.y>0?-step:step),Math.max(0,flickable.contentHeight-flickable.height)))
                wAnim.to=newY; wAnim.restart(); ev.accepted=true
            }
        }
        NumberAnimation { id: wAnim; target: flickable; property: "contentY"; duration: 520; easing.type: Easing.OutExpo }

        GridLayout {
            id: grid
            width: flickable.width
            columns: 2
            columnSpacing: 8
            rowSpacing: 8

            // 1. APPEARANCE
            SCard {
                label: "Appearance"
                Layout.columnSpan: 2; Layout.fillWidth: true

                RowLayout {
                    Layout.fillWidth: true; spacing: 10
                    SLabel { text: "Theme" }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        width: 84; height: 28; radius: 7
                        color: root.theme ? root.theme.bgItem : "#313244"
                        border.width: 1; border.color: root.theme ? root.theme.outline : "#333"
                        RowLayout {
                            anchors.fill: parent; anchors.margins: 3; spacing: 3
                            Rectangle {
                                Layout.fillWidth: true; Layout.fillHeight: true; radius: 5
                                color: root.theme && root.theme.isDarkMode ? root.theme.accent : "transparent"
                                Behavior on color { ColorAnimation { duration: 180 } }
                                Item {
                                    anchors.centerIn: parent; width: 18; height: 18
                                    Image { id: darkIcon; anchors.fill: parent; source: "../lib/darkmode.svg"; sourceSize: Qt.size(30,30); visible: false }
                                    ColorOverlay { anchors.fill: darkIcon; source: darkIcon
                                        color: root.theme && root.theme.isDarkMode ? root.theme.textOnAccent : root.theme ? root.theme.textSecondary : "#888"
                                        Behavior on color { ColorAnimation { duration: 180 } } }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true; Layout.fillHeight: true; radius: 5
                                color: root.theme && !root.theme.isDarkMode ? root.theme.accent : "transparent"
                                Behavior on color { ColorAnimation { duration: 180 } }
                                Item {
                                    anchors.centerIn: parent; width: 18; height: 18
                                    Image { id: lightIcon; anchors.fill: parent; source: "../lib/lightmode.svg"; sourceSize: Qt.size(28,28); visible: false }
                                    ColorOverlay { anchors.fill: lightIcon; source: lightIcon
                                        color: root.theme && !root.theme.isDarkMode ? root.theme.textOnAccent : root.theme ? root.theme.textSecondary : "#888"
                                        Behavior on color { ColorAnimation { duration: 180 } } }
                                }
                            }
                        }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (root.theme) root.theme.toggle() }
                    }
                }
                SDivider {}
                RowLayout {
                    Layout.fillWidth: true; spacing: 6
                    CPicker {
                        Layout.fillWidth: true; label: "Hub accent"
                        currentHex: root.theme ? root.flatHex(root.theme.accent, root.theme.bgMain) : "#b4befe"
                        onPicked: (hex) => Lib.Configuration.setCustomAccent(!root.theme || root.theme.isDarkMode, hex)
                    }
                    CPicker {
                        Layout.fillWidth: true; label: "Background"
                        currentHex: root.theme ? root.hex6(root.theme.bgMain) : "#11111b"
                        onPicked: (hex) => Lib.Configuration.setCustomBg(!root.theme || root.theme.isDarkMode, hex)
                    }
                    CPicker {
                        Layout.fillWidth: true; label: "Bar accent"
                        currentHex: Lib.Configuration.taskbarAccent !== "" ? Lib.Configuration.taskbarAccent : (root.theme ? root.hex6(root.theme.accent) : "#b4befe")
                        onPicked: (hex) => { Lib.Configuration.taskbarAccent=hex; Lib.Configuration.save() }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true; spacing: 8
                    SBtn { label: "Reset colors"
                        onTriggered: { Lib.Configuration.useCustomAccent=false; Lib.Configuration.useCustomBg=false; Lib.Configuration.taskbarAccent=""; Lib.Configuration.save() }
                    }
                    Item { Layout.fillWidth: true }
                    SBtn { label: " Wallpaper"; accent: true; onTriggered: root.wallpaperRequested() }
                }
            }

            //  1b. WINDOWS (after dhrruvsharma/shell's customizer, chapter IV)
            SCard {
                id: windowsCard
                label: "Windows"
                Layout.columnSpan: 2; Layout.fillWidth: true

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2; columnSpacing: 16; rowSpacing: 2
                    LookSlider { key: "gaps_in";  text: "Inner gaps";  unit: " px"; to: 20 }
                    LookSlider { key: "gaps_out"; text: "Outer gaps";  unit: " px"; to: 40 }
                    LookSlider { key: "border_size"; text: "Border"; unit: " px"; to: 6 }
                    LookSlider { key: "rounding"; text: "Corners";     unit: " px"; to: 24 }
                    LookSlider { key: "active_opacity";   text: "Focused opacity";   unit: "%"; from: 50; to: 100 }
                    LookSlider { key: "inactive_opacity"; text: "Unfocused opacity"; unit: "%"; from: 50; to: 100 }
                    LookSlider { key: "blur_size";   text: "Blur size";   to: 20; enabled: Lib.WindowLook.get("blur"); opacity: enabled ? 1 : 0.4 }
                    LookSlider { key: "blur_passes"; text: "Blur passes"; from: 1; to: 6; enabled: Lib.WindowLook.get("blur"); opacity: enabled ? 1 : 0.4 }
                    LookSlider { key: "shadow_range"; text: "Shadow"; unit: " px"; to: 40; enabled: Lib.WindowLook.get("shadow"); opacity: enabled ? 1 : 0.4 }
                }
                SDivider {}
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2; columnSpacing: 16; rowSpacing: 0
                    SToggle { label: "Blur";        checked: Lib.WindowLook.get("blur");         onToggled: (v) => Lib.WindowLook.set("blur", v) }
                    SToggle { label: "Shadows";     checked: Lib.WindowLook.get("shadow");       onToggled: (v) => Lib.WindowLook.set("shadow", v) }
                    SToggle { label: "Dim unfocused"; checked: Lib.WindowLook.get("dim_inactive"); onToggled: (v) => Lib.WindowLook.set("dim_inactive", v) }
                    SToggle { label: "Animations";  checked: Lib.WindowLook.get("animations");   onToggled: (v) => Lib.WindowLook.set("animations", v) }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Item { Layout.fillWidth: true }
                    SBtn { label: "Reset windows"; onTriggered: { Lib.WindowLook.resetAll(); root.toastRequested("Window settings reset") } }
                }
            }

            //  1c. COLOUR (matugen scheme; after dhrruvsharma/shell's customizer, chapter V)
            SCard {
                id: colourCard
                label: "Colour"
                Layout.columnSpan: 2; Layout.fillWidth: true

                // palette.json: { scheme, contrast }, read by utils/matugen-apply.sh
                property var palette: ({ scheme: "scheme-tonal-spot", contrast: 0 })
                property var swatches: ({})
                readonly property string utils: Qt.resolvedUrl("../utils/").toString().replace("file://", "")

                function setPalette(key, value) {
                    var p = Object.assign({}, colourCard.palette)
                    p[key] = value
                    colourCard.palette = p
                    paletteFile.setText(JSON.stringify(p) + "\n")
                    applyTimer.restart()
                }
                // Coalesces a contrast drag into one matugen run
                Timer {
                    id: applyTimer; interval: 350
                    onTriggered: Quickshell.execDetached([colourCard.utils + "matugen-apply.sh"])
                }

                FileView {
                    id: paletteFile
                    path: Qt.resolvedUrl("../palette.json").toString().replace("file://", "")
                    preload: true; printErrors: false
                    onLoaded: { try { colourCard.palette = Object.assign({ scheme: "scheme-tonal-spot", contrast: 0 }, JSON.parse(text())) } catch (e) {} }
                }
                // Swatches follow the wallpaper and mode: refresh when the scheme file changes
                Process {
                    id: swatchProc
                    command: [colourCard.utils + "scheme-swatches.sh"]
                    stdout: StdioCollector { onStreamFinished: { try { colourCard.swatches = JSON.parse(this.text) } catch (e) {} } }
                }
                Connections {
                    target: Lib.Colors
                    function onPrimaryChanged() { swatchProc.running = true }
                }
                Component.onCompleted: swatchProc.running = true

                SLabel { text: "Scheme from the wallpaper"; opacity: 0.8 }
                Flow {
                    Layout.fillWidth: true
                    spacing: 6
                    Repeater {
                        model: [
                            { id: "scheme-tonal-spot", name: "Tonal spot" }, { id: "scheme-content", name: "Content" },
                            { id: "scheme-expressive", name: "Expressive" }, { id: "scheme-fidelity", name: "Fidelity" },
                            { id: "scheme-fruit-salad", name: "Fruit salad" }, { id: "scheme-monochrome", name: "Monochrome" },
                            { id: "scheme-neutral", name: "Neutral" }, { id: "scheme-rainbow", name: "Rainbow" },
                            { id: "scheme-vibrant", name: "Vibrant" }
                        ]
                        Rectangle {
                            id: chip
                            required property var modelData
                            readonly property bool current: colourCard.palette.scheme === modelData.id
                            readonly property var sw: colourCard.swatches[modelData.id] || []
                            width: (grid.width - 20 - 12) / 3; height: 48; radius: 10
                            color: chipHov.hovered ? (root.theme ? root.theme.bgItemHover : "#45475a") : (root.theme ? root.theme.bgItem : "#313244")
                            border.width: chip.current ? 2 : 1
                            border.color: chip.current ? (root.theme ? root.theme.accent : "#b4befe") : (root.theme ? root.theme.outline : "#333")
                            Behavior on color { ColorAnimation { duration: 120 } }
                            HoverHandler { id: chipHov; cursorShape: Qt.PointingHandCursor }
                            TapHandler { onTapped: colourCard.setPalette("scheme", chip.modelData.id) }
                            Column {
                                anchors.centerIn: parent; spacing: 5
                                Row {
                                    anchors.horizontalCenter: parent.horizontalCenter; spacing: 3
                                    Repeater {
                                        model: chip.sw
                                        Rectangle { required property var modelData; width: 14; height: 14; radius: 7; color: modelData
                                            border.width: 1; border.color: Qt.rgba(1,1,1,0.12) }
                                    }
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: chip.modelData.name
                                    font.family: root.theme ? root.theme.textFont : ""; font.pixelSize: 11
                                    font.weight: chip.current ? 700 : 500
                                    color: root.theme ? root.theme.textPrimary : "#cdd6f4"
                                }
                            }
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    SLabel { text: "Contrast" }
                    Text {
                        text: (colourCard.palette.contrast > 0 ? "+" : "") + Number(colourCard.palette.contrast).toFixed(1)
                        font.family: "DM Mono"; font.pixelSize: 12
                        color: root.theme ? root.theme.textSecondary : "#888"
                    }
                }
                SSlider {
                    from: -10; to: 10
                    value: Math.round(Number(colourCard.palette.contrast) * 10)
                    onMoved: (v) => colourCard.setPalette("contrast", v / 10)
                }
            }

            //  1d. DESKTOP THEME (from dhrruvsharma/shell: window look + desktop layer)
            SCard {
                id: themeCard
                label: "Desktop theme"
                Layout.columnSpan: 2; Layout.fillWidth: true

                readonly property var cur: DT.DesktopTheme.current

                Text {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    text: themeCard.cur ? themeCard.cur.description
                        : "Off. Pick a theme to restyle windows and draw over the wallpaper, in the wallpaper's colours."
                    font.family: root.theme ? root.theme.textFont : ""; font.pixelSize: 12
                    color: root.theme ? root.theme.textSecondary : "#888"
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: 6
                    Repeater {
                        model: [{ id: "", name: "Off", tagline: "Your own look" }].concat(DT.DesktopTheme.themes)
                        Rectangle {
                            id: tc
                            required property var modelData
                            readonly property bool current: DT.DesktopTheme.theme === modelData.id
                            width: (grid.width - 20 - 12) / 3; height: 52; radius: 10
                            color: tcHov.hovered ? (root.theme ? root.theme.bgItemHover : "#45475a") : (root.theme ? root.theme.bgItem : "#313244")
                            border.width: tc.current ? 2 : 1
                            border.color: tc.current ? (root.theme ? root.theme.accent : "#b4befe") : (root.theme ? root.theme.outline : "#333")
                            Behavior on color { ColorAnimation { duration: 120 } }
                            HoverHandler { id: tcHov; cursorShape: Qt.PointingHandCursor }
                            TapHandler { onTapped: DT.DesktopTheme.setTheme(tc.modelData.id) }
                            RowLayout {
                                anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
                                spacing: 6
                                Column {
                                    spacing: 2
                                    visible: tc.modelData.id !== ""
                                    Rectangle { width: 10; height: 10; radius: 5; color: tc.modelData.id ? DT.DesktopTheme.accentOf(tc.modelData.id) : "transparent" }
                                    Rectangle { width: 10; height: 10; radius: 5; color: tc.modelData.id ? DT.DesktopTheme.accent2Of(tc.modelData.id) : "transparent" }
                                }
                                Column {
                                    Layout.fillWidth: true
                                    spacing: 1
                                    Text {
                                        width: parent.width; elide: Text.ElideRight
                                        text: tc.modelData.name
                                        font.family: root.theme ? root.theme.textFont : ""; font.pixelSize: 12
                                        font.weight: tc.current ? 700 : 600
                                        color: root.theme ? root.theme.textPrimary : "#cdd6f4"
                                    }
                                    Text {
                                        width: parent.width; elide: Text.ElideRight
                                        text: tc.modelData.tagline
                                        font.family: root.theme ? root.theme.textFont : ""; font.pixelSize: 10
                                        color: root.theme ? root.theme.textSecondary : "#888"
                                    }
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    enabled: DT.DesktopTheme.enabled
                    opacity: enabled ? 1 : 0.4
                    spacing: 6
                    SLabel { text: "Screen effect" }
                    Repeater {
                        model: [{ id: "off", name: "Off" }, { id: "subtle", name: "Subtle" }, { id: "strong", name: "Strong" }]
                        SBtn {
                            required property var modelData
                            label: modelData.name
                            accent: DT.DesktopTheme.screenEffect === modelData.id
                            onTriggered: DT.DesktopTheme.setScreenEffect(modelData.id)
                        }
                    }
                }
                Text {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    visible: themeCard.cur && DT.DesktopTheme.screenEffect !== "off"
                    text: themeCard.cur && themeCard.cur.effects ? (themeCard.cur.effects[DT.DesktopTheme.screenEffect] || "") + " (Night light takes over the screen while it's on.)" : ""
                    font.family: root.theme ? root.theme.textFont : ""; font.pixelSize: 11
                    color: root.theme ? root.theme.textSecondary : "#888"
                }

                SDivider {}
                SLabel { text: "Desktop widgets (drag them into place)" }
                GridLayout {
                    Layout.fillWidth: true
                    columns: 3; columnSpacing: 12; rowSpacing: 0
                    Repeater {
                        model: DT.DesktopWidgets.widgets
                        SToggle {
                            required property var modelData
                            label: modelData.name
                            checked: DT.DesktopWidgets.enabled(modelData.id)
                            onToggled: (v) => DT.DesktopWidgets.setEnabled(modelData.id, v)
                        }
                    }
                }
                Flow {
                    Layout.fillWidth: true
                    spacing: 6
                    SLabel { text: "On"; Layout.fillWidth: false; width: implicitWidth + 4 }
                    Repeater {
                        model: Quickshell.screens
                        SBtn {
                            required property var modelData
                            required property int index
                            label: modelData.name
                            accent: DT.DesktopWidgets.screenName === modelData.name
                                || (DT.DesktopWidgets.screenName === "" && index === 0)
                            onTriggered: DT.DesktopWidgets.setScreen(modelData.name)
                        }
                    }
                    SBtn { label: "Reset positions"; onTriggered: DT.DesktopWidgets.resetPositions() }
                }
            }

            //  1e. WALLPAPER: how it's drawn (utils/wallpaper-show.sh reads wallpaper.json)
            SCard {
                id: wallCard
                label: "Wallpaper"
                Layout.columnSpan: 2; Layout.fillWidth: true

                readonly property var defaults: ({ mode: "cover", gravity: "center", fill: "auto", filter: "Lanczos3",
                                                   transition: "grow", duration: 1, tileScale: 100 })
                property var cfg: defaults
                function val(k) { return cfg[k] !== undefined ? cfg[k] : defaults[k] }
                function setVal(k, v) {
                    var c = Object.assign({}, wallCard.cfg); c[k] = v; wallCard.cfg = c
                    wallFile.setText(JSON.stringify(c, null, 2) + "\n")
                    reshow.restart()
                }
                // Redraws the current wallpaper once the clicks settle
                Timer {
                    id: reshow; interval: 450
                    onTriggered: Quickshell.execDetached([Qt.resolvedUrl("../utils/wallpaper-show.sh").toString().replace("file://", "")])
                }
                FileView {
                    id: wallFile
                    path: Qt.resolvedUrl("../wallpaper.json").toString().replace("file://", "")
                    preload: true; printErrors: false
                    onLoaded: { try { wallCard.cfg = Object.assign({}, wallCard.defaults, JSON.parse(text())) } catch (e) {} }
                }

                component Choice: Flow {
                    id: ch
                    property string key: ""
                    property var options: []   // [{ id, name }]
                    Layout.fillWidth: true
                    spacing: 6
                    Repeater {
                        model: ch.options
                        SBtn {
                            required property var modelData
                            label: modelData.name
                            accent: String(wallCard.val(ch.key)) === String(modelData.id)
                            onTriggered: wallCard.setVal(ch.key, modelData.id)
                        }
                    }
                }

                SLabel { text: "Display" }
                Choice { key: "mode"; options: [
                    { id: "cover", name: "Cover" }, { id: "contain", name: "Contain" }, { id: "stretch", name: "Stretch" },
                    { id: "center", name: "Centre" }, { id: "tile", name: "Tile" } ] }
                Text {
                    Layout.fillWidth: true; wrapMode: Text.WordWrap
                    text: ({ cover: "Fills the screen; the edges that don't fit are cropped.",
                             contain: "The whole picture, as large as fits; the rest is filled.",
                             stretch: "Fills the screen, stretched out of proportion if need be.",
                             center: "At its own size, in the middle; the rest is filled.",
                             tile: "Repeated across the screen, like a pattern." })[wallCard.val("mode")] || ""
                    font.family: root.theme ? root.theme.textFont : ""; font.pixelSize: 11
                    color: root.theme ? root.theme.textSecondary : "#888"
                }

                ColumnLayout {
                    Layout.fillWidth: true; spacing: 6
                    visible: wallCard.val("mode") === "cover"
                    SLabel { text: "Crop from" }
                    Choice { key: "gravity"; options: [
                        { id: "center", name: "Centre" }, { id: "top", name: "Top" }, { id: "bottom", name: "Bottom" },
                        { id: "left", name: "Left" }, { id: "right", name: "Right" } ] }
                }

                ColumnLayout {
                    Layout.fillWidth: true; spacing: 2
                    visible: wallCard.val("mode") === "tile"
                    RowLayout {
                        Layout.fillWidth: true
                        SLabel { text: "Tile size" }
                        Text { text: wallCard.val("tileScale") + "%"; font.family: "DM Mono"; font.pixelSize: 12
                               color: root.theme ? root.theme.textSecondary : "#888" }
                    }
                    SSlider { from: 25; to: 200; value: wallCard.val("tileScale"); onMoved: (v) => wallCard.setVal("tileScale", v) }
                }

                ColumnLayout {
                    Layout.fillWidth: true; spacing: 6
                    visible: wallCard.val("mode") === "contain" || wallCard.val("mode") === "center"
                    SToggle {
                        label: "Fill with the wallpaper's own colour"
                        checked: wallCard.val("fill") === "auto"
                        onToggled: (v) => wallCard.setVal("fill", v ? "auto" : "#000000")
                    }
                    CPicker {
                        Layout.fillWidth: true
                        visible: wallCard.val("fill") !== "auto"
                        label: "Fill colour"
                        currentHex: wallCard.val("fill") !== "auto" ? wallCard.val("fill") : "#000000"
                        onPicked: (hex) => wallCard.setVal("fill", hex)
                    }
                }

                SDivider {}
                SLabel { text: "Scaling" }
                Choice { key: "filter"; options: [
                    { id: "Lanczos3", name: "Sharp" }, { id: "Mitchell", name: "Soft" }, { id: "Nearest", name: "Pixel art" } ] }

                SLabel { text: "Transition" }
                Choice { key: "transition"; options: [
                    { id: "grow", name: "Grow" }, { id: "wipe", name: "Wipe" }, { id: "fade", name: "Fade" },
                    { id: "outer", name: "Outer" }, { id: "wave", name: "Wave" }, { id: "random", name: "Random" },
                    { id: "none", name: "None" } ] }
                ColumnLayout {
                    Layout.fillWidth: true; spacing: 2
                    visible: wallCard.val("transition") !== "none"
                    RowLayout {
                        Layout.fillWidth: true
                        SLabel { text: "Duration" }
                        Text { text: Number(wallCard.val("duration")).toFixed(1) + " s"; font.family: "DM Mono"; font.pixelSize: 12
                               color: root.theme ? root.theme.textSecondary : "#888" }
                    }
                    SSlider { from: 2; to: 30; value: Math.round(Number(wallCard.val("duration")) * 10)
                              onMoved: (v) => wallCard.setVal("duration", v / 10) }
                }
            }

            //  1f. LOGIN SCREEN: SDDM's sddm-astronaut-theme. utils/sddm-preset.sh writes
            //      a preset into the theme's config, utils/sddm-wallpaper.sh its background;
            //      both files are made yours once by `sudo sddm/install.sh` in the repo.
            SCard {
                id: loginCard
                label: "Login screen"
                Layout.columnSpan: 2; Layout.fillWidth: true

                readonly property string themeDir: "/usr/share/sddm/themes/sddm-astronaut-theme"
                readonly property var presets: [
                    { id: "hud", name: "HUD", tagline: "Arcade HUD in your wallpaper's colours: Orbitron, sharp corners, centred." },
                    { id: "mainframe", name: "Mainframe", tagline: "Green phosphor on black, monospace, a login prompt on the left." },
                    { id: "neon-noir", name: "Neon Noir", tagline: "Pink and cyan neon on deep violet, the form on the right." },
                    { id: "sekiro", name: "Sekiro", tagline: "Ink black and blood red in Zen Old Mincho, the form on the left." },
                    { id: "still", name: "Still", tagline: "Quiet: the whole wallpaper blurred, a clock and a field." }
                ]
                // The preset in the theme's config, from its first line
                property string preset: ""
                // false until sddm/install.sh has made the config yours
                property bool ready: true
                property string error: ""
                function util(name) { return Qt.resolvedUrl("../utils/" + name).toString().replace("file://", "") }
                function apply(id) {
                    loginCard.error = ""
                    presetProc.exec([util("sddm-preset.sh"), id])
                }
                // Checked again whenever the card shows: install.sh may have run since
                function refresh() {
                    readyCheck.running = true
                    loginConf.reload()
                }
                onVisibleChanged: if (visible) refresh()

                FileView {
                    id: loginConf
                    path: loginCard.themeDir + "/Themes/qs-active.conf"
                    preload: true; watchChanges: true; printErrors: false
                    onFileChanged: reload()
                    onLoaded: { var m = text().match(/^# qs-preset=(\S+)/); loginCard.preset = m ? m[1] : "" }
                }
                Process {
                    id: readyCheck
                    running: true
                    command: ["test", "-w", loginConf.path]
                    onExited: (code) => loginCard.ready = code === 0
                }
                Process {
                    id: presetProc
                    stderr: StdioCollector { onStreamFinished: loginCard.error = text.trim() }
                    onExited: (code) => { if (code === 0) root.toastRequested("Login screen updated") }
                }

                Text {
                    Layout.fillWidth: true; wrapMode: Text.WordWrap
                    visible: !loginCard.ready
                    text: "Not set up yet. Run once in a terminal: sudo ~/repos/configdotfile/sddm/install.sh"
                    font.family: root.theme ? root.theme.textFont : ""; font.pixelSize: 12
                    color: root.theme ? root.theme.accentRed : "#f38ba8"
                }

                ColumnLayout {
                    Layout.fillWidth: true; spacing: 8
                    enabled: loginCard.ready
                    opacity: enabled ? 1 : 0.4

                    SLabel { text: "Style" }
                    Flow {
                        Layout.fillWidth: true
                        spacing: 6
                        Repeater {
                            model: loginCard.presets
                            SBtn {
                                required property var modelData
                                label: modelData.name
                                accent: loginCard.preset === modelData.id
                                onTriggered: loginCard.apply(modelData.id)
                            }
                        }
                    }
                    Text {
                        Layout.fillWidth: true; wrapMode: Text.WordWrap
                        text: loginCard.error || (loginCard.presets.find(p => p.id === loginCard.preset) || { tagline: "" }).tagline
                        font.family: root.theme ? root.theme.textFont : ""; font.pixelSize: 11
                        color: loginCard.error ? (root.theme ? root.theme.accentRed : "#f38ba8") : (root.theme ? root.theme.textSecondary : "#888")
                    }

                    SDivider {}
                    // Shared with the wallpaper picker's settings (wallpicker.json)
                    SToggle {
                        label: "Use the desktop wallpaper"
                        checked: WP.SettingsConfig.sddmWallpaper
                        onToggled: (v) => {
                            WP.SettingsConfig.sddmWallpaper = v
                            if (v)
                                Quickshell.execDetached(["sh", "-c", 'exec "$1" "$(readlink -f "$2")"', "sh", loginCard.util("sddm-wallpaper.sh"),
                                                         Quickshell.env("HOME") + "/.config/hypr/.cache/current_wallpaper.png"])
                        }
                    }
                    Text {
                        Layout.fillWidth: true; wrapMode: Text.WordWrap
                        text: WP.SettingsConfig.sddmWallpaper ? "Each wallpaper you set goes to the login screen too."
                            : "The login screen keeps the last wallpaper it was given."
                        font.family: root.theme ? root.theme.textFont : ""; font.pixelSize: 11
                        color: root.theme ? root.theme.textSecondary : "#888"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            Layout.fillWidth: true; wrapMode: Text.WordWrap
                            text: "Shows on the next login. Preview opens it in a window."
                            font.family: root.theme ? root.theme.textFont : ""; font.pixelSize: 11
                            color: root.theme ? root.theme.textSecondary : "#888"
                        }
                        SBtn { label: "Preview"; onTriggered: Quickshell.execDetached(["sddm-greeter-qt6", "--test-mode", "--theme", loginCard.themeDir]) }
                    }
                }
            }

            //  2. WEATHER API 
            SCard {
                label: "Weather API"
                Layout.fillWidth: true; Layout.fillHeight: true

                FileView { id: weatherConf; path: Quickshell.env("HOME")+"/.config/quickshell/weather_api.conf" }
                SField { id: apiKeyField; label: "API Key (OpenWeatherMap)"; isPassword: true; text: Lib.Configuration.weatherApiKey }
                SField { Layout.fillWidth: true; id: latField; label: "Latitude"; text: Lib.Configuration.weatherLat }
                SField { Layout.fillWidth: true; id: lonField; label: "Longitude"; text: Lib.Configuration.weatherLon }
                RowLayout {
                    Layout.fillWidth: true
                    Item { Layout.fillWidth: true }
                    SBtn { label: "Save & refresh"; accent: true
                        onTriggered: {
                            Lib.Configuration.weatherApiKey=apiKeyField.text.trim()
                            Lib.Configuration.weatherLat=latField.text.trim()
                            Lib.Configuration.weatherLon=lonField.text.trim()
                            Lib.Configuration.save()
                            weatherConf.setText('API_KEY="'+apiKeyField.text.trim()+'"\nLAT="'+latField.text.trim()+'"\nLON="'+lonField.text.trim()+'"\n')
                            Quickshell.execDetached(["rm","-f",Quickshell.env("HOME")+"/.config/quickshell/.cache/weather.json"])
                        }
                    }
                }
            }

            //  5. PROFILE
            SCard {
                label: "Profile"
                Layout.columnSpan: 2; Layout.fillWidth: true

                RowLayout {
                    Layout.fillWidth: true; spacing: 12
                    Rectangle {
                        width: 44; height: 44; radius: 8; clip: true
                        color: root.theme ? root.theme.bgItem : "#313244"
                        border.width: 1; border.color: root.theme ? root.theme.outline : "#333"
                        Image {
                            anchors.fill: parent
                            source: root.profileImagePath !== ""
                                ? (root.profileImagePath.startsWith("file://") ? root.profileImagePath : "file://"+root.profileImagePath)
                                : ""
                            fillMode: Image.PreserveAspectCrop; smooth: true; mipmap: true
                        }
                        Text { anchors.centerIn: parent; text: ""; font.family: root.theme ? root.theme.iconFont : ""; font.pixelSize: 20
                            color: root.theme ? root.theme.textSecondary : "#888"; opacity: 0.4
                            visible: root.profileImagePath === "" }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true; spacing: 3
                        Text { text: "Profile picture path"; font.family: root.theme ? root.theme.textFont : ""; font.pixelSize: 14
                            color: root.theme ? root.theme.textSecondary : "#888" }
                        Rectangle {
                            Layout.fillWidth: true; height: 30; radius: 7
                            color: root.theme ? root.theme.bgItem : "#313244"
                            border.width: 1; border.color: pfpIn.activeFocus ? (root.theme ? root.theme.accent : "#b4befe") : (root.theme ? root.theme.outline : "#333")
                            Behavior on border.color { ColorAnimation { duration: 150 } }
                            Text {
                                anchors { fill: parent; margins: 7 }
                                verticalAlignment: Text.AlignVCenter
                                text: "/path/to/photo.jpg"; font.family: root.theme ? root.theme.textFont : ""; font.pixelSize: 14
                                color: root.theme ? root.theme.textSecondary : "#888"; opacity: 0.45
                                visible: pfpIn.text === ""
                            }
                            TextInput {
                                id: pfpIn
                                anchors { fill: parent; margins: 7 }
                                verticalAlignment: Text.AlignVCenter
                                font.family: root.theme ? root.theme.textFont : ""; font.pixelSize: 14
                                color: root.theme ? root.theme.textPrimary : "#cdd6f4"; clip: true; selectByMouse: true
                                selectionColor: root.theme ? Qt.rgba(root.theme.accent.r,root.theme.accent.g,root.theme.accent.b,0.35) : "#40b4befe"
                                text: Lib.Configuration.profileImageOverride
                                onEditingFinished: { Lib.Configuration.profileImageOverride=text; Lib.Configuration.save() }
                            }
                        }
                    }
                }
            }

            Item { Layout.preferredHeight: 4; Layout.columnSpan: 2 }
        }
    }

    //  COMPONENT LIBRARY 

    // A Settings > Windows slider bound to one WindowLook key
    component LookSlider: ColumnLayout {
        id: ls
        property string key: ""
        property string text: ""
        property string unit: ""
        property int from: 0
        property int to: 20
        Layout.fillWidth: true
        spacing: 0
        RowLayout {
            Layout.fillWidth: true
            SLabel { text: ls.text }
            Text {
                text: Lib.WindowLook.get(ls.key) + ls.unit
                font.family: "DM Mono"; font.pixelSize: 12
                color: root.theme ? root.theme.textSecondary : "#888"
            }
        }
        SSlider {
            from: ls.from; to: ls.to
            value: Lib.WindowLook.get(ls.key)
            onMoved: (v) => Lib.WindowLook.set(ls.key, v)
        }
    }

    component SCard: Rectangle {
        id: sc
        default property alias items: scCol.data
        property string label: ""
        Layout.fillWidth: true
        color: root.theme ? root.theme.bgCard : "#1e1e2e"
        radius: root.theme ? root.theme.radiusOuter : 12
        border.width: 1
        border.color: scHov.hovered
            ? Qt.rgba(root.theme ? root.theme.accent.r : 0.46, root.theme ? root.theme.accent.g : 0.61, root.theme ? root.theme.accent.b : 0.38, 0.45)
            : (root.theme ? root.theme.outline : "#333")
        implicitHeight: scCol.implicitHeight + 20
        Behavior on color { ColorAnimation { duration: 200 } }
        Behavior on border.color { ColorAnimation { duration: 200 } }
        HoverHandler { id: scHov }

        ColumnLayout {
            id: scCol
            anchors { fill: parent; margins: 10 }
            spacing: 8
            Text {
                text: sc.label
                font.family: root.theme ? root.theme.textFont : ""; font.pixelSize: 16; font.weight: 600
                color: root.theme ? root.theme.accent : "#a6adc8"
                opacity: 0.8
                Layout.bottomMargin: 2
            }
        }
    }

    component SLabel: Text {
        font.family: root.theme ? root.theme.textFont : ""; font.pixelSize: 14
        color: root.theme ? root.theme.textPrimary : "#cdd6f4"; Layout.fillWidth: true
    }

    component SDivider: Rectangle {
        Layout.fillWidth: true; height: 1
        color: root.theme ? root.theme.outline : "#333"; opacity: 0.5
    }

    // Toggle row 
    component SToggle: Item {
        id: tog; property string label: ""; property bool checked: false
        signal toggled(bool v)
        Layout.fillWidth: true
        implicitHeight: togRow.implicitHeight + 10

        Rectangle {
            anchors { fill: parent; leftMargin: -4; rightMargin: -4 }
            radius: 8
            color: togHov.hovered
                ? (root.theme ? Qt.rgba(root.theme.accent.r, root.theme.accent.g, root.theme.accent.b, 0.08) : "#1e1e2e")
                : "transparent"
            Behavior on color { ColorAnimation { duration: 150 } }
        }
        HoverHandler { id: togHov; cursorShape: Qt.PointingHandCursor }

        RowLayout {
            id: togRow
            anchors { fill: parent; topMargin: 5; bottomMargin: 5 }
            spacing: 8
            Text {
                text: tog.label; font.family: root.theme ? root.theme.textFont : ""; font.pixelSize: 15
                color: root.theme ? root.theme.textPrimary : "#cdd6f4"; Layout.fillWidth: true
            }
            Item { Layout.fillWidth: true }
            Rectangle {
                width: 42; height: 24; radius: 12
                color: tog.checked ? (root.theme ? root.theme.accent : "#b4befe") : (root.theme ? root.theme.subtleFill : "#313244")
                Behavior on color { ColorAnimation { duration: 200 } }
                border.width: 1; border.color: root.theme ? root.theme.outline : "#333"
                Rectangle {
                    x: tog.checked ? parent.width-width-3 : 3; y: 3; width: 18; height: 18; radius: 9; color: "white"
                    Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: tog.toggled(!tog.checked) }
            }
        }
    }

    component SField: ColumnLayout {
        id: sf; property string label: ""; property alias text: sfIn.text; property bool isPassword: false
        Layout.fillWidth: true; spacing: 3
        Text { text: sf.label; font.family: root.theme ? root.theme.textFont : ""; font.pixelSize: 13
            color: root.theme ? root.theme.textSecondary : "#888" }
        Rectangle {
            Layout.fillWidth: true; height: 30; radius: 7
            color: sfIn.activeFocus
                ? (root.theme ? Qt.rgba(root.theme.accent.r, root.theme.accent.g, root.theme.accent.b, 0.07) : "#313244")
                : sfHov.hovered ? (root.theme ? root.theme.bgItemHover : "#45475a")
                : (root.theme ? root.theme.bgItem : "#313244")
            Behavior on color { ColorAnimation { duration: 150 } }
            border.width: 1; border.color: sfIn.activeFocus ? (root.theme ? root.theme.accent : "#b4befe")
                : sfHov.hovered ? Qt.rgba(root.theme ? root.theme.accent.r : 0.46, root.theme ? root.theme.accent.g : 0.61, root.theme ? root.theme.accent.b : 0.38, 0.35)
                : (root.theme ? root.theme.outline : "#333")
            Behavior on border.color { ColorAnimation { duration: 150 } }
            HoverHandler { id: sfHov }
            TextInput {
                id: sfIn
                anchors { fill: parent; margins: 7 }
                verticalAlignment: Text.AlignVCenter
                font.family: root.theme ? root.theme.textFont : ""; font.pixelSize: 13
                color: root.theme ? root.theme.textPrimary : "#cdd6f4"; clip: true; selectByMouse: true
                echoMode: sf.isPassword ? TextInput.Password : TextInput.Normal
                selectionColor: root.theme ? Qt.rgba(root.theme.accent.r,root.theme.accent.g,root.theme.accent.b,0.35) : "#40b4befe"
            }
        }
    }

    component SStepper: RowLayout {
        id: stp; property int value: 1; property int min: 1; property int max: 10
        signal stepped(int v)
        spacing: 4
        Rectangle {
            width: 26; height: 26; radius: 7
            color: dH.hovered ? (root.theme ? root.theme.subtleFillHover : "#45475a") : (root.theme ? root.theme.subtleFill : "#313244")
            Behavior on color { ColorAnimation { duration: 120 } }
            border.width: 1; border.color: root.theme ? root.theme.outline : "#333"
            Text { anchors.centerIn: parent; text: "−"; font.pixelSize: 15; color: root.theme ? root.theme.textPrimary : "#cdd6f4" }
            HoverHandler { id: dH; cursorShape: Qt.PointingHandCursor }
            TapHandler { onTapped: { if(stp.value>stp.min){stp.value--;stp.stepped(stp.value)} } }
        }
        Text { text: stp.value; font.family: root.theme ? root.theme.textFont : ""; font.pixelSize: 14; font.weight: 600
            color: root.theme ? root.theme.textPrimary : "#cdd6f4"; width: 22; horizontalAlignment: Text.AlignHCenter }
        Rectangle {
            width: 26; height: 26; radius: 7
            color: iH.hovered ? (root.theme ? root.theme.subtleFillHover : "#45475a") : (root.theme ? root.theme.subtleFill : "#313244")
            Behavior on color { ColorAnimation { duration: 120 } }
            border.width: 1; border.color: root.theme ? root.theme.outline : "#333"
            Text { anchors.centerIn: parent; text: "+"; font.pixelSize: 15; color: root.theme ? root.theme.textPrimary : "#cdd6f4" }
            HoverHandler { id: iH; cursorShape: Qt.PointingHandCursor }
            TapHandler { onTapped: { if(stp.value<stp.max){stp.value++;stp.stepped(stp.value)} } }
        }
    }

    component SSlider: Item {
        id: ssl; property int from: 1; property int to: 20; property int value: 7
        signal moved(int v)
        height: 28; Layout.fillWidth: true
        HoverHandler { id: slHov }
        Rectangle {
            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
            height: slHov.hovered ? 7 : 5; radius: 3
            color: root.theme ? root.theme.bgItem : "#313244"; border.width: 1; border.color: root.theme ? root.theme.outline : "#333"
            Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            Rectangle {
                width: (ssl.value-ssl.from)/Math.max(1,ssl.to-ssl.from)*parent.width
                height: parent.height; radius: parent.radius
                color: root.theme ? root.theme.accent : "#b4befe"
                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }
        Rectangle {
            x: (ssl.value-ssl.from)/Math.max(1,ssl.to-ssl.from)*(ssl.width-width)
            anchors.verticalCenter: parent.verticalCenter
            width: 18; height: 18; radius: 9; color: "white"
            border.width: 2
            border.color: sDrag.pressed ? (root.theme ? root.theme.accent : "#b4befe")
                        : slHov.hovered ? Qt.rgba(root.theme ? root.theme.accent.r : 0.46, root.theme ? root.theme.accent.g : 0.61, root.theme ? root.theme.accent.b : 0.38, 0.6)
                        : Qt.rgba(0,0,0,0.25)
            scale: sDrag.pressed ? 1.18 : (slHov.hovered ? 1.09 : 1.0)
            Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack; easing.overshoot: 1.3 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }
        }
        MouseArea {
            id: sDrag; anchors.fill: parent; anchors.margins: -5
            function go(mx) { var f=Math.max(0,Math.min(1,mx/ssl.width)); var v=Math.round(ssl.from+f*(ssl.to-ssl.from)); ssl.value=v; ssl.moved(v) }
            onPressed: (m)=>go(m.x); onPositionChanged: (m)=>go(m.x)
        }
    }

    component SBtn: Item {
        id: sb; property string label: ""; property bool accent: false
        signal triggered()
        implicitWidth: bTxt.implicitWidth+22; implicitHeight: 30
        scale: bMa.containsPress ? 0.91 : (bMa.containsMouse ? 1.04 : 1.0)
        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutBack; easing.overshoot: 1.4 } }
        Rectangle {
            anchors.fill: parent; radius: 8
            color: sb.accent
                ? (bMa.containsPress ? Qt.darker(root.theme ? root.theme.accent : "#b4befe", 1.08)
                    : bMa.containsMouse ? Qt.lighter(root.theme ? root.theme.accent : "#b4befe", 1.14)
                    : (root.theme ? root.theme.accent : "#b4befe"))
                : (bMa.containsPress ? (root.theme ? root.theme.bgItem : "#313244")
                    : bMa.containsMouse ? (root.theme ? root.theme.subtleFillHover : "#45475a")
                    : (root.theme ? root.theme.subtleFill : "#313244"))
            Behavior on color { ColorAnimation { duration: 100 } }
            border.width: 1
            border.color: sb.accent
                ? Qt.rgba(1,1,1, bMa.containsMouse ? 0.18 : 0.0)
                : (root.theme ? root.theme.outline : "#333")
            Behavior on border.color { ColorAnimation { duration: 120 } }
            Text { id: bTxt; anchors.centerIn: parent; text: sb.label
                font.family: root.theme ? root.theme.textFont : ""; font.pixelSize: 14
                color: sb.accent ? (root.theme ? root.theme.textOnAccent : "#11111b") : (root.theme ? root.theme.textPrimary : "#cdd6f4") }
        }
        MouseArea { id: bMa; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true; onClicked: sb.triggered() }
    }

    // Color picker: label + swatch + hex input, click swatch to expand H/S/L
    component CPicker: ColumnLayout {
        id: cp; property string label: ""; property string currentHex: "#b4befe"
        signal picked(string hex)
        Layout.fillWidth: true; spacing: 5

        property int  _h: 0; property int _s: 50; property int _l: 50
        property bool _open: false; property bool _lock: false; property bool _userEditing: false

        onCurrentHexChanged: {
            if (!_userEditing && !_lock && root.validHex(currentHex)) {
                _lock = true
                var hsl=root.hexToHsl(currentHex); _h=hsl.h; _s=hsl.s; _l=hsl.l
                hexIn.text=currentHex
                _lock = false
            }
        }
        // _userEditing guards against infinite loops when the user is typing a hex value, which triggers onCurrentHexChanged.
        Timer { id: editReset; interval: 300; onTriggered: cp._userEditing = false }
        function applyHex(hex) {
            if (_lock) return; _lock=true; _userEditing=true; editReset.restart()
            if (root.validHex(hex)) { hexIn.text=hex; var hsl=root.hexToHsl(hex); _h=hsl.h; _s=hsl.s; _l=hsl.l; cp.picked(hex) }
            _lock=false
        }
        function applyHsl() {
            if (_lock) return; _lock=true; _userEditing=true; editReset.restart()
            var hex=root.hslToHex(_h,_s,_l); hexIn.text=hex; cp.picked(hex); _lock=false
        }
        Component.onCompleted: {
            if (root.validHex(currentHex)) { var hsl=root.hexToHsl(currentHex); _h=hsl.h; _s=hsl.s; _l=hsl.l; hexIn.text=currentHex }
        }

        RowLayout {
            Layout.fillWidth: true; spacing: 6
            Text { text: cp.label; font.family: root.theme ? root.theme.textFont : ""; font.pixelSize: 14
                color: root.theme ? root.theme.textPrimary : "#cdd6f4"; Layout.fillWidth: true }
            Rectangle {
                width: 24; height: 24; radius: 6
                color: root.validHex(hexIn.text) ? hexIn.text : (root.theme ? root.theme.accent : "#b4befe")
                border.width: 2; border.color: cp._open ? (root.theme ? root.theme.accent : "#b4befe") : (root.theme ? root.theme.outline : "#333")
                Behavior on color { ColorAnimation { duration: 100 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: cp._open=!cp._open }
            }
            Rectangle {
                width: 82; height: 26; radius: 6
                color: root.theme ? root.theme.bgItem : "#313244"
                border.width: 1; border.color: hexIn.activeFocus ? (root.theme ? root.theme.accent : "#b4befe") : (root.theme ? root.theme.outline : "#333")
                Behavior on border.color { ColorAnimation { duration: 150 } }
                TextInput {
                    id: hexIn
                    anchors { fill: parent; margins: 5 }
                    verticalAlignment: Text.AlignVCenter
                    font.family: root.theme ? root.theme.textFont : ""; font.pixelSize: 12; font.letterSpacing: 0.5
                    color: root.theme ? root.theme.textPrimary : "#cdd6f4"; clip: true; selectByMouse: true
                    selectionColor: root.theme ? Qt.rgba(root.theme.accent.r,root.theme.accent.g,root.theme.accent.b,0.35) : "#40b4befe"
                    validator: RegularExpressionValidator { regularExpression: /^#?[0-9a-fA-F]{0,6}$/ }
                    onEditingFinished: { var h=text.startsWith('#')?text:'#'+text; cp.applyHex(h) }
                }
            }
        }
        Item {
            Layout.fillWidth: true
            implicitHeight: cp._open ? sliderCol.implicitHeight + 4 : 0
            clip: true
            Behavior on implicitHeight { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
            ColumnLayout {
                id: sliderCol; width: parent.width; spacing: 5
                CSlider { label: "H"; value: cp._h/360
                    c0:"#ff0000"; c1:"#ffff00"; c2:"#00ff00"; c3:"#00ffff"; c4:"#0000ff"; c5:"#ff00ff"; c6:"#ff0000"
                    onMv: (v)=>{cp._h=Math.round(v*360); cp.applyHsl()} }
                CSlider { label: "S"; value: cp._s/100
                    c0:Qt.hsla(cp._h/360,0,cp._l/100,1); c1:Qt.hsla(cp._h/360,0.17,cp._l/100,1)
                    c2:Qt.hsla(cp._h/360,0.33,cp._l/100,1); c3:Qt.hsla(cp._h/360,0.5,cp._l/100,1)
                    c4:Qt.hsla(cp._h/360,0.67,cp._l/100,1); c5:Qt.hsla(cp._h/360,0.83,cp._l/100,1)
                    c6:Qt.hsla(cp._h/360,1,cp._l/100,1)
                    onMv: (v)=>{cp._s=Math.round(v*100); cp.applyHsl()} }
                CSlider { label: "L"; value: cp._l/100
                    c0:"#000000"; c1:Qt.hsla(cp._h/360,cp._s/100,0.17,1)
                    c2:Qt.hsla(cp._h/360,cp._s/100,0.33,1); c3:Qt.hsla(cp._h/360,cp._s/100,0.5,1)
                    c4:Qt.hsla(cp._h/360,cp._s/100,0.67,1); c5:Qt.hsla(cp._h/360,cp._s/100,0.83,1)
                    c6:"#ffffff"
                    onMv: (v)=>{cp._l=Math.round(v*100); cp.applyHsl()} }
            }
        }
    }

    component CSlider: RowLayout {
        id: cs; property string label: ""; property real value: 0.5
        property color c0:"black"; property color c1:"black"; property color c2:"gray"
        property color c3:"gray";  property color c4:"gray";  property color c5:"white"; property color c6:"white"
        signal mv(real v)
        Layout.fillWidth: true; spacing: 5
        Text { text: cs.label; font.family: root.theme ? root.theme.textFont : ""; font.pixelSize: 10
            color: root.theme ? root.theme.textSecondary : "#888"; width: 10 }
        Item {
            Layout.fillWidth: true; height: 20
            Rectangle {
                id: csTk; anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                height: 8; radius: 4; border.width: 1; border.color: Qt.rgba(0,0,0,0.2)
                gradient: Gradient { orientation: Gradient.Horizontal
                    GradientStop { position: 0.000; color: cs.c0 }
                    GradientStop { position: 0.167; color: cs.c1 }
                    GradientStop { position: 0.333; color: cs.c2 }
                    GradientStop { position: 0.500; color: cs.c3 }
                    GradientStop { position: 0.667; color: cs.c4 }
                    GradientStop { position: 0.833; color: cs.c5 }
                    GradientStop { position: 1.000; color: cs.c6 }
                }
            }
            Rectangle {
                x: Math.max(0,Math.min(cs.value*(parent.width-width),parent.width-width))
                anchors.verticalCenter: parent.verticalCenter
                width: 16; height: 16; radius: 8; color: "white"
                border.width: 2; border.color: csDrag.pressed ? (root.theme ? root.theme.accent : "#b4befe") : Qt.rgba(0,0,0,0.3)
                scale: csDrag.pressed ? 1.12 : 1.0; Behavior on scale { NumberAnimation { duration: 100 } }
            }
            MouseArea { id: csDrag; anchors.fill: parent; anchors.margins: -4
                onPressed:        (m)=>cs.mv(Math.max(0,Math.min(1,m.x/csTk.width)))
                onPositionChanged:(m)=>cs.mv(Math.max(0,Math.min(1,m.x/csTk.width)))
            }
        }
    }
}
