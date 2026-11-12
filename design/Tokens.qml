import QtQuick
import "Appearance.js" as Appearance

QtObject {
    property string accentName: "lavender"
    readonly property color accent: Appearance.accentColor(accentName)
    readonly property color text: "#eeedf3"
    readonly property color muted: "#a4a2b1"
    readonly property color background: "#202026"
    readonly property color surface: "#29292f"
    readonly property color border: "#48464f"
    readonly property int radius: 18
    readonly property int barHeight: 40
    readonly property int edgeGap: 12
    readonly property int spacing: 12
    readonly property int duration: 180
    readonly property string fontFamily: "sans-serif"
}
