import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    visible: false
    property string accent: "lavender"
    property string errorText: ""
    property bool requested: false
    function schedule() { requested = true; debounce.restart(); }
    function drain() {
        if (!requested || worker.running) return;
        requested = false;
        worker.requestAccent = accent;
        worker.result = "";
        worker.running = true;
    }
    onAccentChanged: schedule()
    Component.onCompleted: schedule()
    FileView {
        path: Quickshell.env("HOME") + "/.local/state/omarchy/current/theme.name"
        watchChanges: true; printErrors: false
        onFileChanged: reload()
        onLoaded: root.schedule()
    }
    Timer { id: debounce; interval: 400; onTriggered: root.drain() }
    Process {
        id: worker
        property string requestAccent: ""
        property string result: ""
        command: ["python3", decodeURIComponent(Qt.resolvedUrl("scripts/browser-accent.py").toString().replace(/^(file|qs):\/\//, ""))]
        stdinEnabled: true
        onStarted: write(JSON.stringify({accent: requestAccent}) + "\n")
        stdout: StdioCollector { onStreamFinished: worker.result = text }
        onExited: function(exitCode) {
            try {
                var reply = JSON.parse(result);
                root.errorText = reply.ok && exitCode === 0 ? "" : reply.error || "Could not synchronize the Chromium accent.";
            } catch (error) { root.errorText = "Could not synchronize the Chromium accent."; }
            Qt.callLater(root.drain);
        }
    }
}
