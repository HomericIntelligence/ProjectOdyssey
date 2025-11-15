# Issue #128: [Plan] Update Gitignore - Design and Documentation

## Objective

Update the .gitignore file with comprehensive patterns to exclude generated files, build artifacts, virtual environments, IDE files, and ML-specific temporary files from version control.

## Deliverables

- Detailed specifications for .gitignore patterns organized by category
- Python-specific ignore patterns (bytecode, caches, virtual environments)
- Mojo/MAX-specific build artifact patterns
- IDE and editor ignore patterns (VS Code, PyCharm, Vim, etc.)
- ML-specific ignore patterns (checkpoints, logs, datasets, model weights)
- OS-specific patterns (macOS, Windows, Linux)
- Generated file patterns with clear section organization

## Success Criteria

- [ ] .gitignore file is comprehensive and up-to-date
- [ ] All common generated files are ignored
- [ ] File is organized with clear sections and comments
- [ ] No unnecessary files will be committed
- [ ] Planning documentation includes all pattern categories
- [ ] Rationale for each category is documented

## References

- Source Plan: `/notes/plan/01-foundation/02-configuration-files/03-git-config/01-update-gitignore/plan.md`
- Parent Component: #143 (Git Config)
- Related Issues: #129 (Test), #130 (Impl), #131 (Package), #132 (Cleanup)
- GitHub Repository Standard Gitignore: <https://github.com/github/gitignore>

## Implementation Notes

This planning phase will define the comprehensive set of ignore patterns needed for an ML research project using Mojo and Python. The implementation should prevent accidental commits of large files (datasets, model weights) while maintaining a clean repository structure.

## Design Decisions

### Ignore Pattern Categories

The .gitignore file will be organized into the following sections:

#### 1. Python Artifacts

- **Bytecode**: `__pycache__/`, `*.py[cod]`, `*$py.class`
- **Distribution**: `dist/`, `build/`, `*.egg-info/`, `*.egg`, `wheels/`
- **Virtual Environments**: `venv/`, `env/`, `.venv/`, `ENV/`, `virtualenv/`
- **Package Management**: `pip-log.txt`, `pip-delete-this-directory.txt`, `.pixi/`
- **Testing**: `.pytest_cache/`, `.coverage`, `htmlcov/`, `.tox/`
- **Type Checking**: `.mypy_cache/`, `.pytype/`, `.pyre/`

#### 2. Mojo/MAX Specific Patterns

- **Build Artifacts**: `*.mojopkg`, `*.o`, `*.a`, `*.so`, `*.dylib`, `*.dll`
- **Compilation Cache**: `.mojo_cache/`, `__mojo_cache__/`
- **Generated Files**: `*.ll`, `*.bc` (LLVM intermediate representations)
- **MAX Platform**: `.max/`, `*.maxpkg`
- **Build Directories**: `build/`, `cmake-build-*/`

#### 3. ML Project Specific Patterns

- **Model Checkpoints**: `checkpoints/`, `*.ckpt`, `*.pth`, `*.pt`, `*.h5`, `*.pb`
- **Training Logs**: `logs/`, `tensorboard/`, `runs/`, `wandb/`, `mlruns/`
- **Datasets**: `data/raw/`, `data/processed/`, `datasets/`, `*.csv`, `*.parquet` (large data files)
- **Model Weights**: `weights/`, `models/`, `*.safetensors`, `*.bin`
- **Jupyter Notebooks**: `.ipynb_checkpoints/`, `*.ipynb` (output cells)
- **Experiment Tracking**: `.neptune/`, `.comet/`, `lightning_logs/`

Note: Dataset patterns should be carefully considered - use a whitelist approach for critical small datasets that should be committed.

#### 4. IDE and Editor Patterns

- **VS Code**: `.vscode/`, `*.code-workspace`
- **PyCharm/IntelliJ**: `.idea/`, `*.iml`, `*.iws`
- **Vim/Neovim**: `*.swp`, `*.swo`, `*~`, `.vim/`
- **Emacs**: `*~`, `\#*\#`, `.emacs.d/`
- **Sublime Text**: `*.sublime-workspace`, `*.sublime-project`
- **JetBrains**: `*.iml`, `.idea/`

#### 5. Operating System Patterns

- **macOS**: `.DS_Store`, `.AppleDouble`, `.LSOverride`, `._*`
- **Windows**: `Thumbs.db`, `ehthumbs.db`, `Desktop.ini`, `$RECYCLE.BIN/`
- **Linux**: `.directory`, `*~`, `.fuse_hidden*`, `.nfs*`

