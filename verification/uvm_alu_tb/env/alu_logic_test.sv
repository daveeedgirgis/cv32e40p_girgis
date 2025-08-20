// =============================================================================
// ALU Logic Test
//
// Focused test for logic ALU operations (AND, OR, XOR)
// =============================================================================

class alu_logic_test extends alu_base_test;
    
    // UVM Factory registration
    `uvm_component_utils(alu_logic_test)
    
    // Constructor
    function new(string name = "alu_logic_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Configure test-specific parameters
    virtual function void configure_test();
        super.configure_test();
        
        // Focus on logic operations
        cfg.num_instructions = 80;
        cfg.enable_arithmetic_ops = 0;
        cfg.enable_logic_ops = 1;
        cfg.enable_shift_ops = 0;
        cfg.enable_comparison_ops = 0;
        
        // Increase logic weight
        cfg.arithmetic_weight = 5;
        cfg.logic_weight = 90;
        cfg.shift_weight = 5;
        
        `uvm_info("TEST", "Logic test configuration applied", UVM_MEDIUM)
    endfunction

endclass : alu_logic_test