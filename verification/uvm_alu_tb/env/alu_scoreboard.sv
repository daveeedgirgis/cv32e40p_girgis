// =============================================================================
// ALU Scoreboard
//
// UVM scoreboard for checking ALU operation results
// Compares actual ALU behavior against expected results
// =============================================================================

class alu_scoreboard extends uvm_scoreboard;
    
    // UVM Factory registration
    `uvm_component_utils(alu_scoreboard)
    
    // Analysis FIFOs for receiving transactions
    uvm_tlm_analysis_fifo #(alu_monitor_item) alu_fifo;
    uvm_tlm_analysis_fifo #(instruction_item) instr_fifo;
    
    // Configuration
    alu_tb_config cfg;
    
    // Statistics
    int total_operations;
    int passed_operations;
    int failed_operations;
    
    // Constructor
    function new(string name = "alu_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        total_operations = 0;
        passed_operations = 0;
        failed_operations = 0;
    endfunction
    
    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Create analysis FIFOs
        alu_fifo = new("alu_fifo", this);
        instr_fifo = new("instr_fifo", this);
        
        // Get configuration
        if (!uvm_config_db#(alu_tb_config)::get(this, "", "cfg", cfg)) begin
            `uvm_fatal("NOCFG", "Configuration object not found")
        end
    endfunction
    
    // Run phase
    task run_phase(uvm_phase phase);
        fork
            process_alu_operations();
        join
    endtask
    
    // Process ALU operations from monitor
    task process_alu_operations();
        alu_monitor_item alu_item;
        
        forever begin
            alu_fifo.get(alu_item);
            check_alu_operation(alu_item);
        end
    endtask
    
    // Check individual ALU operation
    function void check_alu_operation(alu_monitor_item item);
        total_operations++;
        
        if (!cfg.enable_scoreboard) begin
            return; // Scoreboard checking disabled
        end
        
        `uvm_info("SCB", $sformatf("Checking ALU operation: %s", item.get_operation_name()), UVM_HIGH)
        
        // The item already has result checking built-in
        if (item.result_matches) begin
            passed_operations++;
            `uvm_info("SCB", $sformatf("PASS: %s operation", item.get_operation_name()), UVM_HIGH)
        end else begin
            failed_operations++;
            `uvm_error("SCB", $sformatf("FAIL: %s operation - %s", 
                      item.get_operation_name(), item.error_message))
        end
    endfunction
    
    // Report phase
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        
        `uvm_info("SCB", "=== ALU Scoreboard Results ===", UVM_LOW)
        `uvm_info("SCB", $sformatf("Total operations: %0d", total_operations), UVM_LOW)
        `uvm_info("SCB", $sformatf("Passed operations: %0d", passed_operations), UVM_LOW)
        `uvm_info("SCB", $sformatf("Failed operations: %0d", failed_operations), UVM_LOW)
        
        if (total_operations > 0) begin
            real pass_rate = real'(passed_operations) / real'(total_operations) * 100.0;
            `uvm_info("SCB", $sformatf("Pass rate: %.1f%%", pass_rate), UVM_LOW)
        end
        
        `uvm_info("SCB", "=============================", UVM_LOW)
        
        if (failed_operations > 0) begin
            `uvm_error("SCB", $sformatf("Scoreboard detected %0d failed operations", failed_operations))
        end
    endfunction

endclass : alu_scoreboard