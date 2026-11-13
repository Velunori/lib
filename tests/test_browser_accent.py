import importlib.util
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('browser_accent', Path(__file__).parents[1] / 'scripts/browser-accent.py')
bridge = importlib.util.module_from_spec(spec)
spec.loader.exec_module(bridge)


class BrowserAccentTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.home = Path(self.temp.name)
        self.current = self.home / '.local/state/omarchy/current'
        (self.current / 'theme').mkdir(parents=True)
        self.source = self.home / '.config/omarchy/themes/velunori'
        self.source.mkdir(parents=True)
        (self.current / 'theme.name').write_text('velunori')
        self.policy = self.home / 'policy/color.json'
        self.policy.parent.mkdir()
        self.policy.write_text('{"BrowserThemeColor":"#202026"}')
        self.policy_patch = patch.object(bridge, 'POLICY', self.policy)
        self.policy_patch.start()
        self.saved('mint')

    def saved(self, accent):
        (self.home / '.config/omarchy/shell.json').write_text(json.dumps({'bar': {'velunori': {'accent': accent}}}))

    def tearDown(self):
        self.policy_patch.stop()
        self.temp.cleanup()

    def run_command(self, args, **kwargs):
        if args[0] == 'sudo':
            self.assertEqual(args[:3], ['sudo', '-n', '/usr/bin/omarchy-theme-set-browser-policy'])
            self.policy.write_text(json.dumps({'BrowserThemeColor': '#' + args[-1]}))
        return subprocess.CompletedProcess(args, 0)

    def test_saved_accent_updates_policy_and_persists_theme_without_restarting_browser(self):
        with patch.object(bridge.subprocess, 'run', side_effect=self.run_command) as runner, patch.object(bridge.shutil, 'which', return_value='/usr/bin/chromium'):
            self.assertTrue(bridge.synchronize('mint', self.home)['ok'])
            runner.assert_any_call(['chromium', '--refresh-platform-policy', '--no-startup-window'], capture_output=True, timeout=15)
        self.assertEqual(json.loads(self.policy.read_text())['BrowserThemeColor'], '#374242')
        for path in (self.current / 'theme/chromium.theme', self.source / 'chromium.theme'):
            self.assertEqual(path.read_text(), '55,66,66\n')

    def test_other_theme_and_stale_request_do_nothing(self):
        with patch.object(bridge.subprocess, 'run') as runner:
            self.assertTrue(bridge.synchronize('pearl', self.home)['skipped'])
            (self.current / 'theme.name').write_text('catppuccin')
            self.assertTrue(bridge.synchronize('mint', self.home)['skipped'])
            runner.assert_not_called()
        self.assertFalse((self.source / 'chromium.theme').exists())

    def test_repeated_monitor_requests_are_idempotent(self):
        with patch.object(bridge.subprocess, 'run', side_effect=self.run_command) as runner, patch.object(bridge.shutil, 'which', return_value=None):
            bridge.synchronize('mint', self.home)
            bridge.synchronize('mint', self.home)
            self.assertEqual(runner.call_count, 1)

    def test_policy_failure_is_reported_without_recording_success(self):
        with patch.object(bridge.subprocess, 'run', return_value=subprocess.CompletedProcess([], 1)):
            with self.assertRaisesRegex(ValueError, 'permissions'):
                bridge.synchronize('mint', self.home)
        self.assertFalse((self.source / 'chromium.theme').exists())

    def test_failed_refresh_is_retried_even_when_policy_was_already_written(self):
        def failure(args, **kwargs):
            if args[0] == 'chromium':
                return subprocess.CompletedProcess(args, 1)
            return self.run_command(args, **kwargs)
        with patch.object(bridge.subprocess, 'run', side_effect=failure), patch.object(bridge.shutil, 'which', return_value='/usr/bin/chromium'):
            with self.assertRaisesRegex(ValueError, 'Reopen Chromium'):
                bridge.synchronize('mint', self.home)
        with patch.object(bridge.subprocess, 'run', side_effect=self.run_command) as runner, patch.object(bridge.shutil, 'which', return_value='/usr/bin/chromium'):
            bridge.synchronize('mint', self.home)
            runner.assert_any_call(['chromium', '--refresh-platform-policy', '--no-startup-window'], capture_output=True, timeout=15)

    def test_browser_seeds_stay_dark_and_keep_distinct_accent_tints(self):
        seeds = [bridge.browser_seed(name) for name in bridge.ACCENTS]
        self.assertEqual(len(set(seeds)), 3)
        self.assertEqual(bridge.browser_seed('lavender'), '#3e3a4b')
        for color in seeds:
            channels = [int(color[i:i+2], 16) / 255 for i in (1, 3, 5)]
            linear = [value / 12.92 if value <= .04045 else ((value + .055) / 1.055) ** 2.4 for value in channels]
            luminance = sum(a*b for a,b in zip(linear, (.2126,.7152,.0722)))
            self.assertGreater((1.05 / (luminance + .05)), 9, color)

    def test_all_supported_colors_and_invalid_input(self):
        with patch.object(bridge.subprocess, 'run', side_effect=self.run_command), patch.object(bridge.shutil, 'which', return_value=None):
            for name, color in bridge.ACCENTS.items():
                self.saved(name)
                bridge.synchronize(name, self.home)
                self.assertEqual(json.loads(self.policy.read_text())['BrowserThemeColor'], bridge.browser_seed(name))
            with self.assertRaises(ValueError):
                bridge.synchronize('mint; touch /tmp/unsafe', self.home)


if __name__ == '__main__':
    unittest.main()
