# CV32E40P ALU Verification Environment - Stage 1

## Overview

This directory contains a professional UVM-based verification environment for the CV32E40P ALU (Arithmetic Logic Unit). The verification targets ALU operations within the CV32E40P RISC-V processor through processor-level testing with ALU-focused stimulus.

**STAGE 1 IMPLEMENTATION - BUILT FROM SCRATCH**

This implementation addresses all requirements for Stage 1:
- Correct RTL signal connections based on actual CV32E40P hierarchy  
- Proper UVM methodology with modular design
- Comprehensive configuration system
- Professional build scripts for VCS
- Parameterizable for different test scenarios

## Directory Structure

```
verification_new/
├── README.md                    # This documentation
├── config/                      # Configuration files
│   └── alu_test_config.yaml    # Main YAML configuration
├── scripts/                     # Build and run scripts
│   ├── run_vcs.sh              # VCS compilation and simulation
│   ├── compile_check.sh        # Syntax validation
│   └── clean.sh                # Clean build artifacts
├── uvm_tb/                     # UVM Testbench
│   ├── interfaces/             # SystemVerilog interfaces
│   │   ├── cv32e40p_if.sv     # Processor interface
│   │   └── alu_monitor_if.sv   # ALU monitoring interface
│   ├── env/                    # UVM Environment components
│   │   ├── alu_pkg.sv         # Main UVM package
│   │   ├── alu_config.sv      # Configuration class
│   │   ├── alu_env.sv         # Main environment
│   │   ├── alu_agent.sv       # ALU agent
│   │   ├── alu_driver.sv      # ALU driver
│   │   ├── alu_monitor.sv     # ALU monitor
│   │   ├── alu_scoreboard.sv  # Result checking
│   │   └── alu_sequence_lib.sv # Sequence library
│   ├── tests/                  # UVM Test classes
│   │   ├── alu_base_test.sv   # Base test class
│   │   ├── alu_arith_test.sv  # Arithmetic operations test
│   │   ├── alu_logic_test.sv  # Logic operations test
│   │   └── alu_shift_test.sv  # Shift operations test
│   └── tb/                     # Top-level testbench
│       └── alu_tb_top.sv      # Testbench top module
└── docs/                       # Documentation
    ├── STAGE1_PLAN.md         # Stage 1 implementation plan
    └── USER_GUIDE.md          # User guide
```

## Key Features

### 1. Processor-Level Testing
- Tests ALU through actual RISC-V instruction execution
- Uses standard processor interfaces (OBI memory interface)
- Proper memory models with protocol compliance
- Real instruction sequences that exercise ALU operations

### 2. Comprehensive ALU Coverage
- **Arithmetic Operations**: ADD, SUB, ADDU, SUBU
- **Logic Operations**: AND, OR, XOR
- **Shift Operations**: SLL, SRL, SRA, ROR
- **Comparison Operations**: LT, LTU, EQ, NE, GT, GE
- **Extensible for future operations**

### 3. Professional UVM Architecture
- **Modular Design**: Clean separation of concerns
- **Standard UVM Components**: Proper hierarchy and methodology
- **Configuration-Driven**: YAML-based test control
- **Parameterizable**: Easy customization for different scenarios

## Getting Started

### Prerequisites
- VCS simulator with UVM support
- Python 3.x for configuration parsing
- SystemVerilog-compatible simulator

### Quick Start
```bash
cd verification_new/scripts
./run_vcs.sh                    # Run default test
./run_vcs.sh alu_arith_test     # Run arithmetic test
```

### Configuration
Edit `config/alu_test_config.yaml` to customize:
- Number of instructions
- Operation types to enable/disable
- Coverage collection settings
- Debug and logging options

## Stage 1 Deliverables

✅ **UVM Test Classes**: Base test and derived tests for different operation types
✅ **UVM Environment**: Container for all verification components  
✅ **UVM Agent**: Handles ALU interface transactions
✅ **UVM Driver**: Drives operands and control signals to ALU
✅ **UVM Monitor**: Observes ALU inputs/outputs
✅ **Configuration System**: YAML-based test parameters and coverage control
✅ **Build Scripts**: VCS compilation and simulation with configuration integration

## Next Stages

**Stage 2**: Advanced stimulus generation with constrained randomization
**Stage 3**: Comprehensive coverage analysis and verification closure

---
*Built with professional UVM methodology for production-quality verification*