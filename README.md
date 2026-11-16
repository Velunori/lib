# Velunori Library

Shared QML components and scoped host adapters for Velunori plugins, independent of Floating Bars.

![Shared Velunori visual identity](docs/preview.png)

## Features

- Semantic palette, spacing, typography, branding and panel geometry.
- Shared panels, buttons, sliders, toggles, surfaces and appearance editor.
- A scoped desktop adapter for night light, notification quiet mode and idle state; unavailable host capabilities remain unavailable.
- Versioned library API, declared dependency metadata and read-only compatibility checks.
- No bar, widget, daemon, session-lock client, authentication flow or plugin entry point.

## Requirements

Omarchy with its QML shell API and Quickshell/Qt. The extraction is checked against Omarchy 4.0.6-1, Quickshell 0.3.2.r7.g2b4501a-1 and Qt 6.12.0. Other environments are unverified. Feature plugins still need their own documented backend requirements.

Library version **1.0.0**, API **1**. Consumers require version `>=1.0.0, <2.0.0`; an incompatible API requires an explicit migration.

## Install

Keep real source repositories beside one another: `lib/`, `bar/`, `clock/`, `control-center/`, etc. No manifest-ID shortcuts are needed in the workspace.

```bash
bash lib/scripts/install-local.sh
```

Run from the workspace root. The installer copies the library into `${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/plugins/lib`. This directory deliberately has `library.json`, not a plugin `manifest.json`: Omarchy ignores it as a runtime plugin. No bar is enabled, shell configuration is unchanged, and no shell restart or symlink is created. An existing target is refused rather than overwritten. Managed in-place upgrades are a later installer task.

Copied plugin installs import the real sibling `lib/`; symlinked source installs import their source checkout's real sibling `lib/`. The consumer installer checks both the installed dependency and physical source layout. Install the selected feature plugin afterward. Installing Control Center does not install or activate Floating Bars.

## Usage

```qml
import "../lib/kit" as V

V.Theme { id: theme; bar: widget.bar }
```

Nested component directories use `../../lib/kit`. `Theme` uses a Velunori bar's detached presentation data when available and supplies default Velunori styling with the stock bar. `Panel` uses the host's normal popout/keyboard contract. `DesktopBridge` delegates to a bar's scoped extension when present, otherwise uses host-provided service proxies; it never bypasses host capability checks.

Library metadata and dependency declarations are documented in [the API contract](docs/api-v1.md). License and third-party notices are retained from the original shared components.

## Development

```bash
bash lib/scripts/check.sh
VELUNORI_PREVIEW_PATH=/tmp/velunori-lib.png bash lib/scripts/check.sh
bash lib/scripts/compose-preview.sh /tmp/velunori-lib.png lib/docs/preview.png
```

Run from the workspace root. Checks cover copy-only installation without shell changes, conflict protection, absence of alias creation, appearance normalization, panel geometry, QML lint, default styling without a bar and scoped desktop adapters using stand-ins. QML runs offscreen in temporary directories. No account access, authentication, desktop locking, theme activation or real system update is performed.

Set `VELUNORI_LIB_PATH` when a consumer's checks use this library from another location. The isolated `.refactor/` consumers use that override while development changes remain off the live desktop.

## Limits

The library does not install external dependencies, create account connections, grant host permissions or make a non-supported Omarchy version compatible. Bar-specific Island/Orbit appearance controls remain a bar feature; standalone Control Center does not offer them. Automated passes are not live desktop verification, and do not prove the documented Qt/Quickshell crash fixed.

This is a locally prepared repository. It has not been committed, pushed, deployed or published. The old core checkout stays intact until the running desktop is deliberately migrated.

## Velunori components

| Repository | Role |
| --- | --- |
| lib | Shared QML primitives, assets and host adapters |
| bar | Optional Island/Orbit Floating Bars |
| clock | Clock and editable calendars |
| control-center | System controls, independent of Floating Bars |
| notifications | Notification cards and history |
| menu | Commands and prompts |
| weather | Cities and forecast |
| update | Omarchy update presentation |
| lockscreen | Serene presentation using Omarchy's lock/PAM service |
| lieferando | Order status and tracking |
| theme | Standalone palette and wallpaper; no QML library dependency |

## Contributing

Read the organization’s [contributor guide](https://github.com/Velunori/.github/blob/main/CONTRIBUTING.md), [plugin-author guide](https://github.com/Velunori/.github/blob/main/docs/plugin-authoring.md), and [suite inclusion process](https://github.com/Velunori/.github/blob/main/docs/suite-inclusion.md). The authoring guide includes a minimal example and distinguishes the prepared library migration from published branches. These shared documents are being prepared locally alongside this change.

## License

MIT; see [LICENSE](LICENSE) and [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
