import Quickshell
import QtQuick

// Headless preview/test harness. The desktop hosts SettingsContent in kit/Panel.
FloatingWindow {
    id: root
    title: "Velunori preview"
    visible: false
    implicitWidth: 460
    implicitHeight: content.implicitHeight + 40
    color: "#202026"
    property alias shell: content.shell
    property alias activePage: content.activePage
    property alias draft: content.draft
    property alias errorText: content.errorText
    readonly property color accent: content.accent
    signal commandRequested(var argv)
    signal previewRequested(var appearance)
    signal applyRequested(var appearance)
    signal cancelRequested()
    function choose(key, value) { content.choose(key, value); }
    function open(appearance) { content.open(appearance); visible = true; }
    onVisibleChanged: if (!visible) content.active = false
    Rectangle {
        anchors.fill: parent
        color: root.color
        SettingsContent {
            id: content
            anchors.fill: parent; anchors.margins: 20
            activePage: "appearance"
            onPreviewRequested: function(value) { root.previewRequested(value); }
            onApplyRequested: function(value) { root.applyRequested(value); }
            onCancelRequested: root.cancelRequested()
            onCloseRequested: root.visible = false
            onCommandRequested: function(argv) { root.commandRequested(argv); }
        }
    }
}
