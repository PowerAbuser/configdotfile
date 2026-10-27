pragma ComponentBehavior: Bound
import QtQuick
import Quickshell

// The desktop widgets (after dhrruvsharma/shell's modules/desktopwidgets):
// the clock, the music player and the system monitor, each in its own
// surface on the Bottom layer (WidgetWindow), dragged into place with the
// mouse. Each follows the desktop theme; with none on, the plain look.
// Which are on, where and on which screen: DesktopWidgets.
Scope {
    WidgetWindow {
        widgetId: "clock"
        widget: Component { ClockWidget {} }
    }

    WidgetWindow {
        widgetId: "music"
        widget: Component { MusicWidget {} }
    }

    WidgetWindow {
        widgetId: "sysmon"
        widget: Component { SysmonWidget {} }
    }
}
