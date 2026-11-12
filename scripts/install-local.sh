#!/usr/bin/env bash
# Run from your terminal: links this checkout and activates the replacement bar.
set -euo pipefail
repo_dir=$(cd "$(dirname "$0")/.." && pwd -P)
bash "$repo_dir/scripts/prepare-dev-layout.sh"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy"
plugin_dir="$config_dir/plugins/velunori.core"
for executable in omarchy omarchy-shell python3; do
  command -v "$executable" >/dev/null || { echo "Missing: $executable" >&2; exit 1; }
done
if [[ -e "$plugin_dir" || -L "$plugin_dir" ]]; then
  [[ -L "$plugin_dir" && $(readlink -f "$plugin_dir") == "$repo_dir" ]] || {
    echo "Refusing to overwrite $plugin_dir" >&2
    exit 1
  }
fi
[[ $(omarchy-shell shell ping) == ok ]] || { echo 'Omarchy shell is not running.' >&2; exit 1; }
mkdir -p "$config_dir/plugins"
if [[ -f "$config_dir/shell.json" ]]; then
  backup=$(mktemp "$config_dir/shell.json.before-velunori.XXXXXXXX")
  cp -p "$config_dir/shell.json" "$backup"
  echo "Configuration backup: $backup"
fi
[[ -L "$plugin_dir" ]] || ln -s "$repo_dir" "$plugin_dir"
omarchy-shell shell rescanPlugins
discovered=false
for attempt in {1..25}; do
  if omarchy-shell shell listPlugins | python3 -c '
import json, sys
plugins = json.load(sys.stdin)
sys.exit(0 if any(p.get("id") == "velunori.core" for p in plugins) else 1)
'; then
    discovered=true
    break
  fi
  sleep 0.2
done
[[ "$discovered" == true ]] || { echo 'Plugin discovery failed; original bar remains selected.' >&2; exit 1; }
omarchy plugin enable velunori.core
echo 'Velunori enabled. Open appearance settings with:'
echo '  omarchy-shell velunori settings'
echo 'Return to the original bar with:'
echo '  omarchy plugin enable omarchy.bar'
