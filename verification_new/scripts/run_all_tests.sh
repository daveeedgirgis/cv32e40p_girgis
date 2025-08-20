#!/bin/bash
# =============================================================================
# Comprehensive Test Suite Runner for CV32E40P ALU Verification
#
# Runs all Stage 1 and Stage 2 tests with detailed logging and analysis
# Perfect for Stage 3 coverage analysis and regression testing
#
# Usage: ./run_all_tests.sh [options]
# Options:
#   -q, --quick     Run only quick tests (< 10 minutes total)
#   -f, --full      Run full test suite (default)
#   -c, --coverage  Enable detailed coverage collection
#   -v, --verbose   Enable verbose logging
#   -h, --help      Show this help
# =============================================================================

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFICATION_DIR="$(dirname "$SCRIPT_DIR")"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_DIR="$VERIFICATION_DIR/logs/regression_$TIMESTAMP"
RESULTS_DIR="$VERIFICATION_DIR/results/regression_$TIMESTAMP"

# Test configuration
QUICK_MODE=false
FULL_MODE=true
COVERAGE_MODE=false
VERBOSE_MODE=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Test results tracking
declare -A test_results
declare -A test_durations
declare -A test_transactions
total_tests=0
passed_tests=0
failed_tests=0
total_transactions=0
total_duration=0

# Function to print colored output
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_header() { echo -e "${PURPLE}[HEADER]${NC} $1"; }
print_test() { echo -e "${CYAN}[TEST]${NC} $1"; }

# Function to show usage
show_usage() {
    cat << EOF
CV32E40P ALU Verification - Comprehensive Test Suite Runner

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -q, --quick     Run only quick tests (Stage 1 + quick Stage 2, ~15 minutes)
    -f, --full      Run full test suite (all tests, ~2 hours) [DEFAULT]
    -c, --coverage  Enable detailed coverage collection and analysis
    -v, --verbose   Enable verbose logging (UVM_HIGH for all tests)
    -h, --help      Show this help message

EXAMPLES:
    $0                          # Run full test suite
    $0 --quick                  # Run quick validation tests
    $0 --coverage --verbose     # Full suite with coverage and verbose logs
    $0 -q -v                    # Quick tests with verbose output

OUTPUT:
    Logs:     $LOG_DIR/
    Results:  $RESULTS_DIR/
    Summary:  regression_summary_$TIMESTAMP.log

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -q|--quick)
            QUICK_MODE=true
            FULL_MODE=false
            shift
            ;;
        -f|--full)
            FULL_MODE=true
            QUICK_MODE=false
            shift
            ;;
        -c|--coverage)
            COVERAGE_MODE=true
            shift
            ;;
        -v|--verbose)
            VERBOSE_MODE=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Create output directories
create_directories() {
    mkdir -p "$LOG_DIR"
    mkdir -p "$RESULTS_DIR"
    mkdir -p "$VERIFICATION_DIR/coverage/regression_$TIMESTAMP"
}

# Function to run a single test
run_single_test() {
    local test_name=$1
    local expected_duration=$2
    local expected_transactions=$3
    local test_category=$4
    
    print_test "Running $test_name ($test_category)"
    print_info "Expected: $expected_transactions transactions, ~$expected_duration minutes"
    
    local start_time=$(date +%s)
    local verbosity="UVM_MEDIUM"
    
    if [ "$VERBOSE_MODE" = true ]; then
        verbosity="UVM_HIGH"
    fi
    
    # Run the test with logging
    local test_log="$LOG_DIR/${test_name}_${TIMESTAMP}.log"
    local coverage_opts=""
    
    if [ "$COVERAGE_MODE" = true ]; then
        coverage_opts="-cm_dir $VERIFICATION_DIR/coverage/regression_$TIMESTAMP/${test_name}.vdb"
    fi
    
    # Execute test with better error handling
    print_info "Command: ./scripts/run_vcs.sh \"$test_name\" \"$verbosity\" \"$RANDOM\" $coverage_opts"
    
    if timeout 3600 ./scripts/run_vcs.sh "$test_name" "$verbosity" "$RANDOM" $coverage_opts > "$test_log" 2>&1; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        local duration_min=$((duration / 60))
        
        # Extract results from log (check if log file exists first)
        if [ -f "$test_log" ]; then
            local actual_transactions=$(grep -o "transactions: [0-9]*" "$test_log" | tail -1 | grep -o "[0-9]*" || echo "N/A")
            local errors=$(grep -c "UVM_ERROR" "$test_log" || echo "0")
            local warnings=$(grep -c "UVM_WARNING" "$test_log" || echo "0")
        else
            print_warning "Log file not created: $test_log"
            local actual_transactions="N/A"
            local errors="UNKNOWN"
            local warnings="UNKNOWN"
        fi
        
        if [ "$errors" = "0" ]; then
            test_results[$test_name]="PASSED"
            print_success "$test_name PASSED (${duration_min}m, ${actual_transactions} trans, ${warnings} warnings)"
            ((passed_tests++))
        elif [ "$errors" = "UNKNOWN" ]; then
            test_results[$test_name]="FAILED"
            print_error "$test_name FAILED (script error - no log created)"
            ((failed_tests++))
        else
            test_results[$test_name]="FAILED"
            print_error "$test_name FAILED ($errors errors, $warnings warnings)"
            ((failed_tests++))
        fi
        
        test_durations[$test_name]=$duration_min
        test_transactions[$test_name]=$actual_transactions
        total_duration=$((total_duration + duration_min))
        
        if [ "$actual_transactions" != "N/A" ]; then
            total_transactions=$((total_transactions + actual_transactions))
        fi
        
    else
        test_results[$test_name]="TIMEOUT"
        print_error "$test_name TIMEOUT (>60 minutes)"
        ((failed_tests++))
        test_durations[$test_name]="TIMEOUT"
        test_transactions[$test_name]="N/A"
    fi
    
    ((total_tests++))
    echo ""
}

