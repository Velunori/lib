import QtQuick

// Scoped adapters only. Never launches commands or handles authentication.
QtObject {
    id: root
    property var bar: null
    readonly property var host: bar && bar.shell ? bar.shell : null
    readonly property var nightlight: host && typeof host.firstPartyServiceFor === "function" ? host.firstPartyServiceFor("omarchy.nightlight") : null
    readonly property var notifications: host && typeof host.firstPartyServiceFor === "function" ? host.firstPartyServiceFor("omarchy.notifications") : null
    readonly property var idle: host && typeof host.firstPartyServiceFor === "function" ? host.firstPartyServiceFor("omarchy.idle") : null
    readonly property var state: bar && bar.desktopState ? bar.desktopState : ({
        nightlight: nightlight ? nightlight.enabled === true : false, nightlightAvailable: !!nightlight,
        dnd: notifications ? notifications.doNotDisturb === true : false, dndAvailable: !!notifications,
        stayAwake: idle ? idle.stayAwake === true : false, stayAwakeAvailable: !!idle
    })
    function setToggle(name, enabled) {
        if (typeof enabled !== "boolean") return false
        if (bar && typeof bar.setDesktopToggle === "function") return bar.setDesktopToggle(name, enabled)
        if (name === "nightlight" && nightlight) nightlight.setNightlight(enabled)
        else if (name === "dnd" && notifications) notifications.setDoNotDisturb(enabled)
        else if (name === "stayAwake" && idle) idle.setIdleEnabled(!enabled)
        else return false
        return true
    }
}
