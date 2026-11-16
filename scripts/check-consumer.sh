#!/usr/bin/env bash
# Check physical sibling imports without creating any directory aliases.
set -euo pipefail
consumer_dir=$(cd "$1" && pwd -P)
sibling="$(dirname "$consumer_dir")/lib"
[[ -f $sibling/scripts/check-install.sh ]] || {
  echo "Missing shared library beside source checkout: $sibling. Keep lib/ and plugin repositories beside each other." >&2
  exit 1
}
bash "$sibling/scripts/check-install.sh"