# Function to run Stage 1 tests
run_stage1_tests() {
    print_header "=== STAGE 1 TESTS (Basic UVM Foundation) ==="
    
    run_single_test "alu_base_test" "3" "100" "Stage 1 - Basic"
    run_single_test "alu_arith_test" "5" "200" "Stage 1 - Arithmetic"
    run_single_test "alu_logic_test" "5" "200" "Stage 1 - Logic"
    run_single_test "alu_shift_test" "5" "200" "Stage 1 - Shift"
}

# Function to run Stage 2 quick tests
run_stage2_quick_tests() {
    print_header "=== STAGE 2 QUICK TESTS (Advanced Verification) ==="
    
    run_single_test "alu_data_pattern_test" "5" "500" "Stage 2 - Data Patterns"
    run_single_test "alu_corner_case_test" "5" "400" "Stage 2 - Corner Cases"
    run_single_test "alu_exhaustive_test" "10" "1000" "Stage 2 - Exhaustive"
}

# Function to run Stage 2 comprehensive tests
run_stage2_comprehensive_tests() {
    print_header "=== STAGE 2 COMPREHENSIVE TESTS (Full Verification) ==="
    
    run_single_test "alu_performance_test" "15" "2000" "Stage 2 - Performance"
    run_single_test "alu_mixed_workload_test" "20" "2000" "Stage 2 - Mixed Workload"
    run_single_test "alu_pipeline_hazard_test" "15" "600" "Stage 2 - Pipeline Hazards"
    run_single_test "alu_comprehensive_stage2_test" "30" "3000" "Stage 2 - Comprehensive"
}

# Function to run Stage 2 stress tests
run_stage2_stress_tests() {
    print_header "=== STAGE 2 STRESS TESTS (Reliability Verification) ==="
    
    run_single_test "alu_stress_test" "45" "10000" "Stage 2 - Stress"
}

