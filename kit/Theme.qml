import QtQuick
import "../design"

Tokens {
    property var bar: null
    readonly property var savedAppearance: bar && bar.shell && bar.shell.barConfig
        ? bar.shell.barConfig.velunori : null
    readonly property var appearance: bar && bar.velunori && bar.velunori.apiVersion === 1
        ? bar.velunori : (savedAppearance ? ({accentName: savedAppearance.accent || "lavender",
            motion: savedAppearance.motion !== false, style: savedAppearance.style || "island"}) : ({}))
    accentName: appearance.accentName || "lavender"
    readonly property bool motion: appearance.motion !== false
    readonly property string layoutStyle: appearance.style === "orbit" ? "orbit" : "island"
    readonly property int apiVersion: 1
}
