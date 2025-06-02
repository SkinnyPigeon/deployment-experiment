.PHONY: test test-local test-debug test-amd64-simple test-python-image lint style type-check test-only lint-local style-local type-check-local signoff signoff-lint signoff-style signoff-type-check signoff-test signoff-all status help clean

# Configuration
DOCKER_REGISTRY ?= docker.io
DOCKER_SOCKET = unix://$(HOME)/.rd/docker.sock
ARCH = linux/amd64
SUMMARY ?= false

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
	@echo "Sign-off commands (for PR merging):"
	@echo "  signoff-lint       - Sign off on linting checks (requires AMD64 confirmation)"
	@echo "  signoff-style      - Sign off on style checks (requires AMD64 confirmation)"
	@echo "  signoff-type-check - Sign off on type checking (requires AMD64 confirmation)"
	@echo "  signoff-test       - Sign off on unit tests (requires AMD64 confirmation)"
	@echo "  signoff-all        - Sign off on all checks"
	@echo "  status             - Check current signoff status"
	@echo ""
	@echo "  clean           - Clean up act containers"
	@echo "  help            - Show this help message"
	@echo ""
	@echo "Configuration:"
	@echo "  ARCH           - Container architecture (default: linux/amd64)"
	@echo "  DOCKER_REGISTRY - Docker registry to use (default: docker.io)"
	@echo "  SUMMARY        - Show clean summary instead of verbose output (default: false)"
	@echo ""
	@echo "Examples:"
	@echo "  make test ARCH=linux/arm64              # Run all tests with ARM64"
	@echo "  make test SUMMARY=true                  # Run with clean summary output"
	@echo "  make style ARCH=linux/arm64 SUMMARY=true # Style check with summary"
	@echo ""
	@echo "Output modes:"
	@echo "  Default (SUMMARY=false) - Shows full verbose act output for debugging"
	@echo "  Summary (SUMMARY=true)  - Shows clean summary with just pass/fail status"
	@echo "  Debug (test-debug)      - Shows maximum verbosity with debug info"
	@echo ""
	@echo "Architecture Notes:"
	@echo "  - linux/arm64: Uses Python setup actions (local testing)"
	@echo "  - linux/amd64: Uses Python containers (production-like, slower on Apple Silicon)"
	@echo "  - The workflow automatically adapts based on the ARCH setting"
	@echo "  - On GitHub Actions, it defaults to linux/amd64 (production environment)"

# Clean up act containers
clean:
	@echo "🧹 Cleaning up act containers..."
	@docker ps -a --filter "name=act-" --format "{{.Names}}" | xargs -r docker rm -f 2>/dev/null || true
	@echo "✅ Cleanup complete"

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

test-local:
	@echo "Running tests locally with pytest..."
	python -m pytest test_trie.py -v

all-local: lint-local style-local type-check-local test-local
	@echo "✅ All local checks completed!"

