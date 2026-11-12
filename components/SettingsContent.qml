pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../design/Appearance.js" as Appearance

Item {
    id: root
    property bool active: false
    property int padding: 0
    implicitWidth: 418
    implicitHeight: settingsLayout.implicitHeight + padding * 2

    property var shell: null
    property var availablePanels: []
    property string activePage: "system"
    signal commandRequested(var argv)
    signal closeRequested()
    signal panelRequested(string id)
    SystemControls {
        id: desktopControls
        shell: root.shell
        active: root.active && root.activePage === "system"
        onCommandRequested: function(argv) {
            root.close();
            root.commandRequested(argv);
        }
    }

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
        active = true;
    }

    function close() { active = false; closeRequested(); }
    onActiveChanged: if (!active) cancelRequested()

    Item {
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: root.close()

        ColumnLayout {
            id: settingsLayout
            anchors.fill: parent
            anchors.margins: root.padding
            spacing: 16

            RowLayout {
                Layout.fillWidth: true
                Text { text: "VELUNORI"; color: root.accent; font.pixelSize: 12; font.letterSpacing: 3 }
                Item { Layout.fillWidth: true }
                ActionButton { text: "Appearance"; accent: root.accent; primary: root.activePage === "appearance"; onClicked: root.activePage = "appearance" }
                ActionButton { text: "System"; accent: root.accent; primary: root.activePage === "system"; onClicked: root.activePage = "system" }
            }
            Text {
                Layout.fillWidth: true
                text: root.activePage === "appearance" ? "Choose a layout. Preview it on your desktop before applying." : "Desktop controls · Changes take effect immediately."
                color: "#a4a2b1"; font.pixelSize: 13; wrapMode: Text.WordWrap
            }

            ColumnLayout {
                visible: root.activePage === "appearance"
                Layout.fillWidth: true
                spacing: 16
            RowLayout {
                spacing: 16
                StyleCard {
                    Layout.fillWidth: true
                    styleName: "island"; title: "Island"
                    description: "One centered capsule."
                    checked: root.draft.style === "island"
                    accent: root.accent
                    onClicked: root.choose("style", "island")
                }
                StyleCard {
                    Layout.fillWidth: true
                    styleName: "orbit"; title: "Orbit"
                    description: "Three floating capsules."
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
                text: root.errorText || "Live preview · Closing this panel discards unapplied changes."
                color: root.errorText ? "#f0a6a6" : "#a4a2b1"
                font.pixelSize: 12; wrapMode: Text.WordWrap
            }
            }
            RowLayout {
                visible: root.activePage === "system"
                Layout.fillWidth: true
                Repeater {
                    model: [
                        {id: "omarchy.monitor", title: "Display"},
                        {id: "omarchy.power", title: "Power"},
                        {id: "omarchy.audio", title: "Sound"}
                    ]
                    delegate: ActionButton {
                        required property var modelData
                        Layout.fillWidth: true
                        implicitWidth: 80
                        text: modelData.title
                        accent: root.accent
                        enabled: root.availablePanels.indexOf(modelData.id) !== -1
                        onClicked: root.panelRequested(modelData.id)
                    }
                }
            }
            GridLayout {
                visible: root.activePage === "system"
                Layout.fillWidth: true
                columns: 2; columnSpacing: 12; rowSpacing: 12
                Repeater {
                    model: desktopControls.entries
                    delegate: SystemControlCard {
                        required property var modelData
                        Layout.fillWidth: true
                        entry: modelData
                        accent: root.accent
                        onActivated: function(id) { desktopControls.execute(id) }
                    }
                }
            }
            Item { Layout.fillHeight: true }
            RowLayout {
                Item { Layout.fillWidth: true }
                ActionButton { text: root.activePage === "appearance" ? "Cancel" : "Close"; accent: root.accent; onClicked: root.close() }
                ActionButton { visible: root.activePage === "appearance"; text: "Apply"; primary: true; accent: root.accent; onClicked: root.applyRequested(root.draft) }
            }
        }
    }
}
