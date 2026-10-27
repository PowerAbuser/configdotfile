import QtQuick
import QtQuick.Layouts
import "top" as Top

// Card set for the top bar: single column, in the order the original top-bar
// hub used. These are that hub's own cards, not the task-bar ones reflowed.
ColumnLayout {
    id: root

    required property QtObject theme
    property bool hubVisible: false
    property bool batteryActive: false

    signal closeRequested()
    signal batteryToggleRequested()
    signal batteryDismissed()
    signal wifiRequested()
    signal bluetoothRequested()
    signal themesRequested()

    property alias notifs: notifsCard

    spacing: theme.gapCard

    Top.ButtonsSlidersCard {
        id: buttons
        Layout.fillWidth: true
        active: root.hubVisible
        theme: root.theme
        onCloseRequested: root.closeRequested()
        onBatteryToggleRequested: root.batteryToggleRequested()
        onWifiRequested: root.wifiRequested()
        onBluetoothRequested: root.bluetoothRequested()
        onThemesRequested: root.themesRequested()
    }

    Top.BatteryHealthCard {
        id: battery
        Layout.fillWidth: true
        active: root.batteryActive
        theme: root.theme
        onActiveChanged: if (!active && !root.hubVisible) root.batteryDismissed()
    }

    Top.MediaCard {
        id: media
        Layout.fillWidth: true
        onCloseRequested: root.closeRequested()
    }

    Top.CalendarWeatherCard {
        Layout.fillWidth: true
        active: root.hubVisible
        theme: root.theme
        onCloseRequested: root.closeRequested()
    }

    Top.VitalsCard {
        Layout.fillWidth: true
        active: root.hubVisible
        theme: root.theme
    }

    Top.NotificationsCard {
        id: notifsCard
        Layout.fillWidth: true
        active: root.hubVisible
        compactMode: media.visible || battery.visible
        dndActive: buttons.dnd
        theme: root.theme
    }

    // The hub runs the full height of the screen: the power row sits at the
    // bottom, whatever the cards above take
    Item { Layout.fillHeight: true }

    Top.PowerRowCard {
        Layout.fillWidth: true
        theme: root.theme
        onCloseRequested: root.closeRequested()
    }
}
