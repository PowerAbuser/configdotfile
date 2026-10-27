import QtQuick

QtObject {
    id: root

    // Follows the shared state by default; assign to pin an instance to one mode
    property bool isDarkMode: ThemeState.isDarkMode
    function toggle() { ThemeState.toggle() }

    // Surfaces
    function _elevate(delta) {
        var h = bgMain.hsvHue < 0 ? 0 : bgMain.hsvHue
        var v = bgMain.hsvValue + (isDarkMode ? delta : -delta)
        return Qt.hsva(h, bgMain.hsvSaturation, Math.max(0, Math.min(1, v)), bgMain.a)
    }

    // Colours come from the wallpaper (Colors: matugen's scheme, Catppuccin
    // until one exists). Settings > custom accent / background still win.
    readonly property color bgMain: Configuration.useCustomBg
        ? (isDarkMode ? Configuration.customBgDark : Configuration.customBgLight)
        : Colors.surfaceContainerLowest
    readonly property color bgCard: Configuration.useCustomBg
        ? _elevate(0.051)
        : Colors.surfaceContainer
    readonly property color bgItem: Configuration.useCustomBg
        ? _elevate(isDarkMode ? 0.133 : 0.095)
        : Colors.surfaceContainerHighest
    readonly property color bgItemHover: Configuration.useCustomBg
        ? _elevate(isDarkMode ? 0.173 : 0.122)
        : Colors.surfaceBright
    readonly property color bgWidget: bgCard

    // Text
    readonly property color textPrimary:   Colors.fgSurface
    readonly property color textSecondary: Colors.fgSurfaceVariant
    readonly property color textOnAccent:  Colors.fgPrimary

    // Accents
    readonly property color customAccent:
        isDarkMode ? Configuration.customAccentDark : Configuration.customAccentLight
    readonly property color accent: Configuration.useCustomAccent
        ? customAccent
        : Colors.primary
    readonly property color accentBlue: Configuration.useCustomAccent
        ? customAccent
        : Colors.secondary
    readonly property color accentRed:     Colors.error
    readonly property color accentSlider:  Colors.primary
    readonly property color accentSlider2: Colors.tertiary

    // Lines and hovers
    readonly property color border:          Colors.alpha(Colors.primary, isDarkMode ? 0.44 : 0.25)
    readonly property color outline:         Colors.alpha(Colors.outlineVariant, 0.6)
    readonly property color subtleFill:      isDarkMode ? Qt.rgba(1,1,1,0.05) : Qt.rgba(0,0,0,0.05)
    readonly property color subtleFillHover: isDarkMode ? Qt.rgba(1,1,1,0.15) : Qt.rgba(0,0,0,0.10)
    readonly property color hoverSpotlight:  isDarkMode ? Qt.rgba(1,1,1,0.14) : Qt.rgba(0,0,0,0.10)

    // Sizing
    readonly property int radiusOuter: 12
    readonly property int radiusInner: 16
    readonly property int padCard:     12
    readonly property int gapCard:     10
    readonly property int btnH:        54
    readonly property int sliderH:     24

    // Used by the top-style calendar card
    readonly property color weatherColor: Colors.fgSurfaceVariant

    readonly property string textFont: "Manrope"
    readonly property string iconFont: "JetBrainsMono Nerd Font"
}
