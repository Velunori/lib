# Velunori design kit v1

Core owns the bar, appearance settings and presentation primitives. Feature
plugins own their widget logic, data and panels. Core never imports a feature
plugin. Install core under its manifest ID `velunori.core`; dependent plugins
import `../velunori.core/kit` from their own plugin directory.

```qml
import "../velunori.core/kit" as Velunori

Velunori.Theme {
    id: theme
    bar: widget.bar
}
```

## API

- `Theme`: semantic colors, spacing, font family, radii, `motion`, `layoutStyle`, `apiVersion`.
  Set `bar` to the injected widget bar facade. The palette reacts to live core
  previews. Without a Velunori facade, the default palette is available.
- `Button`: shared keyboard-focusable button with `bar`, `text`, `primary`,
  `clicked`; override implicit size when appropriate.
- `Panel`: anchored layer panel with rounded Velunori surface, theme-aware
  animation, outside-click dismissal and Omarchy's popout coordination. Set
  `bar`, `anchorItem`, `owner`, `open`, `contentWidth`, `contentHeight`, and
  `focusTarget`. Its default content area excludes padding and borders.

The owner supplies `close()`; a widget supplies `open()`, `close()`, `opened`
and calls `bar.requestPopout(widget)` / `bar.releasePopout(widget)`. Use a
`qs.Ui.WidgetButton` so click forwarding, tooltips and drag handling follow the
host's contract. Use `qs.Ui.PanelKeyCatcher` to handle Escape and navigation.

## Detached appearance contract

Core extends the existing scoped `PluginBarApi` with one property:

```js
bar.velunori = { apiVersion: 1, style: "island", accentName: "lavender", motion: true }
```

This is copied presentation data. There are no references to core's private
settings window, token objects or services. It is a reactive property: consumers
must bind to it rather than copy it on startup. Feature plugins should prefer
`Theme` over interpreting this object themselves.

## Compatibility

Kit v1 starts in core 0.2.0. Existing v1 components and properties should remain
compatible through additive changes. A future incompatible API needs a new
versioned interface. Installers must validate the dependency before enabling a
plugin; Omarchy does not currently provide dependency installation for this kit.
Missing core is an installation error, rather than a reason to duplicate its
colors and components into every plugin.

## Additions in core 0.4.0

`Slider`, `Toggle`, `Surface`, `Choice`, and `AppearanceEditor` provide shared
controls. Theme also exposes `secondaryAccent` for paired traffic graphs.
Only `velunori.control-center` receives the scoped `desktopState` and
`setDesktopToggle`, `previewAppearance`, `applyAppearance`,
`clearAppearancePreview` callbacks. Other plugins receive no mutation callbacks.

Core 0.4.3 adds `bar.appearanceSyncError`, an empty string on success or a
browser accent synchronization error for the appearance editor to display.
`AppearanceEditor.syncError` accepts that message separately from save errors.
Only the saved accent is synchronized; preview and cancel do not alter the browser.
No device service objects cross this facade. Control Center requires core 0.4.0.

## Brand mark (core 0.4.4)

`BrandMark` is a transparent vector icon with an `ink` color property and a
default 24 × 24 size. Use 18 × 18 for a bar launcher, with `ink: theme.accent`.
It does not depend on the Omarchy icon font. SVG exports and the editable
wordmark are documented in [branding.md](branding.md).

## Composite bar indicators (core 0.4.1)

A widget that draws its own per-target active marks may set
`readonly property real openPanelIndicatorWidth: 0` to suppress the generic
host underline. Positive numeric hints keep their previous behavior; widgets
without a valid hint retain the automatic indicator extent.
