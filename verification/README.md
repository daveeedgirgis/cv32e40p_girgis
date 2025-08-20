# CV32E40P ALU Verification Environment

## Overview

This directory contains a comprehensive UVM-based verification environment for the CV32E40P ALU (Arithmetic Logic Unit). The verification targets ALU operations within the CV32E40P RISC-V processor through processor-level testing with ALU-focused stimulus.

## Directory Structure

```
verification/
├── uvm_alu_tb/                 # UVM Testbench Directory
│   ├── interfaces/             # SystemVerilog Interfaces
│   │   ├── cv32e40p_if.sv     # Processor top-level interface
│   │   └── alu_monitor_if.sv   # ALU monitoring interface
│   ├── env/                    # UVM Environment Components
│   │   ├── alu_tb_pkg.sv      # Main UVM package
│   │   ├── alu_tb_config.sv   # Configuration class
│   │   ├── instruction_item.sv # Instruction sequence item
│   │   ├── memory_item.sv     # Memory transaction item
│   │   ├── alu_monitor_item.sv # ALU monitoring item
│   │   ├── instruction_driver.sv # Instruction memory driver
│   │   ├── memory_driver.sv   # Data memory driver
│   │   ├── alu_monitor.sv     # ALU operation monitor
│   │   └── [additional UVM components...]
│   ├── tests/                  # UVM Test Classes
│   ├── agents/                 # UVM Agent Components
│   ├── tb/                     # Top-level Testbench
│   └── config/                 # Configuration Files
│       └── alu_test_config.yaml # Main configuration file
├── scripts/                    # Build and Run Scripts
│   └── run_vcs.sh             # VCS compilation and simulation script
└── README.md                   # This documentation file
```

## Key Features

### 1. Processor-Level Testing
- Tests ALU through actual RISC-V instruction execution
- Uses standard processor interfaces (OBI memory interface)
- Generates real instruction sequences that exercise ALU operations

### 2. Comprehensive ALU Coverage
- **Arithmetic Operations**: ADD, SUB, ADDU, SUBU
- **Logic Operations**: AND, OR, XOR
- **Shift Operations**: SLL, SRL, SRA, ROR
- **Comparison Operations**: LT, LTU, EQ, NE, GT, GE
- **Support for Future Extensions**: Division, bit manipulation, PULP operations

### 3. Advanced UVM Architecture
- **Modular Design**: Separate agents for instruction memory, data memory, and ALU monitoring
- **Configurable Environment**: YAML-based configuration system
- **Intelligent Stimulus**: Mix of constrained random and directed test generation
- **Comprehensive Monitoring**: Detailed ALU operation tracking and verification

### 4. Professional Verification Features
- **Coverage Collection**: Functional and code coverage measurement
- **Scoreboard Checking**: Automatic result verification
- **Waveform Generation**: FSDB/VCD support for debugging
- **Flexible Configuration**: Easy test customization and parameter control

## Quick Start Guide

### Prerequisites
- Synopsys VCS simulator with UVM support
- Python 3.x for configuration parsing
- Access to CV32E40P RTL files

### Basic Usage

1. **Run Default Test**:
   ```bash
   cd verification/scripts
   ./run_vcs.sh
   ```

2. **Run Specific Test**:
   ```bash
   ./run_vcs.sh alu_arithmetic_test
   ```

3. **Run with Custom Configuration**:
   ```bash
   ./run_vcs.sh alu_stress_test ../uvm_alu_tb/config/alu_test_config.yaml
   ```

4. **Run with Debug Options**:
   ```bash
   ./run_vcs.sh alu_base_test config.yaml UVM_HIGH 42
   ```

### Available Tests

| Test Name | Description | Instructions | Focus Area |
|-----------|-------------|--------------|------------|
| `alu_base_test` | Basic mixed operations | 100 | General ALU functionality |
| `alu_arithmetic_test` | Arithmetic focus | 500 | ADD, SUB operations |
| `alu_logic_test` | Logic focus | 300 | AND, OR, XOR operations |
| `alu_shift_test` | Shift focus | 200 | SLL, SRL, SRA operations |
| `alu_comparison_test` | Comparison focus | 400 | LT, EQ, GT operations |
| `alu_stress_test` | High-volume testing | 10000 | Stress testing |
| `alu_corner_case_test` | Edge cases | 200 | Corner case coverage |

## Configuration System

The verification environment uses a YAML-based configuration system that allows fine-grained control over all aspects of testing.

### Key Configuration Categories

#### Test Control
```yaml
test_control:
  num_instructions: 1000          # Number of instructions to execute
  test_timeout_cycles: 50000      # Maximum simulation cycles
  random_seed: 1                  # Random seed for reproducibility
  verbosity: "UVM_MEDIUM"         # UVM verbosity level
```

#### ALU Operations
```yaml
alu_operations:
  enable_arithmetic: true         # Enable ADD, SUB, etc.
  enable_logic: true              # Enable AND, OR, XOR
  enable_shift: true              # Enable SLL, SRL, SRA
  enable_comparison: true         # Enable LT, EQ, GT
  enable_division: false          # Enable DIV, REM (slower)
```

#### Coverage Control
```yaml
coverage_config:
  enable_instruction_coverage: true    # Cover instruction types
  enable_operand_coverage: true        # Cover operand ranges
  functional_coverage_goal: 95         # Target coverage percentage
```

## UVM Architecture Details

### Interface Hierarchy
- **cv32e40p_if**: Top-level processor interface handling instruction/data memory
- **alu_monitor_if**: Specialized interface for monitoring internal ALU signals

