#!/bin/bash
# =============================================================================
# VCS Build and Run Script for ALU Testbench
#
# This script compiles and runs the UVM ALU testbench using VCS simulator
# Usage: ./run_vcs.sh [test_name] [config_file] [additional_options]
# =============================================================================

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
VERIFICATION_DIR="$PROJECT_ROOT/verification"
UVM_TB_DIR="$VERIFICATION_DIR/uvm_alu_tb"
RTL_DIR="$PROJECT_ROOT/rtl"

# Default values
DEFAULT_CONFIG="$UVM_TB_DIR/config/alu_test_config.yaml"
DEFAULT_TEST="alu_base_test"
DEFAULT_VERBOSITY="UVM_MEDIUM"
DEFAULT_SEED="1"

# Parse command line arguments
TEST_NAME="${1:-$DEFAULT_TEST}"
CONFIG_FILE="${2:-$DEFAULT_CONFIG}"
VERBOSITY="${3:-$DEFAULT_VERBOSITY}"
SEED="${4:-$DEFAULT_SEED}"
ADDITIONAL_OPTS="${@:5}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

# Function to check if command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "$1 could not be found. Please ensure it's in your PATH."
        exit 1
    fi
}

# Function to validate file exists
check_file() {
    if [ ! -f "$1" ]; then
        print_error "File not found: $1"
        exit 1
    fi
}

# Function to create directory if it doesn't exist
ensure_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        print_info "Created directory: $1"
    fi
}

# Function to parse YAML config (simplified)
parse_config() {
    local config_file="$1"
    if [ -f "$config_file" ]; then
        print_info "Using configuration file: $config_file"
        # Extract key configuration values
        ENABLE_COVERAGE=$(grep "enable_coverage:" "$config_file" | awk '{print $2}')
        ENABLE_WAVEFORMS=$(grep "enable_waveform_dump:" "$config_file" | awk '{print $2}')
        WAVEFORM_FORMAT=$(grep "waveform_format:" "$config_file" | awk '{print $2}' | tr -d '"')
        NUM_INSTRUCTIONS=$(grep "num_instructions:" "$config_file" | awk '{print $2}')
    else
        print_warning "Configuration file not found: $config_file"
        print_info "Using default configuration"
        ENABLE_COVERAGE="true"
        ENABLE_WAVEFORMS="true"
        WAVEFORM_FORMAT="fsdb"
        NUM_INSTRUCTIONS="1000"
    fi
}

# Function to display script usage
show_usage() {
    echo "Usage: $0 [test_name] [config_file] [verbosity] [seed] [additional_options]"
    echo ""
    echo "Arguments:"
    echo "  test_name      Test to run (default: $DEFAULT_TEST)"
    echo "  config_file    YAML configuration file (default: $DEFAULT_CONFIG)"
    echo "  verbosity      UVM verbosity level (default: $DEFAULT_VERBOSITY)"
    echo "  seed           Random seed (default: $DEFAULT_SEED)"
    echo "  additional_options  Additional VCS options"
    echo ""
    echo "Available tests:"
    echo "  alu_base_test        - Basic mixed ALU operations"
    echo "  alu_arithmetic_test  - Arithmetic operations focus"
    echo "  alu_logic_test       - Logic operations focus"
    echo "  alu_shift_test       - Shift operations focus"
    echo "  alu_comparison_test  - Comparison operations focus"
    echo "  alu_stress_test      - High-volume stress test"
    echo "  alu_corner_case_test - Corner case focused test"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Run default test"
    echo "  $0 alu_arithmetic_test                # Run arithmetic test"
    echo "  $0 alu_stress_test config.yaml       # Run with custom config"
    echo "  $0 alu_base_test config.yaml UVM_HIGH 42  # Custom verbosity and seed"
}

# Function to clean previous builds
clean_build() {
    print_info "Cleaning previous build artifacts..."
    rm -rf simv simv.daidir csrc *.vpd *.fsdb *.log DVEfiles *.key ucli.key
    rm -rf work_* *.vcd AN.DB coverage.vdb
}

