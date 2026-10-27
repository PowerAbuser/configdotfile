pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// The wallpaper's colour scheme, as Material roles. utils/matugen-apply.sh
// has matugen write colors/Colors.json on every wallpaper and dark/light
// change; this watches it. Until it exists (or if it fails to parse) the
// roles fall back to Catppuccin Mocha / Latte, so the shell never goes blank.
//
// Most code should go through ThemeEngine (theme.bgCard, theme.accent, ...),
// which maps these roles onto the shell's own names.
Singleton {
    id: root

    readonly property string path: Qt.resolvedUrl("../colors/Colors.json").toString().replace("file://", "")

    // True once a generated scheme is loaded
    property bool ready: false
    property var _c: ({})

    readonly property bool _dark: ThemeState.isDarkMode
    function _pick(name, dark, light) {
        var v = root._c[name]
        return (typeof v === "string" && v.length > 0) ? v : (root._dark ? dark : light)
    }

    readonly property color surface:                 _pick("surface",                   "#1e1e2e", "#eff1f5")
    readonly property color surfaceDim:              _pick("surface_dim",               "#181825", "#e6e9ef")
    readonly property color surfaceBright:           _pick("surface_bright",            "#45475a", "#ffffff")
    readonly property color surfaceContainerLowest:  _pick("surface_container_lowest",  "#11111b", "#ffffff")
    readonly property color surfaceContainerLow:     _pick("surface_container_low",     "#181825", "#e6e9ef")
    readonly property color surfaceContainer:        _pick("surface_container",         "#1e1e2e", "#e6e9ef")
    readonly property color surfaceContainerHigh:    _pick("surface_container_high",    "#313244", "#dce0e8")
    readonly property color surfaceContainerHighest: _pick("surface_container_highest", "#45475a", "#ccd0da")
    readonly property color onSurface:               _pick("on_surface",                "#cdd6f4", "#4c4f69")
    readonly property color onSurfaceVariant:        _pick("on_surface_variant",        "#a6adc8", "#6c6f85")
    readonly property color outline:                 _pick("outline",                   "#7f849c", "#8c8fa1")
    readonly property color outlineVariant:          _pick("outline_variant",           "#45475a", "#ccd0da")

    readonly property color primary:                 _pick("primary",                   "#b4befe", "#7287fd")
    readonly property color onPrimary:               _pick("on_primary",                "#11111b", "#eff1f5")
    readonly property color primaryContainer:        _pick("primary_container",         "#45475a", "#ccd0da")
    readonly property color onPrimaryContainer:      _pick("on_primary_container",      "#b4befe", "#7287fd")
    readonly property color secondary:               _pick("secondary",                 "#89b4fa", "#1e66f5")
    readonly property color onSecondary:             _pick("on_secondary",              "#11111b", "#eff1f5")
    readonly property color secondaryContainer:      _pick("secondary_container",       "#313244", "#dce0e8")
    readonly property color onSecondaryContainer:    _pick("on_secondary_container",    "#cdd6f4", "#4c4f69")
    readonly property color tertiary:                _pick("tertiary",                  "#fab387", "#fe640b")
    readonly property color onTertiary:              _pick("on_tertiary",               "#11111b", "#eff1f5")
    readonly property color error:                   _pick("error",                     "#f38ba8", "#d20f39")
    readonly property color onError:                 _pick("on_error",                  "#11111b", "#eff1f5")

    // Semantic colours, blended toward the wallpaper (matugen custom_colors)
    readonly property color red:     _pick("red",     "#f38ba8", "#d20f39")
    readonly property color green:   _pick("green",   "#a6e3a1", "#40a02b")
    readonly property color yellow:  _pick("yellow",  "#f9e2af", "#df8e1d")
    readonly property color orange:  _pick("orange",  "#fab387", "#fe640b")
    readonly property color blue:    _pick("blue",    "#89b4fa", "#1e66f5")

    // `c` with its alpha replaced
    function alpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a) }

    FileView {
        id: file
        path: root.path
        watchChanges: true
        preload: true
        onFileChanged: reload()
        onLoaded: {
            try {
                root._c = JSON.parse(text())
                root.ready = true
            } catch (e) {
                console.warn("Colors: can't parse " + root.path + ": " + e)
            }
        }
        onLoadFailed: { root._c = ({}); root.ready = false }
    }
}