### Component Architecture
- **instruction_driver**: Manages instruction memory and provides instructions to processor
- **memory_driver**: Handles data memory transactions (loads/stores)
- **alu_monitor**: Observes and verifies ALU operations within the processor
- **alu_scoreboard**: Compares actual vs. expected ALU results

### Sequence Item Types
- **instruction_item**: Represents RISC-V instructions targeting ALU operations
- **memory_item**: Represents memory transactions with timing and error modeling
- **alu_monitor_item**: Captures complete ALU operation details for verification

## Verification Methodology

### Stimulus Generation Strategy

#### 1. Constrained Random Testing
- **When Used**: For coverage-driven verification and stress testing
- **Benefits**: Discovers unexpected corner cases and achieves broad coverage
- **Implementation**: UVM sequences with intelligent constraints

#### 2. Directed Testing
- **When Used**: For specific corner cases and known critical scenarios
- **Benefits**: Ensures important edge cases are thoroughly tested
- **Implementation**: Hand-crafted instruction sequences

#### 3. Hybrid Approach
- **Mix Ratio**: 70% constrained random, 30% directed tests
- **Rationale**: Balances coverage breadth with targeted verification

### Coverage Strategy

#### Functional Coverage
- **Instruction Coverage**: All ALU instruction types executed
- **Operand Coverage**: Full range of operand values tested
- **Result Coverage**: All possible result ranges covered
- **Cross Coverage**: Combinations of operations and operand types

#### Code Coverage
- **Line Coverage**: Every line of ALU RTL executed
- **Branch Coverage**: All conditional branches tested
- **Toggle Coverage**: All signals exercised

### Verification Closure Criteria
- Functional coverage ≥ 95%
- Code coverage ≥ 90%
- All regression tests passing
- Zero open critical bugs

## Advanced Features

### 1. Waveform Generation
- Supports both VCD and FSDB formats
- Automatic waveform dumping for failed tests
- Configurable signal depth and sampling

### 2. Coverage Analysis
- Automatic coverage collection during simulation
- HTML coverage reports with drill-down capability
- Coverage hole analysis and recommendations

### 3. Regression Framework
- Automated test execution across multiple configurations
- Parallel test execution for faster results
- Automatic result comparison and regression detection

### 4. Debug Capabilities
- Comprehensive transaction logging
- ALU signal tracing
- Instruction execution trace
- UVM sequence debugging support

## File Organization

### Core UVM Files
- **alu_tb_pkg.sv**: Main package containing all UVM components
- **alu_tb_config.sv**: Centralized configuration management
- **instruction_item.sv**: RISC-V instruction representation
- **alu_monitor_item.sv**: ALU operation monitoring data

### Interface Files
- **cv32e40p_if.sv**: Processor-level interface (OBI, debug, interrupts)
- **alu_monitor_if.sv**: ALU-specific monitoring interface

### Driver Files
- **instruction_driver.sv**: Instruction memory management and response
- **memory_driver.sv**: Data memory transaction handling

### Monitor Files
- **alu_monitor.sv**: ALU operation monitoring and verification

## Integration with CV32E40P

### RTL Dependencies
The verification environment requires these CV32E40P RTL files:
- Core ALU components (cv32e40p_alu.sv, cv32e40p_alu_div.sv)
- Pipeline stages (cv32e40p_ex_stage.sv, cv32e40p_id_stage.sv)
- Top-level modules (cv32e40p_core.sv, cv32e40p_top.sv)
- Package definitions (cv32e40p_pkg.sv)

### Signal Monitoring
The verification environment monitors these key ALU signals:
- ALU inputs: operand_a_i, operand_b_i, operand_c_i, operator_i
- ALU outputs: result_o, comparison_result_o, ready_o
- Control signals: enable_i, vector_mode_i, bmask_*
- Pipeline signals: id_valid, ex_valid, ex_ready

## Build System

### VCS Integration
- Automated compilation with proper include paths
- UVM library integration
- Coverage database management
- Waveform dump configuration

### Script Features
- Intelligent error checking and reporting
- Configuration file parsing
- Automatic output organization
- Parallel build support

## Troubleshooting

### Common Issues

1. **Compilation Errors**
   - Check RTL file paths in configuration
   - Verify UVM installation and environment variables
   - Ensure proper include directories

2. **Simulation Failures**
   - Check test timeout settings
   - Verify instruction memory initialization
   - Review UVM sequence constraints

3. **Coverage Issues**
   - Adjust test instruction counts
   - Enable additional operation types
   - Review coverage exclusions

### Debug Techniques
- Enable higher UVM verbosity (UVM_HIGH, UVM_DEBUG)
- Generate waveforms for signal-level debugging
- Use transaction logging for sequence analysis
- Enable ALU signal logging for operation verification

## Future Enhancements

### Stage 2: Advanced Stimulus (Planned)
- Sophisticated instruction sequence generation
- Assembly code generation scripts
- Advanced constraint randomization
- Performance-oriented test scenarios

### Stage 3: Coverage Analysis (Planned)
- Advanced coverage metrics and analysis
- Coverage-driven test generation
- Automated coverage hole identification
- Regression analysis and trending

### Additional Features (Planned)
- Support for PULP custom instructions
- Floating-point operation verification
- Multi-core verification support
- Performance analysis capabilities

## Contact and Support

For questions about this verification environment:
- Review the configuration files for customization options
- Check the build scripts for compilation issues
- Examine the UVM components for architectural understanding
- Refer to CV32E40P documentation for RTL details

This verification environment provides a solid foundation for comprehensive ALU verification and can be extended for broader CV32E40P verification efforts.