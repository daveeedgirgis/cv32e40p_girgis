// =============================================================================
// Processor Monitor
//
// UVM monitor for observing processor-level activities
// Placeholder implementation for basic functionality
// =============================================================================

class processor_monitor extends uvm_monitor;
    
    // UVM Factory registration
    `uvm_component_utils(processor_monitor)
    
    // Virtual interface handle
    virtual cv32e40p_if.monitor vif;
    
    // Analysis port
    uvm_analysis_port #(instruction_item) ap;
    
    // Configuration
    alu_tb_config cfg;
    
    // Constructor
    function new(string name = "processor_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Create analysis port
        ap = new("ap", this);
        
        // Get configuration
        if (!uvm_config_db#(alu_tb_config)::get(this, "", "cfg", cfg)) begin
            `uvm_fatal("NOCFG", "Configuration object not found")
        end
        
        // Get virtual interface
        if (!uvm_config_db#(virtual cv32e40p_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", "Virtual interface not found")
        end
    endfunction
    
    // Run phase - basic monitoring
    task run_phase(uvm_phase phase);
        `uvm_info("PMON", "Processor monitor started", UVM_MEDIUM)
        
        forever begin
            @(posedge vif.clk);
            // Basic monitoring - can be expanded later
        end
    endtask

endclass : processor_monitor