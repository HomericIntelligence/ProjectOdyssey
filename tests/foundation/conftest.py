"""
Shared pytest fixtures for foundation test suite.

This module provides common fixtures used across all foundation tests
to ensure consistency and reduce duplication.

Fixtures:
- repo_root: Real repository root directory
- supporting_dirs: All supporting directory paths
"""

import pytest
from pathlib import Path
from typing import Dict


@pytest.fixture
def repo_root() -> Path:
    """
    Provide the real repository root directory for testing.

    Returns:
        Path to the actual repository root directory
    """
    # Navigate up from tests/foundation/ to repository root
    current_file = Path(__file__)
    return current_file.parent.parent.parent


@pytest.fixture
def benchmarks_dir(repo_root: Path) -> Path:
    """
    Provide the benchmarks/ directory path.

    Args:
        repo_root: Real repository root directory

    Returns:
        Path to benchmarks directory
    """
    return repo_root / "benchmarks"


@pytest.fixture
def docs_dir(repo_root: Path) -> Path:
    """
    Provide the docs/ directory path.

    Args:
        repo_root: Real repository root directory

    Returns:
        Path to docs directory
    """
    return repo_root / "docs"


@pytest.fixture
def agents_dir(repo_root: Path) -> Path:
    """
    Provide the agents/ directory path.

    Args:
        repo_root: Real repository root directory

    Returns:
        Path to agents directory
    """
    return repo_root / "agents"


@pytest.fixture
def tools_dir(repo_root: Path) -> Path:
    """
    Provide the tools/ directory path.

    Args:
        repo_root: Real repository root directory

    Returns:
        Path to tools directory
    """
    return repo_root / "tools"


@pytest.fixture
def configs_dir(repo_root: Path) -> Path:
    """
    Provide the configs/ directory path.

    Args:
        repo_root: Real repository root directory

    Returns:
        Path to configs directory
    """
    return repo_root / "configs"


@pytest.fixture
def supporting_dirs(
    benchmarks_dir: Path,
    docs_dir: Path,
    agents_dir: Path,
    tools_dir: Path,
    configs_dir: Path,
) -> Dict[str, Path]:
    """
    Provide dictionary of all supporting directory paths.

    Args:
        benchmarks_dir: Path to benchmarks directory
        docs_dir: Path to docs directory
        agents_dir: Path to agents directory
        tools_dir: Path to tools directory
        configs_dir: Path to configs directory

    Returns:
        Dictionary mapping directory names to their paths
    """
    return {
        "benchmarks": benchmarks_dir,
        "docs": docs_dir,
        "agents": agents_dir,
        "tools": tools_dir,
        "configs": configs_dir,
    }
