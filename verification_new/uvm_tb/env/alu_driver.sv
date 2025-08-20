// =============================================================================
// ALU Driver - Stage 1
//
// Simple UVM driver for ALU testing - basic implementation for Stage 1
// =============================================================================

class alu_driver extends uvm_driver #(alu_sequence_item);
    
    `uvm_component_utils(alu_driver)
    
    // Virtual interface handle
    virtual cv32e40p_if.mem_driver vif;
    
    // Configuration handle
    alu_config cfg;
    
    // Constructor
    function new(string name = "alu_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Get configuration
        if (!uvm_config_db#(alu_config)::get(this, "", "cfg", cfg)) begin
            `uvm_fatal("ALU_DRIVER", "Configuration object not found")
        end
        
        // Get virtual interface
        if (!uvm_config_db#(virtual cv32e40p_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("ALU_DRIVER", "Virtual interface not found")
        end
    endfunction
    
    // Run phase - simplified for Stage 1
    virtual task run_phase(uvm_phase phase);
        `uvm_info("ALU_DRIVER", "Driver started", UVM_LOW)
        
        forever begin
            alu_sequence_item item;
            
            // Get next item from sequencer
            seq_item_port.get_next_item(item);
            
            // Drive the item (simplified - just log for Stage 1)
            drive_item(item);
            
            // Signal completion
            seq_item_port.item_done();
        end
    endtask
    
    // Drive item task - simplified for Stage 1
    virtual task drive_item(alu_sequence_item item);
        `uvm_info("ALU_DRIVER", $sformatf("Driving: %s", item.convert2string()), UVM_MEDIUM)
        
        // For Stage 1, we'll just simulate driving by waiting some cycles
        // In Stage 2, this will actually drive instructions to the processor
        repeat(5) @(posedge vif.clk);
        
        `uvm_info("ALU_DRIVER", "Item driven", UVM_HIGH)
    endtask

endclass : alu_driver