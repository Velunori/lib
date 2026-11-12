//@ pragma OmarchyLoadPatch
import Quickshell
import QtQuick
import "../components"

ShellRoot {
    property int previews: 0
    property int applies: 0
    property int cancellations: 0
    property string failure: ""

    function check(condition, message) {
        if (!condition) failure += message + "; ";
    }

    SettingsWindow {
        id: settings
        onPreviewRequested: function(value) { previews++; check(value.style === "orbit", "preview style") }
        onApplyRequested: function(value) { applies++; check(value.accent === "mint", "applied accent") }
        onCancelRequested: cancellations++
    }

    // The workspace strip has a 28px natural height but its slot is 40px.
    // Exercise the real component at both sizes, including the wider slot.
    QtObject {
        id: clickHost
        property var targets: []
        property string lastCommand: ""
        property color urgent: "#c4aff1"
        property var appearance: ({motion: false})
        function registerClickTarget(target) {
            if (targets.indexOf(target) === -1) targets = targets.concat([target]);
        }
        function unregisterClickTarget(target) { targets = targets.filter(function(item) { return item !== target; }); }
        function run(command) { lastCommand = command; }
        function showTooltip(target, text) {}
        function hideTooltip(target) {}
    }
    Workspaces { id: workspaceStrip; width: 200; height: 40; bar: clickHost }

    QtObject {
        id: nightlight
        property bool enabled: false
        function setNightlight(value) { enabled = value; }
    }
    QtObject {
        id: notifications
        property bool doNotDisturb: false
        function setDoNotDisturb(value) { doNotDisturb = value; }
    }
    QtObject {
        id: idle
        property bool stayAwake: false
        function setIdleEnabled(value) { stayAwake = !value; }
    }
    QtObject {
        id: systemHost
        function firstPartyServiceFor(id) {
            if (id === "omarchy.nightlight") return nightlight;
            if (id === "omarchy.notifications") return notifications;
            if (id === "omarchy.idle") return idle;
            return null;
        }
    }
    property var systemCommand: []
    SystemControls { id: systemControls; shell: systemHost; onCommandRequested: function(argv) { systemCommand = argv; } }
    QtObject {
        id: audioBackend
        property bool hasOutput: true
        property real outputVolume: 0.4
        property bool outputMuted: false
        property int writes: 0
        function setOutputVolume(value) { outputVolume = value; writes++; }
        function toggleOutputMute() { outputMuted = !outputMuted; }
    }
    AudioControls { id: audioControls; width: 400; backend: audioBackend }
    QtObject {
        id: monitorBackend
        property var displays: [{name: "DP-1", enabled: true, width: 1920, height: 1080}, {name: "DP-2", enabled: true, width: 1920, height: 1080}]
        property int enabledDisplayCount: 2
        property string toggled: ""
        function refresh() {}
        function toggleDisplay(name, enabled) { toggled = name; }
    }
    DisplayControls { id: displayControls; width: 400; backend: monitorBackend; preferredMonitor: "DP-2" }

    Timer {
        interval: 100; running: true
        onTriggered: {
            check(audioBackend.writes === 0, "audio binding does not change system volume");
            audioControls.setVolume(1.5);
            check(audioBackend.outputVolume === 1, "audio volume clamped");
            audioControls.toggleMute();
            check(audioBackend.outputMuted, "audio mute action");
            audioBackend.hasOutput = false;
            audioControls.setVolume(0);
            check(audioBackend.outputVolume === 1, "unavailable output cannot be changed");
            check(displayControls.selectedMonitor === "DP-2", "monitor defaults to panel's screen");
            displayControls.toggleSelectedDisplay();
            check(monitorBackend.toggled === "DP-2", "monitor action targets selection");
            monitorBackend.toggled = "";
            monitorBackend.enabledDisplayCount = 1;
            displayControls.toggleSelectedDisplay();
            check(monitorBackend.toggled === "", "last enabled display cannot be disabled");
            systemControls.execute("nightlight");
            systemControls.execute("dnd");
            systemControls.execute("awake");
            check(nightlight.enabled && notifications.doNotDisturb && idle.stayAwake, "system toggles enabled");
            check(systemControls.entries[0].state === "On", "system status follows service");
            systemControls.execute("nightlight");
            systemControls.execute("dnd");
            systemControls.execute("awake");
            check(!nightlight.enabled && !notifications.doNotDisturb && !idle.stayAwake, "system toggles disabled");
            systemControls.execute("recording");
            check(systemCommand[0] === "omarchy-menu", "start recording action");
            systemControls.recording = true;
            systemControls.execute("recording");
            check(systemCommand[1] === "--stop-recording", "stop recording action");
            systemControls.execute("reminders");
            check(systemCommand[1] === "-i", "create reminder action");
            systemControls.reminderCount = 2;
            systemControls.execute("reminders");
            check(systemCommand[1] === "show", "view reminders action");
            systemControls.execute("dictation");
            check(systemCommand[0] === "omarchy-voxtype-config", "dictation settings action");
            var row = workspaceStrip.children[0];
            check(Math.abs(row.y + row.height / 2 - workspaceStrip.height / 2) < 0.01, "workspace vertical alignment at 40px");
            workspaceStrip.height = 48;
            check(Math.abs(row.y + row.height / 2 - workspaceStrip.height / 2) < 0.01, "workspace vertical alignment at 48px");
            var second = clickHost.targets.filter(function(target) { return target.modelData === 2; })[0];
            check(second !== undefined, "workspace 2 registered for forwarded clicks");
            if (second) second.triggerPress(Qt.LeftButton);
            check(clickHost.lastCommand.indexOf('workspace = "2"') !== -1, "forwarded click dispatches workspace 2");
            workspaceStrip.bar = null;
            check(clickHost.targets.length === 0, "workspace click targets unregistered");
            settings.open({style: "island", accent: "mint", motion: false});
            settings.choose("style", "orbit");
            check(settings.draft.style === "orbit", "selected card");
            check(settings.draft.motion === false, "motion preserved");
            settings.applyRequested(settings.draft);
            settings.visible = false;
            settings.open({style: "island", accent: "pearl", motion: true});
            check(settings.draft.style === "island", "reopen resets draft");
            check(settings.draft.accent === "pearl", "reopen resets accent");
            settings.visible = false;
            check(previews === 1 && applies === 1 && cancellations >= 2, "lifecycle events");
            console.log(failure ? "SETTINGS_TEST_FAILED: " + failure : "SETTINGS_TEST_PASSED");
            Qt.quit();
        }
    }
}
