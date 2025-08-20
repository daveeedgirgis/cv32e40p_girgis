// =============================================================================
// ALU Arithmetic Test - Stage 1
//
// Focused arithmetic operations test - basic implementation for Stage 1
// =============================================================================

class alu_arith_test extends alu_base_test;
    
    `uvm_component_utils(alu_arith_test)
    
    // Constructor
    function new(string name = "alu_arith_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase - customize configuration for arithmetic focus
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Customize configuration for arithmetic operations
        cfg.enable_arithmetic = 1;
        cfg.enable_logic = 0;
        cfg.enable_shift = 0;
        cfg.enable_comparison = 0;
        cfg.arithmetic_weight = 100;
        cfg.num_instructions = 50;
        
        `uvm_info("ALU_ARITH_TEST", "Arithmetic test configured", UVM_LOW)
    endfunction
    
    // Run phase
    virtual task run_phase(uvm_phase phase);
        alu_arithmetic_sequence seq;
        
        phase.raise_objection(this);
        
        `uvm_info("ALU_ARITH_TEST", "Starting arithmetic test", UVM_LOW)
        
        // Create and run arithmetic sequence
        seq = alu_arithmetic_sequence::type_id::create("seq");
        seq.start(env.agent.sequencer);
        
        // Wait some time for monitor
        #1500ns;
        
        `uvm_info("ALU_ARITH_TEST", "Arithmetic test completed", UVM_LOW)
        
        phase.drop_objection(this);
    endtask

endclass : alu_arith_test