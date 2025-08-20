#!/bin/bash
# =============================================================================
# Test Coverage Framework Script
# 
# Tests the Stage 3 coverage model and closure methodology
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFICATION_DIR="$(dirname "$SCRIPT_DIR")"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

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
echo "  Stage 3 Coverage Framework Test"
echo "=========================================="
echo ""

# Change to verification directory
cd "$VERIFICATION_DIR" || exit 1

print_info "Testing Stage 3 coverage framework..."
print_info "Working directory: $(pwd)"
print_info "Timestamp: $TIMESTAMP"
echo ""

# Test 1: Syntax check
print_info "Step 1: Checking syntax of coverage files..."
if ./scripts/syntax_check.sh > /dev/null 2>&1; then
    print_success "Syntax check passed"
else
    print_error "Syntax check failed"
    print_info "Run ./scripts/syntax_check.sh for details"
    exit 1
fi

# Test 2: Run coverage test
print_info "Step 2: Running coverage framework test..."
LOG_FILE="logs/coverage_test_${TIMESTAMP}.log"
mkdir -p logs

print_info "Command: ./scripts/run_vcs.sh alu_coverage_test UVM_MEDIUM"
print_info "Log file: $LOG_FILE"

if ./scripts/run_vcs.sh alu_coverage_test UVM_MEDIUM > "$LOG_FILE" 2>&1; then
    print_success "Coverage test completed successfully!"
    
    # Check for coverage reports in log
    if grep -q "=== ALU COVERAGE ANALYSIS REPORT ===" "$LOG_FILE"; then
        print_success "Coverage model generated reports"
    else
        print_error "Coverage reports not found in log"
    fi
    
    if grep -q "=== VERIFICATION CLOSURE REPORT ===" "$LOG_FILE"; then
        print_success "Closure system generated reports"
    else
        print_error "Closure reports not found in log"
    fi
    
    # Show summary
    echo ""
    print_info "=== TEST RESULTS SUMMARY ==="
    
    # Extract key metrics from log
    if grep -q "Total transactions:" "$LOG_FILE"; then
        TRANSACTIONS=$(grep "Total transactions:" "$LOG_FILE" | tail -1 | grep -o "[0-9]*")
        print_info "Transactions processed: $TRANSACTIONS"
    fi
    
    if grep -q "Operation Coverage:" "$LOG_FILE"; then
        OP_COV=$(grep "Operation Coverage:" "$LOG_FILE" | tail -1 | grep -o "[0-9]*\.[0-9]*")
        print_info "Operation Coverage: ${OP_COV}%"
    fi
    
    if grep -q "Overall Coverage:" "$LOG_FILE"; then
        OVERALL_COV=$(grep "Overall Coverage:" "$LOG_FILE" | tail -1 | grep -o "[0-9]*\.[0-9]*")
        print_info "Overall Coverage: ${OVERALL_COV}%"
    fi
    
    if grep -q "Confidence:" "$LOG_FILE"; then
        CONFIDENCE=$(grep "Confidence:" "$LOG_FILE" | tail -1 | grep -o "[0-9]*\.[0-9]*")
        print_info "Closure Confidence: ${CONFIDENCE}%"
    fi
    
    echo ""
    print_success "✅ Coverage framework test PASSED!"
    print_info "Full log available at: $LOG_FILE"
    
else
    print_error "Coverage test failed!"
    echo ""
    print_info "Last 20 lines of log:"
    tail -20 "$LOG_FILE"
    echo ""
    print_info "Full log available at: $LOG_FILE"
    exit 1
fi

echo ""
print_info "=== NEXT STEPS ==="
print_info "1. Review the full log file for detailed coverage analysis"
print_info "2. Run with more transactions: modify num_transactions in alu_coverage_test.sv"
print_info "3. Test with real ALU operations using existing tests"
print_info "4. Integrate coverage model into existing test environment"

echo ""
print_success "Coverage framework test complete!"