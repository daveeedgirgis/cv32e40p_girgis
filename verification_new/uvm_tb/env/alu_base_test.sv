// =============================================================================
// ALU Base Test - Stage 1
//
// Base UVM test class for ALU testing - basic implementation for Stage 1
// =============================================================================

class alu_base_test extends uvm_test;
    
    `uvm_component_utils(alu_base_test)
    
    // Test components
    alu_env         env;
    alu_config      cfg;
    
    // Constructor
    function new(string name = "alu_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Create and configure the configuration object
        cfg = alu_config::type_id::create("cfg");
        
        // Validate configuration
        if (!cfg.validate_config()) begin
            `uvm_fatal("ALU_BASE_TEST", "Configuration validation failed")
        end
        
        // Set configuration in database
        uvm_config_db#(alu_config)::set(this, "*", "cfg", cfg);
        
        // Create environment
        env = alu_env::type_id::create("env", this);
        
        `uvm_info("ALU_BASE_TEST", "Base test built successfully", UVM_LOW)
    endfunction
    
    // Run phase
    virtual task run_phase(uvm_phase phase);
        alu_base_sequence seq;
        
        phase.raise_objection(this);
        
        `uvm_info("ALU_BASE_TEST", "Starting base test", UVM_LOW)
        
        // Create and run sequence
        seq = alu_base_sequence::type_id::create("seq");
        seq.num_transactions = 20; // Run 20 transactions for Stage 1
        
        seq.start(env.agent.sequencer);
        
        // Wait some time for monitor to generate transactions
        #1000ns;
        
        `uvm_info("ALU_BASE_TEST", "Base test completed", UVM_LOW)
        
        phase.drop_objection(this);
    endtask
    
    // Final phase
    function void final_phase(uvm_phase phase);
        super.final_phase(phase);
        `uvm_info("ALU_BASE_TEST", "=== TEST COMPLETED ===", UVM_LOW)
    endfunction

endclass : alu_base_test