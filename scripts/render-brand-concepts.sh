#!/usr/bin/env bash
set -euo pipefail
repo_dir=$(cd "$(dirname "$0")/.." && pwd -P)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
env -u WAYLAND_DISPLAY -u DISPLAY XDG_RUNTIME_DIR="$work" \
  QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME=generic QT_QUICK_BACKEND=software \
  VELUNORI_CONCEPTS_PATH="${VELUNORI_CONCEPTS_PATH:-$repo_dir/docs/brand-concepts.png}" \
  timeout 10s quickshell -p "$repo_dir/docs/brand-concepts.qml" --no-color > "$work/render.log" 2>&1 || { cat "$work/render.log"; exit 1; }
cat "$work/render.log"
rg -q CONCEPTS_SAVED "$work/render.log"
! rg -q 'CONCEPTS_FAILED|Failed to load|ReferenceError|TypeError|Unable to assign|Error decoding|Cannot open' "$work/render.log"
