// =============================================================================
// ALU Monitor Agent
//
// UVM agent for monitoring ALU operations within the processor
// Contains only monitor (passive agent) for observing ALU behavior
// =============================================================================

class alu_monitor_agent extends uvm_agent;
    
    // UVM Factory registration
    `uvm_component_utils(alu_monitor_agent)
    
    // Agent components
    alu_monitor monitor;
    
    // Configuration
    alu_tb_config cfg;
    
    // Analysis port
    uvm_analysis_port #(alu_monitor_item) ap;
    
    // Constructor
    function new(string name = "alu_monitor_agent", uvm_component parent = null);
        super.new(name, parent);
        // ALU monitor is always passive (only observes)
        set_is_active(UVM_PASSIVE);
    endfunction
    
    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Get configuration
        if (!uvm_config_db#(alu_tb_config)::get(this, "", "cfg", cfg)) begin
            `uvm_fatal("NOCFG", "Configuration object not found")
        end
        
        // Create analysis port
        ap = new("ap", this);
        
        // Create monitor
        monitor = alu_monitor::type_id::create("monitor", this);
    endfunction
    
    // Connect phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Connect monitor analysis port to agent analysis port
        monitor.ap.connect(ap);
    endfunction

endclass : alu_monitor_agent