.PHONY: test test-local test-debug test-amd64-simple test-python-image lint style type-check test-only lint-local style-local type-check-local signoff status help docker-check clean

# Configuration
DOCKER_REGISTRY ?= docker.io
DOCKER_SOCKET = unix://$(HOME)/.rd/docker.sock
ARCH = linux/amd64

# Default target
help:
	@echo "Available commands:"
	@echo "  test            - Run all jobs with specified architecture"
	@echo "  lint            - Run only linting checks"
	@echo "  style           - Run only style checks"
	@echo "  type-check      - Run only type checking"
	@echo "  test-only       - Run only unit tests"
	@echo "  test-debug      - Run tests with verbose debugging output"
	@echo "  test-amd64-simple - Test AMD64 compatibility with simpler workflow"
	@echo "  test-python-image - Test using official Python image (bypasses Python setup)"
	@echo "  test-local      - Run tests directly with pytest"
	@echo ""
	@echo "Local development (faster, no Docker):"
	@echo "  lint-local      - Run linting checks locally"
	@echo "  style-local     - Run style checks locally"
	@echo "  type-check-local- Run type checking locally"
	@echo "  all-local       - Run all checks locally"
	@echo ""
	@echo "  clean           - Clean up act containers"
	@echo "  signoff         - Sign off on all checks (marks them as successful)"
	@echo "  status          - Check signoff status"
	@echo "  help            - Show this help message"
	@echo ""
	@echo "Configuration:"
	@echo "  ARCH           - Container architecture (default: linux/amd64)"
	@echo "  DOCKER_REGISTRY - Docker registry to use (default: docker.io)"
	@echo "  Example: make test ARCH=linux/arm64 DOCKER_REGISTRY=your-registry.com"
	@echo ""
	@echo "Architecture Notes:"
	@echo "  - linux/arm64: Uses Python setup actions (faster on Apple Silicon)"
	@echo "  - linux/amd64: Uses Python containers (production-like, slower on Apple Silicon)"
	@echo "  - The workflow automatically adapts based on the ARCH setting"
	@echo "  - On GitHub Actions, it defaults to linux/amd64 (production environment)"


# Local development targets (faster, no Docker)
lint-local:
	@echo "Running linting checks locally..."
	@echo "🔍 Running flake8..."
	flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
	flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics
	@echo "🔍 Running pylint..."
	pylint --exit-zero *.py

style-local:
	@echo "Running style checks locally..."
	@echo "🎨 Checking code formatting with black..."
	black --check --diff .
	@echo "📦 Checking import sorting with isort..."
	isort --check-only --diff .

type-check-local:
	@echo "Running type checks locally..."
	@echo "🔍 Type checking with mypy..."
	mypy --ignore-missing-imports *.py

all-local: lint-local style-local type-check-local test-local
	@echo "✅ All local checks completed!"

# Run all jobs with specified architecture
test: clean
	@echo "Running all GitHub Actions jobs..."
	@echo "Using Docker registry: $(DOCKER_REGISTRY)"
	@echo "Using architecture: $(ARCH)"
	@if [ "$(ARCH)" = "linux/amd64" ]; then \
		echo "Note: Using Python containers for AMD64 (production-like)"; \
	else \
		echo "Note: Using Python setup actions for $(ARCH) (faster on Apple Silicon)"; \
	fi
	DOCKER_HOST=$(DOCKER_SOCKET) act workflow_dispatch \
		--container-architecture $(ARCH) \
		--platform ubuntu-latest=$(DOCKER_REGISTRY)/catthehacker/ubuntu:act-latest \
		--input target_arch=$(ARCH)

# Run only linting job
lint: clean
	@echo "Running linting checks with act..."
	@echo "Using Docker registry: $(DOCKER_REGISTRY)"
	@echo "Using architecture: $(ARCH)"
	DOCKER_HOST=$(DOCKER_SOCKET) act workflow_dispatch \
		--container-architecture $(ARCH) \
		--platform ubuntu-latest=$(DOCKER_REGISTRY)/catthehacker/ubuntu:act-latest \
		--input target_arch=$(ARCH) \
		--job lint

# Run only style checking job
style: clean
	@echo "Running style checks with act..."
	@echo "Using Docker registry: $(DOCKER_REGISTRY)"
	@echo "Using architecture: $(ARCH)"
	DOCKER_HOST=$(DOCKER_SOCKET) act workflow_dispatch \
		--container-architecture $(ARCH) \
		--platform ubuntu-latest=$(DOCKER_REGISTRY)/catthehacker/ubuntu:act-latest \
		--input target_arch=$(ARCH) \
		--job style

# Run only type checking job
type-check: clean
	@echo "Running type checks with act..."
	@echo "Using Docker registry: $(DOCKER_REGISTRY)"
	@echo "Using architecture: $(ARCH)"
	DOCKER_HOST=$(DOCKER_SOCKET) act workflow_dispatch \
		--container-architecture $(ARCH) \
		--platform ubuntu-latest=$(DOCKER_REGISTRY)/catthehacker/ubuntu:act-latest \
		--input target_arch=$(ARCH) \
		--job type-check

# Run only unit tests job
test-only: clean
	@echo "Running unit tests with act..."
	@echo "Using Docker registry: $(DOCKER_REGISTRY)"
	@echo "Using architecture: $(ARCH)"
	DOCKER_HOST=$(DOCKER_SOCKET) act workflow_dispatch \
		--container-architecture $(ARCH) \
		--platform ubuntu-latest=$(DOCKER_REGISTRY)/catthehacker/ubuntu:act-latest \
		--input target_arch=$(ARCH) \
		--job test

# Run tests with verbose debugging output
test-debug: clean
	@echo "Running GitHub Actions locally with act (DEBUG MODE)..."
	@echo "Using Docker registry: $(DOCKER_REGISTRY)"
	@echo "Using architecture: $(ARCH)"
	DOCKER_HOST=$(DOCKER_SOCKET) act workflow_dispatch \
		--verbose \
		--container-architecture $(ARCH) \
		--platform ubuntu-latest=$(DOCKER_REGISTRY)/catthehacker/ubuntu:act-latest \
		--input target_arch=$(ARCH)

# Test AMD64 compatibility with a simpler container that has Python pre-installed
test-amd64-simple: clean
	@echo "Testing AMD64 compatibility with pre-installed Python..."
	@echo "Using Docker registry: $(DOCKER_REGISTRY)"
	@echo "Note: This uses a container with Python already installed to avoid setup issues"
	DOCKER_HOST=$(DOCKER_SOCKET) act \
		--container-architecture linux/amd64 \
		--platform ubuntu-latest=$(DOCKER_REGISTRY)/catthehacker/ubuntu:act-22.04

# Test using official Python image with simplified workflow
test-python-image: clean
	@echo "Testing with official Python image and simplified workflow..."
	@echo "Using Docker registry: $(DOCKER_REGISTRY)"
	@echo "Using architecture: $(ARCH)"
	@echo "Note: This uses python:3.12-slim image with a workflow that skips Python setup"
	DOCKER_HOST=$(DOCKER_SOCKET) act \
		--container-architecture $(ARCH) \
		--platform ubuntu-latest=$(DOCKER_REGISTRY)/catthehacker/ubuntu:act-latest \
		--workflows .github/workflows/test.yml

# Run tests directly with pytest (faster for development)
test-local:
	@echo "Running tests locally with pytest..."
	python -m pytest test_trie.py -v

# Sign off on all checks (marks them as successful for PR merging)
signoff:
	@echo "Signing off on all checks..."
	gh signoff

# Check the current signoff status
status:
	@echo "Checking signoff status..."
	gh signoff status 