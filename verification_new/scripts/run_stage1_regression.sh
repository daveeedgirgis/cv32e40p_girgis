#!/bin/bash
# =============================================================================
# Stage 1 Only Regression Script
# 
# Simplified regression script that only runs Stage 1 tests that we know work
# Perfect for debugging and Stage 3 preparation
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFICATION_DIR="$(dirname "$SCRIPT_DIR")"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_DIR="$VERIFICATION_DIR/logs/stage1_regression_$TIMESTAMP"
RESULTS_DIR="$VERIFICATION_DIR/results/stage1_regression_$TIMESTAMP"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_header() { echo -e "${PURPLE}[HEADER]${NC} $1"; }

# Test tracking
declare -A test_results
total_tests=0
passed_tests=0
failed_tests=0
total_transactions=0

# Create directories
mkdir -p "$LOG_DIR"
mkdir -p "$RESULTS_DIR"

# Change to verification directory
cd "$VERIFICATION_DIR" || exit 1

print_header "=========================================="
print_header "  CV32E40P ALU - Stage 1 Regression"
print_header "=========================================="
print_info "Timestamp: $TIMESTAMP"
print_info "Logs: $LOG_DIR"
print_info "Results: $RESULTS_DIR"
echo ""

# Function to run a single test
run_test() {
    local test_name=$1
    local expected_transactions=$2
    
    print_info "Running $test_name..."
    
    local start_time=$(date +%s)
    local test_log="$LOG_DIR/${test_name}_${TIMESTAMP}.log"
    
    # Run the test
    if ./scripts/run_vcs.sh "$test_name" UVM_MEDIUM > "$test_log" 2>&1; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        # Extract results
        if [ -f "$test_log" ]; then
            local transactions=$(grep "Total transactions:" "$test_log" | grep -o "[0-9]*" | tail -1 || echo "N/A")
            local errors=$(grep -c "UVM_ERROR" "$test_log" || echo "0")
            local warnings=$(grep -c "UVM_WARNING" "$test_log" || echo "0")
            
            if [ "$errors" -eq 0 ]; then
                test_results[$test_name]="PASSED"
                print_success "$test_name PASSED (${duration}s, ${transactions} trans, ${warnings} warnings)"
                ((passed_tests++))
                if [ "$transactions" != "N/A" ]; then
                    total_transactions=$((total_transactions + transactions))
                fi
            else
                test_results[$test_name]="FAILED"
                print_error "$test_name FAILED ($errors errors, $warnings warnings)"
                ((failed_tests++))
            fi
        else
            test_results[$test_name]="FAILED"
            print_error "$test_name FAILED (no log file created)"
            ((failed_tests++))
        fi
    else
        test_results[$test_name]="FAILED"
        print_error "$test_name FAILED (script error)"
        ((failed_tests++))
    fi
    
    ((total_tests++))
    echo ""
}

# Run Stage 1 tests
print_header "=== STAGE 1 TESTS ==="
run_test "alu_base_test" "19"
run_test "alu_arith_test" "200"
run_test "alu_logic_test" "200"
run_test "alu_shift_test" "200"

# Generate summary
print_header "=== REGRESSION SUMMARY ==="
print_info "Total Tests: $total_tests"
print_success "Passed: $passed_tests"
if [ $failed_tests -gt 0 ]; then
    print_error "Failed: $failed_tests"
fi
print_info "Success Rate: $(( passed_tests * 100 / total_tests ))%"
print_info "Total Transactions: $total_transactions"

# Create summary file
summary_file="$RESULTS_DIR/stage1_regression_summary.log"
cat > "$summary_file" << EOF
# Stage 1 Regression Test Summary
# Generated: $(date)

## Results
- Total Tests: $total_tests
- Passed: $passed_tests
- Failed: $failed_tests
- Success Rate: $(( passed_tests * 100 / total_tests ))%
- Total Transactions: $total_transactions

## Individual Test Results
EOF

for test_name in "${!test_results[@]}"; do
    echo "- $test_name: ${test_results[$test_name]}" >> "$summary_file"
done

cat >> "$summary_file" << EOF

## Log Files
- Individual logs: $LOG_DIR/
- Summary: $summary_file

## Stage 3 Readiness
EOF

if [ $failed_tests -eq 0 ]; then
    echo "✅ READY - All Stage 1 tests passed" >> "$summary_file"
    print_success "✅ STAGE 3 READY - All tests passed!"
else
    echo "❌ NOT READY - $failed_tests tests failed" >> "$summary_file"
    print_error "❌ Fix failed tests before Stage 3"
fi

print_info "Summary saved to: $summary_file"

# Exit with appropriate code
if [ $failed_tests -eq 0 ]; then
    exit 0
else
    exit 1
fi