# Function to generate summary report
generate_summary_report() {
    local summary_file="$RESULTS_DIR/regression_summary_$TIMESTAMP.log"
    
    print_header "=== GENERATING COMPREHENSIVE SUMMARY REPORT ==="
    
    cat > "$summary_file" << EOF
# CV32E40P ALU Verification - Regression Test Summary
# Generated: $(date)
# Test Suite: $([ "$QUICK_MODE" = true ] && echo "Quick Mode" || echo "Full Mode")
# Coverage: $([ "$COVERAGE_MODE" = true ] && echo "Enabled" || echo "Disabled")
# Verbosity: $([ "$VERBOSE_MODE" = true ] && echo "High (UVM_HIGH)" || echo "Medium (UVM_MEDIUM)")

## Executive Summary
- Total Tests: $total_tests
- Passed: $passed_tests
- Failed: $failed_tests
- Success Rate: $(( passed_tests * 100 / total_tests ))%
- Total Duration: ${total_duration} minutes ($(( total_duration / 60 )) hours $(( total_duration % 60 )) minutes)
- Total Transactions: $total_transactions

## Test Results Detail
EOF

    # Add detailed results
    echo "" >> "$summary_file"
    echo "| Test Name | Result | Duration | Transactions | Category |" >> "$summary_file"
    echo "|-----------|--------|----------|--------------|----------|" >> "$summary_file"
    
    for test_name in "${!test_results[@]}"; do
        local result="${test_results[$test_name]}"
        local duration="${test_durations[$test_name]}"
        local transactions="${test_transactions[$test_name]}"
        local category=""
        
        if [[ $test_name == *"base"* ]] || [[ $test_name == *"arith"* ]] || [[ $test_name == *"logic"* ]] || [[ $test_name == *"shift"* ]]; then
            category="Stage 1"
        else
            category="Stage 2"
        fi
        
        echo "| $test_name | $result | ${duration}m | $transactions | $category |" >> "$summary_file"
    done
    
    # Add coverage summary if enabled
    if [ "$COVERAGE_MODE" = true ]; then
        cat >> "$summary_file" << EOF

## Coverage Analysis
- Coverage databases: $VERIFICATION_DIR/coverage/regression_$TIMESTAMP/
- Individual test coverage: Available per test
- Merged coverage: Run 'urg -dir coverage/regression_$TIMESTAMP/*.vdb' for combined analysis

## Coverage Files Generated
EOF
        find "$VERIFICATION_DIR/coverage/regression_$TIMESTAMP" -name "*.vdb" -type d | while read -r coverage_db; do
            echo "- $(basename "$coverage_db")" >> "$summary_file"
        done
    fi
    
    # Add log file locations
    cat >> "$summary_file" << EOF

## Log Files
- Individual test logs: $LOG_DIR/
- Summary report: $summary_file
- Results directory: $RESULTS_DIR/

## Python Analysis Command
python3 scripts/analyze_regression.py --results-dir "$RESULTS_DIR" --logs-dir "$LOG_DIR"

## Next Steps for Stage 3
1. Analyze coverage databases in coverage/regression_$TIMESTAMP/
2. Review failed tests in individual log files
3. Use summary data for coverage model development
4. Identify coverage holes for additional stimulus

EOF

    print_success "Summary report generated: $summary_file"
}

