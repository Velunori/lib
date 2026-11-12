import QtQuick
import QtQuick.Controls

Switch {
    id: root
    property color accent: "#c4aff1"
    implicitWidth: 42; implicitHeight: 28
    indicator: Rectangle {
        x: 2; y: (root.height - height) / 2
        width: 38; height: 22; radius: 11
        color: root.checked ? root.accent : "#48464f"
        border.color: root.activeFocus ? "#eeedf3" : "transparent"
        Rectangle { x: 3 + root.visualPosition * 16; y: 3; width: 16; height: 16; radius: 8; color: root.checked ? "#202026" : "#eeedf3" }
    }
}
