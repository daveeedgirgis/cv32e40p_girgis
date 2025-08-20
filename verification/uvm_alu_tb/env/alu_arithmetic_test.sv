// =============================================================================
// ALU Arithmetic Test
//
// Focused test for arithmetic ALU operations (ADD, SUB, etc.)
// =============================================================================

class alu_arithmetic_test extends alu_base_test;
    
    // UVM Factory registration
    `uvm_component_utils(alu_arithmetic_test)
    
    // Constructor
    function new(string name = "alu_arithmetic_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Configure test-specific parameters
    virtual function void configure_test();
        super.configure_test();
        
        // Focus on arithmetic operations
        cfg.num_instructions = 100;
        cfg.enable_arithmetic_ops = 1;
        cfg.enable_logic_ops = 0;
        cfg.enable_shift_ops = 0;
        cfg.enable_comparison_ops = 0;
        
        // Increase arithmetic weight
        cfg.arithmetic_weight = 90;
        cfg.logic_weight = 5;
        cfg.shift_weight = 5;
        
        `uvm_info("TEST", "Arithmetic test configuration applied", UVM_MEDIUM)
    endfunction

endclass : alu_arithmetic_test