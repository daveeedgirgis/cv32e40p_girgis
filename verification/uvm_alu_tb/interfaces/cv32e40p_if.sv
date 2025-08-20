// =============================================================================
// CV32E40P Top-Level Interface
// 
// Interface that connects to the CV32E40P processor top-level module
// Used for instruction memory, data memory, and control signals
// =============================================================================

interface cv32e40p_if (
    input logic clk_i,
    input logic rst_ni
);

    // Clock and reset
    logic clk;
    logic rst_n;
    
    // Boot address
    logic [31:0] boot_addr_i;
    
    // Instruction Memory Interface (OBI)
    logic        instr_req_o;
    logic        instr_gnt_i;
    logic        instr_rvalid_i;
    logic [31:0] instr_addr_o;
    logic [31:0] instr_rdata_i;
    logic        instr_err_i;
    
    // Data Memory Interface (OBI)
    logic        data_req_o;
    logic        data_gnt_i;
    logic        data_rvalid_i;
    logic [31:0] data_addr_o;
    logic        data_we_o;
    logic [3:0]  data_be_o;
    logic [31:0] data_wdata_o;
    logic [31:0] data_rdata_i;
    logic        data_err_i;
    
    // Interrupt Interface
    logic [31:0] irq_i;
    logic        irq_ack_o;
    logic [4:0]  irq_id_o;
    
    // Debug Interface
    logic        debug_req_i;
    logic        debug_havereset_o;
    logic        debug_running_o;
    logic        debug_halted_o;
    
    // Core control signals
    logic        fetch_enable_i;
    logic        core_sleep_o;
    
    // Pulp cluster interface signals
    logic [5:0]  cluster_id_i;
    
    // APU interface (if FPU enabled)
    logic        apu_req_o;
    logic        apu_gnt_i;
    logic        apu_rvalid_i;
    
    // Assign clock and reset from interface inputs
    assign clk = clk_i;
    assign rst_n = rst_ni;
    
    // Default values for unused signals
    initial begin
        boot_addr_i = 32'h80;
        fetch_enable_i = 1'b1;
        cluster_id_i = 6'h0;
        debug_req_i = 1'b0;
        
        // Initialize memory interface inputs
        instr_gnt_i = 1'b0;
        instr_rvalid_i = 1'b0;
        instr_rdata_i = 32'h0;
        instr_err_i = 1'b0;
        
        data_gnt_i = 1'b0;
        data_rvalid_i = 1'b0;
        data_rdata_i = 32'h0;
        data_err_i = 1'b0;
        
        irq_i = 32'h0;
        
        // APU interface defaults
        apu_gnt_i = 1'b0;
        apu_rvalid_i = 1'b0;
    end
    
    // Modport for testbench (drives inputs, monitors outputs)
    modport tb (
        input  clk, rst_n,
        input  instr_req_o, instr_addr_o,
        output instr_gnt_i, instr_rvalid_i, instr_rdata_i, instr_err_i,
        input  data_req_o, data_addr_o, data_we_o, data_be_o, data_wdata_o,
        output data_gnt_i, data_rvalid_i, data_rdata_i, data_err_i,
        output boot_addr_i, fetch_enable_i, cluster_id_i, debug_req_i,
        input  debug_havereset_o, debug_running_o, debug_halted_o, core_sleep_o,
        output irq_i,
        input  irq_ack_o, irq_id_o,
        output apu_gnt_i, apu_rvalid_i,
        input  apu_req_o
    );
    
    // Modport for DUT (opposite of testbench)
    modport dut (
        input  clk_i, rst_ni,
        output instr_req_o, instr_addr_o,
        input  instr_gnt_i, instr_rvalid_i, instr_rdata_i, instr_err_i,
        output data_req_o, data_addr_o, data_we_o, data_be_o, data_wdata_o,
        input  data_gnt_i, data_rvalid_i, data_rdata_i, data_err_i,
        input  boot_addr_i, fetch_enable_i, cluster_id_i, debug_req_i,
        output debug_havereset_o, debug_running_o, debug_halted_o, core_sleep_o,
        input  irq_i,
        output irq_ack_o, irq_id_o,
        input  apu_gnt_i, apu_rvalid_i,
        output apu_req_o
    );
    
    // Modport for driver
    modport driver (
        input  clk, rst_n,
        input  instr_req_o, instr_addr_o,
        output instr_gnt_i, instr_rvalid_i, instr_rdata_i, instr_err_i,
        input  data_req_o, data_addr_o, data_we_o, data_be_o, data_wdata_o,
        output data_gnt_i, data_rvalid_i, data_rdata_i, data_err_i,
        output boot_addr_i, fetch_enable_i, debug_req_i, irq_i
    );
    
    // Modport for monitor
    modport monitor (
        input clk, rst_n,
        input instr_req_o, instr_addr_o, instr_gnt_i, instr_rvalid_i, instr_rdata_i,
        input data_req_o, data_addr_o, data_we_o, data_be_o, data_wdata_o,
        input data_gnt_i, data_rvalid_i, data_rdata_i,
        input debug_havereset_o, debug_running_o, debug_halted_o, core_sleep_o,
        input irq_ack_o, irq_id_o
    );

endinterface : cv32e40p_if