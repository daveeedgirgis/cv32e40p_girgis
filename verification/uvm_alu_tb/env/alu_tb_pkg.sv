// =============================================================================
// ALU Testbench UVM Package
//
// Contains all UVM classes and components for CV32E40P ALU verification
// =============================================================================

package alu_tb_pkg;

    // Import UVM library
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    // Import processor package for ALU opcodes and constants
    import cv32e40p_pkg::*;
    
    // UVM Configuration Classes
    `include "alu_tb_config.sv"
    
    // UVM Sequence Items
    `include "instruction_item.sv"
    `include "memory_item.sv"
    `include "alu_monitor_item.sv"
    
    // UVM Sequences
    `include "alu_instruction_sequence.sv"
    `include "basic_alu_sequence.sv"
    
    // UVM Drivers and Monitors
    `include "instruction_driver.sv"
    `include "memory_driver.sv"
    `include "alu_monitor.sv"
    `include "processor_monitor.sv"
    
    // UVM Agents
    `include "instruction_agent.sv"
    `include "memory_agent.sv"
    `include "alu_monitor_agent.sv"
    
    // UVM Scoreboard
    `include "alu_scoreboard.sv"
    
    // UVM Environment
    `include "alu_tb_env.sv"
    
    // UVM Tests
    `include "alu_base_test.sv"
    `include "alu_arithmetic_test.sv"
    `include "alu_logic_test.sv"
    `include "alu_shift_test.sv"
    `include "alu_comparison_test.sv"

endpackage : alu_tb_pkg