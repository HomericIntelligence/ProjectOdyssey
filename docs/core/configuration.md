# Configuration

ML Odyssey uses a modern configuration approach with environment management via Pixi, code quality
checks via pre-commit hooks, and documentation site configuration via MkDocs.

## Overview

The project manages three main areas of configuration:

- **Environment Management**: Dependencies and tool versions via Pixi
- **Code Quality**: Automated linting and formatting via pre-commit hooks
- **Documentation**: Site structure and theme via MkDocs
- **Markdown Linting**: Style rules for documentation via markdownlint

## Pixi Configuration (pixi.toml)

Pixi manages the Python environment and Mojo toolchain. The workspace configuration specifies:

```toml
```toml

[workspace]
channels = ["<https://conda.modular.com/max-nightly",> "conda-forge"]
name = "ml-odyssey"
platforms = ["linux-64"]
version = "0.1.0"

```text

### Dependencies

The project requires:

- **Mojo** (>=0.25.7.0.dev2025110405) - ML language and compiler
- **pre-commit** (>=3.5.0) - Git hook framework
- **PyGithub** (>=2.8.1) - GitHub API interaction

### Using Pixi

```bash
```bash

# Activate the environment
pixi shell

# Run a command in the environment
pixi run python3 scripts/script.py

# Install additional packages
pixi add package_name

```text

See [Pixi documentation](https://pixi.sh) for complete reference.

## Pre-commit Hooks

Pre-commit hooks automatically check code quality before commits. Configuration is in `.pre-commit-config.yaml`.

### Configured Hooks

**Markdown Linting**

- Lints markdown files for consistency
- Excludes `notes/plan`, `notes/issues`, `notes/review`, `notes/blog`
- Uses configuration from `.markdownlint.json`

**File Checks**

- Trailing whitespace removal
- End-of-file fixing
- YAML validation
- Large file detection (max 1000KB)
- Mixed line ending fixes

**Mojo Formatting** (Currently Disabled)

- Disabled due to bug in mojo format
- Will be re-enabled when fixed
- See [GitHub issue](https://github.com/modular/modular/issues/5573)

### Using Pre-commit

```bash
```bash

# Install hooks (one-time setup)
pre-commit install

# Run on all files
pre-commit run --all-files

# Run on staged files only
pre-commit run

# Skip hooks (use sparingly)
git commit --no-verify

```text

## Markdown Linting Configuration

File: `.markdownlint.json`

Key settings:

- **Line Length**: 120 characters (excludes code blocks and tables)
- **Heading Style**: ATX format (#, ##, ###)
- **List Indentation**: 2 spaces
- **HTML Elements**: Allows custom elements for documentation

### Markdown Standards

Write markdown following these rules:

1. **Code Blocks**: Specify language, surround with blank lines
2. **Lists**: Surround with blank lines before and after
3. **Headings**: Add blank lines before and after
4. **Line Length**: Keep under 120 characters

Example:

```markdown
```markdown

Some text here.

```python
```python

def hello():
    pass

```text

- Item 1
- Item 2

More text.

```text

## MkDocs Configuration

File: `mkdocs.yml`

### Site Settings

- **Name**: ML Odyssey
- **Description**: Mojo-based AI research platform
- **Repo**: <https://github.com/mvillmow/ml-odyssey>
- **Theme**: Material with Material icons

### Theme Features

- Tabbed navigation
- Expandable sections
- Search highlighting
- Copy-to-clipboard for code blocks
- Light/dark mode toggle

### Navigation Structure

The site is organized in tabs:

- Getting Started (installation, quickstart, first model)
- Core (architecture, workflow, patterns, configuration)
- Advanced (performance, visualization, debugging)
- Development (CI/CD, API reference)
- Integration (papers, shared library)

## Environment Variables

Currently, no environment variables are required for basic setup. Build and deployment processes may define additional variables:

- `GITHUB_TOKEN` - (CI/CD) GitHub API authentication
- `MOJO_NIGHTLY` - (Optional) Use nightly Mojo builds

## Configuration Customization

### Adding Dependencies

```bash
```bash

pixi add package_name

```text

This updates `pixi.toml` and locks dependencies in `pixi.lock`.

### Modifying Pre-commit Hooks

1. Edit `.pre-commit-config.yaml`
2. Reinstall hooks: `pre-commit install`
3. Test: `pre-commit run --all-files`

### Customizing Markdown Rules

Edit `.markdownlint.json` to adjust linting rules. Reference: [markdownlint rules](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md)

### Updating Documentation Theme

Edit `mkdocs.yml` to modify:

- Color scheme (primary, accent colors)
- Navigation structure
- Theme features and plugins

## Configuration Files Reference

| File | Purpose | Audience |
| ------ | --------- | ---------- || `pixi.toml` | Environment management | Developers, CI/CD |
| `.pre-commit-config.yaml` | Code quality checks | Developers |
| `.markdownlint.json` | Markdown style rules | Documentation writers |
| `mkdocs.yml` | Documentation site | Documentation writers |
| `.clinerules` | Claude Code conventions | AI assistants |

## Troubleshooting

**"Mojo not found"** - Ensure you're in the Pixi environment: `pixi shell`

**Pre-commit hook failures** - Run `pre-commit run --all-files` to see all issues, then fix them

**Markdown linting errors** - Check `.markdownlint.json` rules and review your formatting against the markdown standards

**MkDocs build fails** - Verify all referenced files in `nav` section exist and are valid markdown
