#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
node tests/appearance.test.mjs
/usr/lib/qt6/bin/qmllint components/*.qml design/Tokens.qml
runtime_dir=$(mktemp -d)
trap 'rm -rf "$runtime_dir"' EXIT
chmod 700 "$runtime_dir"
mkdir -p "$runtime_dir/imports/qs"
shell_root="${OMARCHY_PATH:-/usr/share/omarchy}/shell"
ln -s "$shell_root/Commons" "$runtime_dir/imports/qs/Commons"
ln -s "$shell_root/Ui" "$runtime_dir/imports/qs/Ui"
# The inherited host uses dynamically injected QObjects and flag enums; keep
# their type-inference diagnostics informational, while enforcing other checks.
/usr/lib/qt6/bin/qmllint -I "$runtime_dir/imports" \
  --unqualified info --missing-property info --incompatible-type info \
  Bar.qml kit/*.qml > "$runtime_dir/bar-lint.log" 2>&1 || {
    cat "$runtime_dir/bar-lint.log"
    exit 1
  }
ln -s "$PWD/components" "$runtime_dir/components"
ln -s "$PWD/design" "$runtime_dir/design"
ln -s "$PWD/kit" "$runtime_dir/kit"
ln -s "$shell_root/Commons" "$runtime_dir/Commons"
ln -s "$shell_root/Ui" "$runtime_dir/Ui"
sed -e 's|"../components"|"components"|' -e 's|"../kit"|"kit"|' tests/settings.qml > "$runtime_dir/shell.qml"
env -u WAYLAND_DISPLAY -u DISPLAY XDG_RUNTIME_DIR="$runtime_dir" \
  QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME=generic \
  QT_QUICK_CONTROLS_STYLE=Basic QT_QUICK_BACKEND=software \
  timeout 10s quickshell -p "$runtime_dir/shell.qml" --no-color > "$runtime_dir/settings.log" 2>&1 || {
    cat "$runtime_dir/settings.log"
    exit 1
  }
cat "$runtime_dir/settings.log"
rg -q 'SETTINGS_TEST_PASSED' "$runtime_dir/settings.log"
if rg -q 'SETTINGS_TEST_FAILED|Failed to load|ReferenceError|TypeError|Binding loop|Unable to assign' "$runtime_dir/settings.log"; then
  exit 1
fi
