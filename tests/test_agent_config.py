"""Exercise post-sync config application without changing the real user home."""

from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
TEMPLATE = ROOT / 'home/.chezmoiscripts/run_after_45-apply-agent-config.ps1.tmpl'


class AgentConfigTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.script = self.root / 'apply.ps1'
        self.script.write_text('\n'.join(TEMPLATE.read_text().splitlines()[1:-1]) + '\n')

    def apply(self):
        return subprocess.run([
            'pwsh', '-NoProfile', '-File', str(self.script), '-HomeDirectory', str(self.root),
        ], capture_output=True, text=True)

    def test_absent_tools_do_not_create_configuration_repos(self):
        result = self.apply()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertFalse((self.root / '.claude').exists())
        self.assertFalse((self.root / '.codex').exists())

    def test_missing_merger_preserves_existing_runtime(self):
        target = self.root / '.claude/settings.json'
        target.parent.mkdir()
        target.write_text('{"local": true}')
        result = self.apply()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('helper is absent', result.stdout)
        self.assertEqual(target.read_text(), '{"local": true}')

    def test_calls_merger_with_the_selected_home(self):
        helper = self.root / '.claude/scripts/Merge-ClaudeSettings.ps1'
        helper.parent.mkdir(parents=True)
        helper.write_text(
            'param([string]$PortablePath, [string]$SettingsPath)\n'
            'Set-Content -LiteralPath $SettingsPath -Value $PortablePath\n'
        )
        result = self.apply()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual((self.root / '.claude/settings.json').read_text().strip(),
                         str(self.root / '.claude/settings.portable.json'))

    def test_instruction_drift_warns_without_rewriting_tracked_file(self):
        helper = self.root / '.agents/scripts/sync-instructions.py'
        helper.parent.mkdir(parents=True)
        helper.write_text('raise SystemExit(1)\n')
        target = self.root / '.codex/AGENTS.md'
        target.parent.mkdir()
        target.write_text('native instructions')
        result = self.apply()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('Shared instructions need attention', result.stdout)
        self.assertEqual(target.read_text(), 'native instructions')


    def test_skill_drift_is_reported_without_overwriting_local_edits(self):
        checker = self.root / '.agents/scripts/check-skill-sync.py'
        checker.parent.mkdir(parents=True)
        checker.write_text('raise SystemExit(1)\n')
        skill = self.root / '.claude/skills/example/SKILL.md'
        skill.parent.mkdir(parents=True)
        skill.write_text('local variation')
        result = self.apply()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('Claude skill mirrors need attention', result.stdout)
        self.assertEqual(skill.read_text(), 'local variation')


if __name__ == '__main__':
    unittest.main()
