# Omarchy 4.5 compatibility audit — 2026-11-13

**Result: do not call the current Velunori checkout 4.5-compatible yet.**
There are confirmed behavior conflicts in workspaces, bar sections and Apps,
plus a notification-preferences migration conflict. No update was installed,
no live configuration was modified, and the desktop was never locked.

## Baseline and scope

- Installed, from `pacman -Q`: Omarchy 4.0.6-1, Hyprland 0.56.2-4,
  Quickshell 0.3.2.r7.g2b4501a-1, Qt base 6.12.0-3 and declarative 6.12.0-1.
- Compared against the **v4.5.0** source tag,
  `ac2690cd7be4f47e4a255f5e2e78d904d436b068`.
- Read the complete repository tree through GitHub, fetched the target's
  Commons/Ui and relevant services, plugin sources, theme templates and helpers,
  and reviewed the 18 migrations newer than the installed last migration
  `1792334754.sh`. Downloaded source is in `/tmp/velunori-audit45/target`.
- Identical local files were reused only after their Git blob hash matched
  the target tree. This is not an installation or a launch of the 4.5 host.
- The locally cached pacman database still advertises 4.0.6-1. It was not
  refreshed. The exact pending package build and its downstream patches have
  not been validated; a release tag is not proof of binary-package compatibility.

## Confirmed conflicts

### 1. Per-monitor workspaces — high priority

4.5 loads `default.hypr.monitor-workspaces`. Each monitor owns a block of
ten global IDs: 1–10, 11–20, etc. The host's workspace widget reads
`$XDG_STATE_HOME/omarchy/monitor-workspaces`, labels local slots and dispatches
through the new monitor-aware workspace functions.

Velunori's `components/Workspaces.qml` always starts with 1–5, only includes
IDs up to 10, highlights the globally focused workspace, and dispatches a
global ID. A second monitor's normal IDs therefore do not appear. Clicking
its dots can take focus to another monitor's workspaces.

Control Center's `DisplaysPage.qml` offers global assignments 1–10. Its
backend persists workspace rules and explicitly moves those IDs on Keep.
4.5's reconcile logic runs on config reload and monitor changes, renumbers
workspaces and brings them into their owner's block. These are competing
models; passing the existing layout tests does not validate their coexistence.

Required: adopt the monitor/block/slot model in the bar and redesign/migrate
workspace destinations to cooperate with it. Preserve the monitor geometry
preview and rollback transaction independently.

