// =============================================================================
// Memory Agent
//
// UVM agent for handling data memory interface
// Contains driver, monitor, and sequencer for memory transactions
// =============================================================================

class memory_agent extends uvm_agent;
    
    // UVM Factory registration
    `uvm_component_utils(memory_agent)
    
    // Agent components
    uvm_sequencer #(memory_item) sequencer;
    memory_driver driver;
    uvm_monitor monitor;  // Placeholder for memory monitor
    
    // Configuration
    alu_tb_config cfg;
    
    // Analysis port
    uvm_analysis_port #(memory_item) ap;
    
    // Constructor
    function new(string name = "memory_agent", uvm_component parent = null);
        super.new(name, parent);
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
        
        // Create sequencer and driver for active agent
        if (get_is_active() == UVM_ACTIVE) begin
            sequencer = uvm_sequencer#(memory_item)::type_id::create("sequencer", this);
            driver = memory_driver::type_id::create("driver", this);
        end
        
        // Note: Monitor creation would go here when implemented
    endfunction
    
    // Connect phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Connect driver to sequencer
        if (get_is_active() == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
        
        // Monitor connections would go here when implemented
    endfunction

endclass : memory_agent