#!/bin/bash
# =============================================================================
# Test Compilation Script
#
# Tests the compilation readiness of the UVM ALU testbench
# Can be run without VCS license to verify basic structure
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFICATION_DIR="$(dirname "$SCRIPT_DIR")"
UVM_TB_DIR="$VERIFICATION_DIR/uvm_alu_tb"
PROJECT_ROOT="$(dirname "$VERIFICATION_DIR")"
RTL_DIR="$PROJECT_ROOT/rtl"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

print_info "=== UVM ALU Testbench Compilation Test ==="

# Check RTL dependencies
print_info "Checking RTL dependencies..."
required_rtl_files=(
    "include/cv32e40p_pkg.sv"
    "cv32e40p_alu.sv"
    "cv32e40p_top.sv"
    "cv32e40p_core.sv"
    "cv32e40p_ex_stage.sv"
)

missing_rtl=0
for file in "${required_rtl_files[@]}"; do
    if [ ! -f "$RTL_DIR/$file" ]; then
        print_error "Missing RTL file: $file"
        ((missing_rtl++))
    else
        print_success "Found RTL file: $file"
    fi
done

if [ "$missing_rtl" -gt 0 ]; then
    print_error "$missing_rtl RTL files missing. Cannot proceed with compilation test."
    exit 1
fi

# Check testbench file completeness
print_info "Checking testbench completeness..."

# Check critical files
critical_files=(
    "interfaces/cv32e40p_if.sv"
    "interfaces/alu_monitor_if.sv"
    "env/alu_tb_pkg.sv"
    "env/alu_tb_config.sv"
    "env/alu_tb_env.sv"
    "env/alu_base_test.sv"
    "tb/alu_tb_top.sv"
    "config/alu_test_config.yaml"
)

missing_tb=0
for file in "${critical_files[@]}"; do
    if [ ! -f "$UVM_TB_DIR/$file" ]; then
        print_error "Missing testbench file: $file"
        ((missing_tb++))
    else
        print_success "Found testbench file: $file"
    fi
done

if [ "$missing_tb" -gt 0 ]; then
    print_error "$missing_tb testbench files missing."
    exit 1
fi

# Check UVM component structure
print_info "Checking UVM component structure..."

# Check for UVM base classes usage
check_uvm_usage() {
    local file="$1"
    local component_type="$2"
    
    if grep -q "extends uvm_$component_type" "$file"; then
        print_success "$file: Properly extends uvm_$component_type"
        return 0
    else
        print_warning "$file: May not properly extend uvm_$component_type"
        return 1
    fi
}

# Check drivers
check_uvm_usage "$UVM_TB_DIR/env/instruction_driver.sv" "driver"
check_uvm_usage "$UVM_TB_DIR/env/memory_driver.sv" "driver"

# Check monitors
check_uvm_usage "$UVM_TB_DIR/env/alu_monitor.sv" "monitor"

# Check agents
check_uvm_usage "$UVM_TB_DIR/env/instruction_agent.sv" "agent"
check_uvm_usage "$UVM_TB_DIR/env/memory_agent.sv" "agent"

# Check environment
check_uvm_usage "$UVM_TB_DIR/env/alu_tb_env.sv" "env"

# Check tests
check_uvm_usage "$UVM_TB_DIR/env/alu_base_test.sv" "test"

# Check sequence items
if grep -q "extends uvm_sequence_item" "$UVM_TB_DIR/env/instruction_item.sv"; then
    print_success "instruction_item.sv: Properly extends uvm_sequence_item"
else
    print_warning "instruction_item.sv: May not properly extend uvm_sequence_item"
fi

# Check for factory registration
print_info "Checking UVM factory registrations..."
factory_files=(
    "env/alu_tb_config.sv"
    "env/instruction_item.sv"
    "env/memory_item.sv"
    "env/alu_monitor_item.sv"
    "env/instruction_driver.sv"
    "env/memory_driver.sv"
    "env/alu_monitor.sv"
    "env/alu_base_test.sv"
    "env/alu_tb_env.sv"
)

missing_factory=0
for file in "${factory_files[@]}"; do
    if grep -q "uvm_.*_utils" "$UVM_TB_DIR/$file"; then
        print_success "$file: Has factory registration"
    else
        print_warning "$file: Missing factory registration"
        ((missing_factory++))
    fi
done

# Generate compilation file list
print_info "Generating file list for compilation..."