Sources:
[monitor-workspaces.lua](https://github.com/omacom/omarchy/blob/v4.5.0/default/hypr/monitor-workspaces.lua),
[host Workspaces.qml](https://github.com/omacom/omarchy/blob/v4.5.0/shell/plugins/bar/widgets/Workspaces.qml).

### 2. New bar sections — high priority

The 4.5 layout has `left`, `centerBegin`, `center`, `centerEnd`, `right`
and `tray`. Velunori's `Bar.qml::normalizeLayout` reads the shared
normalizer but returns only left/center/right. `BarModel.inlineSettingsDelta`
and the rendering/dragging model also assume three regions.

Reproduced by evaluating the actual function with a six-section normalizer:
an input containing clock in center, weather in centerEnd and a widget in
tray returns only the clock. Existing widgets can therefore disappear from
the rendered strip when placed in a new section; this reproduction does not
claim their saved configuration was deleted.

Required: explicitly support and preserve all host sections, including
placement indices, tray ownership and drag/drop writes. Merely appending
centerEnd to center would change the centering semantics.

Source: [4.5 shell reference](https://github.com/omacom/omarchy/blob/v4.5.0/docs/omarchy-shell.md).

### 3. Apps menu and model drift — high priority

4.5's default `apps` entry has both `provider: "apps"` and
`action: "omarchy-shell omarchy.dock apps"`. Velunori's current parser
classifies an entry with an action as `kind: "action"`. Its activation and
route handlers execute that action. Parsing the new default JSONC with the
actual Velunori model reproduced that result: Apps now routes to the Omarchy
dock rather than the Velunori application list.

The model also adds `disabled`, translated search terms and resilient menu
file reads. Velunori's parser drops the new disabled flag, so install rows
which 4.5 intends to keep visible but unselectable remain executable.
The bundled fallback AppLibrary lacks the new terminal-app launch path.

The existing check correctly stops at its upstream-model comparison; it does
not prove that every menu route will fail. Required: a deliberate model/provider
merge, preserving Apps inside Velunori and adding tests using the 4.5 definition.

Sources:
[default menu](https://github.com/omacom/omarchy/blob/v4.5.0/default/omarchy/omarchy-menu.jsonc),
[MenuModel](https://github.com/omacom/omarchy/blob/v4.5.0/shell/plugins/menu/MenuModel.js),
[AppLibrary](https://github.com/omacom/omarchy/blob/v4.5.0/shell/services/AppLibrary.qml).

### 4. Notification preferences removed by migration — confirmed data conflict

Migration `1792648436.sh` migrates old DND to the native engine's
`~/.local/state/omarchy/notifications/quiet.json` and deletes
`~/.local/state/omarchy/notifications.json`. Velunori still uses the deleted
file for DND, delivery mode and selected monitor. It does not read the new
quiet.json. Those preferences can reset after the update.

Reproduced the migration in a disposable HOME containing a Velunori version-4
settings fixture: it exited successfully, removed the fixture and created native
quiet.json. No real user settings were used. Velunori's session history is in
its separate runtime directory, so this test does not show that its history
is deleted by this migration.

Required: preserve/import the old preferences before migration and move
Velunori-specific preferences to a Velunori-owned path; preserve compatibility
with the host's DND facade. The old and new native engines have different
history/delivery models, which need a separate integration review.

Source: [migration](https://github.com/omacom/omarchy/blob/v4.5.0/migrations/1792648436.sh).

## Lockscreen service drift — review before upgrading

Velunori intentionally carries the installed Omarchy authentication service
unchanged. The 4.5 service differs substantially: fingerprint retry/probe and
sleep handling, a new FingerprintModel.js, and video-wallpaper support. Its
LockView calls now include `videoPosterPath` and `fingerprintUnavailable`,
which the current Velunori view does not expose.

The exact-service comparison in `lockscreen/scripts/check.sh` fails against
4.5. This is **not evidence that the old service immediately fails to unlock**.
It is evidence that the promised unchanged service is no longer the target's
service. Blindly replacing Service.qml alone would introduce a view-contract
mismatch. Rebase the presentation onto the target service and test its view
without invoking session lock or PAM, then have the user verify unlocking in
the desktop session. No real authentication was tested in this audit.

Source: [4.5 lock service](https://github.com/omacom/omarchy/blob/v4.5.0/shell/plugins/lock/Service.qml).

## Automated checks using 4.5 shared modules

Commands used `OMARCHY_PATH=/tmp/velunori-audit45/target`; copied-layout checks,
current installed Qt/Quickshell binaries, stand-in devices and temporary data.

| Repository | Result | What it establishes |
| --- | --- | --- |
| core | Passed | Model/settings checks and QML lint; not full replacement-bar integration |
| clock | Passed | Backend, calendar models and offscreen QML |
| control-center | Passed | Backend/model/UI checks, including wheel events and preview recovery |
| notifications | Passed | Existing notification logic and mocked offscreen UI |
| weather | Passed | City storage, independent forecast fixtures and offscreen UI |
| update | UI checks passed | `VELUNORI_TEST_UI_ONLY=1`; real update and updater runner integration not executed |
| theme | Passed | Palette, stubbed installer/rollback, Lua stub and the target's native template renderer |
| menu | Stopped | Upstream MenuModel.js equality guard detects target drift |
| lockscreen | Stopped | Exact authentication-service equality guard detects target drift |

Logs are in `/tmp/velunori-audit45/*.log`. These passing tests do not erase
the confirmed semantic conflicts above, validate account authentication, or
certify a future package's native runtime.

The reported 4.5 BarIconButton composite-content shrink is not a direct match
for our own launchers/graphs, which use WidgetButton. Third-party or native
widgets hosted in Velunori still need a real placement/input check.
[Upstream report](https://github.com/omacom/omarchy/issues/17794).

The previously diagnosed OmarchyLoadPatch scanner race remains unresolved
by this audit: omarchy-pkgs PR 1667 was still open/unmerged when checked.
Do not claim that updating to 4.5 fixes the known native crash.
[Stability evidence](stability.md),
[upstream PR](https://github.com/omacom/omarchy-pkgs/pull/1667).

## Recommendation

Finish workspace/block support, six-section bar compatibility, menu integration
and notification-preference preservation before recommending this machine's
upgrade with all Velunori plugins active. Review/rebase the lockscreen separately.
Then repeat checks against the exact package sources/binaries and verify the
real desktop (both monitors, hotplug, Preview/Keep/Revert, Apps, DND, history,
theme switching and unlock). The snapshot made by the normal updater is useful
recovery, not a substitute for these compatibility fixes.
