import QtQuick
import QtQuick.Controls

Slider {
    id: root
    property color accent: "#c4aff1"
    implicitHeight: 30
    from: 0; to: 1; stepSize: 0.01
    background: Rectangle {
        x: root.leftPadding
        y: root.topPadding + root.availableHeight / 2 - height / 2
        width: root.availableWidth; height: 6; radius: 3
        color: "#48464f"
        opacity: root.enabled ? 1 : 0.4
        Rectangle { width: root.visualPosition * parent.width; height: parent.height; radius: 3; color: root.accent }
    }
    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + root.availableHeight / 2 - height / 2
        implicitWidth: 16; implicitHeight: 16; radius: 8
        color: root.enabled ? "#eeedf3" : "#777381"
        border.width: root.activeFocus ? 2 : 0
        border.color: root.accent
    }
}
