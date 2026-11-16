import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class LibraryInstallTests(unittest.TestCase):
    def run_script(self, script, home, *args):
        return subprocess.run(['bash', str(ROOT / 'scripts' / script), *map(str,args)],
            env={**os.environ,'HOME':str(home),'XDG_CONFIG_HOME':str(home/'config')},
            capture_output=True,text=True)

    def test_copy_installs_library_without_plugin_or_shell_changes(self):
        with tempfile.TemporaryDirectory() as temporary:
            home=Path(temporary);config=home/'config/omarchy';config.mkdir(parents=True)
            shell=config/'shell.json';shell.write_text('{"bar":{"id":"omarchy.bar"}}')
            before=shell.read_bytes()
            result=self.run_script('install-local.sh',home)
            self.assertEqual(result.returncode,0,result.stderr)
            target=config/'plugins/lib'
            self.assertFalse(target.is_symlink())
            self.assertTrue((target/'kit/Panel.qml').is_file())
            self.assertFalse((target/'manifest.json').exists())
            self.assertEqual(shell.read_bytes(),before)
            self.assertFalse(any(p.is_symlink() for p in home.rglob('*')))
            self.assertEqual(self.run_script('check-install.sh',home).returncode,0)

    def test_existing_library_is_not_overwritten(self):
        with tempfile.TemporaryDirectory() as temporary:
            home=Path(temporary);target=home/'config/omarchy/plugins/lib';target.mkdir(parents=True)
            sentinel=target/'mine';sentinel.write_text('keep')
            result=self.run_script('install-local.sh',home)
            self.assertNotEqual(result.returncode,0)
            self.assertEqual(sentinel.read_text(),'keep')

    def test_missing_sibling_is_reported_without_creating_alias(self):
        with tempfile.TemporaryDirectory() as temporary:
            home=Path(temporary);consumer=home/'control-center';consumer.mkdir()
            result=self.run_script('check-consumer.sh',home,consumer)
            self.assertNotEqual(result.returncode,0)
            self.assertFalse((home/'lib').exists())
            self.assertFalse((home/'velunori.lib').exists())


if __name__=='__main__':
    unittest.main()
