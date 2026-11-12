pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: root
    property var backend: null
    property bool active: false
    property string preferredMonitor: ""
    property color accent: "#c4aff1"
    property string selectedMonitor: ""
    property bool brightnessAvailable: false
    property int brightness: 0
    property string errorText: ""
    property var pendingWrite: null
    readonly property var displays: backend ? backend.displays : []
    readonly property var names: (displays || []).map(function(display) { return display.name; })
    readonly property var selectedDisplay: {
        for (var display of displays) if (display.name === selectedMonitor) return display;
        return null;
    }
    signal advancedRequested()
    implicitHeight: body.implicitHeight + 28
    radius: 16; color: "#29292f"; border.color: "#48464f"
    function ensureSelection() {
        var values = names || [];
        if (values.indexOf(selectedMonitor) === -1)
            selectedMonitor = values.indexOf(preferredMonitor) !== -1 ? preferredMonitor : (values[0] || "");
    }
    function refresh() {
        if (!active || !backend) return;
        backend.refresh();
        if (selectedMonitor && !readBrightness.running && !writeBrightness.running && !pendingWrite) {
            readBrightness.monitor = selectedMonitor;
            readBrightness.command = ["omarchy-brightness-display", "--monitor", selectedMonitor];
            readBrightness.running = true;
        }
    }
    function setBrightness(value) {
        if (!active || !brightnessAvailable || !selectedMonitor) return;
        brightness = Math.max(0, Math.min(100, Math.round(value)));
        errorText = "";
        pendingWrite = {monitor: selectedMonitor, value: brightness};
        debounce.restart();
    }
    function sendBrightness() {
        if (!pendingWrite || writeBrightness.running) return;
        var request = pendingWrite;
        pendingWrite = null;
        writeBrightness.monitor = request.monitor;
        writeBrightness.command = ["omarchy-brightness-display", "--no-osd", "--monitor", request.monitor, request.value + "%"];
        writeBrightness.running = true;
    }
    function toggleSelectedDisplay() {
        if (!backend || !selectedDisplay) return;
        if (selectedDisplay.enabled && backend.enabledDisplayCount <= 1) return;
        backend.toggleDisplay(selectedMonitor, selectedDisplay.enabled);
    }
    onNamesChanged: ensureSelection()
    onBackendChanged: if (active) refresh()
    onPreferredMonitorChanged: if (names && names.indexOf(preferredMonitor) !== -1) selectedMonitor = preferredMonitor
    onSelectedMonitorChanged: { brightnessAvailable = false; errorText = ""; refresh(); }
    onActiveChanged: if (active) { ensureSelection(); refresh(); }
    Timer { interval: 5000; running: root.active; repeat: true; onTriggered: root.refresh() }
    Timer { id: debounce; interval: 120; onTriggered: root.sendBrightness() }
    Process {
        id: readBrightness
        property string monitor: ""
        property string result: ""
        stdout: StdioCollector { onStreamFinished: readBrightness.result = text.trim(); }
        onExited: function(exitCode) {
            if (monitor !== root.selectedMonitor) { root.refresh(); return; }
            if (root.pendingWrite || writeBrightness.running) return;
            var value = Number(result);
            root.brightnessAvailable = exitCode === 0 && result !== "" && isFinite(value) && value >= 0 && value <= 100;
            if (root.brightnessAvailable) root.brightness = Math.round(value);
        }
    }
    Process {
        id: writeBrightness
        property string monitor: ""
        onExited: function(exitCode) {
            if (monitor === root.selectedMonitor) root.errorText = exitCode === 0 ? "" : "Brightness change failed.";
            root.sendBrightness();
        }
    }
    ColumnLayout {
        id: body
        x: 14; y: 14; width: parent.width - 28; spacing: 8
        RowLayout {
            Layout.fillWidth: true
            Text { text: "Displays"; color: "#eeedf3"; font.pixelSize: 15; font.weight: Font.DemiBold }
            Item { Layout.fillWidth: true }
            ActionButton { text: "Advanced"; accent: root.accent; implicitWidth: 85; implicitHeight: 28; enabled: !!root.backend; onClicked: root.advancedRequested() }
        }
        RowLayout {
            Layout.fillWidth: true
            ComboBox {
                id: monitorPicker
                Layout.fillWidth: true
                model: root.names
                currentIndex: root.names.indexOf(root.selectedMonitor)
                enabled: root.names.length > 0
                Accessible.name: "Display"
                implicitHeight: 34
                background: Rectangle { radius: 10; color: "#202026"; border.color: monitorPicker.activeFocus ? root.accent : "#48464f" }
                contentItem: Text {
                    text: monitorPicker.displayText
                    leftPadding: 12; rightPadding: 28
                    color: "#eeedf3"; font.pixelSize: 12; verticalAlignment: Text.AlignVCenter
                }
                indicator: Text { text: "⌄"; color: "#a4a2b1"; x: monitorPicker.width - width - 12; anchors.verticalCenter: parent.verticalCenter }
                delegate: ItemDelegate {
                    id: option
                    required property string modelData
                    required property int index
                    width: monitorPicker.width - 8
                    text: modelData
                    highlighted: monitorPicker.highlightedIndex === index
                    contentItem: Text { text: option.text; color: "#eeedf3"; font.pixelSize: 12; verticalAlignment: Text.AlignVCenter }
                    background: Rectangle { radius: 8; color: option.highlighted ? "#37363f" : "#29292f" }
                }
                popup: Popup {
                    y: monitorPicker.height + 4
                    width: monitorPicker.width
                    height: Math.min(contentItem.implicitHeight + 8, 200)
                    padding: 4
                    background: Rectangle { radius: 12; color: "#29292f"; border.color: "#48464f" }
                    contentItem: ListView {
                        clip: true; implicitHeight: contentHeight
                        model: monitorPicker.popup.visible ? monitorPicker.delegateModel : null
                        currentIndex: monitorPicker.highlightedIndex
                    }
                }
                onActivated: function(index) { root.selectedMonitor = root.names[index]; }
            }
            ActionButton {
                text: root.selectedDisplay && root.selectedDisplay.enabled ? "Disable" : "Enable"
                accent: root.accent; implicitWidth: 80; implicitHeight: 32
                enabled: !!root.selectedDisplay && (!root.selectedDisplay.enabled || root.backend.enabledDisplayCount > 1)
                onClicked: root.toggleSelectedDisplay()
            }
        }
        Text {
            Layout.fillWidth: true
            text: root.selectedDisplay ? root.selectedDisplay.width + " × " + root.selectedDisplay.height : "No displays detected"
            color: "#a4a2b1"; font.pixelSize: 11
        }
        RowLayout {
            Layout.fillWidth: true
            Text { text: "Brightness"; color: "#a4a2b1"; font.pixelSize: 12 }
            Item { Layout.fillWidth: true }
            Text { text: root.brightnessAvailable ? root.brightness + "%" : "Not supported"; color: "#a4a2b1"; font.pixelSize: 12 }
        }
        ControlSlider {
            Layout.fillWidth: true
            accent: root.accent; from: 0; to: 100; stepSize: 1
            enabled: root.brightnessAvailable
            value: root.brightness
            Accessible.name: "Display brightness"
            onMoved: root.setBrightness(value)
        }
        Text { visible: root.errorText !== ""; text: root.errorText; color: "#f0a6a6"; font.pixelSize: 12; Layout.fillWidth: true; wrapMode: Text.WordWrap }
    }
}
