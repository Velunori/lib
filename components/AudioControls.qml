import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property var backend: null
    property color accent: "#c4aff1"
    signal advancedRequested()
    readonly property bool available: !!backend && backend.hasOutput
    implicitHeight: 132
    radius: 16; color: "#29292f"; border.color: "#48464f"
    function setVolume(value) { if (available) backend.setOutputVolume(Math.max(0, Math.min(1, value))); }
    function toggleMute() { if (available) backend.toggleOutputMute(); }
    ColumnLayout {
        anchors.fill: parent; anchors.margins: 14; spacing: 6
        RowLayout {
            Layout.fillWidth: true
            Text { text: "Sound"; color: "#eeedf3"; font.pixelSize: 15; font.weight: Font.DemiBold }
            Item { Layout.fillWidth: true }
            Text { text: root.available ? Math.round(Math.min(1, root.backend.outputVolume) * 100) + "%" : "No output"; color: "#a4a2b1"; font.pixelSize: 12 }
            ActionButton {
                text: root.backend && root.backend.outputMuted ? "Unmute" : "Mute"
                accent: root.accent; implicitWidth: 70; implicitHeight: 28
                enabled: root.available; onClicked: root.toggleMute()
            }
        }
        ControlSlider {
            Layout.fillWidth: true
            accent: root.accent
            enabled: root.available
            value: root.available ? root.backend.outputVolume : 0
            Accessible.name: "Output volume"
            onMoved: root.setVolume(value)
        }
        ActionButton { text: "Outputs and mixer"; accent: root.accent; implicitHeight: 28; onClicked: root.advancedRequested(); enabled: !!root.backend }
    }
}
