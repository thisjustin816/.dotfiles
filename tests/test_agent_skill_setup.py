"""Exercise skill restoration through chezmoi using a disposable home directory."""

import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
HOOK = "run_after_35-export-agent-skills.ps1.tmpl"


class AgentSkillSetupTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.base = Path(temporary.name)
        self.home = self.base / "home"
        self.source = self.base / "source"
        self.source.mkdir()
        self.home.mkdir()
        (self.home / ".claude").mkdir()
        self.repository = self.home / "repos/team-skills"
        self.skill = self.repository / "skills/example-workflow"
        (self.skill / "scripts").mkdir(parents=True)
        (self.skill / "SKILL.md").write_text("upstream instructions\n")
        (self.skill / "scripts/check.ps1").write_text("'supporting file'\n")
        tools = self.repository / "tools"
        tools.mkdir()
        (tools / "Export-Skill.ps1").write_text(
            "param ([string[]]$Name, [string]$Destination)\n"
            "$null = New-Item -ItemType Directory -Path $Destination -Force\n"
            "foreach ($skill in $Name) {\n"
            "    $target = Join-Path $Destination $skill\n"
            "    if (-not (Test-Path -LiteralPath $target)) {\n"
            "        Copy-Item -LiteralPath (Join-Path $PSScriptRoot '../skills' $skill) "
            "-Destination $target -Recurse\n"
            "    }\n"
            "}\n"
        )
        hook = ROOT / "home/.chezmoiscripts" / HOOK
        if hook.exists():
            target = self.source / ".chezmoiscripts"
            target.mkdir()
            shutil.copy2(hook, target / HOOK)
        self.config = self.base / "config.json"
        self.config.write_text(json.dumps({
            "sourceDir": str(self.source),
            "destDir": str(self.home),
            "data": {"repositories": {
                "ordinary": {"path": "repos/project"},
                "team": {
                    "path": "repos/team-skills",
                    "skills": ["example-workflow"],
                },
            }},
        }))
        self.env = {**os.environ, "HOME": str(self.home)}

    def apply(self, check=True):
        result = subprocess.run([
            "chezmoi", "--config", str(self.config), "--persistent-state",
            str(self.base / "state.boltdb"), "apply", "--no-tty",
        ], env=self.env, capture_output=True, text=True)
        if check:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        return result

    def installed(self, tool=".agents"):
        return self.home / tool / "skills/example-workflow"

    def test_exports_supporting_files_and_mirrors_to_claude(self):
        self.apply()
        for tool in (".agents", ".claude"):
            target = self.installed(tool)
            self.assertEqual((target / "SKILL.md").read_bytes(), (self.skill / "SKILL.md").read_bytes())
            self.assertTrue((target / "scripts/check.ps1").is_file())

    def test_preserves_portable_edits_and_mirrors_from_portable(self):
        portable = self.installed()
        shutil.copytree(self.skill, portable)
        (portable / "SKILL.md").write_text("personal instructions\n")
        self.apply()
        self.assertEqual((portable / "SKILL.md").read_text(), "personal instructions\n")
        self.assertEqual((self.installed(".claude") / "SKILL.md").read_text(), "personal instructions\n")
        (self.installed(".claude") / "SKILL.md").write_text("runtime edits\n")
        self.apply()
        self.assertEqual((self.installed(".claude") / "SKILL.md").read_text(), "runtime edits\n")

    def test_restores_missing_skill_on_next_apply(self):
        self.apply()
        shutil.rmtree(self.installed())
        shutil.rmtree(self.installed(".claude"))
        self.apply()
        self.assertTrue((self.installed() / "scripts/check.ps1").is_file())
        self.assertTrue((self.installed(".claude") / "scripts/check.ps1").is_file())

    def test_does_not_create_claude_when_not_installed(self):
        (self.home / ".claude").rmdir()
        self.apply()
        self.assertTrue((self.installed() / "SKILL.md").is_file())
        self.assertFalse((self.home / ".claude").exists())

    def test_repository_path_keeps_literal_quotes_and_dollars(self):
        repository = self.home / "repos/team's-$skills"
        self.repository.rename(repository)
        config = json.loads(self.config.read_text())
        config["data"]["repositories"]["team"]["path"] = "repos/team's-$skills"
        self.config.write_text(json.dumps(config))
        self.apply()
        self.assertTrue((self.installed() / "scripts/check.ps1").is_file())

    def test_reports_incomplete_install_without_overwriting(self):
        portable = self.installed()
        portable.mkdir(parents=True)
        (portable / "SKILL.md").write_text("personal instructions\n")
        result = self.apply(check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("incomplete", result.stdout + result.stderr)
        self.assertEqual((portable / "SKILL.md").read_text(), "personal instructions\n")

    def test_reports_missing_exporter(self):
        (self.repository / "tools/Export-Skill.ps1").unlink()
        result = self.apply(check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("exporter is missing", result.stdout + result.stderr)

    def test_reports_missing_source_skill(self):
        (self.skill / "SKILL.md").unlink()
        result = self.apply(check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("is missing from", result.stdout + result.stderr)

    def test_repository_export_preserves_selected_skills(self):
        repositories = self.home / "repos"
        checkout = repositories / "selected"
        checkout.mkdir()
        for arguments in (
            ["git", "init", str(checkout)],
            ["git", "-C", str(checkout), "remote", "add", "origin", "https://example.invalid/selected.git"],
        ):
            subprocess.run(arguments, check=True, capture_output=True)
        # Only this fixture has a Git marker, so the unrelated skill source is omitted.
        manifest = self.base / "repositories.local.json"
        manifest.write_text(json.dumps({"repositories": {"selected": {
            "path": "repos/selected", "skills": ["example-workflow"],
        }}}))
        result = subprocess.run([
            "pwsh", "-NoLogo", "-NoProfile", "-File",
            str(ROOT / "scripts/Export-RepositoryManifest.ps1"),
            "-RepositoriesRoot", str(repositories), "-OutputPath", str(manifest),
        ], env=self.env, text=True, capture_output=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        actual = json.loads(manifest.read_text())["repositories"]["selected"]
        self.assertEqual(actual["skills"], ["example-workflow"])


if __name__ == "__main__":
    unittest.main()
