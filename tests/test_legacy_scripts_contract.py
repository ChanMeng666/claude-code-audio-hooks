"""Contract tests for the legacy script-install path.

``scripts/install-complete.sh`` and ``scripts/uninstall.sh`` each carry a
hand-written list of Claude Code event names, and nothing validated either one
until this module existed. Both had silently drifted:

  * ``install-complete.sh`` registered 20 of the 28 events the plugin template
    registers — missing the four v5.0 events (``PermissionDenied``,
    ``CwdChanged``, ``FileChanged``, ``TaskCreated``) and all four v6.2 ones
    (``Setup``, ``UserPromptExpansion``, ``PostToolBatch``, ``MessageDisplay``).
    A script install was quietly less capable than a plugin install.

  * ``uninstall.sh`` knew only 9 events, in two separate lists that disagreed
    with each other. Uninstalling therefore left 19 orphaned registrations in
    ``~/.claude/settings.json`` pointing at scripts that no longer existed —
    the worse of the two bugs, because it outlives the uninstall.

The authority is ``plugins/audio-hooks/hooks/hooks.json``: whatever the plugin
registers, the script installer must be able to register and the uninstaller
must be able to remove.

Run with::

    python -m unittest discover tests
"""

from __future__ import annotations

import json
import re
import unittest
from pathlib import Path
from typing import Set

REPO_ROOT = Path(__file__).resolve().parent.parent
CC_TEMPLATE = REPO_ROOT / "plugins" / "audio-hooks" / "hooks" / "hooks.json"
INSTALL_SH = REPO_ROOT / "scripts" / "install-complete.sh"
UNINSTALL_SH = REPO_ROOT / "scripts" / "uninstall.sh"


def _authoritative_events() -> Set[str]:
    """Claude Code event names the plugin template registers."""
    data = json.loads(CC_TEMPLATE.read_text(encoding="utf-8"))
    return set(data["hooks"].keys())


class TestLegacyScriptEventCoverage(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.expected = _authoritative_events()
        cls.install_src = INSTALL_SH.read_text(encoding="utf-8")
        cls.uninstall_src = UNINSTALL_SH.read_text(encoding="utf-8")

    def test_authority_is_non_trivial(self) -> None:
        """Guard the guard: if the template ever fails to parse, the other
        assertions would pass vacuously against an empty set."""
        self.assertGreaterEqual(len(self.expected), 25)

    def test_install_script_registers_every_event(self) -> None:
        block = re.search(
            r"all_hook_types\s*=\s*\{(.*?)\n    \}", self.install_src, re.DOTALL
        )
        self.assertIsNotNone(block, "all_hook_types dict not found")
        found = set(re.findall(r"'([A-Za-z]+)':\s*'[a-z_]+'", block.group(1)))
        self.assertEqual(
            self.expected - found,
            set(),
            "install-complete.sh cannot register events the plugin registers",
        )

    def test_uninstall_bash_array_covers_every_event(self) -> None:
        block = re.search(r"HOOK_EVENTS=\((.*?)\)", self.uninstall_src, re.DOTALL)
        self.assertIsNotNone(block, "HOOK_EVENTS array not found")
        found = set(re.findall(r'"([A-Za-z]+)"', block.group(1)))
        self.assertEqual(
            self.expected - found,
            set(),
            "uninstall.sh would leave orphaned hook registrations behind",
        )

    def test_uninstall_python_list_covers_every_event(self) -> None:
        block = re.search(
            r"hook_events\s*=\s*\[(.*?)\]", self.uninstall_src, re.DOTALL
        )
        self.assertIsNotNone(block, "hook_events list not found")
        found = set(re.findall(r'"([A-Za-z]+)"', block.group(1)))
        self.assertEqual(
            self.expected - found,
            set(),
            "uninstall.sh's embedded Python would leave registrations behind",
        )

    def test_uninstall_lists_agree_with_each_other(self) -> None:
        """The two lists are used on different code paths; a value in one but
        not the other is how they drifted apart in the first place."""
        bash = set(
            re.findall(
                r'"([A-Za-z]+)"',
                re.search(r"HOOK_EVENTS=\((.*?)\)", self.uninstall_src, re.DOTALL).group(1),
            )
        )
        py = set(
            re.findall(
                r'"([A-Za-z]+)"',
                re.search(r"hook_events\s*=\s*\[(.*?)\]", self.uninstall_src, re.DOTALL).group(1),
            )
        )
        self.assertEqual(bash, py, "uninstall.sh's two event lists disagree")


if __name__ == "__main__":
    unittest.main()
