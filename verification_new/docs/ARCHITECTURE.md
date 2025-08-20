# CV32E40P ALU Verification Architecture

## 🏗️ UVM Architecture Overview

This document provides a detailed technical overview of the UVM-based verification architecture for the CV32E40P ALU verification environment.

---

## 📐 System Architecture

### High-Level Block Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        UVM Test Environment                      │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐                     │
│  │   alu_base_test │    │  alu_arith_test │  ... (other tests)  │
│  └─────────┬───────┘    └─────────┬───────┘                     │
│            │                      │                             │
│            └──────────┬───────────┘                             │
│                       │                                         │
│  ┌────────────────────▼────────────────────┐                    │
│  │              alu_env                    │                    │
│  │  ┌─────────────────┐  ┌───────────────┐ │                    │
│  │  │   alu_agent     │  │ alu_scoreboard│ │                    │
│  │  │ ┌─────────────┐ │  │               │ │                    │
│  │  │ │alu_driver   │ │  │               │ │                    │
│  │  │ └─────────────┘ │  │               │ │                    │
│  │  │ ┌─────────────┐ │  │               │ │                    │
│  │  │ │alu_monitor  │ │  │               │ │                    │
│  │  │ └─────────────┘ │  │               │ │                    │
│  │  │ ┌─────────────┐ │  │               │ │                    │
│  │  │ │uvm_sequencer│ │  │               │ │                    │
│  │  │ └─────────────┘ │  │               │ │                    │
│  │  └─────────────────┘  └───────────────┘ │                    │
│  └─────────────────────────────────────────┘                    │
└─────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                    SystemVerilog Interfaces                     │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐              ┌─────────────────┐           │
│  │  cv32e40p_if    │              │ alu_monitor_if  │           │
│  │  (OBI Protocol) │              │  (ALU Signals)  │           │
│  └─────────┬───────┘              └─────────┬───────┘           │
└────────────┼────────────────────────────────┼───────────────────┘
             │                                │
             ▼                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      CV32E40P RTL DUT                          │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                   cv32e40p_top                          │   │
│  │  ┌─────────────────────────────────────────────────┐    │   │
│  │  │                cv32e40p_core                    │    │   │
│  │  │  ┌─────────────────────────────────────────┐    │    │   │
│  │  │  │            cv32e40p_ex_stage            │    │    │   │
│  │  │  │  ┌─────────────────────────────────┐    │    │    │   │
│  │  │  │  │        cv32e40p_alu             │    │    │    │   │
│  │  │  │  │      (Target Under Test)        │    │    │    │   │
│  │  │  │  └─────────────────────────────────┘    │    │    │   │
│  │  │  └─────────────────────────────────────────┘    │    │   │
│  │  └─────────────────────────────────────────────────┘    │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🧩 Component Details

### 1. Test Layer

#### `alu_base_test`
**Purpose**: Base test class providing common functionality
**Key Features**:
- UVM test infrastructure setup
- Environment configuration
- Common test phases (build, run, cleanup)
- Default sequence execution

**Code Structure**:
```systemverilog
class alu_base_test extends uvm_test;
    alu_env env;
    alu_config cfg;
    
    virtual function void build_phase(uvm_phase phase);
        // Create and configure environment
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        // Execute test sequences
    endtask
endclass
```

#### Derived Test Classes
- **`alu_arith_test`**: Focuses on arithmetic operations (ADD, SUB)
- **`alu_logic_test`**: Focuses on logic operations (AND, OR, XOR)
- **`alu_shift_test`**: Focuses on shift operations (SLL, SRL, SRA)

### 2. Environment Layer

#### `alu_env`
**Purpose**: Top-level verification environment container
**Responsibilities**:
- Component instantiation and configuration
- Connection management between components
- Phase coordination
- Reporting and analysis

**Component Hierarchy**:
```systemverilog
class alu_env extends uvm_env;
    alu_agent       agent;
    alu_scoreboard  scoreboard;
    alu_config      cfg;
    
    virtual function void connect_phase(uvm_phase phase);
        agent.monitor.ap.connect(scoreboard.ap);
    endfunction
endclass
```

### 3. Agent Layer

#### `alu_agent`
**Purpose**: Encapsulates driver, monitor, and sequencer
**Configuration**:
- Active/Passive mode selection
- Interface assignment
- Component enable/disable

**Internal Structure**:
```systemverilog
class alu_agent extends uvm_agent;
    alu_driver      driver;
    alu_monitor     monitor;
    uvm_sequencer   sequencer;
    
    virtual function void connect_phase(uvm_phase phase);
        if (get_is_active() == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
    endfunction
endclass
```

