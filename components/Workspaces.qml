pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import Quickshell.Hyprland

Item {
    id: root
    property var bar: null
    property string moduleName: "omarchy.workspaces"
    property var settings: ({})
    implicitHeight: 28
    implicitWidth: workspaceRow.width

    function workspaceIds() {
        var ids = [1, 2, 3, 4, 5];
        var values = Hyprland.workspaces.values;
        for (var i = 0; i < values.length; i++) {
            if (values[i].id > 0 && values[i].id <= 10 && ids.indexOf(values[i].id) === -1)
                ids.push(values[i].id);
        }
        return ids.sort(function(a, b) { return a - b; });
    }

    Row {
        id: workspaceRow
        anchors.centerIn: parent
        spacing: 2
        Repeater {
            model: root.workspaceIds()
            delegate: AbstractButton {
                id: workspaceButton
                required property int modelData
                readonly property bool focused: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === modelData
                width: focused ? 38 : 24
                height: 28
                hoverEnabled: true
                // The bar's drag surface forwards clicks through this contract.
                property var host: root.bar
                property var registeredHost: null
                readonly property bool tooltipHovered: workspaceHover.hovered
                function triggerPress(button) {
                    if (button === Qt.LeftButton && root.bar)
                        root.bar.run("hyprctl dispatch 'hl.dsp.focus({ workspace = \"" + modelData + "\" })'");
                }
                function syncHost() {
                    if (registeredHost) registeredHost.unregisterClickTarget(workspaceButton);
                    registeredHost = host;
                    if (registeredHost) registeredHost.registerClickTarget(workspaceButton);
                }
                onHostChanged: syncHost()
                Component.onCompleted: syncHost()
                Component.onDestruction: if (registeredHost) registeredHost.unregisterClickTarget(workspaceButton)
                Accessible.name: "Workspace " + modelData
                Accessible.role: Accessible.Button
                onClicked: triggerPress(Qt.LeftButton)
                HoverHandler {
                    id: workspaceHover
                    onHoveredChanged: {
                        if (!hovered) {
                            if (root.bar) root.bar.hideTooltip(workspaceButton);
                            return;
                        }
                        // Let tooltipHovered settle before the host validates it.
                        // HoverHandler also observes movement beneath the bar's
                        // click/drag surface, independently of Control.hovered.
                        Qt.callLater(function() {
                            if (workspaceHover.hovered && root.bar)
                                root.bar.showTooltip(workspaceButton, "Workspace " + workspaceButton.modelData);
                        });
                    }
                }
                background: Rectangle {
                    anchors.centerIn: parent
                    width: workspaceButton.focused ? 28 : 6
                    height: workspaceButton.focused ? 8 : 6
                    radius: height / 2
                    color: workspaceButton.focused && root.bar ? root.bar.urgent : workspaceButton.hovered ? "#eeedf3" : "#8d8999"
                    border.width: workspaceButton.activeFocus ? 1 : 0
                    border.color: "#eeedf3"
                }
                Behavior on width {
                    NumberAnimation { duration: root.bar && root.bar.appearance.motion ? 140 : 0; easing.type: Easing.OutCubic }
                }
            }
        }
    }
}