#### 6. Build and Development Tools

- **CMake**: `CMakeCache.txt`, `CMakeFiles/`, `cmake_install.cmake`
- **Make**: `*.o`, `*.so`, `*.a`, `Makefile.in`
- **Docker**: `.dockerignore`, `docker-compose.override.yml`
- **Environment**: `.env`, `.env.local`, `*.env` (secrets)
- **Temporary Files**: `*.tmp`, `*.temp`, `*.log`, `*.bak`

### ML Project Specific Patterns (Detailed)

ML projects generate large files that should not be committed:

1. **Model Checkpoints** (can be multi-GB):
   - PyTorch: `*.pth`, `*.pt`, `*.ckpt`
   - TensorFlow: `*.h5`, `*.pb`, `saved_model/`
   - Safetensors: `*.safetensors`

2. **Training Artifacts**:
   - TensorBoard logs: `runs/`, `tensorboard/`
   - Weights & Biases: `wandb/`
   - MLflow: `mlruns/`, `mlartifacts/`

3. **Large Datasets**:
   - Use specific patterns, not blanket `*.csv`
   - Consider: `data/raw/`, `data/processed/` (directories)
   - Whitelist small reference datasets explicitly

4. **Experiment Outputs**:
   - Generated plots: `figures/`, `plots/` (if auto-generated)
   - Intermediate results: `results/tmp/`, `cache/`

### Mojo-Specific Patterns (Detailed)

Mojo is a compiled language, so we need patterns for:

1. **Compilation Artifacts**:
   - Object files: `*.o`
   - Static libraries: `*.a`
   - Shared libraries: `*.so`, `*.dylib`, `*.dll`
   - Package files: `*.mojopkg`

2. **LLVM Intermediate Representations**:
   - LLVM IR: `*.ll`
   - Bitcode: `*.bc`

3. **Build Directories**:
   - Generic build output: `build/`, `out/`
   - CMake build: `cmake-build-debug/`, `cmake-build-release/`

4. **MAX Platform**:
   - MAX packages: `*.maxpkg`
   - MAX cache: `.max/`

5. **Pixi Environment** (already in use):
   - Pixi directory: `.pixi/`
   - Pixi lock file: Should NOT be ignored (keep `pixi.lock`)

### Organization Strategy

The .gitignore file will be structured with:

1. **Clear Section Headers**: Comments like `# Python Artifacts`, `# Mojo/MAX Build`
2. **Subsection Comments**: Group related patterns (e.g., `# Virtual Environments`)
3. **Explanatory Comments**: Add comments for non-obvious patterns
4. **Alphabetical Within Sections**: For easier maintenance
5. **Whitelist Exceptions**: Use `!` prefix for files that should NOT be ignored

Example structure:

```text
# =============================================================================
# Python Artifacts
# =============================================================================

# Bytecode
__pycache__/
*.py[cod]

# Virtual Environments
venv/
.venv/

# =============================================================================
# Mojo/MAX Build Artifacts
# =============================================================================

# Compilation
*.o
*.mojopkg
```

### Special Considerations

1. **Pixi Lock File**: Do NOT ignore `pixi.lock` - it should be committed for reproducibility
2. **Environment Files**: Ignore `.env` but document where secrets should be stored
3. **Test Fixtures**: Do NOT ignore small test datasets in `tests/fixtures/`
4. **Documentation Assets**: Do NOT ignore images/diagrams in `docs/`
5. **CI/CD Artifacts**: May need patterns for GitHub Actions caches

### Best Practices

1. **Be Specific**: Use specific patterns rather than broad wildcards
2. **Comment Reasoning**: Explain why unusual patterns are needed
3. **Whitelist Exceptions**: Use `!pattern` to explicitly include files
4. **Test Coverage**: Ensure test fixtures are not accidentally ignored
5. **Review Regularly**: Update as new tools/frameworks are added

### Pattern Testing Strategy

Before finalizing, test patterns by:

1. Creating sample files matching each pattern
2. Running `git status --ignored` to verify they're caught
3. Checking that legitimate files are NOT ignored
4. Validating with `git check-ignore -v <file>` for specific files

## Next Steps

Once this planning documentation is approved:

1. **Issue #129 (Test)**: Create tests to verify ignore patterns work correctly
2. **Issue #130 (Implementation)**: Update .gitignore with documented patterns
3. **Issue #131 (Packaging)**: Ensure .gitignore is properly integrated
4. **Issue #132 (Cleanup)**: Review and refine patterns based on actual usage
