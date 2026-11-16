//@ pragma OmarchyLoadPatch
import QtQuick
import Quickshell
import "kit" as V

ShellRoot {
    id: test
    property string failure: ""
    function check(value, message) { if (!value) failure += message + "; "; }
    V.Theme { id: defaultTheme }
    V.AppearanceEditor { id: editor; width: 520 }
    QtObject {
        id: night
        property bool enabled: false
        function setNightlight(value) { enabled = value }
    }
    QtObject {
        id: notification
        property bool doNotDisturb: false
        function setDoNotDisturb(value) { doNotDisturb = value }
    }
    QtObject {
        id: idle
        property bool stayAwake: false
        function setIdleEnabled(value) { stayAwake = !value }
    }
    QtObject {
        id: stockHost
        property var barConfig: ({velunori: {accent: "mint", motion: false, style: "orbit"}})
        function firstPartyServiceFor(id) {
            if (id === "omarchy.nightlight") return night
            if (id === "omarchy.notifications") return notification
            if (id === "omarchy.idle") return idle
            return null
        }
    }
    QtObject { id: stockBar; property var shell: stockHost }
    V.Theme { id: stockTheme; bar: stockBar }
    V.DesktopBridge { id: bridge; bar: stockBar }
    V.DesktopBridge { id: absent }
    Timer {
        interval: 150; running: true
        onTriggered: {
            test.check(defaultTheme.apiVersion === 1, "library API available without a bar")
            test.check(defaultTheme.accentName === "lavender", "default palette without a bar")
            editor.choose("accent", "mint")
            test.check(editor.draft.accent === "mint", "shared appearance editor")
            test.check(stockTheme.accentName === "mint" && stockTheme.motion === false, "stock bar reads saved styling without a bar plugin")
            test.check(bridge.state.nightlightAvailable, "stock bar scoped service")
            test.check(bridge.setToggle("nightlight", true) && night.enabled, "night light bridge")
            test.check(bridge.setToggle("dnd", true) && notification.doNotDisturb, "notification bridge")
            test.check(bridge.setToggle("stayAwake", true) && idle.stayAwake, "idle bridge")
            test.check(!bridge.setToggle("unexpected", true), "unknown action refused")
            test.check(!absent.state.dndAvailable && !absent.setToggle("dnd", true), "missing capability fails closed")
            if (test.failure) console.error("LIBRARY_TEST_FAILED: " + test.failure)
            else console.log("LIBRARY_TEST_PASSED")
            Qt.quit()
        }
    }
}
