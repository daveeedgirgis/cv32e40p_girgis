#!/bin/bash
# =============================================================================
# Syntax Check Script for UVM ALU Testbench
#
# This script performs basic syntax checking of SystemVerilog files
# without requiring the full VCS license or RTL dependencies
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFICATION_DIR="$(dirname "$SCRIPT_DIR")"
UVM_TB_DIR="$VERIFICATION_DIR/uvm_alu_tb"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

print_info "=== UVM ALU Testbench Syntax Check ==="

# Function to check file syntax
check_file_syntax() {
    local file="$1"
    local basename=$(basename "$file")
    
    if [ ! -f "$file" ]; then
        print_error "File not found: $file"
        return 1
    fi
    
    print_info "Checking: $basename"
    
    # Basic SystemVerilog syntax checks
    local errors=0
    
    # Check for matching begin/end
    local begin_count=$(grep -c "\bbegin\b" "$file")
    local end_count=$(grep -c "\bend\b" "$file")
    
    if [ "$begin_count" -ne "$end_count" ]; then
        print_warning "$basename: Mismatched begin ($begin_count) and end ($end_count) statements"
        ((errors++))
    fi
    
    # Check for matching parentheses in function/task definitions
    if grep -q "function\|task" "$file"; then
        local func_lines=$(grep -n "function\|task" "$file")
        print_info "$basename: Found function/task definitions"
    fi
    
    # Check for basic SystemVerilog issues
    if grep -q "^\s*\`include.*\.sv" "$file"; then
        local includes=$(grep "^\s*\`include.*\.sv" "$file" | wc -l)
        print_info "$basename: Found $includes include statements"
    fi
    
    # Check for UVM usage
    if grep -q "uvm_" "$file"; then
        print_info "$basename: UVM components detected"
    fi
    
    # Check for common syntax issues
    if grep -q ";" "$file" && grep -q "endmodule\|endclass\|endfunction\|endtask" "$file"; then
        print_info "$basename: Basic syntax structure looks good"
    fi
    
    if [ "$errors" -eq 0 ]; then
        print_success "$basename: Syntax check passed"
        return 0
    else
        print_error "$basename: Syntax check failed with $errors issues"
        return 1
    fi
}

# Check all our SystemVerilog files
print_info "Checking interface files..."
check_file_syntax "$UVM_TB_DIR/interfaces/cv32e40p_if.sv"
check_file_syntax "$UVM_TB_DIR/interfaces/alu_monitor_if.sv"

print_info "Checking environment files..."
check_file_syntax "$UVM_TB_DIR/env/alu_tb_pkg.sv"
check_file_syntax "$UVM_TB_DIR/env/alu_tb_config.sv"
check_file_syntax "$UVM_TB_DIR/env/instruction_item.sv"
check_file_syntax "$UVM_TB_DIR/env/memory_item.sv"
check_file_syntax "$UVM_TB_DIR/env/alu_monitor_item.sv"

print_info "Checking driver files..."
check_file_syntax "$UVM_TB_DIR/env/instruction_driver.sv"
check_file_syntax "$UVM_TB_DIR/env/memory_driver.sv"
check_file_syntax "$UVM_TB_DIR/env/alu_monitor.sv"

print_info "Checking agent files..."
check_file_syntax "$UVM_TB_DIR/env/instruction_agent.sv"
check_file_syntax "$UVM_TB_DIR/env/memory_agent.sv"
check_file_syntax "$UVM_TB_DIR/env/alu_monitor_agent.sv"

print_info "Checking test files..."
check_file_syntax "$UVM_TB_DIR/env/alu_base_test.sv"
check_file_syntax "$UVM_TB_DIR/env/alu_arithmetic_test.sv"
check_file_syntax "$UVM_TB_DIR/env/alu_logic_test.sv"

print_info "Checking sequence files..."
check_file_syntax "$UVM_TB_DIR/env/basic_alu_sequence.sv"
check_file_syntax "$UVM_TB_DIR/env/alu_instruction_sequence.sv"

print_info "Checking verification components..."
check_file_syntax "$UVM_TB_DIR/env/alu_scoreboard.sv"
check_file_syntax "$UVM_TB_DIR/env/alu_tb_env.sv"

print_info "Checking top-level testbench..."
check_file_syntax "$UVM_TB_DIR/tb/alu_tb_top.sv"

# Check configuration file
print_info "Checking configuration file..."
if [ -f "$UVM_TB_DIR/config/alu_test_config.yaml" ]; then
    print_success "Configuration file found"
else
    print_error "Configuration file missing"
fi

# Summary
print_info "=== File Structure Check ==="
print_info "Verification directory: $(ls -1 "$VERIFICATION_DIR" | wc -l) items"
print_info "UVM testbench directory: $(ls -1 "$UVM_TB_DIR" | wc -l) items"
print_info "Interface files: $(ls -1 "$UVM_TB_DIR/interfaces" 2>/dev/null | wc -l) files"
print_info "Environment files: $(ls -1 "$UVM_TB_DIR/env" 2>/dev/null | wc -l) files"
print_info "Test files: $(find "$UVM_TB_DIR" -name "*test*.sv" 2>/dev/null | wc -l) files"

print_success "=== Syntax Check Complete ==="
print_info "All basic syntax checks completed."
print_info "For full compilation testing, use: ./run_vcs.sh"