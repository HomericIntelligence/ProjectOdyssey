#!/usr/bin/env python3
"""
Unit tests for scripts/common.py

Tests the shared utility functions used across multiple scripts.
"""

import sys
import unittest
from pathlib import Path

# Add scripts directory to path
sys.path.insert(0, str(Path(__file__).parent.parent / "scripts"))

from common import get_repo_root, get_agents_dir, get_plan_dir, LABEL_COLORS


class TestCommonUtilities(unittest.TestCase):
    """Test suite for common.py utility functions."""

    def test_label_colors_defined(self):
        """Test that all required label colors are defined."""
        required_labels = [
            'planning',
            'documentation',
            'testing',
            'tdd',
            'implementation',
            'packaging',
            'integration',
            'cleanup'
        ]

        for label in required_labels:
            self.assertIn(label, LABEL_COLORS, f"Missing color for label: {label}")
            # Verify color is 6-character hex string
            color = LABEL_COLORS[label]
            self.assertEqual(len(color), 6, f"Color for {label} should be 6 chars")
            self.assertTrue(
                all(c in '0123456789abcdef' for c in color.lower()),
                f"Color for {label} should be hex: {color}"
            )

    def test_get_repo_root_returns_path(self):
        """Test that get_repo_root returns a Path object."""
        repo_root = get_repo_root()

        self.assertIsInstance(repo_root, Path)
        self.assertTrue(repo_root.exists(), "Repo root should exist")
        self.assertTrue(repo_root.is_dir(), "Repo root should be a directory")

    def test_get_repo_root_contains_git(self):
        """Test that repo root contains .git directory."""
        repo_root = get_repo_root()
        git_dir = repo_root / ".git"

        self.assertTrue(
            git_dir.exists(),
            f"Repository root should contain .git directory: {repo_root}"
        )

    def test_get_agents_dir_returns_path(self):
        """Test that get_agents_dir returns a Path object."""
        agents_dir = get_agents_dir()

        self.assertIsInstance(agents_dir, Path)
        self.assertTrue(agents_dir.exists(), "Agents directory should exist")
        self.assertTrue(agents_dir.is_dir(), "Agents directory should be a directory")

    def test_get_agents_dir_relative_to_root(self):
        """Test that agents_dir is .claude/agents relative to repo root."""
        repo_root = get_repo_root()
        agents_dir = get_agents_dir()

        expected = repo_root / ".claude" / "agents"
        self.assertEqual(
            agents_dir.resolve(),
            expected.resolve(),
            "Agents dir should be .claude/agents"
        )

    def test_get_plan_dir_returns_path(self):
        """Test that get_plan_dir returns a Path object."""
        plan_dir = get_plan_dir()

        self.assertIsInstance(plan_dir, Path)
        # Note: plan_dir might not exist in all environments
        # Just verify it's a Path with the right structure

    def test_get_plan_dir_relative_to_root(self):
        """Test that plan_dir is notes/plan relative to repo root."""
        repo_root = get_repo_root()
        plan_dir = get_plan_dir()

        expected = repo_root / "notes" / "plan"
        self.assertEqual(
            plan_dir.resolve(),
            expected.resolve(),
            "Plan dir should be notes/plan"
        )


class TestLabelColors(unittest.TestCase):
    """Test suite for label color consistency."""

    def test_phase_colors_consistent(self):
        """Test that related phases use consistent colors."""
        # Testing and TDD should use same color
        self.assertEqual(
            LABEL_COLORS['testing'],
            LABEL_COLORS['tdd'],
            "Testing and TDD should use the same color"
        )

        # Packaging and integration should use same color
        self.assertEqual(
            LABEL_COLORS['packaging'],
            LABEL_COLORS['integration'],
            "Packaging and integration should use the same color"
        )

    def test_no_duplicate_colors(self):
        """Test that primary phase labels use unique colors."""
        primary_phases = ['planning', 'testing', 'implementation', 'packaging', 'cleanup']
        colors_used = set()

        for phase in primary_phases:
            color = LABEL_COLORS[phase]
            self.assertNotIn(
                color,
                colors_used,
                f"Color {color} for {phase} is already used"
            )
            colors_used.add(color)


if __name__ == '__main__':
    unittest.main()