cat > "$VERIFICATION_DIR/file_list.f" << EOF
// RTL Files
$RTL_DIR/include/cv32e40p_pkg.sv
$RTL_DIR/cv32e40p_alu.sv
$RTL_DIR/cv32e40p_alu_div.sv
$RTL_DIR/cv32e40p_ff_one.sv
$RTL_DIR/cv32e40p_popcnt.sv
$RTL_DIR/cv32e40p_mult.sv
$RTL_DIR/cv32e40p_int_controller.sv
$RTL_DIR/cv32e40p_ex_stage.sv
$RTL_DIR/cv32e40p_id_stage.sv
$RTL_DIR/cv32e40p_if_stage.sv
$RTL_DIR/cv32e40p_load_store_unit.sv
$RTL_DIR/cv32e40p_controller.sv
$RTL_DIR/cv32e40p_fifo.sv
$RTL_DIR/cv32e40p_hwloop_regs.sv
$RTL_DIR/cv32e40p_prefetch_buffer.sv
$RTL_DIR/cv32e40p_prefetch_controller.sv
$RTL_DIR/cv32e40p_obi_interface.sv
$RTL_DIR/cv32e40p_aligner.sv
$RTL_DIR/cv32e40p_decoder.sv
$RTL_DIR/cv32e40p_compressed_decoder.sv
$RTL_DIR/cv32e40p_register_file_ff.sv
$RTL_DIR/cv32e40p_cs_registers.sv
$RTL_DIR/cv32e40p_sleep_unit.sv
$RTL_DIR/cv32e40p_core.sv
$RTL_DIR/cv32e40p_top.sv

// Testbench Files
$UVM_TB_DIR/interfaces/cv32e40p_if.sv
$UVM_TB_DIR/interfaces/alu_monitor_if.sv
$UVM_TB_DIR/env/alu_tb_pkg.sv
$UVM_TB_DIR/tb/alu_tb_top.sv
EOF

print_success "File list generated: $VERIFICATION_DIR/file_list.f"

# Test with iverilog if available (basic syntax check)
if command -v iverilog &> /dev/null; then
    print_info "Testing basic compilation with iverilog..."
    
    # Create a minimal test for interfaces only
    cat > "$VERIFICATION_DIR/test_interfaces.sv" << EOF
\`timescale 1ns/1ps

module test_interfaces;
    logic clk = 0;
    logic rst_n = 1;
    
    always #5 clk = ~clk;
    
    cv32e40p_if processor_if(.clk_i(clk), .rst_ni(rst_n));
    alu_monitor_if alu_mon_if(.clk(clk), .rst_n(rst_n));
    
    initial begin
        #100;
        \$display("Interface test completed successfully");
        \$finish;
    end
endmodule
EOF
    
    if iverilog -g2012 -I"$UVM_TB_DIR/interfaces" "$UVM_TB_DIR/interfaces/cv32e40p_if.sv" "$UVM_TB_DIR/interfaces/alu_monitor_if.sv" "$VERIFICATION_DIR/test_interfaces.sv" -o "$VERIFICATION_DIR/test_interfaces" 2>/dev/null; then
        print_success "Basic interface compilation test passed with iverilog"
        rm -f "$VERIFICATION_DIR/test_interfaces" "$VERIFICATION_DIR/test_interfaces.sv"
    else
        print_warning "Basic interface compilation test failed with iverilog"
    fi
else
    print_info "iverilog not available - skipping basic compilation test"
fi

# Summary report
print_info "=== Compilation Readiness Summary ==="
print_info "RTL files: $(( ${#required_rtl_files[@]} - missing_rtl ))/${#required_rtl_files[@]} found"
print_info "Testbench files: $(( ${#critical_files[@]} - missing_tb ))/${#critical_files[@]} found"
print_info "Factory registrations: $(( ${#factory_files[@]} - missing_factory ))/${#factory_files[@]} found"

total_issues=$((missing_rtl + missing_tb + missing_factory))

if [ "$total_issues" -eq 0 ]; then
    print_success "=== COMPILATION READY ==="
    print_info "All required files found and basic structure validated"
    print_info "Ready for VCS compilation with:"
    print_info "  cd verification/scripts"
    print_info "  ./run_vcs.sh"
else
    print_warning "=== ISSUES FOUND ==="
    print_warning "Total issues: $total_issues"
    print_info "Please fix issues before attempting VCS compilation"
fi

print_info "=== Test Complete ==="