### 4. Driver Layer

#### `alu_driver`
**Purpose**: Converts sequence items to pin-level stimulus
**Key Functions**:
- Sequence item consumption
- Interface signal driving
- Timing control
- Protocol compliance

**Drive Process**:
```systemverilog
virtual task run_phase(uvm_phase phase);
    forever begin
        seq_item_port.get_next_item(req);
        drive_item(req);
        seq_item_port.item_done();
    end
endtask

virtual task drive_item(alu_sequence_item item);
    // Convert sequence item to interface signals
    // Apply stimulus to DUT
    // Wait for response
endtask
```

### 5. Monitor Layer

#### `alu_monitor`
**Purpose**: Observes DUT behavior and creates transactions
**Key Functions**:
- Signal observation
- Transaction reconstruction
- Protocol checking
- Analysis port communication

**Monitor Process**:
```systemverilog
virtual task run_phase(uvm_phase phase);
    forever begin
        alu_transaction txn = alu_transaction::type_id::create("txn");
        collect_transaction(txn);
        ap.write(txn);
    end
endtask
```

### 6. Scoreboard Layer

#### `alu_scoreboard`
**Purpose**: Result verification and statistics collection
**Key Functions**:
- Expected result calculation
- Actual vs expected comparison
- Pass/fail statistics
- Error reporting

**Verification Process**:
```systemverilog
virtual function void write(alu_transaction txn);
    if (txn.check_results()) begin
        passed_count++;
        `uvm_info("SCOREBOARD", "Transaction PASSED", UVM_MEDIUM)
    end else begin
        failed_count++;
        `uvm_error("SCOREBOARD", $sformatf("Transaction FAILED: %s", 
                   txn.error_message))
    end
endfunction
```

---

## 🔄 Data Flow Architecture

### Transaction Flow

```
Sequence Generation → Driver Conversion → DUT Stimulus → Monitor Collection → Scoreboard Verification
```

#### 1. Sequence Generation
```systemverilog
// alu_sequence_lib.sv
class alu_base_sequence extends uvm_sequence #(alu_sequence_item);
    virtual task body();
        for (int i = 0; i < num_transactions; i++) begin
            alu_sequence_item item = alu_sequence_item::type_id::create("item");
            start_item(item);
            assert(item.randomize());
            finish_item(item);
        end
    endtask
endclass
```

#### 2. Driver Conversion
```systemverilog
// alu_driver.sv
virtual task drive_item(alu_sequence_item item);
    // Wait for appropriate time
    @(posedge vif.clk);
    
    // Apply stimulus (simplified - actual implementation drives processor)
    drive_instruction(item.operation, item.operand_a, item.operand_b);
    
    // Wait for completion
    wait_for_completion();
endtask
```

#### 3. Monitor Collection
```systemverilog
// alu_monitor.sv
virtual task collect_transaction(alu_transaction txn);
    // Wait for ALU activity
    wait(alu_active());
    
    // Capture inputs
    txn.operand_a = vif.operand_a;
    txn.operand_b = vif.operand_b;
    txn.operation = vif.operation;
    
    // Wait for result
    wait(result_ready());
    txn.result = vif.result;
    
    // Calculate expected result
    txn.calculate_expected_result();
endtask
```

#### 4. Scoreboard Verification
```systemverilog
// alu_scoreboard.sv
virtual function void write(alu_transaction txn);
    total_transactions++;
    
    if (txn.result == txn.expected_result) begin
        passed_transactions++;
        `uvm_info("SCOREBOARD", "PASS", UVM_MEDIUM)
    end else begin
        failed_transactions++;
        `uvm_error("SCOREBOARD", $sformatf(
            "FAIL: Expected 0x%08h, Got 0x%08h", 
            txn.expected_result, txn.result))
    end
endfunction
```

---

## 🔌 Interface Architecture

### SystemVerilog Interfaces

#### `cv32e40p_if`
**Purpose**: Processor-level interface following OBI protocol
**Key Signals**:
```systemverilog
interface cv32e40p_if(input logic clk_i, input logic rst_ni);
    // Clock and Reset
    logic clk, rst_n;
    
    // Instruction Memory Interface (OBI)
    logic        instr_req_o;
    logic        instr_gnt_i;
    logic        instr_rvalid_i;
    logic [31:0] instr_addr_o;
    logic [31:0] instr_rdata_i;
    
    // Data Memory Interface (OBI)
    logic        data_req_o;
    logic        data_gnt_i;
    logic        data_rvalid_i;
    logic [31:0] data_addr_o;
    logic        data_we_o;
    logic [3:0]  data_be_o;
    logic [31:0] data_wdata_o;
    logic [31:0] data_rdata_i;
    
    // Control Signals
    logic [31:0] boot_addr_i;
    logic        fetch_enable_i;
    
    // Modports for different components
    modport tb (/* testbench connections */);
    modport dut (/* DUT connections */);
    modport mem_driver (/* memory model connections */);
endinterface
```

