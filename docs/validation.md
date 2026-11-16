# Shared library extraction — validation

Checked locally on 2026-11-15. These are uncommitted isolated source changes, not published releases or a desktop deployment.

| Source | Layout | Result |
| --- | --- | --- |
| lib | copy | Passed |
| bar | copy | Passed |
| clock | copy | Passed |
| clock | symlink | Passed |
| control-center | copy | Passed |
| control-center | symlink | Passed |
| notifications | copy | Passed |
| notifications | symlink | Passed |
| menu | copy | Passed |
| menu | symlink | Passed |
| weather | copy | Passed |
| weather | symlink | Passed |
| update | copy | Passed |
| update | symlink | Passed |
| lockscreen | copy | Passed |
| lockscreen | symlink | Passed |
| lieferando | copy | Passed |
| lieferando | symlink | Passed |

Additional evidence:

- All nine native plugin manifests validate with the installed `omarchy plugin validate`. The library intentionally has no runtime plugin manifest.
- Calendar dependency-dependent Python tests: all 17 passed using the existing private workspace environment; no account connections were made.
- Library tests include three copy-install/layout protection checks and offscreen checks of default styling, saved stock-bar styling, scoped service adapters and missing capabilities.
- Control Center checks exercise the stock-style facade without bar appearance callbacks; only Floating Bars settings are hidden, while system-control destinations remain available.
- Core-free temporary consumer layouts contain the feature and shared library, not a core or bar checkout. Both copied and symlinked legacy installation modes are covered without workspace alias directories.
- The final-output race found by the update stand-in test was fixed only in the isolated update source. Backend tests passed three successive runs, followed by both full layout checks. No real update ran.
- The current `core`, clock, Control Center, notifications, menu, weather, lockscreen, theme and update source repositories remained clean throughout.

Environment: Omarchy 4.0.6-1, Quickshell 0.3.2.r7.g2b4501a-1, Qt 6.12.0, Python 3.14.8. Tests needing local IPC/subprocesses ran outside the restricted sandbox, with temporary test data and offscreen rendering.

No new `velunori.lib` workspace symlink exists. `lib/` and `bar/` are real Git working directories. The older `velunori.core` alias existed during these checks, then was removed by the workspace owner. It must not be recreated. This historical validation does not establish that older live imports now resolve without it.

Still pending: publishing the library, renaming the GitHub core repository to bar, committing/pinning coordinated component revisions, migrating the active workspace, and live desktop verification on the stock and Floating Bars hosts. Cloud authentication/synchronization, lock authentication and real system updates are not established by these checks. Finite passes do not establish that the known Qt/Quickshell host crash is fixed.
