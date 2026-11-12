pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls

ComboBox {
    id: root
    property color accent: "#c4aff1"
    implicitHeight: 34
    background: Rectangle { radius: 10; color: "#202026"; border.color: root.activeFocus ? root.accent : "#48464f" }
    contentItem: Text { text: root.displayText; leftPadding: 12; rightPadding: 28; color: "#eeedf3"; font.pixelSize: 12; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }
    indicator: Text { text: "⌄"; color: "#a4a2b1"; x: root.width - width - 12; anchors.verticalCenter: parent.verticalCenter }
    delegate: ItemDelegate {
        id: option
        required property var modelData
        required property int index
        width: root.width - 8; text: String(modelData)
        highlighted: root.highlightedIndex === index
        contentItem: Text { text: option.text; color: "#eeedf3"; font.pixelSize: 12; elide: Text.ElideRight; verticalAlignment: Text.AlignVCenter }
        background: Rectangle { radius: 8; color: option.highlighted ? "#37363f" : "#29292f" }
    }
    popup: Popup {
        y: root.height + 4; width: root.width; padding: 4
        height: Math.min(contentItem.implicitHeight + 8, 240)
        background: Rectangle { radius: 12; color: "#29292f"; border.color: "#48464f" }
        contentItem: ListView { clip: true; implicitHeight: contentHeight; model: root.popup.visible ? root.delegateModel : null; currentIndex: root.highlightedIndex }
    }
}
