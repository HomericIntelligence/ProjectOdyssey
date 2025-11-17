# Tool Integration Guide

## Overview

ML Odyssey integrates multiple tools and external systems while maintaining clean boundaries and
performance. The integration philosophy emphasizes:

- **Pragmatic Language Selection**: Mojo for ML/AI, Python for automation with external tools
- **Clean Interfaces**: Well-defined boundaries between components
- **Error Handling**: Graceful degradation when external tools unavailable
- **Testability**: Integration layers mockable for unit testing

## Python Integration

### Calling Python from Mojo

Use `PythonObject` for Python library integration:

```mojo
```mojo

fn load_dataset(path: String) -> PythonObject:
    var np = Python.import_module("numpy")
    var arr = np.load(path)
    return arr

fn process_with_sklearn(data: PythonObject) -> PythonObject:
    var sklearn = Python.import_module("sklearn.preprocessing")
    var scaler = sklearn.StandardScaler()
    return scaler.fit_transform(data)

```python

### Best Practices

- Import modules once, reuse across function calls
- Handle `ImportError` for optional dependencies
- Convert between Mojo Tensors and NumPy arrays at boundaries
- Document Python version requirements in `pyproject.toml`

### Performance Considerations

- Minimize data copying between Mojo and Python
- Batch Python calls to reduce overhead
- Keep hot loops in Mojo, use Python for initialization/serialization

## External Tools Integration

### Git Integration

```bash
```bash

# Programmatic access via subprocess
git_output=$(git log --oneline -n 10)
git_status=$(git status --porcelain)

```text

Use `subprocess` module in Python scripts for git operations. Avoid shell escaping issues.

### GitHub CLI Integration

```bash
```bash

# Creating issues
gh issue create --title "..." --body "..." --label "feature"

# Checking PR status
gh pr checks PR_NUMBER

# Viewing issue details
gh issue view ISSUE_NUMBER --json title,body,state

```text

Recommended for automation: `gh pr create --issue NUMBER` links PRs to issues automatically.

### Pre-commit Hooks

Configuration in `.pre-commit-config.yaml`:

```yaml
```yaml

- repo: local
- repo: local

  hooks:

    - id: mojo-format
    - id: mojo-format

      name: Mojo formatter
      entry: mojo format
      language: system
      types: [mojo]

```text

Run hooks before commit:

```bash
```bash

pre-commit run --all-files

```text

## CI/CD Integration

### GitHub Actions Workflows

Structure in `.github/workflows/`:

```yaml
```yaml

name: Test Suite
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:

      - uses: actions/checkout@v4
      - uses: modularml/mojo@nightly
      - run: mojo test main.mojo

```text

### Status Checks

Integrate with PR workflow:

- Unit tests must pass
- Code formatting must pass pre-commit
- Documentation builds successfully
- Performance benchmarks tracked

Monitor with `gh pr checks PR_NUMBER`.

## Data Pipeline Integration

### Input Sources

- Local files: Direct file I/O in Mojo
- Remote data: Python `requests` library for HTTP
- Database systems: Python connector libraries
- Cloud storage: Python `boto3` for AWS, `google-cloud-storage`

### Output Destinations

- Local files: Mojo file operations
- Databases: Python ORM layers (SQLAlchemy)
- Cloud storage: Python cloud SDKs
- Monitoring systems: HTTP POST to metrics endpoints

### Error Handling

```mojo
```mojo

fn process_pipeline(input_path: String) raises -> Tensor:
    try:
        var data = load_data(input_path)
        return transform(data)
    except:
        print("Pipeline failed, using fallback")
        return default_tensor()

```text

## Monitoring and Logging

### Application Logging

Use structured logging:

```python
```python

import logging

logger = logging.getLogger(__name__)
logger.info("Training started", extra={"epoch": 0})
logger.warning("High loss detected", extra={"loss": 1.5})

```text

### Metrics Collection

Track during training:

```mojo
```mojo

fn train_step(inout model: Model, batch: Tensor) -> Float32:
    var loss = forward(model, batch)
    # Log to monitoring system
    log_metric("train_loss", loss)
    return loss

```text

### Health Checks

Implement periodic health monitoring:

```bash
```bash

# Check system resources
df -h  # Disk space
free -h  # Memory
nvidia-smi  # GPU status (if applicable)

```text

## Best Practices

### 1. Dependency Management

- Specify versions in `pyproject.toml`
- Use virtual environments (Pixi for this project)
- Document minimum Mojo version required
- Pin transitive dependencies for reproducibility

### 2. Error Recovery

- Implement retry logic with exponential backoff
- Provide meaningful error messages
- Log full stack traces to files
- Fail fast on unrecoverable errors

### 3. Testing Integration

```python
```python

# Mock external tools in tests
@pytest.fixture
def mock_git(monkeypatch):
    def mock_run(*args, **kwargs):
        return "mocked output"
    monkeypatch.setattr("subprocess.run", mock_run)

```text

### 4. Documentation

- Document each integration point
- Include example configurations
- List required environment variables
- Specify version compatibility matrix

### 5. Security

- Never commit credentials (use environment variables)
- Validate external input strictly
- Use HTTPS for remote connections
- Audit dependencies with `pip-audit` or `safety`

### 6. Performance

- Cache external tool outputs when possible
- Implement connection pooling for databases
- Profile integration overhead
- Consider async operations for I/O-bound tasks

### 7. Maintainability

- Abstract external tool calls into dedicated modules
- Use dependency injection for testing
- Keep integration code separate from business logic
- Version-lock external tool dependencies
