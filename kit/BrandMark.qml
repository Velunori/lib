import QtQuick
import "Brand.js" as Brand

Item {
    id: root
    property color ink: "#c4aff1"
    objectName: "velunoriBrandMark"
    implicitWidth: 24; implicitHeight: 24
    readonly property int status: glyph.status
    Image {
        id: glyph
        anchors.fill: parent
        source: "data:image/svg+xml;utf8," + encodeURIComponent(Brand.markSvg(root.ink.toString()))
        sourceSize.width: Math.ceil(root.width)
        sourceSize.height: Math.ceil(root.height)
        fillMode: Image.PreserveAspectFit
        smooth: true
    }
}