# Main script execution
main() {
    print_info "=== CV32E40P ALU Testbench VCS Runner ==="
    print_info "Test: $TEST_NAME"
    print_info "Config: $CONFIG_FILE"
    print_info "Verbosity: $VERBOSITY"
    print_info "Seed: $SEED"
    
    # Check for help flag
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        show_usage
        exit 0
    fi
    
    # Verify prerequisites
    print_info "Checking prerequisites..."
    check_command "vcs"
    check_command "python3"
    
    # Verify directory structure
    check_file "$RTL_DIR/cv32e40p_top.sv"
    check_file "$UVM_TB_DIR/env/alu_tb_pkg.sv"
    
    # Parse configuration
    parse_config "$CONFIG_FILE"
    
    # Create output directories
    ensure_dir "logs"
    ensure_dir "reports"
    ensure_dir "coverage"
    ensure_dir "waves"
    
    # Clean previous builds
    clean_build
    
    # Set up environment variables
    export UVM_HOME="${UVM_HOME:-/opt/synopsys/vcs/etc/uvm}"
    export VCS_HOME="${VCS_HOME:-/opt/synopsys/vcs}"
    
    if [ ! -d "$UVM_HOME" ]; then
        print_error "UVM_HOME not found: $UVM_HOME"
        print_info "Please set UVM_HOME environment variable or install UVM"
        exit 1
    fi
    
    # Build VCS compile options
    COMPILE_OPTS=""
    COMPILE_OPTS="$COMPILE_OPTS -sverilog"                    # Enable SystemVerilog
    COMPILE_OPTS="$COMPILE_OPTS -ntb_opts uvm-1.2"          # Use UVM 1.2
    COMPILE_OPTS="$COMPILE_OPTS +define+UVM_REGEX_NO_DPI"    # UVM without DPI regex
    COMPILE_OPTS="$COMPILE_OPTS -timescale=1ns/1ps"         # Time scale
    COMPILE_OPTS="$COMPILE_OPTS -debug_access+all"          # Debug access
    COMPILE_OPTS="$COMPILE_OPTS +vcs+lic+wait"              # License wait
    COMPILE_OPTS="$COMPILE_OPTS -l compile.log"             # Compile log
    COMPILE_OPTS="$COMPILE_OPTS +incdir+$UVM_TB_DIR/env"    # Include UVM env
    COMPILE_OPTS="$COMPILE_OPTS +incdir+$RTL_DIR/include"   # Include RTL packages
    COMPILE_OPTS="$COMPILE_OPTS +incdir+$UVM_TB_DIR/interfaces" # Include interfaces
    
    # Add coverage options if enabled
    if [ "$ENABLE_COVERAGE" = "true" ]; then
        COMPILE_OPTS="$COMPILE_OPTS -cm line+cond+fsm+branch+tgl"
        COMPILE_OPTS="$COMPILE_OPTS -cm_dir coverage.vdb"
        print_info "Coverage collection enabled"
    fi
    
    # Build runtime options
    RUNTIME_OPTS=""
    RUNTIME_OPTS="$RUNTIME_OPTS +UVM_TESTNAME=$TEST_NAME"
    RUNTIME_OPTS="$RUNTIME_OPTS +UVM_VERBOSITY=$VERBOSITY"
    RUNTIME_OPTS="$RUNTIME_OPTS +ntb_random_seed=$SEED"
    RUNTIME_OPTS="$RUNTIME_OPTS -l simulation.log"
    RUNTIME_OPTS="$RUNTIME_OPTS +vcs+lic+wait"
    
    # Add waveform options if enabled
    if [ "$ENABLE_WAVEFORMS" = "true" ]; then
        if [ "$WAVEFORM_FORMAT" = "fsdb" ]; then
            RUNTIME_OPTS="$RUNTIME_OPTS +fsdbfile+waves/alu_test.fsdb"
            COMPILE_OPTS="$COMPILE_OPTS +define+DUMP_FSDB"
        else
            RUNTIME_OPTS="$RUNTIME_OPTS +vcdfile+waves/alu_test.vcd"
            COMPILE_OPTS="$COMPILE_OPTS +define+DUMP_VCD"
        fi
        print_info "Waveform dump enabled ($WAVEFORM_FORMAT format)"
    fi
    
    # Add coverage runtime options
    if [ "$ENABLE_COVERAGE" = "true" ]; then
        RUNTIME_OPTS="$RUNTIME_OPTS -cm line+cond+fsm+branch+tgl"
        RUNTIME_OPTS="$RUNTIME_OPTS -cm_dir coverage.vdb"
    fi
    
    # Create file list
    print_info "Creating file list..."
    cat > files.f << EOF
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

// Verification Files  
$UVM_TB_DIR/interfaces/cv32e40p_if.sv
$UVM_TB_DIR/interfaces/alu_monitor_if.sv
$UVM_TB_DIR/env/alu_tb_pkg.sv
$UVM_TB_DIR/tb/alu_tb_top.sv
EOF
    
    # Compilation phase
    print_info "Starting VCS compilation..."
    echo "vcs $COMPILE_OPTS -f files.f $ADDITIONAL_OPTS"
    
    if vcs $COMPILE_OPTS -f files.f $ADDITIONAL_OPTS; then
        print_success "Compilation completed successfully"
    else
        print_error "Compilation failed"
        exit 1
    fi
    
    # Simulation phase
    print_info "Starting simulation..."
    echo "./simv $RUNTIME_OPTS"
    
    if ./simv $RUNTIME_OPTS; then
        print_success "Simulation completed successfully"
    else
        print_error "Simulation failed"
        exit 1
    fi
    
    # Post-processing
    print_info "Post-processing results..."
    
    # Move logs to logs directory
    mv compile.log logs/ 2>/dev/null || true
    mv simulation.log logs/ 2>/dev/null || true
    
    # Generate coverage reports if coverage was enabled
    if [ "$ENABLE_COVERAGE" = "true" ] && [ -d "coverage.vdb" ]; then
        print_info "Generating coverage reports..."
        urg -dir coverage.vdb -report reports/coverage_report
        print_success "Coverage reports generated in reports/coverage_report"
    fi
    
    # Summary
    print_success "=== Test Execution Summary ==="
    print_info "Test: $TEST_NAME"
    print_info "Seed: $SEED"
    print_info "Instructions: $NUM_INSTRUCTIONS"
    
    if [ -f "logs/simulation.log" ]; then
        # Extract basic statistics from log
        ERRORS=$(grep -c "UVM_ERROR" logs/simulation.log 2>/dev/null || echo "0")
        WARNINGS=$(grep -c "UVM_WARNING" logs/simulation.log 2>/dev/null || echo "0")
        
        print_info "Errors: $ERRORS"
        print_info "Warnings: $WARNINGS"
        
        if [ "$ERRORS" -eq "0" ]; then
            print_success "Test PASSED"
        else
            print_error "Test FAILED with $ERRORS errors"
            exit 1
        fi
    fi
    
    print_info "Logs available in: logs/"
    if [ "$ENABLE_COVERAGE" = "true" ]; then
        print_info "Coverage reports in: reports/"
    fi
    if [ "$ENABLE_WAVEFORMS" = "true" ]; then
        print_info "Waveforms available in: waves/"
    fi
    
    print_success "Script execution completed"
}

# Run main function
main "$@"