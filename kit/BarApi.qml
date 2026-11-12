import qs.Ui

PluginBarApi {
    // Detached presentation data only; no access to core's internal objects.
    property var velunori: ({apiVersion: 1, style: "island", accentName: "lavender", motion: true})
    property var desktopState: ({})
    property var _desktopToggle: null
    property var _previewAppearance: null
    property var _applyAppearance: null
    property var _clearAppearance: null
    function setDesktopToggle(name, enabled) { return _desktopToggle ? _desktopToggle(name, enabled) : false; }
    function previewAppearance(value) { return _previewAppearance ? _previewAppearance(value) : false; }
    function applyAppearance(value) { return _applyAppearance ? _applyAppearance(value) : false; }
    function clearAppearancePreview() { if (_clearAppearance) _clearAppearance(); }
}
