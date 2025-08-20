// =============================================================================
// ALU Environment - Stage 1
//
// UVM environment for ALU testing - basic implementation for Stage 1
// =============================================================================

class alu_env extends uvm_env;
    
    `uvm_component_utils(alu_env)
    
    // Environment components
    alu_agent       agent;
    alu_scoreboard  scoreboard;
    
    // Configuration handle
    alu_config cfg;
    
    // Constructor
    function new(string name = "alu_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Get configuration
        if (!uvm_config_db#(alu_config)::get(this, "", "cfg", cfg)) begin
            `uvm_fatal("ALU_ENV", "Configuration object not found")
        end
        
        // Create components
        agent = alu_agent::type_id::create("agent", this);
        
        if (cfg.enable_scoreboard) begin
            scoreboard = alu_scoreboard::type_id::create("scoreboard", this);
        end
        
        `uvm_info("ALU_ENV", "Environment built successfully", UVM_LOW)
    endfunction
    
    // Connect phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Connect monitor to scoreboard if enabled
        if (cfg.enable_scoreboard && scoreboard != null) begin
            agent.monitor.ap.connect(scoreboard.ap);
            `uvm_info("ALU_ENV", "Monitor connected to scoreboard", UVM_LOW)
        end
    endfunction
    
    // End of elaboration phase
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        
        // Print configuration
        cfg.print_config();
        
        // Print topology
        `uvm_info("ALU_ENV", "=== Environment Topology ===", UVM_LOW)
        this.print();
    endfunction

endclass : alu_env