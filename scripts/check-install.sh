#!/usr/bin/env bash
# Read-only dependency validation. No plugin/bar activation.
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd -P)
python3 - "$root" <<'PY'
import json,pathlib,sys
root=pathlib.Path(sys.argv[1])
try:
 data=json.loads((root/'library.json').read_text())
 assert data['id']=='velunori.lib' and data['apiVersion']==1
 version=tuple(map(int,data['version'].split('.')))
 assert (1,0,0)<=version<(2,0,0)
 for name in ['kit/Theme.qml','kit/Panel.qml','kit/BrandMark.qml','design/Tokens.qml','components/ActionButton.qml']:
  assert (root/name).is_file(),name
except (OSError,ValueError,KeyError,TypeError,AssertionError) as error:
 sys.exit('Velunori Library API 1 (version 1.x) is required: '+str(error))
PY
