import QtQuick
import "../design"

Rectangle {
    id: root
    property string text: ""
    Tokens { id: tokens }
    implicitWidth: label.implicitWidth + 24
    implicitHeight: label.implicitHeight + 16
    radius: 10
    color: tokens.surface
    border.color: tokens.border
    border.width: 1
    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        textFormat: Text.PlainText
        color: tokens.text
        font.family: tokens.fontFamily
        font.pixelSize: 13
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
