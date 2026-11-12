import QtQuick
import "../design"

Tokens {
    property var bar: null
    readonly property var appearance: bar && bar.velunori && bar.velunori.apiVersion === 1 ? bar.velunori : ({})
    accentName: appearance.accentName || "lavender"
    readonly property bool motion: appearance.motion !== false
    readonly property string layoutStyle: appearance.style === "orbit" ? "orbit" : "island"
    readonly property int apiVersion: 1
}
