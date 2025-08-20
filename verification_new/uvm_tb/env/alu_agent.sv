// =============================================================================
// ALU Agent - Stage 1
//
// Simple UVM agent for ALU testing - basic implementation for Stage 1
// =============================================================================

class alu_agent extends uvm_agent;
    
    `uvm_component_utils(alu_agent)
    
    // Agent components
    alu_driver      driver;
    alu_monitor     monitor;
    uvm_sequencer #(alu_sequence_item) sequencer;
    
    // Configuration handle
    alu_config cfg;
    
    // Constructor
    function new(string name = "alu_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Get configuration
        if (!uvm_config_db#(alu_config)::get(this, "", "cfg", cfg)) begin
            `uvm_fatal("ALU_AGENT", "Configuration object not found")
        end
        
        // Create monitor (always present)
        monitor = alu_monitor::type_id::create("monitor", this);
        
        // Create driver and sequencer if agent is active
        if (get_is_active() == UVM_ACTIVE) begin
            driver = alu_driver::type_id::create("driver", this);
            sequencer = uvm_sequencer#(alu_sequence_item)::type_id::create("sequencer", this);
        end
    endfunction
    
    // Connect phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Connect driver to sequencer if active
        if (get_is_active() == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
    endfunction

endclass : alu_agent