#### `alu_monitor_if`
**Purpose**: Direct ALU signal monitoring
**Key Signals**:
```systemverilog
interface alu_monitor_if(input logic clk_i, input logic rst_ni);
    // ALU Input Signals
    logic [31:0] operand_a;
    logic [31:0] operand_b;
    logic [6:0]  operator;
    
    // ALU Output Signals
    logic [31:0] result;
    logic        comparison_result;
    logic        ready;
    
    // Control Signals
    logic        valid;
    logic        enable;
    
    modport monitor (
        input clk_i, rst_ni, operand_a, operand_b, operator,
              result, comparison_result, ready, valid, enable
    );
endinterface
```

---

## 📊 Configuration Architecture

### Configuration Class Hierarchy

```
alu_config (Base Configuration)
├── Test Control Parameters
├── ALU Operation Control
├── Stimulus Generation Control
├── Coverage Configuration
├── Debug and Logging Control
└── Performance Monitoring
```

#### Configuration Parameters

```systemverilog
class alu_config extends uvm_object;
    // Test Control
    int unsigned        num_instructions;
    int unsigned        test_timeout_cycles;
    uvm_verbosity       verbosity_level;
    
    // Operation Control
    bit                 enable_arithmetic;
    bit                 enable_logic;
    bit                 enable_shift;
    bit                 enable_comparison;
    
    // Stimulus Control
    bit                 enable_corner_cases;
    int                 operand_min_value;
    int                 operand_max_value;
    logic [31:0]        corner_case_values[];
    
    // Coverage Control
    bit                 enable_functional_coverage;
    bit                 enable_code_coverage;
    int unsigned        functional_coverage_goal;
    
    // Debug Control
    bit                 enable_waveform_dump;
    string              waveform_format;
    bit                 enable_transaction_logging;
    
    // Virtual Interface Handles
    virtual cv32e40p_if     processor_vif;
    virtual alu_monitor_if  alu_monitor_vif;
endclass
```

---

## 🎯 Sequence Architecture

### Sequence Class Hierarchy

```
uvm_sequence #(alu_sequence_item)
└── alu_base_sequence
    ├── alu_arithmetic_sequence
    ├── alu_logic_sequence
    ├── alu_shift_sequence
    └── alu_comparison_sequence
```

#### Sequence Item Structure

```systemverilog
class alu_sequence_item extends uvm_sequence_item;
    // Randomizable Fields
    rand alu_opcode_e   operation;
    rand logic [31:0]   operand_a;
    rand logic [31:0]   operand_b;
    
    // Calculated Fields
    logic [31:0]        expected_result;
    
    // Constraints
    constraint operation_constraint {
        operation inside {ALU_ADD, ALU_SUB, ALU_AND, ALU_OR, ALU_XOR, 
                         ALU_SLL, ALU_SRL, ALU_SRA};
    }
    
    constraint operand_constraint {
        operand_a inside {[0:1000], 32'h0, 32'hFFFFFFFF, 32'h7FFFFFFF, 32'h80000000};
        operand_b inside {[0:31], 32'h0, 32'hFFFFFFFF, 32'h7FFFFFFF, 32'h80000000};
    }
    
    // Post-randomize calculation
    function void post_randomize();
        calculate_expected_result();
    endfunction
endclass
```

---

## 🔍 Coverage Architecture

### Coverage Model

#### Functional Coverage Groups

```systemverilog
covergroup alu_operation_cg;
    operation_cp: coverpoint operation {
        bins arithmetic = {ALU_ADD, ALU_SUB, ALU_ADDU, ALU_SUBU};
        bins logic      = {ALU_AND, ALU_OR, ALU_XOR};
        bins shift      = {ALU_SLL, ALU_SRL, ALU_SRA};
        bins comparison = {ALU_LTS, ALU_LTU, ALU_EQ, ALU_NE};
    }
    
    operand_a_cp: coverpoint operand_a {
        bins zero     = {32'h00000000};
        bins max_pos  = {32'h7FFFFFFF};
        bins max_neg  = {32'h80000000};
        bins all_ones = {32'hFFFFFFFF};
        bins small    = {[1:100]};
        bins medium   = {[101:1000]};
        bins large    = {[1001:$]};
    }
    
    operand_b_cp: coverpoint operand_b {
        bins zero     = {32'h00000000};
        bins shift_range = {[0:31]};
        bins small    = {[1:100]};
        bins medium   = {[101:1000]};
        bins large    = {[1001:$]};
    }
    
    // Cross coverage
    operation_operand_cross: cross operation_cp, operand_a_cp, operand_b_cp;
endgroup
```

