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

    Timer {
        interval: 100; running: true
        onTriggered: {
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
