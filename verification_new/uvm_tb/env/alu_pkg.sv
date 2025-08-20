// =============================================================================
// ALU Testbench UVM Package - Stage 1
//
// Main UVM package containing all verification components for CV32E40P ALU
// Built from scratch with proper UVM methodology and correct RTL connections
// =============================================================================

package alu_pkg;

    // Import UVM library and macros
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    // Import processor package for ALU opcodes and constants
    import cv32e40p_pkg::*;
    
    // Include all UVM components in proper dependency order
    
    // 1. Configuration and data structures
    `include "alu_config.sv"
    `include "alu_transaction.sv"
    
    // 2. Sequence items and sequences
    `include "alu_sequence_item.sv"
    `include "alu_sequence_lib.sv"
    
    // 3. Driver and monitor components
    `include "alu_driver.sv"
    `include "alu_monitor.sv"
    `include "alu_scoreboard.sv"
    
    // 4. Agent and environment
    `include "alu_agent.sv"
    `include "alu_env.sv"
    
    // 5. Test classes
    `include "alu_base_test.sv"
    `include "alu_arith_test.sv"
    `include "alu_logic_test.sv"
    `include "alu_shift_test.sv"
    
    // 6. Stage 2 Advanced Test Classes
    `include "alu_stage2_tests.sv"

endpackage : alu_pkg