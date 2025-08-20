// =============================================================================
// ALU Base Test
//
// Base UVM test class for ALU verification
// Provides common functionality for all ALU tests
// =============================================================================

class alu_base_test extends uvm_test;
    
    // UVM Factory registration
    `uvm_component_utils(alu_base_test)
    
    // Environment and configuration
    alu_tb_env env;
    alu_tb_config cfg;
    
    // Constructor
    function new(string name = "alu_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Create configuration object
        cfg = alu_tb_config::type_id::create("cfg");
        
        // Configure based on test parameters
        configure_test();
        
        // Set configuration in database
        uvm_config_db#(alu_tb_config)::set(this, "*", "cfg", cfg);
        
        // Create environment
        env = alu_tb_env::type_id::create("env", this);
        
        `uvm_info("TEST", "ALU base test built", UVM_MEDIUM)
    endfunction
    
    // Configure test-specific parameters
    virtual function void configure_test();
        // Basic test configuration
        cfg.num_instructions = 50;
        cfg.test_timeout_cycles = 5000;
        cfg.enable_scoreboard = 1;
        cfg.enable_coverage = 1;
        cfg.verbosity_level = UVM_MEDIUM;
        
        // Enable basic ALU operations
        cfg.enable_arithmetic_ops = 1;
        cfg.enable_logic_ops = 1;
        cfg.enable_shift_ops = 1;
        cfg.enable_comparison_ops = 1;
        
        `uvm_info("TEST", "Base test configuration applied", UVM_MEDIUM)
    endfunction
    
    // Run phase
    task run_phase(uvm_phase phase);
        basic_alu_sequence seq;
        
        phase.raise_objection(this);
        
        `uvm_info("TEST", "Starting ALU base test", UVM_LOW)
        
        // Create and run sequence
        seq = basic_alu_sequence::type_id::create("basic_seq");
        seq.start(env.instr_agent.sequencer);
        
        // Wait for completion
        #1000ns;
        
        `uvm_info("TEST", "ALU base test completed", UVM_LOW)
        
        phase.drop_objection(this);
    endtask
    
    // Final phase
    function void final_phase(uvm_phase phase);
        super.final_phase(phase);
        `uvm_info("TEST", "ALU base test finished", UVM_LOW)
    endfunction

endclass : alu_base_test