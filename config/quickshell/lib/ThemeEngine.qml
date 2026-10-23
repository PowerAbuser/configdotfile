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

    readonly property color bgMain: Configuration.useCustomBg
        ? (isDarkMode ? Configuration.customBgDark : Configuration.customBgLight)
        : (isDarkMode ? "#11111b" : "#eff1f5")
    readonly property color bgCard: Configuration.useCustomBg
        ? _elevate(0.051)
        : (isDarkMode ? "#1e1e2e" : "#e6e9ef")
    readonly property color bgItem: Configuration.useCustomBg
        ? _elevate(isDarkMode ? 0.133 : 0.095)
        : (isDarkMode ? "#313244" : Qt.rgba(0, 0, 0, 0.05))
    readonly property color bgItemHover: Configuration.useCustomBg
        ? _elevate(isDarkMode ? 0.173 : 0.122)
        : (isDarkMode ? "#45475a" : Qt.rgba(0, 0, 0, 0.08))
    readonly property color bgWidget: bgCard

    // Text
    readonly property color textPrimary:   isDarkMode ? "#ddcdd6f4" : "#4c4f69"
    readonly property color textSecondary: isDarkMode ? "#a6adc8"   : "#6c6f85"
    readonly property color textOnAccent:  isDarkMode ? "#11111b"   : "#eff1f5"

    // Accents
    readonly property color customAccent:
        isDarkMode ? Configuration.customAccentDark : Configuration.customAccentLight
    readonly property color accent: Configuration.useCustomAccent
        ? customAccent
        : (isDarkMode ? "#99b4befe" : "#7287fd")
    readonly property color accentBlue: Configuration.useCustomAccent
        ? customAccent
        : "#89b4fa"
    readonly property color accentRed:     isDarkMode ? "#f38ba8" : "#d20f39"
    readonly property color accentSlider:  isDarkMode ? "#b4befe" : "#7287fd"
    readonly property color accentSlider2: isDarkMode ? "#fab387" : "#fe640b"

    // Lines and hovers
    readonly property color border:          isDarkMode ? "#70b4befe"          : "#407287fd"
    readonly property color outline:         isDarkMode ? Qt.rgba(1,1,1,0.10) : Qt.rgba(0,0,0,0.10)
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
    readonly property color weatherColor: isDarkMode ? "#a6adc8" : "#4c4f69"

    readonly property string textFont: "Manrope"
    readonly property string iconFont: "JetBrainsMono Nerd Font"
}
