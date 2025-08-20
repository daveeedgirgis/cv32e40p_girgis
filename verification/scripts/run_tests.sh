#!/bin/bash
# =============================================================================
# Run All Tests Script
#
# Runs all validation tests for the UVM ALU testbench
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

print_info "=========================================="
print_info "  UVM ALU Testbench Validation Suite"
print_info "=========================================="

total_tests=0
passed_tests=0

# Function to run a test and track results
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    ((total_tests++))
    print_info "Running $test_name..."
    
    if eval "$test_command" >/dev/null 2>&1; then
        print_success "$test_name: PASSED"
        ((passed_tests++))
        return 0
    else
        print_error "$test_name: FAILED"
        return 1
    fi
}

# Run syntax check
print_info "=== Test 1: Syntax Check ==="
run_test "SystemVerilog Syntax Check" "$SCRIPT_DIR/syntax_check.sh"

# Run configuration test
print_info "=== Test 2: Configuration Validation ==="
run_test "YAML Configuration Test" "python3 $SCRIPT_DIR/test_config.py"

# Run compilation readiness test
print_info "=== Test 3: Compilation Readiness ==="
run_test "Compilation Readiness Test" "$SCRIPT_DIR/test_compilation.sh"

# Summary
print_info "=========================================="
print_info "  Test Suite Summary"
print_info "=========================================="
print_info "Total tests: $total_tests"
print_info "Passed tests: $passed_tests"
print_info "Failed tests: $((total_tests - passed_tests))"

if [ "$passed_tests" -eq "$total_tests" ]; then
    print_success "ALL TESTS PASSED!"
    print_info ""
    print_info "Your UVM ALU testbench is ready for:"
    print_info "  1. VCS compilation and simulation"
    print_info "  2. Running ALU-focused verification tests"
    print_info "  3. Coverage collection and analysis"
    print_info ""
    print_info "Next steps:"
    print_info "  cd verification/scripts"
    print_info "  ./run_vcs.sh                    # Run default test"
    print_info "  ./run_vcs.sh alu_arithmetic_test # Run specific test"
    print_info ""
    exit 0
else
    print_error "SOME TESTS FAILED!"
    print_info "Please fix the failing tests before proceeding."
    exit 1
fi