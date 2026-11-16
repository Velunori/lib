# Velunori Library API 1

`library.json` identifies `velunori.lib`, version 1.0.0, API 1. This is a code library, not an Omarchy runtime plugin. Consumers declare:

```json
{"velunori":{"dependencies":{"velunori.lib":{"apiVersion":1,"minimumVersion":"1.0.0","maximumExclusive":"2.0.0"}}}}
```

Omarchy does not install these dependencies automatically. This metadata is consumed by the locally prepared guided website/shell installer; it is not a published release yet. Individual local installers also validate the dependency themselves. Root plugin IDs and native entry points remain separate.

## Components

- `Theme`: default palette and spacing, or reactive detached `bar.velunori` presentation state when provided. No bar is required.
- `BrandMark`: SVG mark, transparent, accentable with `ink`.
- `Panel`: constrained, scroll-compatible panel surface; the owner provides `close()` and the injected host bar supplies popout coordination.
- `Button`, `Slider`, `Toggle`, `Surface`, `Choice`: reusable controls.
- `AppearanceEditor`: bar-specific layout/accent editor; consumers should expose it only when the active bar supports appearance changes.
- `DesktopBridge`: host-scoped `state` and `setToggle(name, bool)` for nightlight, dnd and stayAwake. Missing or unsupported capabilities fail closed. No commands, secrets or authentication objects are involved.
- `BarApi`: optional presentation extension of Omarchy's scoped plugin facade, used by Floating Bars. Its presence is not required by feature plugins.

Internal `components/`, `design/` and `assets/` are part of the library distribution. Preserve their paths when copying. Public kit properties remain compatible within API 1; additions are allowed, incompatible changes require a versioned interface. Never remove a library version while installed consumers still need it.

## Source and installation paths

Use real sibling `lib/` directories, not manifest-ID aliases. Relative imports follow physical paths for symlinked source plugins; installers validate that real sibling and the installed copy. Tests cover copied and symlinked layouts using temporary fixtures. Source and installed versions must satisfy the declared contract; a future package manager must pin compatible library/component revisions together.

Separating shared files does not grant private host APIs. Control Center uses Omarchy's indicators replacement identity to receive its supported scoped service proxies with the stock bar; Floating Bars can provide its existing scoped callbacks. Authentication remains owned by the unchanged lock service, never this library.
