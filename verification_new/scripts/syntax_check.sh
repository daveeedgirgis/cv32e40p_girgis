#!/bin/bash
# =============================================================================
# Syntax Check Script for Stage 1 Implementation
#
# Quick syntax validation without full compilation
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFICATION_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$VERIFICATION_DIR")"
UVM_TB_DIR="$VERIFICATION_DIR/uvm_tb"
RTL_DIR="$PROJECT_ROOT/rtl"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

print_info "=== Stage 1 Syntax Check ==="

# Check if we have the basic files
print_info "Checking file structure..."

files_to_check=(
    "$VERIFICATION_DIR/config/alu_test_config.yaml"
    "$UVM_TB_DIR/interfaces/cv32e40p_if.sv"
    "$UVM_TB_DIR/interfaces/alu_monitor_if.sv"
    "$UVM_TB_DIR/env/alu_pkg.sv"
    "$UVM_TB_DIR/env/alu_config.sv"
    "$UVM_TB_DIR/env/alu_transaction.sv"
    "$UVM_TB_DIR/env/alu_sequence_item.sv"
    "$UVM_TB_DIR/env/alu_sequence_lib.sv"
    "$UVM_TB_DIR/env/alu_driver.sv"
    "$UVM_TB_DIR/env/alu_monitor.sv"
    "$UVM_TB_DIR/env/alu_scoreboard.sv"
    "$UVM_TB_DIR/env/alu_agent.sv"
    "$UVM_TB_DIR/env/alu_env.sv"
    "$UVM_TB_DIR/env/alu_base_test.sv"
    "$UVM_TB_DIR/env/alu_arith_test.sv"
    "$UVM_TB_DIR/env/alu_logic_test.sv"
    "$UVM_TB_DIR/env/alu_shift_test.sv"
    "$UVM_TB_DIR/tb/alu_tb_top.sv"
    "$VERIFICATION_DIR/scripts/run_vcs.sh"
)

missing_files=0
for file in "${files_to_check[@]}"; do
    if [ ! -f "$file" ]; then
        print_error "Missing file: $file"
        missing_files=$((missing_files + 1))
    fi
done

if [ $missing_files -eq 0 ]; then
    print_success "All expected files found"
else
    print_error "$missing_files files missing"
    exit 1
fi

# Check RTL files
print_info "Checking RTL files..."
rtl_files=(
    "$RTL_DIR/include/cv32e40p_pkg.sv"
    "$RTL_DIR/cv32e40p_alu.sv"
    "$RTL_DIR/cv32e40p_top.sv"
)

missing_rtl=0
for file in "${rtl_files[@]}"; do
    if [ ! -f "$file" ]; then
        print_error "Missing RTL file: $file"
        missing_rtl=$((missing_rtl + 1))
    fi
done

if [ $missing_rtl -eq 0 ]; then
    print_success "Critical RTL files found"
else
    print_error "$missing_rtl RTL files missing"
    exit 1
fi

# Count lines of code
print_info "Counting lines of code..."
total_lines=0
for file in "${files_to_check[@]}"; do
    if [ -f "$file" ] && [[ "$file" == *.sv ]]; then
        lines=$(wc -l < "$file")
        total_lines=$((total_lines + lines))
    fi
done

print_info "Total SystemVerilog lines: $total_lines"

# Check for basic syntax issues (simplified)
print_info "Checking for basic syntax issues..."

syntax_errors=0

# Check for basic SystemVerilog syntax patterns (improved)
for file in "${files_to_check[@]}"; do
    if [[ "$file" == *.sv ]]; then
        if [ -f "$file" ]; then
            # Check for actual syntax issues - look for class/module/interface declarations
            if ! grep -q "^\s*\(class\|module\|interface\|package\)" "$file"; then
                # Skip files that might be include files or have different structure
                continue
            fi
            
            # Check for proper class/module/interface endings
            if grep -q "^\s*class\s" "$file" && ! grep -q "endclass" "$file"; then
                print_error "Class without endclass in $file"
                syntax_errors=$((syntax_errors + 1))
            fi
            
            if grep -q "^\s*module\s" "$file" && ! grep -q "endmodule" "$file"; then
                print_error "Module without endmodule in $file"
                syntax_errors=$((syntax_errors + 1))
            fi
            
            if grep -q "^\s*interface\s" "$file" && ! grep -q "endinterface" "$file"; then
                print_error "Interface without endinterface in $file"
                syntax_errors=$((syntax_errors + 1))
            fi
        fi
    fi
done

if [ $syntax_errors -eq 0 ]; then
    print_success "No obvious syntax errors found"
else
    print_error "$syntax_errors potential syntax issues found"
fi

# Summary
print_info "=== Syntax Check Summary ==="
print_info "Files checked: ${#files_to_check[@]}"
print_info "Total SystemVerilog lines: $total_lines"

if [ $missing_files -eq 0 ] && [ $missing_rtl -eq 0 ] && [ $syntax_errors -eq 0 ]; then
    print_success "*** SYNTAX CHECK PASSED ***"
    print_info "Stage 1 implementation appears syntactically correct"
    exit 0
else
    print_error "*** SYNTAX CHECK FAILED ***"
    exit 1
fi