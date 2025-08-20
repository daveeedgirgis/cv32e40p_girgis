// =============================================================================
// ALU Testbench Top Module
//
// Top-level testbench that instantiates the CV32E40P processor and connects
// all interfaces for UVM-based ALU verification
// =============================================================================

`timescale 1ns/1ps

module alu_tb_top;

    import uvm_pkg::*;
    import alu_tb_pkg::*;
    
    // Clock and reset generation
    logic clk;
    logic rst_n;
    
    // Clock generation (100MHz)
    initial begin
        clk = 0;
        forever #5ns clk = ~clk;
    end
    
    // Reset generation
    initial begin
        rst_n = 0;
        repeat(10) @(posedge clk);
        rst_n = 1;
        `uvm_info("TB_TOP", "Reset released", UVM_LOW)
    end
    
    // Interface instantiations
    cv32e40p_if processor_if(.clk_i(clk), .rst_ni(rst_n));
    alu_monitor_if alu_mon_if(.clk(clk), .rst_n(rst_n));
    
    // DUT instantiation - CV32E40P processor
    cv32e40p_top #(
        .COREV_PULP(0),
        .COREV_CLUSTER(0),
        .FPU(0),
        .ZFINX(0)
    ) dut (
        // Clock and reset
        .clk_i(processor_if.clk),
        .rst_ni(processor_if.rst_n),
        
        // Boot address
        .boot_addr_i(processor_if.boot_addr_i),
        .mtvec_addr_i(32'h0),
        .dm_halt_addr_i(32'h0),
        .dm_exception_addr_i(32'h0),
        .hart_id_i(32'h0),
        
        // Instruction memory interface
        .instr_req_o(processor_if.instr_req_o),
        .instr_gnt_i(processor_if.instr_gnt_i),
        .instr_rvalid_i(processor_if.instr_rvalid_i),
        .instr_addr_o(processor_if.instr_addr_o),
        .instr_rdata_i(processor_if.instr_rdata_i),
        .instr_err_i(processor_if.instr_err_i),
        
        // Data memory interface
        .data_req_o(processor_if.data_req_o),
        .data_gnt_i(processor_if.data_gnt_i),
        .data_rvalid_i(processor_if.data_rvalid_i),
        .data_addr_o(processor_if.data_addr_o),
        .data_we_o(processor_if.data_we_o),
        .data_be_o(processor_if.data_be_o),
        .data_wdata_o(processor_if.data_wdata_o),
        .data_rdata_i(processor_if.data_rdata_i),
        .data_err_i(processor_if.data_err_i),
        
        // Interrupt interface
        .irq_i(processor_if.irq_i),
        .irq_ack_o(processor_if.irq_ack_o),
        .irq_id_o(processor_if.irq_id_o),
        
        // Debug interface
        .debug_req_i(processor_if.debug_req_i),
        .debug_havereset_o(processor_if.debug_havereset_o),
        .debug_running_o(processor_if.debug_running_o),
        .debug_halted_o(processor_if.debug_halted_o),
        
        // Core control
        .fetch_enable_i(processor_if.fetch_enable_i),
        .core_sleep_o(processor_if.core_sleep_o),
        
        // Cluster interface (unused)
        .cluster_id_i(processor_if.cluster_id_i),
        
        // APU interface (unused in this configuration)
        .apu_req_o(processor_if.apu_req_o),
        .apu_gnt_i(processor_if.apu_gnt_i),
        .apu_rvalid_i(processor_if.apu_rvalid_i),
        .apu_operands_o(),
        .apu_op_o(),
        .apu_flags_o(),
        .apu_rdata_i(32'h0),
        .apu_rflags_i(5'h0)
    );
    
    // ALU signal monitoring connections
    // Connect internal ALU signals to monitoring interface
    always_comb begin
        alu_mon_if.alu_enable = dut.core_i.ex_stage_i.alu_en;
        alu_mon_if.alu_operator = dut.core_i.ex_stage_i.alu_operator_i;
        alu_mon_if.alu_operand_a = dut.core_i.ex_stage_i.alu_operand_a_i;
        alu_mon_if.alu_operand_b = dut.core_i.ex_stage_i.alu_operand_b_i;
        alu_mon_if.alu_operand_c = dut.core_i.ex_stage_i.alu_operand_c_i;
        
        alu_mon_if.vector_mode = dut.core_i.ex_stage_i.alu_vec_mode_i;
        alu_mon_if.bmask_a = dut.core_i.ex_stage_i.bmask_a_i;
        alu_mon_if.bmask_b = dut.core_i.ex_stage_i.bmask_b_i;
        alu_mon_if.imm_vec_ext = dut.core_i.ex_stage_i.imm_vec_ext_i;
        alu_mon_if.is_clpx = 1'b0; // Not used in basic configuration
        alu_mon_if.is_subrot = 1'b0; // Not used in basic configuration
        alu_mon_if.clpx_shift = 2'b0; // Not used in basic configuration
        
        alu_mon_if.alu_result = dut.core_i.ex_stage_i.alu_result;
        alu_mon_if.comparison_result = dut.core_i.ex_stage_i.alu_cmp_result;
        alu_mon_if.alu_ready = dut.core_i.ex_stage_i.alu_ready;
        alu_mon_if.ex_ready = dut.core_i.ex_ready_o;
        
        alu_mon_if.id_valid = dut.core_i.id_valid_o;
        alu_mon_if.ex_valid = dut.core_i.ex_valid_i;
        alu_mon_if.ex_ready_internal = dut.core_i.ex_ready_o;
        
        alu_mon_if.instruction = dut.core_i.id_stage_i.instr;
        alu_mon_if.pc = dut.core_i.pc_id;
        alu_mon_if.instr_valid = dut.core_i.id_valid_o;
        
        alu_mon_if.regfile_we = dut.core_i.regfile_we_wb_i;
        alu_mon_if.regfile_waddr = dut.core_i.regfile_waddr_wb_i;
        alu_mon_if.regfile_wdata = dut.core_i.regfile_wdata_wb_i;
    end
    
    // Timeout mechanism
    initial begin
        #1ms; // 1 millisecond timeout
        `uvm_error("TB_TOP", "Simulation timeout reached")
        $finish;
    end
    
    // Waveform dumping
    initial begin
        `ifdef DUMP_VCD
            $dumpfile("waves/alu_test.vcd");
            $dumpvars(0, alu_tb_top);
        `endif
        
        `ifdef DUMP_FSDB
            $fsdbDumpfile("waves/alu_test.fsdb");
            $fsdbDumpvars(0, alu_tb_top);
        `endif
    end
    
    // UVM testbench startup
    initial begin
        // Set virtual interfaces in UVM config database
        uvm_config_db#(virtual cv32e40p_if)::set(null, "*", "vif", processor_if);
        uvm_config_db#(virtual alu_monitor_if)::set(null, "*", "vif", alu_mon_if);
        
        // Print banner
        `uvm_info("TB_TOP", "========================================", UVM_LOW)
        `uvm_info("TB_TOP", "  CV32E40P ALU Verification Testbench  ", UVM_LOW)
        `uvm_info("TB_TOP", "========================================", UVM_LOW)
        
        // Run the test
        run_test();
    end
    
    // Monitor simulation progress
    initial begin
        int cycle_count = 0;
        forever begin
            @(posedge clk);
            cycle_count++;
            if (cycle_count % 1000 == 0) begin
                `uvm_info("TB_TOP", $sformatf("Simulation cycle: %0d", cycle_count), UVM_HIGH)
            end
        end
    end

endmodule : alu_tb_top