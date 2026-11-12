# Stability investigation — 2026-11-12

## Crash evidence

The crash at 15:39:20 CET (PID 571875) was SIGSEGV in the QML loader thread.
The stack shows `QDir::canonicalPath` → `comparesEqual(QDir, QDir)` → unresolved
Quickshell frames → `QQmlImports::resolveType`. The next shell instance loaded.
Installed: Omarchy 4.0.6-1, Quickshell 0.3.2.r7.g2b4501a-1, Qt 6.12.0.

This matches the signature and affected versions in
[Omarchy issue 16167](https://github.com/omacom/omarchy/issues/16167).
The [Omarchy patch](https://github.com/omacom/omarchy-pkgs/blob/master/pkgbuilds/quickshell/load_qtquick_611.patch)
calls the shared scanner from the URL interceptor without synchronization.
[PR 1667](https://github.com/omacom/omarchy-pkgs/pull/1667) addresses that race;
it was still open when checked on 2026-11-12.

The local crash is consistent with this race. The unresolved Quickshell frames
have not been symbolized and the native race has not been reproduced locally
under a debugger. This is a strongly supported diagnosis, not memory-level
proof for this individual crash. Moving plugins and clean smoke tests cannot
prove the host race is fixed. No system binary or package was changed.

## Velunori import fixes

The scanner resolves directory imports through filesystem symlinks. With
`plugins/velunori.clock -> ~/dev/Velunori/clock`, `../velunori.core/kit` also needs
the physical sibling `~/dev/Velunori/velunori.core`. A helper now creates the
alias `velunori.core -> core`, refusing to replace unrelated paths. Both local
installers call it. Actual clones named after manifest IDs need no extra alias.

Kit, components, design tokens and clock now have explicit `qmldir` files.
They no longer depend on synthesized module declarations for dotted plugin
directories. These changes fix import warnings, not the independent C++ race.

## Checks

```bash
bash core/scripts/check.sh
VELUNORI_TEST_STARTS=3 bash clock/scripts/check.sh
VELUNORI_TEST_LAYOUT=symlink VELUNORI_TEST_STARTS=3 bash clock/scripts/check.sh
```

UI harnesses enable `OmarchyLoadPatch`, as the real shell does. Clock checks
cover copied and symlinked installations and reject unresolvable Velunori
imports. They exercise live themes, calendar navigation, leap years and DST.
Core tests cover preview/cancel and click forwarding. Finite headless starts
cannot certify freedom from timing-dependent native failures.

Desktop IPC and Wayland are inaccessible to the restricted development process.
Run in the desktop terminal:

```bash
bash ~/dev/Velunori/clock/scripts/check-session.sh --restart
```

This restarts once, waits for visible clock geometry, opens and closes the
calendar through the host, and fails if a new crash report appears even if the
shell recovers. Widget layout and appearance settings are preserved.

Manual compositor checks remain: Island/Orbit preview, Cancel, Apply; click the
clock, navigate a month, use Today, dismiss with Escape and outside click, and
switch to another widget panel. Repeat on each monitor where applicable.

## Remaining blocker

The affected host package remains installed. A supported host fix needs to be
verified before calling this installation crash-free. No system update was
performed; a generic Omarchy update is not claimed to include PR 1667.
