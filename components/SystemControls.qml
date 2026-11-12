import QtQuick
import Quickshell.Io

Item {
    id: root
    visible: false
    property var shell: null
    property bool active: false
    property bool recording: false
    property int reminderCount: 0
    property string dictationState: "idle"
    readonly property var nightlight: shell ? shell.firstPartyServiceFor("omarchy.nightlight") : null
    readonly property var notifications: shell ? shell.firstPartyServiceFor("omarchy.notifications") : null
    readonly property var idle: shell ? shell.firstPartyServiceFor("omarchy.idle") : null
    readonly property var entries: [
        {id: "nightlight", title: "Night light", description: "Warmer display colors", state: nightlight ? (nightlight.enabled ? "On" : "Off") : "Unavailable", available: !!nightlight, enabled: !!nightlight && nightlight.enabled, action: "Toggle"},
        {id: "dnd", title: "Do not disturb", description: "Silence notification popups", state: notifications ? (notifications.doNotDisturb ? "On" : "Off") : "Unavailable", available: !!notifications, enabled: !!notifications && notifications.doNotDisturb, action: "Toggle"},
        {id: "awake", title: "Stay awake", description: "Pause idle lock and screensaver", state: idle ? (idle.stayAwake ? "On" : "Off") : "Unavailable", available: !!idle, enabled: !!idle && idle.stayAwake, action: "Toggle"},
        {id: "recording", title: "Screen recording", description: "Record your screen", state: recording ? "Recording" : "Not recording", available: true, enabled: recording, action: recording ? "Stop" : "Record"},
        {id: "reminders", title: "Reminders", description: "View or create a reminder", state: reminderCount > 0 ? reminderCount + " queued" : "No reminders", available: true, enabled: reminderCount > 0, action: reminderCount > 0 ? "View" : "Create"},
        {id: "dictation", title: "Dictation", description: "Configure voice typing", state: dictationState === "recording" ? "Listening" : dictationState === "transcribing" ? "Transcribing" : "Ready", available: true, enabled: dictationState === "recording", action: "Configure"}
    ]
    signal commandRequested(var argv)

    function execute(id) {
        if (id === "nightlight" && nightlight) nightlight.setNightlight(!nightlight.enabled);
        else if (id === "dnd" && notifications) notifications.setDoNotDisturb(!notifications.doNotDisturb);
        else if (id === "awake" && idle) idle.setIdleEnabled(idle.stayAwake);
        else if (id === "recording") commandRequested(recording
            ? ["omarchy-capture-screenrecording", "--stop-recording"]
            : ["omarchy-menu", "toggle", "trigger.capture.screenrecord"]);
        else if (id === "reminders") commandRequested(["omarchy-reminder", reminderCount > 0 ? "show" : "-i"]);
        else if (id === "dictation") commandRequested(["omarchy-voxtype-config"]);
    }
    function refresh() {
        if (!active) return;
        if (!recordingProbe.running) recordingProbe.running = true;
        if (!remindersProbe.running) remindersProbe.running = true;
    }
    onActiveChanged: if (active) refresh()
    Timer { interval: 3000; running: root.active; repeat: true; onTriggered: root.refresh() }
    Process {
        id: recordingProbe
        command: ["pgrep", "--quiet", "-f", "^gpu-screen-recorder"]
        onExited: function(exitCode) { root.recording = exitCode === 0; }
    }
    Process {
        id: remindersProbe
        command: ["omarchy-reminder", "show", "--json"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.reminderCount = Math.max(0, Number(JSON.parse(text).count) || 0); }
                catch (error) { root.reminderCount = 0; }
            }
        }
    }
    Process {
        running: root.active
        command: ["omarchy-voxtype-status"]
        stdout: SplitParser {
            onRead: function(line) {
                try { let data = JSON.parse(line); root.dictationState = String(data.alt || data.class || "idle"); }
                catch (error) { root.dictationState = "idle"; }
            }
        }
    }
}
