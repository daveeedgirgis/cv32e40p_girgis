#!/bin/bash
# =============================================================================
# Environment Debug Script
#
# Helps diagnose environment and path issues for VCS compilation
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFICATION_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$VERIFICATION_DIR")"
UVM_TB_DIR="$VERIFICATION_DIR/uvm_alu_tb"
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

print_info "=== Environment Debug Information ==="

# Show current working directory
print_info "Current directory: $(pwd)"

# Show script paths
print_info "Script directory: $SCRIPT_DIR"
print_info "Verification directory: $VERIFICATION_DIR"
print_info "Project root directory: $PROJECT_ROOT"
print_info "UVM testbench directory: $UVM_TB_DIR"
print_info "RTL directory: $RTL_DIR"

# Check directory existence
print_info "=== Directory Existence Check ==="
directories=("$VERIFICATION_DIR" "$PROJECT_ROOT" "$UVM_TB_DIR" "$RTL_DIR")
for dir in "${directories[@]}"; do
    if [ -d "$dir" ]; then
        print_success "Found: $dir"
    else
        print_error "Missing: $dir"
    fi
done

# Check critical RTL files
print_info "=== RTL Files Check ==="
rtl_files=(
    "include/cv32e40p_pkg.sv"
    "cv32e40p_alu.sv"
    "cv32e40p_top.sv"
    "cv32e40p_core.sv"
    "cv32e40p_ex_stage.sv"
)

missing_rtl=0
for file in "${rtl_files[@]}"; do
    full_path="$RTL_DIR/$file"
    if [ -f "$full_path" ]; then
        print_success "Found RTL: $file"
    else
        print_error "Missing RTL: $file"
        print_info "  Expected at: $full_path"
        ((missing_rtl++))
    fi
done

# Check testbench files
print_info "=== Testbench Files Check ==="
tb_files=(
    "interfaces/cv32e40p_if.sv"
    "env/alu_tb_pkg.sv"
    "config/alu_test_config.yaml"
    "tb/alu_tb_top.sv"
)

missing_tb=0
for file in "${tb_files[@]}"; do
    full_path="$UVM_TB_DIR/$file"
    if [ -f "$full_path" ]; then
        print_success "Found TB: $file"
    else
        print_error "Missing TB: $file"
        print_info "  Expected at: $full_path"
        ((missing_tb++))
    fi
done

# Check VCS availability
print_info "=== VCS Environment Check ==="
if command -v vcs &> /dev/null; then
    VCS_VERSION=$(vcs -help 2>&1 | head -1)
    print_success "VCS found: $VCS_VERSION"
else
    print_error "VCS not found in PATH"
    print_info "VCS might not be installed or not in PATH"
    print_info "Try: which vcs"
    print_info "Or: module load vcs (if using environment modules)"
fi

# Check UVM availability
print_info "=== UVM Environment Check ==="
if [ -n "$UVM_HOME" ]; then
    if [ -d "$UVM_HOME" ]; then
        print_success "UVM_HOME set and exists: $UVM_HOME"
    else
        print_error "UVM_HOME set but directory doesn't exist: $UVM_HOME"
    fi
else
    print_warning "UVM_HOME not set"
    # Check common UVM locations
    common_uvm_paths=(
        "/opt/synopsys/vcs/etc/uvm"
        "/usr/synopsys/vcs/etc/uvm"
        "/tools/synopsys/vcs/etc/uvm"
    )
    
    for path in "${common_uvm_paths[@]}"; do
        if [ -d "$path" ]; then
            print_info "Found UVM at: $path"
            print_info "Try: export UVM_HOME=$path"
        fi
    done
fi

# Check other environment variables
print_info "=== Environment Variables ==="
env_vars=("VCS_HOME" "SNPS_VCS_HOME" "SYNOPSYS_HOME")
for var in "${env_vars[@]}"; do
    if [ -n "${!var}" ]; then
        print_info "$var = ${!var}"
    else
        print_warning "$var not set"
    fi
done

# Show file structure
print_info "=== Project Structure ==="
if [ -d "$PROJECT_ROOT" ]; then
    print_info "Project root contents:"
    ls -la "$PROJECT_ROOT" | sed 's/^/  /'
fi

if [ -d "$VERIFICATION_DIR" ]; then
    print_info "Verification directory contents:"
    ls -la "$VERIFICATION_DIR" | sed 's/^/  /'
fi

# Suggestions
print_info "=== Suggestions ==="

if [ "$missing_rtl" -gt 0 ]; then
    print_warning "Missing RTL files detected. Possible solutions:"
    print_info "  1. Check if you're in the correct directory"
    print_info "  2. Verify the cv32e40p repository is complete"
    print_info "  3. Check if RTL files are in a different location"
fi

if ! command -v vcs &> /dev/null; then
    print_warning "VCS not available. Possible solutions:"
    print_info "  1. Load VCS module: module load synopsys/vcs"
    print_info "  2. Add VCS to PATH: export PATH=\$PATH:/path/to/vcs/bin"
    print_info "  3. Source VCS setup script"
    print_info "  4. Contact system administrator for VCS installation"
fi

if [ -z "$UVM_HOME" ]; then
    print_warning "UVM_HOME not set. Try:"
    print_info "  export UVM_HOME=/opt/synopsys/vcs/etc/uvm"
fi

print_info "=== Debug Complete ==="