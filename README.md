# ML Odyssey

Mojo-based AI research platform for reproducing classic research papers.

## Project Status

**Phase**: Planning & Foundation (Pre-Alpha)

- ✅ Repository structure established
- ✅ Agent system implemented (38 agents across 6 levels)
- ✅ Skill system implemented (43 skills across 9 categories)
- ✅ CI/CD pipeline configured (pre-commit hooks, GitHub Actions)
- ✅ Docker development environment ready
- 🚧 Shared library foundation (core tensor operations in progress)
- 📋 First paper implementation (LeNet-5 planned for Q1 2025)

**Current Focus**: Building core tensor operations and gradient computation infrastructure to support neural network implementations.

## Vision

ML Odyssey aims to become the definitive Mojo-based platform for reproducing and understanding classic ML
research papers. Our vision includes:

- **Comprehensive Paper Coverage**: 50+ reproduced papers spanning ML history from LeNet-5 (1998) to modern architectures
- **Production-Ready Implementations**: Fully tested, optimized Mojo implementations with performance benchmarks
- **Educational Resources**: Clear documentation, tutorials, and reproduction guides for each paper
- **Performance Excellence**: Leverage Mojo's SIMD capabilities and compile-time optimizations for superior performance
- **Research Validation**: Rigorous testing to match original paper results and validate implementation correctness
- **Community Platform**: Foster collaboration and knowledge sharing in ML implementation and optimization

## Roadmap

### 2025 Q1: Foundation & First Paper

- Complete shared library core operations (tensor ops, activations, layers)
- Implement gradient computation and backpropagation framework
- Reproduce LeNet-5 with MNIST (first paper milestone)
- Establish performance benchmarking infrastructure
- Achieve 99% MNIST accuracy matching original paper

### 2025 Q2: Growth & Expansion

- Add 5 more classic papers (AlexNet, VGG, ResNet candidates)
- Expand shared library with advanced operations
- Performance optimization focus (SIMD vectorization, cache efficiency)
- Community contribution framework established
- Comprehensive documentation and tutorials

### 2025 Q3-Q4: Maturity & Scale

- 20+ papers implemented across different ML domains
- Advanced features (mixed precision, distributed training)
- Package distribution via Conda/PyPI
- Research paper comparing Mojo vs Python implementations
- Active community contributions and collaborations

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
