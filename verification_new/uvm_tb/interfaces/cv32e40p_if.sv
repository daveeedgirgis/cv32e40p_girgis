// =============================================================================
// CV32E40P Processor Interface - Stage 1
// 
// SystemVerilog interface for connecting to the CV32E40P processor top-level
// Provides proper OBI memory interfaces and control signals
// Based on actual CV32E40P RTL hierarchy and signal names
// =============================================================================

interface cv32e40p_if (
    input logic clk_i,
    input logic rst_ni
);

    // Clock and reset - directly connected to interface inputs
    logic clk;
    logic rst_n;
    
    // Assign from interface inputs
    assign clk = clk_i;
    assign rst_n = rst_ni;
    
    // Boot and configuration addresses
    logic [31:0] boot_addr_i;
    logic [31:0] mtvec_addr_i;
    logic [31:0] dm_halt_addr_i;
    logic [31:0] hart_id_i;
    logic [31:0] dm_exception_addr_i;
    
    // Instruction Memory Interface (OBI Protocol)
    logic        instr_req_o;           // Instruction request
    logic        instr_gnt_i;           // Instruction grant
    logic        instr_rvalid_i;        // Instruction response valid
    logic [31:0] instr_addr_o;          // Instruction address
    logic [31:0] instr_rdata_i;         // Instruction read data
    logic        instr_err_i;           // Instruction error
    
    // Data Memory Interface (OBI Protocol)
    logic        data_req_o;            // Data request
    logic        data_gnt_i;            // Data grant
    logic        data_rvalid_i;         // Data response valid
    logic [31:0] data_addr_o;           // Data address
    logic        data_we_o;             // Data write enable
    logic [3:0]  data_be_o;             // Data byte enable
    logic [31:0] data_wdata_o;          // Data write data
    logic [31:0] data_rdata_i;          // Data read data
    logic        data_err_i;            // Data error
    
    // Interrupt Interface
    logic [31:0] irq_i;                 // Interrupt requests
    logic        irq_ack_o;             // Interrupt acknowledge
    logic [4:0]  irq_id_o;              // Interrupt ID
    
    // Debug Interface
    logic        debug_req_i;           // Debug request
    logic        debug_havereset_o;     // Debug have reset
    logic        debug_running_o;       // Debug running
    logic        debug_halted_o;        // Debug halted
    
    // Core Control Signals
    logic        fetch_enable_i;        // Fetch enable
    logic        core_sleep_o;          // Core sleep output
    
    // PULP Cluster Interface (optional)
    logic        pulp_clock_en_i;       // PULP clock enable
    logic        scan_cg_en_i;          // Scan clock gate enable
    
    // APU Interface (Auxiliary Processing Unit - for FPU)
    logic        apu_req_o;             // APU request
    logic        apu_gnt_i;             // APU grant
    logic        apu_rvalid_i;          // APU response valid
    logic [31:0] apu_operands_o[3];     // APU operands
    logic [5:0]  apu_op_o;              // APU operation
    logic [14:0] apu_flags_o;           // APU flags
    logic [31:0] apu_rdata_i;           // APU result data
    logic [4:0]  apu_rflags_i;          // APU result flags
    
    // Initialize default values for input signals
    initial begin
        // Configuration addresses
        boot_addr_i = 32'h00000080;      // Standard boot address
        mtvec_addr_i = 32'h00000000;     // Machine trap vector
        dm_halt_addr_i = 32'h00000000;   // Debug halt address
        hart_id_i = 32'h00000000;        // Hardware thread ID
        dm_exception_addr_i = 32'h00000000; // Debug exception address
        
        // Control signals
        fetch_enable_i = 1'b1;           // Enable instruction fetch
        pulp_clock_en_i = 1'b1;          // Enable PULP clock
        scan_cg_en_i = 1'b0;             // Disable scan mode
        
        // Instruction memory interface defaults
        instr_gnt_i = 1'b0;              // No grant initially
        instr_rvalid_i = 1'b0;           // No valid response
        instr_rdata_i = 32'h00000013;    // NOP instruction (ADDI x0, x0, 0)
        instr_err_i = 1'b0;              // No error
        
        // Data memory interface defaults
        data_gnt_i = 1'b0;               // No grant initially
        data_rvalid_i = 1'b0;            // No valid response
        data_rdata_i = 32'h00000000;     // Zero data
        data_err_i = 1'b0;               // No error
        
        // Interrupt interface defaults
        irq_i = 32'h00000000;            // No interrupts
        
        // Debug interface defaults
        debug_req_i = 1'b0;              // No debug request
        
        // APU interface defaults (disabled for basic ALU testing)
        apu_gnt_i = 1'b0;                // No APU grant
        apu_rvalid_i = 1'b0;             // No APU response
        apu_rdata_i = 32'h00000000;      // Zero APU data
        apu_rflags_i = 5'h00;            // Zero APU flags
    end
    
    // Modport for testbench (drives inputs, monitors outputs)
    modport tb (
        input  clk, rst_n,
        
        // Processor outputs (inputs to testbench)
        input  instr_req_o, instr_addr_o,
        input  data_req_o, data_addr_o, data_we_o, data_be_o, data_wdata_o,
        input  irq_ack_o, irq_id_o,
        input  debug_havereset_o, debug_running_o, debug_halted_o, core_sleep_o,
        input  apu_req_o, apu_operands_o, apu_op_o, apu_flags_o,
        
        // Processor inputs (outputs from testbench)
        output boot_addr_i, mtvec_addr_i, dm_halt_addr_i, hart_id_i, dm_exception_addr_i,
        output fetch_enable_i, pulp_clock_en_i, scan_cg_en_i,
        output instr_gnt_i, instr_rvalid_i, instr_rdata_i, instr_err_i,
        output data_gnt_i, data_rvalid_i, data_rdata_i, data_err_i,
        output irq_i, debug_req_i,
        output apu_gnt_i, apu_rvalid_i, apu_rdata_i, apu_rflags_i
    );
    
    // Modport for DUT connection (opposite of testbench)
    modport dut (
        input  clk_i, rst_ni,
        
        // Processor inputs
        input  boot_addr_i, mtvec_addr_i, dm_halt_addr_i, hart_id_i, dm_exception_addr_i,
        input  fetch_enable_i, pulp_clock_en_i, scan_cg_en_i,
        input  instr_gnt_i, instr_rvalid_i, instr_rdata_i, instr_err_i,
        input  data_gnt_i, data_rvalid_i, data_rdata_i, data_err_i,
        input  irq_i, debug_req_i,
        input  apu_gnt_i, apu_rvalid_i, apu_rdata_i, apu_rflags_i,
        
        // Processor outputs
        output instr_req_o, instr_addr_o,
        output data_req_o, data_addr_o, data_we_o, data_be_o, data_wdata_o,
        output irq_ack_o, irq_id_o,
        output debug_havereset_o, debug_running_o, debug_halted_o, core_sleep_o,
        output apu_req_o, apu_operands_o, apu_op_o, apu_flags_o
    );
    
    // Modport for memory driver
    modport mem_driver (
        input  clk, rst_n,
        input  instr_req_o, instr_addr_o,
        output instr_gnt_i, instr_rvalid_i, instr_rdata_i, instr_err_i,
        input  data_req_o, data_addr_o, data_we_o, data_be_o, data_wdata_o,
        output data_gnt_i, data_rvalid_i, data_rdata_i, data_err_i
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
    
    // Helper functions for debugging and monitoring
    
    // Function to check if instruction memory transaction is active
    function bit instr_mem_active();
        return instr_req_o && instr_gnt_i;
    endfunction
    
    // Function to check if data memory transaction is active
    function bit data_mem_active();
        return data_req_o && data_gnt_i;
    endfunction
    
    // Function to get instruction memory transaction info
    function string get_instr_mem_info();
        if (instr_mem_active()) begin
            return $sformatf("IMEM: addr=0x%08h, data=0x%08h", instr_addr_o, instr_rdata_i);
        end else begin
            return "IMEM: inactive";
        end
    endfunction
    
    // Function to get data memory transaction info
    function string get_data_mem_info();
        if (data_mem_active()) begin
            if (data_we_o) begin
                return $sformatf("DMEM: WRITE addr=0x%08h, data=0x%08h, be=0x%h", 
                                data_addr_o, data_wdata_o, data_be_o);
            end else begin
                return $sformatf("DMEM: READ addr=0x%08h, data=0x%08h", 
                                data_addr_o, data_rdata_i);
            end
        end else begin
            return "DMEM: inactive";
        end
    endfunction
    
    // Assertion to check OBI protocol compliance for instruction memory
    property instr_obi_protocol;
        @(posedge clk) disable iff (!rst_n)
        instr_req_o && instr_gnt_i |-> ##[1:$] instr_rvalid_i;
    endproperty
    
    // Assertion to check OBI protocol compliance for data memory
    property data_obi_protocol;
        @(posedge clk) disable iff (!rst_n)
        data_req_o && data_gnt_i |-> ##[1:$] data_rvalid_i;
    endproperty
    
    // Enable assertions if configured
    `ifdef ENABLE_ASSERTIONS
        assert_instr_obi: assert property (instr_obi_protocol)
            else $error("Instruction OBI protocol violation");
            
        assert_data_obi: assert property (data_obi_protocol)
            else $error("Data OBI protocol violation");
    `endif

endinterface : cv32e40p_if