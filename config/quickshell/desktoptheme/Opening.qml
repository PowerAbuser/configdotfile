pragma Singleton
import QtQuick
import Quickshell

// Stand-in for dhrruvsharma/shell's services/Opening.qml. Upstream, a bar
// pill's `opens` names a panel to open on click or hover. This shell's bar
// handles its own clicks (TopBar), so these just pass the click on.
Singleton {
    signal requested(string target)
    function clicked(target, arg) { requested(target) }
    function entered(target, arg) {}
    function left(target) {}
}
