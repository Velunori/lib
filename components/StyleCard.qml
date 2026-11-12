import QtQuick
import QtQuick.Controls

AbstractButton {
    id: root
    required property string styleName
    required property string title
    required property string description
    property color accent: "#c4aff1"
    implicitHeight: 240
    implicitWidth: 288
    checkable: true
    hoverEnabled: true
    Accessible.name: title + ". " + description

    background: Rectangle {
        radius: 18
        color: root.hovered ? "#33323c" : "#29292f"
        border.width: root.checked || root.activeFocus ? 2 : 1
        border.color: root.checked || root.activeFocus ? root.accent : "#48464f"
    }
    contentItem: Item {
        StylePreview {
            anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
            anchors.margins: 12
            height: 142
            style: root.styleName; accent: root.accent
        }
        Text {
            x: 16; y: 169; text: root.title
            color: "#eeedf3"; font.pixelSize: 17; font.weight: Font.DemiBold
        }
        Text {
            x: 16; y: 198; width: parent.width - 32
            text: root.description; color: "#a4a2b1"; font.pixelSize: 12
            wrapMode: Text.WordWrap
        }
        Text {
            anchors.right: parent.right; anchors.rightMargin: 18; y: 169
            text: root.checked ? "✓" : ""; color: root.accent; font.pixelSize: 18
        }
    }
}
