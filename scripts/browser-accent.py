#!/usr/bin/env python3
"""Apply a saved Velunori accent through Omarchy's existing browser policy helper."""
import fcntl
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ACCENTS = {'lavender': '#c4aff1', 'mint': '#a0ddbf', 'pearl': '#e8dfd1'}
POLICY = Path('/etc/chromium/policies/managed/color.json')
POLICY_HELPER = '/usr/bin/omarchy-theme-set-browser-policy'


def browser_seed(accent):
    # Chromium generates a whole theme from this seed. A pastel UI accent
    # turns the frame and new-tab page pastel too; keep the seed graphite.
    base = (32, 32, 38)
    color = ACCENTS[accent]
    tint = [int(color[i:i+2], 16) for i in (1, 3, 5)]
    return '#' + ''.join(f'{round(bg * .82 + fg * .18):02x}' for bg, fg in zip(base, tint))


def atomic_write(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(dir=path.parent, prefix='.velunori-')
    try:
        with os.fdopen(fd, 'w') as stream:
            stream.write(text)
        os.replace(temporary, path)
    finally:
        Path(temporary).unlink(missing_ok=True)


def synchronize(accent, home=None):
    if accent not in ACCENTS:
        raise ValueError('Unknown accent')
    home = Path(home or Path.home())
    current = home / '.local/state/omarchy/current'
    try:
        if (current / 'theme.name').read_text().strip() != 'velunori':
            return {'ok': True, 'skipped': True}
    except FileNotFoundError:
        return {'ok': True, 'skipped': True}
    state = home / '.local/state/velunori'
    state.mkdir(parents=True, exist_ok=True)
    # Every monitor has a bar instance. Serialize them and compare the actual
    # policy/files so repeated startups do not reapply an identical accent.
    with (state / 'browser-accent.lock').open('a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        if (current / 'theme.name').read_text().strip() != 'velunori':
            return {'ok': True, 'skipped': True}
        config = home / '.config/omarchy/shell.json'
        if config.exists():
            saved = json.loads(config.read_text()).get('bar', {}).get('velunori', {}).get('accent', 'lavender')
            if saved not in ACCENTS:
                saved = 'lavender'
            if saved != accent:
                return {'ok': True, 'skipped': True}
        color = browser_seed(accent)
        try:
            policy = json.loads(POLICY.read_text())
        except (OSError, ValueError):
            policy = {}
        policy_changed = POLICY.parent.is_dir() and policy.get('BrowserThemeColor') != color
        if policy_changed:
            # No custom privileged code, no password prompt from a bar callback.
            # Omarchy normally grants this exact packaged helper passwordless sudo.
            result = subprocess.run(['sudo', '-n', POLICY_HELPER, color[1:]], capture_output=True, text=True, timeout=20)
            if result.returncode:
                raise ValueError('Could not update the Chromium accent. Check Omarchy browser theme permissions.')
        rgb = ','.join(str(int(color[i:i+2], 16)) for i in (1, 3, 5)) + '\n'
        for path in (current / 'theme/chromium.theme', home / '.config/omarchy/themes/velunori/chromium.theme'):
            if path.parent.is_dir() and (not path.exists() or path.read_text() != rgb):
                atomic_write(path, rgb)
        marker = state / 'browser-accent.json'
        try:
            refreshed = json.loads(marker.read_text()).get('color')
        except (OSError, ValueError):
            refreshed = None
        if (policy_changed or refreshed != color) and shutil.which('chromium'):
            running = subprocess.run(['pgrep', '-x', 'chromium'], capture_output=True, timeout=5)
            if running.returncode == 0:
                result = subprocess.run(['chromium', '--refresh-platform-policy', '--no-startup-window'], capture_output=True, timeout=15)
                if result.returncode:
                    raise ValueError('Chromium accent saved. Reopen Chromium to refresh its appearance.')
        atomic_write(marker, json.dumps({'color': color}))
        return {'ok': True, 'accent': accent}


if __name__ == '__main__':
    try:
        print(json.dumps(synchronize(json.loads(sys.stdin.readline()).get('accent'))))
    except Exception as error:
        message = str(error) if isinstance(error, ValueError) else 'Could not synchronize the Chromium accent.'
        print(json.dumps({'ok': False, 'error': message}))
        sys.exit(1)
