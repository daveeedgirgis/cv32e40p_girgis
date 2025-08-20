// =============================================================================
// ALU Testbench Environment
//
// Main UVM environment that instantiates and connects all verification components
// =============================================================================

class alu_tb_env extends uvm_env;
    
    // UVM Factory registration
    `uvm_component_utils(alu_tb_env)
    
    // Configuration object
    alu_tb_config cfg;
    
    // Agents
    instruction_agent instr_agent;
    memory_agent mem_agent;
    alu_monitor_agent alu_mon_agent;
    
    // Verification components
    alu_scoreboard scoreboard;
    
    // Constructor
    function new(string name = "alu_tb_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Get configuration object
        if (!uvm_config_db#(alu_tb_config)::get(this, "", "cfg", cfg)) begin
            `uvm_fatal("NOCFG", "Configuration object not found")
        end
        
        // Validate configuration
        if (!cfg.validate_config()) begin
            `uvm_fatal("BADCFG", "Invalid configuration")
        end
        
        // Print configuration
        cfg.print_config();
        
        // Set configuration for all child components
        uvm_config_db#(alu_tb_config)::set(this, "*", "cfg", cfg);
        
        // Create agents
        instr_agent = instruction_agent::type_id::create("instr_agent", this);
        mem_agent = memory_agent::type_id::create("mem_agent", this);
        alu_mon_agent = alu_monitor_agent::type_id::create("alu_mon_agent", this);
        
        // Create verification components
        if (cfg.enable_scoreboard) begin
            scoreboard = alu_scoreboard::type_id::create("scoreboard", this);
        end
        
        `uvm_info("ENV", "ALU testbench environment built", UVM_MEDIUM)
    endfunction
    
    // Connect phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Connect ALU monitor to scoreboard
        if (cfg.enable_scoreboard && scoreboard != null) begin
            alu_mon_agent.ap.connect(scoreboard.alu_fifo.analysis_export);
        end
        
        `uvm_info("ENV", "ALU testbench environment connected", UVM_MEDIUM)
    endfunction
    
    // End of elaboration phase
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        
        // Print topology
        `uvm_info("ENV", "=== Environment Topology ===", UVM_LOW)
        this.print();
        `uvm_info("ENV", "===========================", UVM_LOW)
    endfunction

endclass : alu_tb_env