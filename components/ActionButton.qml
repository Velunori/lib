import QtQuick
import QtQuick.Controls

Button {
    id: root
    property bool primary: false
    property color accent: "#c4aff1"
    implicitHeight: 40
    implicitWidth: Math.max(100, label.implicitWidth + 32)
    hoverEnabled: true
    contentItem: Text {
        id: label
        text: root.text
        elide: Text.ElideRight
        color: root.primary ? "#202026" : "#eeedf3"
        font.pixelSize: 14
        font.weight: Font.Medium
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    background: Rectangle {
        radius: 12
        color: root.primary ? root.accent : root.down ? "#48464f" : root.hovered ? "#37363f" : "#29292f"
        border.color: root.activeFocus ? root.accent : "#48464f"
        border.width: root.activeFocus ? 2 : 1
        opacity: root.enabled ? 1 : 0.45
    }
}
