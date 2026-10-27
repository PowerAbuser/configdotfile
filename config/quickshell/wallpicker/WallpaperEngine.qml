pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Stand-in for dhrruvsharma/shell's services/WallpaperEngine.qml, with the
// same API the picker calls. Here awww draws the wallpaper, not Quickshell,
// so the engine is always "external": set() runs utils/set-wallpaper.sh
// (awww, then set-current-wallpaper.sh, which also runs matugen), or the
// picker's own wallpaper command when one is set.
Singleton {
    id: root

    readonly property string dir: expandHome(SettingsConfig.wallpaperDir).replace(/\/+$/, "")
    readonly property string link: Quickshell.env("HOME") + "/.config/hypr/.cache/current_wallpaper.png"
    readonly property string command: SettingsConfig.wallpaperCommand.trim()
    readonly property bool external: true
    property string commandError: ""
    signal commandFinished(bool ok, string message)
    property string current: ""
    property int serial: 0
    property bool ready: false
    property string drawn: ""
    property string pickerCovers: ""
    signal changed(string path)

    function kind(path) {
        const p = String(path ?? "").toLowerCase();
        if (/\.(mp4|webm|mkv|mov|m4v)$/.test(p))
            return "video";
        if (/\.(gif|webp)$/.test(p))
            return "animated";
        return "image";
    }

    function expandHome(path) {
        const p = String(path ?? "").trim();
        if (p === "~" || p.startsWith("~/"))
            return Quickshell.env("HOME") + p.substring(1);
        return p;
    }

    function tildeHome(path) {
        const home = Quickshell.env("HOME");
        return path === home || path.startsWith(home + "/") ? "~" + path.substring(home.length) : path;
    }

    function resolve(path) {
        let p = expandHome(String(path ?? "").trim().replace(/^file:\/\//, ""));
        if (p.length > 0 && !p.startsWith("/"))
            p = dir + "/" + p;
        return p;
    }

    function set(path) {
        const p = resolve(path);
        if (!p)
            return;
        current = p;
        drawn = p;
        serial++;
        changed(p);
        runCommand(p);
    }

    // The picker's wallpaper command with {} as the file, or set-wallpaper.sh
    function runCommand(path) {
        if (!path)
            return;
        const argv = root.command !== ""
            ? ["sh", "-c", root.command.split("{}").join('"$1"') + (root.command.includes("{}") ? "" : ' "$1"'), "sh", path]
            : [Quickshell.shellPath("utils/set-wallpaper.sh"), path];
        run.exec(argv);
    }

    Process {
        id: run
        stderr: StdioCollector {
            onStreamFinished: {
                root.commandError = text.trim();
                if (root.commandError)
                    console.warn("wallpaper:", root.commandError);
            }
        }
        onExited: code => root.commandFinished(code === 0, root.commandError)
    }

    // The wallpaper on screen, from the hub's link
    Process {
        running: true
        command: ["readlink", "-f", root.link]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!root.current)
                    root.current = text.trim();
                root.ready = true;
            }
        }
    }
}
