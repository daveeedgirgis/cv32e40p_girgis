// =============================================================================
// ALU Testbench Top Module - Stage 1
//
// Top-level testbench for ALU verification - simplified for Stage 1 testing
// =============================================================================

`timescale 1ns/1ps

module alu_tb_top;

    import uvm_pkg::*;
    import alu_pkg::*;
    
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
    
    // For Stage 1, we'll create a simple dummy DUT that just toggles some signals
    // In Stage 2, this will be replaced with the actual CV32E40P processor
    
    // Dummy ALU signals for Stage 1 testing
    logic [31:0] dummy_result;
    logic        dummy_ready;
    
    // Simple dummy logic to generate some activity
    always @(posedge clk) begin
        if (!rst_n) begin
            dummy_result <= 32'h0;
            dummy_ready <= 1'b0;
        end else begin
            dummy_result <= dummy_result + 1;
            dummy_ready <= ~dummy_ready;
        end
    end
    
    // Connect dummy signals to monitor interface for Stage 1
    assign alu_mon_if.alu_result = dummy_result;
    assign alu_mon_if.alu_ready = dummy_ready;
    assign alu_mon_if.alu_en = dummy_ready;
    assign alu_mon_if.id_valid = dummy_ready;
    assign alu_mon_if.ex_valid = dummy_ready;
    assign alu_mon_if.ex_ready = 1'b1;
    
    // Timeout mechanism
    initial begin
        #100us; // 100 microsecond timeout for Stage 1
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
        `uvm_info("TB_TOP", "  CV32E40P ALU Verification - Stage 1  ", UVM_LOW)
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