pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import Quickshell.Hyprland
import Quickshell
import Quickshell.Io
import "WorkspaceModel.js" as Model

Item {
    id: root
    property var bar: null
    property string moduleName: "omarchy.workspaces"
    property var settings: ({})
    implicitHeight: 28
    implicitWidth: workspaceRow.width
    property var workspaceValues: Hyprland.workspaces.values
    property var monitor: {
        var window = root.QsWindow.window;
        return window && window.screen ? Hyprland.monitorFor(window.screen) : Hyprland.focusedMonitor;
    }
    property var focusedWorkspace: Hyprland.focusedWorkspace
    property var blocks: ({})
    property bool perMonitor: false
    readonly property string monitorName: monitor ? monitor.name : ""
    readonly property int activeId: perMonitor ? (monitor && monitor.activeWorkspace ? monitor.activeWorkspace.id : -1) : (focusedWorkspace ? focusedWorkspace.id : -1)
    readonly property int block: Model.monitorBlock(blocks, monitorName, activeId)
    FileView {
        // Feature detection, rather than a version check. A stale block file
        // left by a downgrade must not activate the new dispatchers on 4.0.
        path: (Quickshell.env("OMARCHY_PATH") || "/usr/share/omarchy") + "/default/hypr/monitor-workspaces.lua"
        printErrors: false
        onLoaded: root.perMonitor = true
        onLoadFailed: root.perMonitor = false
    }
    FileView {
        path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/omarchy/monitor-workspaces"
        watchChanges: true; printErrors: false
        onFileChanged: reload()
        onLoaded: root.blocks = Model.readBlocks(text())
        onLoadFailed: root.blocks = ({})
    }

    function workspaceIds() {
        return Model.workspaceIds(workspaceValues, perMonitor, monitorName, block);
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
                readonly property bool focused: root.activeId === modelData
                readonly property int label: root.perMonitor && Model.blockOf(modelData) === root.block ? Model.slotOf(modelData) : modelData
                width: focused ? 38 : 24
                height: 28
                hoverEnabled: true
                // The bar's drag surface forwards clicks through this contract.
                property var host: root.bar
                property var registeredHost: null
                readonly property bool tooltipHovered: workspaceHover.hovered
                function triggerPress(button) {
                    if (button === Qt.LeftButton && root.bar)
                        root.bar.run(Model.focusCommand(modelData, root.perMonitor, root.monitorName, root.block));
                }
                function syncHost() {
                    if (registeredHost) registeredHost.unregisterClickTarget(workspaceButton);
                    registeredHost = host;
                    if (registeredHost) registeredHost.registerClickTarget(workspaceButton);
                }
                onHostChanged: syncHost()
                Component.onCompleted: syncHost()
                Component.onDestruction: if (registeredHost) registeredHost.unregisterClickTarget(workspaceButton)
                Accessible.name: "Workspace " + label + (root.perMonitor ? " · " + root.monitorName : "")
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
                                root.bar.showTooltip(workspaceButton, "Workspace " + workspaceButton.label);
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