# Function to create Python analysis script
create_analysis_script() {
    cat > "$VERIFICATION_DIR/scripts/analyze_regression.py" << 'EOF'
#!/usr/bin/env python3
"""
Regression Test Analysis Script for CV32E40P ALU Verification
Analyzes regression test results and generates insights for Stage 3 coverage analysis
"""

import os
import sys
import argparse
import re
from pathlib import Path
import json

class RegressionAnalyzer:
    def __init__(self, results_dir, logs_dir):
        self.results_dir = Path(results_dir)
        self.logs_dir = Path(logs_dir)
        self.test_data = {}
        
    def parse_logs(self):
        """Parse individual test logs for detailed analysis"""
        for log_file in self.logs_dir.glob("*.log"):
            test_name = log_file.stem.split('_')[0]  # Extract test name
            
            with open(log_file, 'r') as f:
                content = f.read()
                
            self.test_data[test_name] = {
                'errors': len(re.findall(r'UVM_ERROR', content)),
                'warnings': len(re.findall(r'UVM_WARNING', content)),
                'transactions': self.extract_transactions(content),
                'ipc': self.extract_ipc(content),
                'coverage_hints': self.extract_coverage_info(content)
            }
    
    def extract_transactions(self, content):
        """Extract transaction count from log"""
        match = re.search(r'transactions:\s*(\d+)', content)
        return int(match.group(1)) if match else 0
    
    def extract_ipc(self, content):
        """Extract IPC measurement if available"""
        match = re.search(r'IPC:\s*([\d.]+)', content)
        return float(match.group(1)) if match else None
    
    def extract_coverage_info(self, content):
        """Extract coverage-related information"""
        coverage_info = []
        if 'coverage' in content.lower():
            coverage_info.append("Coverage data available")
        if 'pattern' in content.lower():
            coverage_info.append("Data pattern coverage")
        return coverage_info
    
    def generate_analysis(self):
        """Generate comprehensive analysis"""
        self.parse_logs()
        
        analysis = {
            'summary': {
                'total_tests': len(self.test_data),
                'total_transactions': sum(data['transactions'] for data in self.test_data.values()),
                'avg_ipc': self.calculate_avg_ipc(),
                'error_rate': self.calculate_error_rate()
            },
            'stage1_analysis': self.analyze_stage1(),
            'stage2_analysis': self.analyze_stage2(),
            'coverage_readiness': self.assess_coverage_readiness(),
            'recommendations': self.generate_recommendations()
        }
        
        return analysis
    
    def calculate_avg_ipc(self):
        """Calculate average IPC across tests that measured it"""
        ipcs = [data['ipc'] for data in self.test_data.values() if data['ipc'] is not None]
        return sum(ipcs) / len(ipcs) if ipcs else None
    
    def calculate_error_rate(self):
        """Calculate overall error rate"""
        total_errors = sum(data['errors'] for data in self.test_data.values())
        total_transactions = sum(data['transactions'] for data in self.test_data.values())
        return (total_errors / total_transactions * 100) if total_transactions > 0 else 0
    
    def analyze_stage1(self):
        """Analyze Stage 1 test results"""
        stage1_tests = {k: v for k, v in self.test_data.items() 
                       if any(stage1_name in k for stage1_name in ['base', 'arith', 'logic', 'shift'])}
        
        return {
            'test_count': len(stage1_tests),
            'total_transactions': sum(data['transactions'] for data in stage1_tests.values()),
            'foundation_solid': all(data['errors'] == 0 for data in stage1_tests.values())
        }
    
    def analyze_stage2(self):
        """Analyze Stage 2 test results"""
        stage2_tests = {k: v for k, v in self.test_data.items() 
                       if not any(stage1_name in k for stage1_name in ['base', 'arith', 'logic', 'shift'])}
        
        return {
            'test_count': len(stage2_tests),
            'total_transactions': sum(data['transactions'] for data in stage2_tests.values()),
            'advanced_features': len([t for t in stage2_tests.keys() if 'performance' in t or 'pattern' in t]),
            'avg_ipc': self.calculate_avg_ipc()  # Stage 2 tests measure IPC
        }
    
    def assess_coverage_readiness(self):
        """Assess readiness for Stage 3 coverage analysis"""
        readiness_score = 0
        factors = []
        
        # Check if we have diverse test types
        if len(self.test_data) >= 8:
            readiness_score += 25
            factors.append("Comprehensive test suite")
        
        # Check transaction volume
        total_trans = sum(data['transactions'] for data in self.test_data.values())
        if total_trans >= 10000:
            readiness_score += 25
            factors.append("High transaction volume")
        
        # Check for performance data
        if any(data['ipc'] is not None for data in self.test_data.values()):
            readiness_score += 25
            factors.append("Performance metrics available")
        
        # Check error rate
        if self.calculate_error_rate() < 1.0:  # Less than 1% error rate
            readiness_score += 25
            factors.append("Low error rate")
        
        return {
            'score': readiness_score,
            'factors': factors,
            'ready_for_stage3': readiness_score >= 75
        }
    
    def generate_recommendations(self):
        """Generate recommendations for Stage 3"""
        recommendations = []
        
        # Coverage model recommendations
        if self.calculate_avg_ipc() and self.calculate_avg_ipc() > 0.8:
            recommendations.append("High IPC indicates good stimulus efficiency - suitable for coverage model")
        
        total_trans = sum(data['transactions'] for data in self.test_data.values())
        if total_trans > 15000:
            recommendations.append("High transaction volume provides good coverage foundation")
        
        # Stage 3 specific recommendations
        recommendations.extend([
            "Focus coverage model on operation × data pattern combinations",
            "Use performance test results to validate coverage efficiency",
            "Consider transaction volume when setting coverage goals",
            "Leverage diverse test types for comprehensive coverage analysis"
        ])
        
        return recommendations

def main():
    parser = argparse.ArgumentParser(description='Analyze CV32E40P ALU regression test results')
    parser.add_argument('--results-dir', required=True, help='Results directory path')
    parser.add_argument('--logs-dir', required=True, help='Logs directory path')
    parser.add_argument('--output', default='regression_analysis.json', help='Output file')
    
    args = parser.parse_args()
    
    analyzer = RegressionAnalyzer(args.results_dir, args.logs_dir)
    analysis = analyzer.generate_analysis()
    
    # Save analysis
    with open(args.output, 'w') as f:
        json.dump(analysis, f, indent=2)
    
    # Print summary
    print("=== CV32E40P ALU Regression Analysis ===")
    print(f"Total Tests: {analysis['summary']['total_tests']}")
    print(f"Total Transactions: {analysis['summary']['total_transactions']}")
    print(f"Average IPC: {analysis['summary']['avg_ipc']:.3f}" if analysis['summary']['avg_ipc'] else "Average IPC: N/A")
    print(f"Error Rate: {analysis['summary']['error_rate']:.2f}%")
    print(f"\nStage 3 Readiness Score: {analysis['coverage_readiness']['score']}/100")
    print(f"Ready for Stage 3: {'Yes' if analysis['coverage_readiness']['ready_for_stage3'] else 'No'}")
    
    print(f"\nAnalysis saved to: {args.output}")

if __name__ == "__main__":
    main()
EOF

    chmod +x "$VERIFICATION_DIR/scripts/analyze_regression.py"
    print_success "Created Python analysis script: scripts/analyze_regression.py"
}

