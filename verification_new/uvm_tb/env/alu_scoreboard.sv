// =============================================================================
// ALU Scoreboard - Stage 1
//
// Simple UVM scoreboard for ALU testing - basic implementation for Stage 1
// =============================================================================

class alu_scoreboard extends uvm_scoreboard;
    
    `uvm_component_utils(alu_scoreboard)
    
    // Analysis import for receiving transactions
    uvm_analysis_imp #(alu_transaction, alu_scoreboard) ap;
    
    // Configuration handle
    alu_config cfg;
    
    // Statistics
    int transaction_count;
    int pass_count;
    int fail_count;
    
    // Constructor
    function new(string name = "alu_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        transaction_count = 0;
        pass_count = 0;
        fail_count = 0;
    endfunction
    
    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Create analysis import
        ap = new("ap", this);
        
        // Get configuration
        if (!uvm_config_db#(alu_config)::get(this, "", "cfg", cfg)) begin
            `uvm_fatal("ALU_SCOREBOARD", "Configuration object not found")
        end
    endfunction
    
    // Write function - called when transaction is received
    virtual function void write(alu_transaction txn);
        transaction_count++;
        
        `uvm_info("ALU_SCOREBOARD", $sformatf("Received transaction #%0d: %s", 
                 transaction_count, txn.convert2string()), UVM_HIGH)
        
        // Check transaction (simplified for Stage 1)
        if (check_transaction(txn)) begin
            pass_count++;
            `uvm_info("ALU_SCOREBOARD", "Transaction PASSED", UVM_MEDIUM)
        end else begin
            fail_count++;
            `uvm_error("ALU_SCOREBOARD", "Transaction FAILED")
        end
        
        // Report progress periodically
        if (transaction_count % 10 == 0) begin
            report_status();
        end
    endfunction
    
    // Check transaction - simplified for Stage 1
    virtual function bit check_transaction(alu_transaction txn);
        // For Stage 1, just check if transaction is valid
        if (!txn.valid || !txn.completed) begin
            `uvm_error("ALU_SCOREBOARD", "Invalid or incomplete transaction")
            return 0;
        end
        
        // Basic sanity checks
        if (txn.has_error) begin
            `uvm_error("ALU_SCOREBOARD", $sformatf("Transaction has error: %s", txn.error_message))
            return 0;
        end
        
        return 1; // Pass for Stage 1
    endfunction
    
    // Report status
    virtual function void report_status();
        `uvm_info("ALU_SCOREBOARD", "=== Scoreboard Status ===", UVM_LOW)
        `uvm_info("ALU_SCOREBOARD", $sformatf("Total transactions: %0d", transaction_count), UVM_LOW)
        `uvm_info("ALU_SCOREBOARD", $sformatf("Passed: %0d", pass_count), UVM_LOW)
        `uvm_info("ALU_SCOREBOARD", $sformatf("Failed: %0d", fail_count), UVM_LOW)
        if (transaction_count > 0) begin
            `uvm_info("ALU_SCOREBOARD", $sformatf("Pass rate: %0.1f%%", 
                     (pass_count * 100.0) / transaction_count), UVM_LOW)
        end
        `uvm_info("ALU_SCOREBOARD", "========================", UVM_LOW)
    endfunction
    
    // Final phase - report final results
    virtual function void final_phase(uvm_phase phase);
        super.final_phase(phase);
        
        `uvm_info("ALU_SCOREBOARD", "=== FINAL RESULTS ===", UVM_LOW)
        report_status();
        
        if (fail_count == 0 && transaction_count > 0) begin
            `uvm_info("ALU_SCOREBOARD", "*** TEST PASSED ***", UVM_LOW)
        end else begin
            `uvm_error("ALU_SCOREBOARD", "*** TEST FAILED ***")
        end
    endfunction

endclass : alu_scoreboard