// =============================================================================
// ALU Shift Test
//
// Focused test for shift ALU operations (SLL, SRL, SRA)
// =============================================================================

class alu_shift_test extends alu_base_test;
    
    // UVM Factory registration
    `uvm_component_utils(alu_shift_test)
    
    // Constructor
    function new(string name = "alu_shift_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Configure test-specific parameters
    virtual function void configure_test();
        super.configure_test();
        
        // Focus on shift operations
        cfg.num_instructions = 60;
        cfg.enable_arithmetic_ops = 0;
        cfg.enable_logic_ops = 0;
        cfg.enable_shift_ops = 1;
        cfg.enable_comparison_ops = 0;
        
        // Increase shift weight
        cfg.arithmetic_weight = 5;
        cfg.logic_weight = 5;
        cfg.shift_weight = 90;
        
        `uvm_info("TEST", "Shift test configuration applied", UVM_MEDIUM)
    endfunction

endclass : alu_shift_test