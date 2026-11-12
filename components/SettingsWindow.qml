pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../design/Appearance.js" as Appearance

FloatingWindow {
    id: root
    title: "Velunori · Appearance"
    visible: false
    implicitWidth: 664
    implicitHeight: 570
    minimumSize: Qt.size(664, 570)
    color: "#202026"

    property var draft: Appearance.normalize({})
    property string errorText: ""
    readonly property color accent: Appearance.accentColor(draft.accent)
    signal previewRequested(var appearance)
    signal applyRequested(var appearance)
    signal cancelRequested()

    function choose(key, value) {
        var next = Appearance.normalize(draft);
        next[key] = value;
        draft = next;
        errorText = "";
        previewRequested(next);
    }

    function open(appearance) {
        draft = Appearance.normalize(appearance);
        errorText = "";
        visible = true;
    }

    onVisibleChanged: if (!visible) cancelRequested()

    Rectangle {
        anchors.fill: parent
        color: root.color
        focus: true
        Keys.onEscapePressed: root.visible = false

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 28
            spacing: 16

            Text { text: "VELUNORI"; color: root.accent; font.pixelSize: 11; font.letterSpacing: 3 }
            Text { text: "Appearance"; color: "#eeedf3"; font.pixelSize: 27; font.weight: Font.DemiBold }
            Text { text: "Choose a layout. Preview it on your desktop before applying."; color: "#a4a2b1"; font.pixelSize: 13 }

            RowLayout {
                spacing: 16
                StyleCard {
                    Layout.fillWidth: true
                    styleName: "island"; title: "Island"
                    description: "One centered capsule. Everything within reach."
                    checked: root.draft.style === "island"
                    accent: root.accent
                    onClicked: root.choose("style", "island")
                }
                StyleCard {
                    Layout.fillWidth: true
                    styleName: "orbit"; title: "Orbit"
                    description: "Three floating capsules. Space to breathe."
                    checked: root.draft.style === "orbit"
                    accent: root.accent
                    onClicked: root.choose("style", "orbit")
                }
            }

            RowLayout {
                spacing: 12
                Text { text: "Accent"; color: "#eeedf3"; font.pixelSize: 14; Layout.rightMargin: 8 }
                Repeater {
                    model: ["lavender", "mint", "pearl"]
                    delegate: AbstractButton {
                        id: swatch
                        required property string modelData
                        implicitWidth: 32; implicitHeight: 32
                        Accessible.name: modelData + " accent"
                        onClicked: root.choose("accent", modelData)
                        background: Rectangle {
                            radius: 16
                            color: Appearance.accentColor(swatch.modelData)
                            border.color: swatch.activeFocus ? "white" : "#202026"
                            border.width: 3
                        }
                        contentItem: Text {
                            text: root.draft.accent === swatch.modelData ? "✓" : ""
                            color: "#202026"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
                Item { Layout.fillWidth: true }
                CheckBox {
                    id: motionToggle
                    text: "Animations"
                    checked: root.draft.motion
                    onClicked: root.choose("motion", checked)
                    indicator: Rectangle {
                        width: 20; height: 20; radius: 6
                        anchors.verticalCenter: parent.verticalCenter
                        color: motionToggle.checked ? root.accent : "#29292f"
                        border.color: motionToggle.activeFocus ? "#eeedf3" : root.accent
                        Text { anchors.centerIn: parent; text: motionToggle.checked ? "✓" : ""; color: "#202026" }
                    }
                    contentItem: Text {
                        text: motionToggle.text; leftPadding: 28
                        verticalAlignment: Text.AlignVCenter
                        color: "#eeedf3"; font.pixelSize: 13
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: root.errorText || "Live preview · Closing this window discards unapplied changes."
                color: root.errorText ? "#f0a6a6" : "#a4a2b1"
                font.pixelSize: 12; wrapMode: Text.WordWrap
            }
            Item { Layout.fillHeight: true }
            RowLayout {
                Item { Layout.fillWidth: true }
                ActionButton { text: "Cancel"; accent: root.accent; onClicked: root.visible = false }
                ActionButton { text: "Apply"; primary: true; accent: root.accent; onClicked: root.applyRequested(root.draft) }
            }
        }
    }
}
