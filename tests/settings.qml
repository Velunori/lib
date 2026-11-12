//@ pragma OmarchyLoadPatch
import Quickshell
import QtQuick
import "../components"
import "../kit" as V
ShellRoot {
    property string failure: ""
    property int previews: 0
    function check(value, message) { if (!value) failure += message + "; "; }
    V.AppearanceEditor { id: editor; width: 520; onPreviewRequested: previews++ }
    QtObject {
        id: clickHost
        property var targets: []
        property string lastCommand: ""
        property color urgent: "#c4aff1"
        property var appearance: ({motion: false})
        function registerClickTarget(target) { if (targets.indexOf(target) === -1) targets = targets.concat([target]); }
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
            check(Math.abs(row.y + row.height / 2 - workspaceStrip.height / 2) < 0.01, "workspace alignment");
            var second = clickHost.targets.filter(function(target) { return target.modelData === 2; })[0];
            check(!!second, "registered workspace 2");
            if (second) second.triggerPress(Qt.LeftButton);
            check(clickHost.lastCommand.indexOf('workspace = "2"') !== -1, "workspace dispatch");
            workspaceStrip.bar = null;
            check(clickHost.targets.length === 0, "unregistered targets");
            editor.reset({style: "island", accent: "mint", motion: false});
            editor.choose("style", "orbit");
            check(editor.draft.style === "orbit" && !editor.draft.motion && previews === 1, "appearance preview");
            editor.reset({style: "island", accent: "pearl", motion: true});
            check(editor.draft.accent === "pearl" && editor.draft.style === "island", "appearance reset");
            console.log(failure ? "SETTINGS_TEST_FAILED: " + failure : "SETTINGS_TEST_PASSED");
            Qt.quit();
        }
    }
}
