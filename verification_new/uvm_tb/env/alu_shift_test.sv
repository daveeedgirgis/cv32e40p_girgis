// =============================================================================
// ALU Shift Test - Stage 1
//
// Focused shift operations test - basic implementation for Stage 1
// =============================================================================

class alu_shift_test extends alu_base_test;
    
    `uvm_component_utils(alu_shift_test)
    
    // Constructor
    function new(string name = "alu_shift_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase - customize configuration for shift focus
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Customize configuration for shift operations
        cfg.enable_arithmetic = 0;
        cfg.enable_logic = 0;
        cfg.enable_shift = 1;
        cfg.enable_comparison = 0;
        cfg.shift_weight = 100;
        cfg.num_instructions = 25;
        
        `uvm_info("ALU_SHIFT_TEST", "Shift test configured", UVM_LOW)
    endfunction

endclass : alu_shift_test