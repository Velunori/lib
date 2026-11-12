import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    required property var entry
    property color accent: "#c4aff1"
    property bool compact: false
    signal activated(string id)
    implicitHeight: compact ? 90 : 114
    implicitWidth: 290
    radius: 16
    color: "#29292f"
    border.color: "#48464f"
    ColumnLayout {
        anchors.fill: parent; anchors.margins: 14; spacing: 6
        RowLayout {
            Layout.fillWidth: true
            Text { text: root.entry.title; color: "#eeedf3"; font.pixelSize: 15; font.weight: Font.DemiBold }
            Item { Layout.fillWidth: true }
            Rectangle { implicitWidth: 6; implicitHeight: 6; radius: 3; color: root.entry.enabled ? root.accent : "#777381" }
        }
        Text { visible: !root.compact; text: root.entry.description; color: "#a4a2b1"; font.pixelSize: 11; Layout.fillWidth: true; wrapMode: Text.WordWrap }
        RowLayout {
            Layout.fillWidth: true
            Text { text: root.entry.state; color: root.entry.enabled ? root.accent : "#a4a2b1"; font.pixelSize: 12 }
            Item { Layout.fillWidth: true }
            ActionButton {
                text: root.entry.action
                accent: root.accent
                enabled: root.entry.available
                implicitWidth: 88; implicitHeight: 30
                Accessible.name: root.entry.action + " " + root.entry.title
                onClicked: root.activated(root.entry.id)
            }
        }
    }
}
