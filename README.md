# ML Odyssey

Mojo-based AI research platform for reproducing classic research papers.

## Features

- Mojo-first ML implementations with performance optimizations
- Hierarchical planning and agent-based development workflow
- Comprehensive testing and CI/CD infrastructure
- Docker support for consistent development environments

## Getting Started

### Option 1: Docker (Recommended)

The easiest way to get started is using Docker:

```bash
# Build and start the development environment
docker-compose up -d ml-odyssey-dev

# Enter the development container
docker-compose exec ml-odyssey-dev bash

# Inside the container, run tests
pixi run pytest tests/

# Run pre-commit hooks
pixi run pre-commit run --all-files
```text

### Option 2: Local Installation with Pixi

If you prefer to work without Docker:

```bash
# Install Pixi (if not already installed)
curl -fsSL https://pixi.sh/install.sh | bash

# Install project dependencies
pixi install

# Activate the Pixi environment
pixi shell

# Install pre-commit hooks
pre-commit install
```text

## Installation

### Docker Installation

### Requirements:

- Docker 20.10+
- Docker Compose 1.29+

### Services:

- `ml-odyssey-dev` - Development environment with full tooling
- `ml-odyssey-ci` - CI/Testing environment (optimized for automated tests)
- `ml-odyssey-prod` - Production environment (read-only volumes)

### Common Commands:

```bash
# Build all services
docker-compose build

# Start development environment
docker-compose up -d ml-odyssey-dev

# Run tests in CI environment
docker-compose run --rm ml-odyssey-ci

# Stop all services
docker-compose down

# Clean up volumes (removes caches)
docker-compose down -v
```text

### Local Installation

### Requirements:

- Python 3.11+
- Pixi (for Mojo and environment management)
- Git

### Steps:

1. Clone the repository
1. Install Pixi: `curl -fsSL https://pixi.sh/install.sh | bash`
1. Install dependencies: `pixi install`
1. Activate environment: `pixi shell`
1. Install pre-commit hooks: `pre-commit install`

See [INSTALL.md](INSTALL.md) for detailed installation instructions.
