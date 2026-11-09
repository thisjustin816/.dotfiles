"""Exercise the rendered repository script using disposable local Git remotes."""

import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class RepositorySyncTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.base = Path(self.temporary.name)
        self.home = self.base / "home"
        self.source = self.home / "dotfiles"
        self.source.mkdir(parents=True)
        self.env = {
            **os.environ,
            "HOME": str(self.home),
            "XDG_CONFIG_HOME": str(self.home / ".config"),
            "GIT_CONFIG_GLOBAL": os.devnull,
            "GIT_CONFIG_NOSYSTEM": "1",
            "GIT_AUTHOR_NAME": "Sync Test",
            "GIT_AUTHOR_EMAIL": "sync@example.invalid",
            "GIT_COMMITTER_NAME": "Sync Test",
            "GIT_COMMITTER_EMAIL": "sync@example.invalid",
            "GIT_TERMINAL_PROMPT": "0",
        }
        self.remote = self.base / "remote.git"
        self.producer = self.base / "producer"
        self.checkout = self.home / ".config-repo"
        self.git(self.base, "init", "--bare", "--initial-branch=main", str(self.remote))
        self.git(self.base, "clone", str(self.remote), str(self.producer))
        self.commit(self.producer, "initial")
        self.git(self.producer, "push", "origin", "main")
        self.git(self.home, "clone", str(self.remote), str(self.checkout))
        self.original = self.git(self.checkout, "rev-parse", "HEAD")
        self.template = next((ROOT / "home/.chezmoiscripts").glob("*30-sync-repositories.ps1.tmpl"))
        scripts = self.source / ".chezmoiscripts"
        scripts.mkdir()
        shutil.copy2(self.template, scripts / self.template.name)
        self.config = self.base / "chezmoi.json"
        self.configure()

    def run_command(self, *arguments, check=True, **kwargs):
        result = subprocess.run(
            arguments, env=self.env, text=True, capture_output=True, **kwargs
        )
        if check and result.returncode:
            self.fail(f"{arguments}:\n{result.stdout}\n{result.stderr}")
        return result

    def git(self, directory, *arguments):
        return self.run_command("git", "-C", str(directory), *arguments).stdout.strip()

    def commit(self, directory, name):
        (directory / name).write_text(name + "\n")
        self.git(directory, "add", name)
        self.git(directory, "commit", "-m", name)

    def advance_remote(self):
        self.commit(self.producer, "remote-change")
        self.git(self.producer, "push", "origin", "main")
        return self.git(self.producer, "rev-parse", "HEAD")

    def configure(self, relative_path=".config-repo"):
        self.config.write_text(json.dumps({
            "sourceDir": str(self.source),
            "destDir": str(self.home),
            "data": {"repositories": {"test": {
                "path": relative_path,
                "url": str(self.remote),
            }}},
        }))

    def sync(self, check=True):
        return self.run_command(
            "chezmoi", "--config", str(self.config),
            "--persistent-state", str(self.base / "state.boltdb"),
            "apply", "--no-tty", check=check,
        )

    def assert_head(self, expected):
        self.assertEqual(self.git(self.checkout, "rev-parse", "HEAD"), expected)

    def test_clones_missing_repository(self):
        shutil.rmtree(self.checkout)
        self.sync()
        self.assert_head(self.original)

    def test_fetches_and_fast_forwards(self):
        latest = self.advance_remote()
        self.sync()
        self.assert_head(latest)

    def test_checks_again_on_next_apply(self):
        self.sync()
        latest = self.advance_remote()
        self.sync()
        self.assert_head(latest)

    def test_dirty_checkout_is_fetched_but_preserved(self):
        latest = self.advance_remote()
        (self.checkout / "initial").write_text("local edits\n")
        result = self.sync()
        self.assert_head(self.original)
        self.assertEqual(self.git(self.checkout, "rev-parse", "origin/main"), latest)
        self.assertEqual((self.checkout / "initial").read_text(), "local edits\n")
        self.assertIn("uncommitted", result.stdout)

    def test_untracked_files_are_preserved(self):
        self.advance_remote()
        (self.checkout / "untracked").write_text("local\n")
        self.sync()
        self.assert_head(self.original)
        self.assertTrue((self.checkout / "untracked").exists())

    def test_staged_changes_are_preserved(self):
        self.advance_remote()
        (self.checkout / "initial").write_text("staged\n")
        self.git(self.checkout, "add", "initial")
        before = self.git(self.checkout, "diff", "--cached")
        self.sync()
        self.assert_head(self.original)
        self.assertEqual(self.git(self.checkout, "diff", "--cached"), before)

    def test_ahead_checkout_is_not_pushed(self):
        self.commit(self.checkout, "local-change")
        local = self.git(self.checkout, "rev-parse", "HEAD")
        self.sync()
        self.assert_head(local)
        self.assertEqual(self.git(self.remote, "rev-parse", "main"), self.original)

    def test_diverged_checkout_is_reported_without_merge(self):
        self.commit(self.checkout, "local-change")
        local = self.git(self.checkout, "rev-parse", "HEAD")
        latest = self.advance_remote()
        result = self.sync()
        self.assert_head(local)
        self.assertEqual(self.git(self.checkout, "rev-parse", "origin/main"), latest)
        self.assertIn("diverged", result.stdout)

    def test_detached_head_is_preserved(self):
        self.git(self.checkout, "checkout", "--detach")
        self.advance_remote()
        result = self.sync()
        self.assert_head(self.original)
        self.assertIn("detached", result.stdout)

    def test_branch_without_upstream_is_preserved(self):
        self.git(self.checkout, "branch", "--unset-upstream")
        self.advance_remote()
        result = self.sync()
        self.assert_head(self.original)
        self.assertIn("no upstream", result.stdout)

    def test_tracks_the_current_branch_and_remote(self):
        self.git(self.producer, "checkout", "-b", "feature")
        self.git(self.producer, "push", "-u", "origin", "feature")
        self.git(self.checkout, "fetch")
        self.git(self.checkout, "checkout", "--track", "origin/feature")
        self.git(self.checkout, "remote", "rename", "origin", "upstream")
        self.commit(self.producer, "feature-change")
        self.git(self.producer, "push")
        latest = self.git(self.producer, "rev-parse", "HEAD")
        self.sync()
        self.assert_head(latest)
        self.assertEqual(self.git(self.checkout, "branch", "--show-current"), "feature")

    def test_fetch_failure_is_an_error(self):
        self.git(self.checkout, "remote", "set-url", "origin", str(self.base / "missing.git"))
        result = self.sync(check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assert_head(self.original)

    def test_other_repositories_are_not_fetched_or_updated(self):
        latest = self.advance_remote()
        for relative_path in ("project", "repos/.config-repo", ".config/nested-repo"):
            with self.subTest(path=relative_path):
                target = self.home / relative_path
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copytree(self.checkout, target)
                self.configure(relative_path)
                self.sync()
                self.assertEqual(self.git(target, "rev-parse", "HEAD"), self.original)
                self.assertEqual(self.git(target, "rev-parse", "origin/main"), self.original)
                self.assertNotEqual(self.git(target, "rev-parse", "origin/main"), latest)

    def test_missing_project_repository_is_still_cloned(self):
        self.configure("repos/project")
        self.sync()
        self.assertEqual(self.git(self.home / "repos/project", "rev-parse", "HEAD"), self.original)

    def test_skips_chezmoi_source_checkout(self):
        self.git(self.source, "init", "--initial-branch=main")
        self.configure("dotfiles")
        result = self.sync()
        self.assertIn("Skipping chezmoi source checkout", result.stdout)
        self.assertFalse((self.source / ".git/FETCH_HEAD").exists())


if __name__ == "__main__":
    unittest.main()
