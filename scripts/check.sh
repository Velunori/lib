#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd -P)
bash "$root/scripts/check-install.sh"
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s "$root/tests" -p 'test_*.py' -v
node "$root/tests/appearance.test.mjs"
node "$root/tests/panel-geometry.test.mjs"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
chmod 700 "$work"
shell_root="${OMARCHY_PATH:-/usr/share/omarchy}/shell"
mkdir -p "$work/imports/qs"
for module in Commons Ui; do
  ln -s "$shell_root/$module" "$work/imports/qs/$module"
  ln -s "$shell_root/$module" "$work/$module"
done
cp -r "$root/kit" "$root/design" "$root/components" "$root/assets" "$work/"
/usr/lib/qt6/bin/qmllint -I "$work/imports" --unqualified info --missing-property warning --incompatible-type info \
  "$work/kit/"*.qml "$work/components/"*.qml "$work/design/"*.qml > "$work/lint.log" 2>&1 || { cat "$work/lint.log"; exit 1; }
cp "$root/tests/library.qml" "$work/shell.qml"
env -u DISPLAY -u WAYLAND_DISPLAY XDG_RUNTIME_DIR="$work" XDG_CONFIG_HOME="$work/config" XDG_DATA_HOME="$work/data" \
  QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME=generic QT_QUICK_BACKEND=software QT_QUICK_CONTROLS_STYLE=Basic \
  timeout 15s quickshell -p "$work/shell.qml" --no-color > "$work/ui.log" 2>&1 || { cat "$work/ui.log"; exit 1; }
cat "$work/ui.log"
rg -q LIBRARY_TEST_PASSED "$work/ui.log"
! rg -q 'LIBRARY_TEST_FAILED|Failed to load|ReferenceError|TypeError|Binding loop|Unable to assign' "$work/ui.log"
if [[ -n ${VELUNORI_PREVIEW_PATH:-} ]]; then
  sed 's|"../kit"|"kit"|' "$root/tests/branding.qml" > "$work/branding.qml"
  env -u DISPLAY -u WAYLAND_DISPLAY XDG_RUNTIME_DIR="$work" VELUNORI_BRAND_PREVIEW_PATH="$VELUNORI_PREVIEW_PATH" \
    QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME=generic QT_QUICK_BACKEND=software \
    timeout 15s quickshell -p "$work/branding.qml" --no-color > "$work/branding.log" 2>&1 || { cat "$work/branding.log"; exit 1; }
  cat "$work/branding.log"
  rg -q BRANDING_PREVIEW_SAVED "$work/branding.log"
fi
