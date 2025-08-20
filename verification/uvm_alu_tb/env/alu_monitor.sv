// =============================================================================
// ALU Monitor
//
// UVM monitor that observes ALU operations within the CV32E40P processor
// Captures ALU inputs, outputs, and timing for verification
// =============================================================================

class alu_monitor extends uvm_monitor;
    
    // UVM Factory registration
    `uvm_component_utils(alu_monitor)
    
    // Virtual interface handle
    virtual alu_monitor_if.monitor vif;
    
    // Analysis port for sending monitored transactions
    uvm_analysis_port #(alu_monitor_item) ap;
    
    // Configuration object
    alu_tb_config cfg;
    
    // Monitoring state
    bit monitoring_enabled;
    int operation_count;
    int error_count;
    
    // Current operation tracking
    alu_monitor_item current_operation;
    bit operation_in_progress;
    
    // Statistics
    int arithmetic_ops;
    int logic_ops;
    int shift_ops;
    int comparison_ops;
    int other_ops;
    
    // Constructor
    function new(string name = "alu_monitor", uvm_component parent = null);
        super.new(name, parent);
        operation_count = 0;
        error_count = 0;
        monitoring_enabled = 1;
        operation_in_progress = 0;
        arithmetic_ops = 0;
        logic_ops = 0;
        shift_ops = 0;
        comparison_ops = 0;
        other_ops = 0;
    endfunction
    
    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Create analysis port
        ap = new("ap", this);
        
        // Get configuration object
        if (!uvm_config_db#(alu_tb_config)::get(this, "", "cfg", cfg)) begin
            `uvm_fatal("NOCFG", "Configuration object not found")
        end
        
        // Get virtual interface
        if (!uvm_config_db#(virtual alu_monitor_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", "ALU monitor virtual interface not found")
        end
    endfunction
    
    // Run phase
    task run_phase(uvm_phase phase);
        fork
            monitor_alu_operations();
            monitor_reset();
        join
    endtask
    
    // Monitor reset signal
    task monitor_reset();
        forever begin
            @(negedge vif.rst_n);
            reset_monitor();
            @(posedge vif.rst_n);
            `uvm_info("ALUM", "Reset released, monitoring resumed", UVM_MEDIUM)
        end
    endtask
    
    // Reset monitor state
    function void reset_monitor();
        monitoring_enabled = 0;
        operation_in_progress = 0;
        if (current_operation != null) begin
            current_operation = null;
        end
        `uvm_info("ALUM", "ALU monitor reset", UVM_MEDIUM)
        
        // Re-enable monitoring after reset
        monitoring_enabled = 1;
    endfunction
    
    // Main monitoring task
    task monitor_alu_operations();
        forever begin
            @(posedge vif.clk);
            
            if (!monitoring_enabled || !vif.rst_n) continue;
            
            // Check for new ALU operation start
            if (vif.alu_enable && vif.id_valid && !operation_in_progress) begin
                start_operation_monitoring();
            end
            
            // Check for operation completion
            if (operation_in_progress && vif.ex_ready && vif.ex_valid) begin
                complete_operation_monitoring();
            end
            
            // Update current operation if in progress
            if (operation_in_progress) begin
                update_current_operation();
            end
        end
    endtask
    
    // Start monitoring a new ALU operation
    function void start_operation_monitoring();
        current_operation = alu_monitor_item::type_id::create("alu_operation");
        current_operation.start_time = $time;
        current_operation.cycle_number = operation_count;
        
        // Capture ALU inputs
        current_operation.alu_operation = vif.alu_operator;
        current_operation.operand_a = vif.alu_operand_a;
        current_operation.operand_b = vif.alu_operand_b;
        current_operation.operand_c = vif.alu_operand_c;
        current_operation.alu_enable = vif.alu_enable;
        
        // Capture control signals
        current_operation.vector_mode = vif.vector_mode;
        current_operation.bmask_a = vif.bmask_a;
        current_operation.bmask_b = vif.bmask_b;
        current_operation.imm_vec_ext = vif.imm_vec_ext;
        current_operation.is_clpx = vif.is_clpx;
        current_operation.is_subrot = vif.is_subrot;
        current_operation.clpx_shift = vif.clpx_shift;
        
        // Capture instruction information
        current_operation.instruction = vif.instruction;
        current_operation.pc = vif.pc;
        current_operation.instruction_valid = vif.instr_valid;
        
        operation_in_progress = 1;
        
        `uvm_info("ALUM", $sformatf("Started monitoring ALU operation: %s at PC 0x%08h", 
                  get_operation_name(vif.alu_operator), vif.pc), UVM_HIGH)
    endfunction
    
    // Update current operation with latest values
    function void update_current_operation();
        if (current_operation == null) return;
        
        // Update result if available
        current_operation.alu_result = vif.alu_result;
        current_operation.comparison_result = vif.comparison_result;
        
        // Update pipeline status
        current_operation.pipeline_stall = !vif.ex_ready_internal;
    endfunction
    
    // Complete operation monitoring and send to analysis port
    function void complete_operation_monitoring();
        if (current_operation == null) return;
        
        // Capture final results
        current_operation.alu_result = vif.alu_result;
        current_operation.comparison_result = vif.comparison_result;
        
        // Capture register writeback information
        current_operation.reg_write_enable = vif.regfile_we;
        current_operation.reg_write_addr = vif.regfile_waddr;
        current_operation.reg_write_data = vif.regfile_wdata;
        
        // Mark operation as complete
        current_operation.complete_operation();
        current_operation.end_time = $time;
        
        // Update statistics
        update_operation_statistics(current_operation);
        
        // Send to analysis port
        ap.write(current_operation);
        
        `uvm_info("ALUM", $sformatf("Completed ALU operation: %s\n%s", 
                  current_operation.get_operation_name(), current_operation.convert2string()), UVM_HIGH)
        
        // Check for errors
        if (current_operation.has_error) begin
            error_count++;
            `uvm_error("ALUM", $sformatf("ALU operation error: %s", current_operation.error_message))
        end
        
        operation_count++;
        operation_in_progress = 0;
        current_operation = null;
    endfunction
    
    // Update operation statistics
    function void update_operation_statistics(alu_monitor_item item);
        if (item.is_arithmetic_operation()) arithmetic_ops++;
        else if (item.is_logical_operation()) logic_ops++;
        else if (item.is_shift_operation()) shift_ops++;
        else if (item.is_comparison_operation()) comparison_ops++;
        else other_ops++;
    endfunction
    
    // Get operation name helper function
    function string get_operation_name(alu_opcode_e op);
        case (op)
            ALU_ADD:    return "ADD";
            ALU_SUB:    return "SUB";
            ALU_ADDU:   return "ADDU";
            ALU_SUBU:   return "SUBU";
            ALU_XOR:    return "XOR";
            ALU_OR:     return "OR";
            ALU_AND:    return "AND";
            ALU_SRA:    return "SRA";
            ALU_SRL:    return "SRL";
            ALU_ROR:    return "ROR";
            ALU_SLL:    return "SLL";
            ALU_LTS:    return "LTS";
            ALU_LTU:    return "LTU";
            ALU_EQ:     return "EQ";
            ALU_NE:     return "NE";
            ALU_SLTS:   return "SLTS";
            ALU_SLTU:   return "SLTU";
            default:    return "UNKNOWN";
        endcase
    endfunction
    
    // Enable/disable monitoring
    function void enable_monitoring();
        monitoring_enabled = 1;
        `uvm_info("ALUM", "ALU monitoring enabled", UVM_MEDIUM)
    endfunction
    
    function void disable_monitoring();
        monitoring_enabled = 0;
        `uvm_info("ALUM", "ALU monitoring disabled", UVM_MEDIUM)
    endfunction
    
    // Print monitoring statistics
    function void print_statistics();
        `uvm_info("ALUM", "=== ALU Monitor Statistics ===", UVM_LOW)
        `uvm_info("ALUM", $sformatf("Total operations: %0d", operation_count), UVM_LOW)
        `uvm_info("ALUM", $sformatf("Arithmetic operations: %0d", arithmetic_ops), UVM_LOW)
        `uvm_info("ALUM", $sformatf("Logic operations: %0d", logic_ops), UVM_LOW)
        `uvm_info("ALUM", $sformatf("Shift operations: %0d", shift_ops), UVM_LOW)
        `uvm_info("ALUM", $sformatf("Comparison operations: %0d", comparison_ops), UVM_LOW)
        `uvm_info("ALUM", $sformatf("Other operations: %0d", other_ops), UVM_LOW)
        `uvm_info("ALUM", $sformatf("Errors detected: %0d", error_count), UVM_LOW)
        `uvm_info("ALUM", "=============================", UVM_LOW)
    endfunction
    
    // Final phase - print statistics
    function void final_phase(uvm_phase phase);
        super.final_phase(phase);
        print_statistics();
    endfunction

endclass : alu_monitor