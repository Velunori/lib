#!/usr/bin/env bash
# Directory imports traverse symlinks physically in the Quickshell scanner.
# A development checkout therefore needs its sibling manifest-ID alias too.
set -euo pipefail
repo_dir=$(cd "$(dirname "$0")/.." && pwd -P)
alias_dir="$(dirname "$repo_dir")/velunori.core"
if [[ "$alias_dir" == "$repo_dir" ]]; then exit 0; fi
if [[ -e "$alias_dir" || -L "$alias_dir" ]]; then
  [[ $(readlink -f "$alias_dir") == "$repo_dir" ]] || {
    echo "Conflicting development alias: $alias_dir" >&2; exit 1;
  }
else
  ln -s "$(basename "$repo_dir")" "$alias_dir"
  echo "Development import alias: $alias_dir"
fi
