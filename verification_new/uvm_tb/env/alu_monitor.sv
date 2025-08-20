// =============================================================================
// ALU Monitor - Stage 1
//
// Simple UVM monitor for ALU testing - basic implementation for Stage 1
// =============================================================================

class alu_monitor extends uvm_monitor;
    
    `uvm_component_utils(alu_monitor)
    
    // Virtual interface handle
    virtual alu_monitor_if vif;
    
    // Analysis port for sending transactions
    uvm_analysis_port #(alu_transaction) ap;
    
    // Configuration handle
    alu_config cfg;
    
    // Constructor
    function new(string name = "alu_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Create analysis port
        ap = new("ap", this);
        
        // Get configuration
        if (!uvm_config_db#(alu_config)::get(this, "", "cfg", cfg)) begin
            `uvm_fatal("ALU_MONITOR", "Configuration object not found")
        end
        
        // Get virtual interface
        if (!uvm_config_db#(virtual alu_monitor_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("ALU_MONITOR", "Virtual interface not found")
        end
    endfunction
    
    // Run phase - simplified for Stage 1
    virtual task run_phase(uvm_phase phase);
        `uvm_info("ALU_MONITOR", "Monitor started", UVM_LOW)
        
        forever begin
            alu_transaction txn;
            
            // Wait for ALU activity (simplified for Stage 1)
            @(posedge vif.clk);
            
            // Create and populate transaction (simplified)
            txn = alu_transaction::type_id::create("alu_txn");
            txn.start_time = $time;
            
            // For Stage 1, just create dummy transactions periodically
            if ($urandom_range(100) < 10) begin // 10% chance each cycle
                populate_transaction(txn);
                ap.write(txn);
                `uvm_info("ALU_MONITOR", $sformatf("Monitored: %s", txn.convert2string()), UVM_HIGH)
            end
        end
    endtask
    
    // Populate transaction with dummy data for Stage 1
    virtual function void populate_transaction(alu_transaction txn);
        txn.alu_operation = alu_opcode_e'($urandom_range(7)); // Random basic operation
        txn.operand_a = $urandom();
        txn.operand_b = $urandom();
        txn.alu_result = txn.operand_a + txn.operand_b; // Dummy result
        txn.valid = 1'b1;
        txn.completed = 1'b1;
        txn.end_time = $time;
    endfunction

endclass : alu_monitor