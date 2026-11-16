#!/usr/bin/env bash
# Copy a library dependency. No plugin registration, symlinks or bar activation.
set -euo pipefail
repo_dir=$(cd "$(dirname "$0")/.." && pwd -P)
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy"
target="$config_dir/plugins/lib"
bash "$repo_dir/scripts/check-install.sh"
[[ ! -e $target && ! -L $target ]] || {
  echo "Library path already exists; refusing to overwrite: $target" >&2; exit 1;
}
mkdir -p "$config_dir/plugins"
stage=$(mktemp -d "$config_dir/plugins/.lib-XXXXXXXX")
trap 'rm -rf "$stage"' EXIT
cp -r "$repo_dir/kit" "$repo_dir/components" "$repo_dir/design" "$repo_dir/assets" "$repo_dir/scripts" "$stage/"
cp "$repo_dir/library.json" "$repo_dir/LICENSE" "$repo_dir/THIRD_PARTY_NOTICES.md" "$stage/"
mv "$stage" "$target"
echo 'Velunori Library installed. No plugin/bar enabled; shell configuration unchanged.'