# Helper function to run act and capture results with summary
define run_act_with_summary
	@echo "🚀 Running $(1)..."
	@echo "Using Docker registry: $(DOCKER_REGISTRY)"
	@echo "Using architecture: $(ARCH)"
	@if [ "$(ARCH)" = "linux/amd64" ]; then \
		echo "Note: Using Python containers for AMD64 (production-like)"; \
	else \
		echo "Note: Using Python setup actions for $(ARCH) (local testing)"; \
	fi
	@if [ "$(SUMMARY)" = "true" ]; then \
		echo ""; \
		echo "📋 Summary will be shown at the end..."; \
		echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; \
		TEMP_LOG=$$(mktemp); \
		if DOCKER_HOST=$(DOCKER_SOCKET) act workflow_dispatch \
			--container-architecture $(ARCH) \
			--platform ubuntu-latest=$(DOCKER_REGISTRY)/catthehacker/ubuntu:act-latest \
			--input target_arch=$(ARCH) \
			$(2) > $$TEMP_LOG 2>&1; then \
			echo ""; \
			echo "🎉 SUCCESS: All jobs completed successfully!"; \
			echo ""; \
			echo "📊 SUMMARY:"; \
			echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; \
			if grep -q "🏁.*succeeded" $$TEMP_LOG; then \
				grep "🏁.*succeeded" $$TEMP_LOG | sed 's/.*\[Run Tests\/\([^]]*\)\].*/✅ \1 job succeeded/'; \
			else \
				echo "✅ All jobs succeeded"; \
			fi; \
			echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; \
		else \
			echo ""; \
			echo "❌ FAILURE: Some jobs failed!"; \
			echo ""; \
			echo "📊 SUMMARY:"; \
			echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; \
			if grep -q "🏁.*succeeded" $$TEMP_LOG; then \
				grep "🏁.*succeeded" $$TEMP_LOG | sed 's/.*\[Run Tests\/\([^]]*\)\].*/✅ \1 job succeeded/'; \
			fi; \
			if grep -q "🏁.*failed" $$TEMP_LOG; then \
				grep "🏁.*failed" $$TEMP_LOG | sed 's/.*\[Run Tests\/\([^]]*\)\].*/❌ \1 job failed/'; \
			fi; \
			echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; \
			echo ""; \
			echo "🔍 For detailed logs, run with 'make test-debug' or 'make $(lastword $(MAKECMDGOALS)) SUMMARY=false'"; \
			rm -f $$TEMP_LOG; \
			exit 1; \
		fi; \
		rm -f $$TEMP_LOG; \
	else \
		echo ""; \
		DOCKER_HOST=$(DOCKER_SOCKET) act workflow_dispatch \
			--container-architecture $(ARCH) \
			--platform ubuntu-latest=$(DOCKER_REGISTRY)/catthehacker/ubuntu:act-latest \
			--input target_arch=$(ARCH) \
			$(2); \
	fi
endef

# Run all jobs with specified architecture
test: clean
	$(call run_act_with_summary,all GitHub Actions jobs,)

# Run only linting job
lint: clean
	$(call run_act_with_summary,linting checks,--job lint)

# Run only style checking job
style: clean
	$(call run_act_with_summary,style checks,--job style)

# Run only type checking job
type-check: clean
	$(call run_act_with_summary,type checks,--job type-check)

# Run only unit tests job
test-only: clean
	$(call run_act_with_summary,unit tests,--job test)

# Run tests with verbose debugging output (no summary)
test-debug: clean
	@echo "Running GitHub Actions locally with act (DEBUG MODE)..."
	@echo "Using Docker registry: $(DOCKER_REGISTRY)"
	@echo "Using architecture: $(ARCH)"
	DOCKER_HOST=$(DOCKER_SOCKET) act workflow_dispatch \
		--verbose \
		--container-architecture $(ARCH) \
		--platform ubuntu-latest=$(DOCKER_REGISTRY)/catthehacker/ubuntu:act-latest \
		--input target_arch=$(ARCH)

# Generic signoff function
define do_signoff
	@echo "$(2) $(1) Sign-off"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "This will mark $(3) as successful for PR merging."
	@echo ""
	@echo "⚠️  IMPORTANT: You should run $(3) on AMD64 (production architecture) before signing off:"
	@echo "   make $(4) ARCH=linux/amd64"
	@echo ""
	@read -p "Have you successfully run $(3) on linux/amd64? Type 'yes' to confirm: " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		echo "✅ Signing off on $(3)..."; \
		if gh signoff $(1); then \
			echo "🎉 $(5) signed off successfully!"; \
		else \
			echo "❌ Failed to sign off on $(3)."; \
			echo "Make sure gh-signoff extension is installed: gh extension install basecamp/gh-signoff"; \
			exit 1; \
		fi; \
	else \
		echo "❌ Sign-off cancelled. Please run $(3) on AMD64 first."; \
		exit 1; \
	fi
endef

# Sign off on linting checks
signoff-lint:
	$(call do_signoff,lint,🔍,linting checks,lint,Linting checks)

# Sign off on style checks
signoff-style:
	$(call do_signoff,style,🎨,style checks,style,Style checks)

# Sign off on type checking
signoff-type-check:
	$(call do_signoff,type-check,🔍,type checking,type-check,Type checking)

# Sign off on unit tests
signoff-test:
	$(call do_signoff,test,🧪,unit tests,test-only,Unit tests)

# Sign off on all checks (convenience command)
signoff-all: signoff-lint signoff-style signoff-type-check signoff-test
	@echo ""
	@echo "🎉 All checks signed off successfully!"
	@echo "Your PR should now be ready for merging."


# Check the current signoff status
status:
	@echo "Checking signoff status..."
	gh signoff status 