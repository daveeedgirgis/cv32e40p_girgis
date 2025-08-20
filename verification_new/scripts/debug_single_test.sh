#!/bin/bash
# =============================================================================
# Debug Single Test Script
# 
# Helps debug why individual tests are failing in the regression suite
# Usage: ./debug_single_test.sh [test_name]
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFICATION_DIR="$(dirname "$SCRIPT_DIR")"
TEST_NAME="${1:-alu_base_test}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

echo "=========================================="
echo "  CV32E40P ALU - Single Test Debug"
echo "=========================================="
echo ""

print_info "Test: $TEST_NAME"
print_info "Working directory: $(pwd)"
print_info "Verification directory: $VERIFICATION_DIR"
echo ""

# Change to verification directory
cd "$VERIFICATION_DIR" || exit 1

# Check if run_vcs.sh exists and is executable
if [ ! -f "scripts/run_vcs.sh" ]; then
    print_error "scripts/run_vcs.sh not found!"
    exit 1
fi

if [ ! -x "scripts/run_vcs.sh" ]; then
    print_error "scripts/run_vcs.sh is not executable!"
    print_info "Run: chmod +x scripts/run_vcs.sh"
    exit 1
fi

print_success "Found executable run_vcs.sh script"

# Check VCS availability
if ! command -v vcs &> /dev/null; then
    print_error "VCS not found in PATH"
    print_info "Current PATH: $PATH"
    exit 1
fi

print_success "VCS found in PATH"

# Test basic syntax check first
print_info "Running syntax check..."
if ./scripts/syntax_check.sh > /dev/null 2>&1; then
    print_success "Syntax check passed"
else
    print_error "Syntax check failed - run ./scripts/syntax_check.sh for details"
    exit 1
fi

# Try to run the test with verbose output
print_info "Attempting to run test: $TEST_NAME"
print_info "Command: ./scripts/run_vcs.sh $TEST_NAME UVM_HIGH"
echo ""

# Create a temporary log file
TEMP_LOG="/tmp/debug_${TEST_NAME}_$(date +%s).log"

print_info "Running test (output will be shown and logged to $TEMP_LOG)..."
echo ""

# Run the test and show output
if ./scripts/run_vcs.sh "$TEST_NAME" UVM_HIGH 2>&1 | tee "$TEMP_LOG"; then
    print_success "Test completed successfully!"
else
    print_error "Test failed!"
    echo ""
    print_info "Last 20 lines of output:"
    tail -20 "$TEMP_LOG"
    echo ""
    print_info "Full log available at: $TEMP_LOG"
fi

echo ""
print_info "Debug complete for test: $TEST_NAME"