pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "." as Kit
import "../components" as UI
import "../design/Appearance.js" as Appearance

Item {
    id: root
    property string syncError: ""
    property var draft: Appearance.normalize({})
    property string errorText: ""
    readonly property color accent: Appearance.accentColor(draft.accent)
    implicitHeight: body.implicitHeight
    signal previewRequested(var value)
    signal applyRequested(var value)
    signal cancelRequested()
    function reset(value) { draft = Appearance.normalize(value); errorText = ""; }
    function choose(key, value) {
        var next = Appearance.normalize(draft); next[key] = value; draft = next;
        previewRequested(next);
    }
    ColumnLayout {
        id: body
        width: parent.width; spacing: 16
        Text { text: "Choose your workspace layout"; color: "#eeedf3"; font.pixelSize: 18; font.weight: Font.DemiBold }
        RowLayout {
            Layout.fillWidth: true; spacing: 12
            UI.StyleCard { Layout.fillWidth: true; styleName: "island"; title: "Island"; description: "One centered capsule."; checked: root.draft.style === "island"; accent: root.accent; onClicked: root.choose("style", "island") }
            UI.StyleCard { Layout.fillWidth: true; styleName: "orbit"; title: "Orbit"; description: "Three floating capsules."; checked: root.draft.style === "orbit"; accent: root.accent; onClicked: root.choose("style", "orbit") }
        }
        RowLayout {
            Text { text: "Accent"; color: "#eeedf3"; font.pixelSize: 14 }
            Repeater {
                model: ["lavender", "mint", "pearl"]
                UI.ActionButton {
                    required property string modelData
                    text: modelData; accent: Appearance.accentColor(modelData)
                    primary: root.draft.accent === modelData
                    implicitWidth: 85
                    onClicked: root.choose("accent", modelData)
                }
            }
            Item { Layout.fillWidth: true }
        }
        RowLayout {
            Text { text: "Animations"; color: "#eeedf3"; font.pixelSize: 14 }
            Item { Layout.fillWidth: true }
            Kit.Toggle { accent: root.accent; checked: root.draft.motion; onClicked: root.choose("motion", checked) }
        }
        Text { Layout.fillWidth: true; text: root.errorText || root.syncError || "Live preview. Dismiss to discard, Apply to save."; color: (root.errorText || root.syncError) ? "#f0a6a6" : "#a4a2b1"; font.pixelSize: 12; wrapMode: Text.WordWrap }
        RowLayout {
            Item { Layout.fillWidth: true }
            UI.ActionButton { text: "Cancel"; accent: root.accent; onClicked: root.cancelRequested() }
            UI.ActionButton { text: "Apply"; accent: root.accent; primary: true; onClicked: root.applyRequested(root.draft) }
        }
    }
}