#### Code Coverage
- **Line Coverage**: Tracks executed lines in RTL
- **Branch Coverage**: Tracks taken/not-taken branches
- **Condition Coverage**: Tracks boolean expression evaluation
- **FSM Coverage**: Tracks state machine transitions

---

## 🚀 Performance Architecture

### Simulation Performance Optimizations

#### 1. Compilation Optimizations
```bash
# VCS Compilation Options
-O3                    # Highest optimization level
-full64               # 64-bit mode for large designs
+vcs+lic+wait         # License queuing
-timescale=1ns/1ps    # Appropriate time resolution
```

#### 2. Runtime Optimizations
```bash
# Runtime Options
+ntb_random_seed_automatic  # Faster randomization
-cm_hier                    # Hierarchical coverage
+UVM_NO_RELNOTES           # Suppress UVM notes
```

#### 3. Memory Management
```systemverilog
// Efficient transaction handling
class alu_scoreboard extends uvm_scoreboard;
    // Limit transaction history
    parameter MAX_HISTORY = 1000;
    alu_transaction history[$];
    
    virtual function void write(alu_transaction txn);
        // Process transaction
        if (history.size() >= MAX_HISTORY) begin
            history.pop_front();
        end
        history.push_back(txn);
    endfunction
endclass
```

---

## 🔧 Build Architecture

### Compilation Flow

```
RTL Package Files → RTL Module Files → Interface Files → UVM Package → Testbench Top
```

#### File Compilation Order
1. **Package Files**: `cv32e40p_pkg.sv`, `cv32e40p_apu_core_pkg.sv`, `cv32e40p_fpu_pkg.sv`
2. **Simulation Models**: `cv32e40p_clock_gate.sv`
3. **RTL Modules**: Core CV32E40P files
4. **Interfaces**: `cv32e40p_if.sv`, `alu_monitor_if.sv`
5. **UVM Package**: `alu_pkg.sv` (includes all UVM components)
6. **Testbench Top**: `alu_tb_top.sv`

#### Build Script Architecture
```bash
# run_vcs.sh structure
validate_environment()     # Check VCS, UVM availability
validate_rtl_files()      # Verify RTL file presence
create_file_list()        # Generate compilation file list
compile_design()          # VCS compilation
run_simulation()          # Execute test
post_process_results()    # Generate reports
```

---

## 📈 Scalability Architecture

### Extension Points

#### 1. Adding New Operations
```systemverilog
// Extend enumeration in cv32e40p_pkg.sv
typedef enum logic [ALU_OP_WIDTH-1:0] {
    // Existing operations...
    ALU_NEW_OP = 7'b1111111
} alu_opcode_e;

// Update sequence item constraints
constraint operation_constraint {
    operation inside {ALU_ADD, ALU_SUB, ..., ALU_NEW_OP};
}

// Update expected result calculation
function void calculate_expected_result();
    case (operation)
        ALU_NEW_OP: expected_result = new_operation_calc(operand_a, operand_b);
        // ... existing cases
    endcase
endfunction
```

#### 2. Adding New Test Types
```systemverilog
// Create new test class
class alu_corner_case_test extends alu_base_test;
    virtual task run_phase(uvm_phase phase);
        alu_corner_case_sequence seq = alu_corner_case_sequence::type_id::create("seq");
        seq.start(env.agent.sequencer);
    endtask
endclass

// Register with factory
`uvm_component_utils(alu_corner_case_test)
```

#### 3. Adding New Coverage
```systemverilog
// Extend coverage model
covergroup alu_corner_case_cg;
    overflow_cp: coverpoint {operand_a, operand_b, operation} {
        bins add_overflow = {[32'h7FFFFFFF, 32'h7FFFFFFF, ALU_ADD]};
        bins sub_underflow = {[32'h80000000, 32'h7FFFFFFF, ALU_SUB]};
    }
endgroup
```

---

## 🎯 Summary

This architecture provides:

- **Modularity**: Clean separation of concerns
- **Scalability**: Easy extension for new operations and tests
- **Reusability**: Components can be reused in other verification environments
- **Maintainability**: Clear interfaces and well-documented code
- **Performance**: Optimized for simulation speed and memory usage
- **Compliance**: Follows UVM best practices and industry standards

The architecture supports both current verification needs and future enhancements, making it suitable for production-level verification of the CV32E40P ALU and extensible to full processor verification.