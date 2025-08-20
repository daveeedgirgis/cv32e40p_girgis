// =============================================================================
// ALU Logic Test - Stage 1
//
// Focused logic operations test - basic implementation for Stage 1
// =============================================================================

class alu_logic_test extends alu_base_test;
    
    `uvm_component_utils(alu_logic_test)
    
    // Constructor
    function new(string name = "alu_logic_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase - customize configuration for logic focus
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Customize configuration for logic operations
        cfg.enable_arithmetic = 0;
        cfg.enable_logic = 1;
        cfg.enable_shift = 0;
        cfg.enable_comparison = 0;
        cfg.logic_weight = 100;
        cfg.num_instructions = 30;
        
        `uvm_info("ALU_LOGIC_TEST", "Logic test configured", UVM_LOW)
    endfunction

endclass : alu_logic_test