# Main execution function
main() {
    print_header "=========================================="
    print_header "  CV32E40P ALU Verification Suite"
    print_header "     COMPREHENSIVE REGRESSION TESTING"
    print_header "=========================================="
    
    print_info "Mode: $([ "$QUICK_MODE" = true ] && echo "Quick" || echo "Full")"
    print_info "Coverage: $([ "$COVERAGE_MODE" = true ] && echo "Enabled" || echo "Disabled")"
    print_info "Verbosity: $([ "$VERBOSE_MODE" = true ] && echo "High" || echo "Medium")"
    print_info "Timestamp: $TIMESTAMP"
    print_info "Logs: $LOG_DIR"
    print_info "Results: $RESULTS_DIR"
    echo ""
    
    # Check prerequisites
    if ! command -v vcs &> /dev/null; then
        print_error "VCS not found. This script requires VCS for simulation."
        exit 1
    fi
    
    # Create directories
    create_directories
    
    # Create analysis script
    create_analysis_script
    
    # Change to verification directory
    cd "$VERIFICATION_DIR" || exit 1
    
    # Record start time
    local suite_start_time=$(date +%s)
    
    # Run test suites based on mode
    run_stage1_tests
    
    if [ "$QUICK_MODE" = true ]; then
        run_stage2_quick_tests
    else
        run_stage2_quick_tests
        run_stage2_comprehensive_tests
        run_stage2_stress_tests
    fi
    
    # Calculate total suite duration
    local suite_end_time=$(date +%s)
    local suite_duration=$(( (suite_end_time - suite_start_time) / 60 ))
    
    # Generate comprehensive summary
    generate_summary_report
    
    # Final summary
    print_header "=========================================="
    print_header "           REGRESSION COMPLETE"
    print_header "=========================================="
    
    print_info "Suite Duration: ${suite_duration} minutes"
    print_info "Tests Run: $total_tests"
    print_success "Passed: $passed_tests"
    if [ $failed_tests -gt 0 ]; then
        print_error "Failed: $failed_tests"
    fi
    print_info "Success Rate: $(( passed_tests * 100 / total_tests ))%"
    print_info "Total Transactions: $total_transactions"
    
    echo ""
    print_header "STAGE 3 READINESS:"
    if [ $failed_tests -eq 0 ] && [ $total_transactions -gt 10000 ]; then
        print_success "✅ EXCELLENT - Ready for comprehensive coverage analysis"
        print_info "   • All tests passed"
        print_info "   • High transaction volume ($total_transactions)"
        print_info "   • Diverse test coverage"
    elif [ $failed_tests -eq 0 ]; then
        print_success "✅ GOOD - Ready for coverage analysis"
        print_warning "   • Consider running full suite for more transactions"
    else
        print_warning "⚠️  NEEDS ATTENTION - Fix failed tests before Stage 3"
        print_error "   • $failed_tests tests failed"
        print_info "   • Review individual test logs"
    fi
    
    echo ""
    print_header "NEXT STEPS:"
    print_info "1. Review summary: $RESULTS_DIR/regression_summary_$TIMESTAMP.log"
    print_info "2. Analyze results: python3 scripts/analyze_regression.py --results-dir '$RESULTS_DIR' --logs-dir '$LOG_DIR'"
    if [ "$COVERAGE_MODE" = true ]; then
        print_info "3. Merge coverage: urg -dir coverage/regression_$TIMESTAMP/*.vdb -report merged_coverage"
    fi
    print_info "4. Use data for Stage 3 coverage model development"
    
    echo ""
    print_header "FILES GENERATED:"
    print_info "📁 Logs: $LOG_DIR/"
    print_info "📊 Results: $RESULTS_DIR/"
    print_info "📈 Summary: regression_summary_$TIMESTAMP.log"
    if [ "$COVERAGE_MODE" = true ]; then
        print_info "📋 Coverage: coverage/regression_$TIMESTAMP/"
    fi
    
    # Exit with appropriate code
    if [ $failed_tests -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
}

# Execute main function
main "$@"