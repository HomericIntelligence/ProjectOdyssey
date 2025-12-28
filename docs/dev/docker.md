# Docker Usage Guide

This document describes how to use Docker for ml-odyssey development and deployment.

## Quick Start

### Pull Pre-Built Images

```bash
# Pull the latest runtime image
docker pull ghcr.io/mvillmow/ml-odyssey:main

# Run tests
docker run --rm ghcr.io/mvillmow/ml-odyssey:main

# Interactive shell
docker run -it --rm ghcr.io/mvillmow/ml-odyssey:main bash
```

### Local Development

```bash
# Start development environment
just docker-up

# Enter shell
just docker-shell

# Run tests inside container
just test

# Stop environment
just docker-down
```

## Image Variants

| Tag | Dockerfile | Target | Purpose |
|-----|------------|--------|---------|
| `main` | Dockerfile.ci | runtime | Default runtime with tests |
| `main-ci` | Dockerfile.ci | ci | Full CI with pre-commit |
| `main-prod` | Dockerfile.ci | production | Minimal production image |
| `v*` | Dockerfile.ci | production | Release versions |
| `dev` | Dockerfile | development | Local development |

## Building Images

### Local Development Image

```bash
# Build dev image (with your user ID for permissions)
just docker-build

# Rebuild without cache
just docker-rebuild
```

### CI/Production Images

```bash
# Build runtime image
just docker-build-ci runtime

# Build all targets
just docker-build-ci-all

# Build with specific tag
docker build -f Dockerfile.ci --target production -t my-tag .
```

## Pushing to Registry

```bash
# Login to GHCR
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# Push specific target
just docker-push runtime

# Push all
just docker-push-all
```

## Multi-Platform Builds

The CI workflow builds for both `linux/amd64` and `linux/arm64`:

```bash
# Local multi-platform build (requires buildx)
docker buildx build \
  --file Dockerfile.ci \
  --target runtime \
  --platform linux/amd64,linux/arm64 \
  -t ghcr.io/mvillmow/ml-odyssey:test \
  --push \
  .
```

## Caching

Docker builds use GitHub Actions cache for faster CI builds:

- Layer caching via `type=gha`
- Pixi lockfile caching
- Build artifact caching

## Security

- Images are scanned with Trivy for vulnerabilities
- SBOM (Software Bill of Materials) generated for each release
- No secrets stored in images

## Troubleshooting

### Permission Issues

```bash
# Rebuild with your user ID
USER_ID=$(id -u) GROUP_ID=$(id -g) docker compose build
```

### Cache Issues

```bash
# Clean all Docker resources
just docker-clean

# Rebuild without cache
just docker-rebuild
```

### Pixi Lock Mismatch

```bash
# Update lockfile before building
pixi install
git add pixi.lock
```
