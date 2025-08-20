// =============================================================================
// ALU Comparison Test
//
// Focused test for comparison ALU operations (LT, EQ, GT, etc.)
// =============================================================================

class alu_comparison_test extends alu_base_test;
    
    // UVM Factory registration
    `uvm_component_utils(alu_comparison_test)
    
    // Constructor
    function new(string name = "alu_comparison_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Configure test-specific parameters
    virtual function void configure_test();
        super.configure_test();
        
        // Focus on comparison operations
        cfg.num_instructions = 70;
        cfg.enable_arithmetic_ops = 0;
        cfg.enable_logic_ops = 0;
        cfg.enable_shift_ops = 0;
        cfg.enable_comparison_ops = 1;
        
        // Increase comparison weight
        cfg.arithmetic_weight = 5;
        cfg.logic_weight = 5;
        cfg.comparison_weight = 90;
        
        `uvm_info("TEST", "Comparison test configuration applied", UVM_MEDIUM)
    endfunction

endclass : alu_comparison_test