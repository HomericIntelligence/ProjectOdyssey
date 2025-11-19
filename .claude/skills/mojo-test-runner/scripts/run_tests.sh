#!/usr/bin/env bash
#
# Run Mojo tests with filtering options
#
# Usage:
#   ./run_tests.sh [test-name] [--unit|--integration|--performance] [--paper <name>] [--help]
#
# Options:
#   --unit          Run only unit tests
#   --integration   Run only integration tests
#   --performance   Run only performance tests
#   --paper <name>  Run tests only for specific paper (by name or partial match)
#   --help          Show this help message

set -euo pipefail

TEST_FILTER=""
TEST_TYPE=""
PAPER_NAME=""

# Show help
show_help() {
    cat << EOF
Usage: run_tests.sh [test-name] [options]

Options:
  --unit          Run only unit tests
  --integration   Run only integration tests
  --performance   Run only performance tests
  --paper <name>  Run tests only for specific paper (supports partial matching)
  --help          Show this help message

Examples:
  # Run all tests
  ./run_tests.sh

  # Run specific test file
  ./run_tests.sh test_tensor

  # Run tests for specific paper
  ./run_tests.sh --paper lenet-5

  # Run tests for paper (partial match)
  ./run_tests.sh --paper lenet

  # Run unit tests only
  ./run_tests.sh --unit

  # Run tests for paper with type filter
  ./run_tests.sh --paper bert --unit
EOF
}

# Parse arguments
prev_arg=""
for arg in "$@"; do
    case "$arg" in
        --help|-h)
            show_help
            exit 0
            ;;
        --unit)
            TEST_TYPE="unit"
            ;;
        --integration)
            TEST_TYPE="integration"
            ;;
        --performance)
            TEST_TYPE="performance"
            ;;
        --paper)
            # Next argument will be the paper name
            ;;
        --*)
            # Unknown option, ignore
            ;;
        *)
            # Positional argument
            if [[ "$prev_arg" == "--paper" ]]; then
                # This is the paper name
                PAPER_NAME="$arg"
            elif [[ -z "$TEST_FILTER" ]]; then
                # First non-option arg is test filter
                TEST_FILTER="$arg"
            fi
            ;;
    esac
    prev_arg="$arg"
done

# Handle paper-specific filtering
if [[ -n "$PAPER_NAME" ]]; then
    # Find paper directory
    PAPER_DIR=""

    if [[ -d "papers/$PAPER_NAME" ]]; then
        # Exact match
        PAPER_DIR="papers/$PAPER_NAME"
    else
        # Try partial match (case-insensitive)
        MATCHES=$(find papers/ -maxdepth 1 -type d -iname "*$PAPER_NAME*" 2>/dev/null || true)

        if [[ -z "$MATCHES" ]]; then
            echo "Error: Paper '$PAPER_NAME' not found"
            echo ""
            echo "Available papers:"
            ls -1 papers/ 2>/dev/null | grep -v "^_" || echo "  (none)"
            exit 1
        fi

        # Count matches
        NUM_MATCHES=$(echo "$MATCHES" | wc -l)

        if [[ $NUM_MATCHES -eq 1 ]]; then
            PAPER_DIR="$MATCHES"
        else
            echo "Error: Multiple papers match '$PAPER_NAME':"
            echo "$MATCHES" | sed 's/^/  /'
            echo ""
            echo "Please be more specific."
            exit 1
        fi
    fi

    # Verify paper has tests directory
    PAPER_TESTS_DIR="$PAPER_DIR/tests"
    if [[ ! -d "$PAPER_TESTS_DIR" ]]; then
        echo "Error: Paper '$(basename "$PAPER_DIR")' has no tests directory"
        exit 1
    fi

    # Use paper's tests directory
    if [[ -n "$TEST_TYPE" ]]; then
        TEST_DIR="$PAPER_TESTS_DIR/$TEST_TYPE"
    else
        TEST_DIR="$PAPER_TESTS_DIR"
    fi

    # Verify test directory exists
    if [[ ! -d "$TEST_DIR" ]]; then
        echo "Error: Test directory not found: $TEST_DIR"
        exit 1
    fi

    echo "Running tests for paper: $(basename "$PAPER_DIR")"
    echo "Test directory: $TEST_DIR"
else
    # Determine test directory (no paper filter)
    if [[ -n "$TEST_TYPE" ]]; then
        TEST_DIR="tests/$TEST_TYPE"
    else
        TEST_DIR="tests"
    fi

    # Verify test directory exists
    if [[ ! -d "$TEST_DIR" ]]; then
        echo "Error: Test directory not found: $TEST_DIR"
        exit 1
    fi

    echo "Running tests from: $TEST_DIR"
fi

if [[ -n "$TEST_FILTER" ]] && [[ "$TEST_FILTER" != --* ]]; then
    echo "Filter: $TEST_FILTER"
fi
echo ""

# Run tests
if [[ -n "$TEST_FILTER" ]] && [[ "$TEST_FILTER" != --* ]]; then
    # Run specific test file
    if [[ -f "$TEST_DIR/$TEST_FILTER.mojo" ]]; then
        mojo test "$TEST_DIR/$TEST_FILTER.mojo"
    elif [[ -f "$TEST_DIR/test_$TEST_FILTER.mojo" ]]; then
        mojo test "$TEST_DIR/test_$TEST_FILTER.mojo"
    else
        # Search for matching files
        MATCHES=$(find "$TEST_DIR" -type f -name "*$TEST_FILTER*.mojo" 2>/dev/null || true)
        if [[ -z "$MATCHES" ]]; then
            echo "Error: No test files matching: $TEST_FILTER"
            exit 1
        fi

        echo "Found matching tests:"
        echo "$MATCHES"
        echo ""

        # Run all matches
        while IFS= read -r test_file; do
            echo "Running: $test_file"
            mojo test "$test_file"
            echo ""
        done <<< "$MATCHES"
    fi
else
    # Run all tests in directory
    mojo test "$TEST_DIR"
fi
