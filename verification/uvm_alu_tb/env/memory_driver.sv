// =============================================================================
// Memory Driver
//
// UVM driver that handles data memory interface for the CV32E40P
// Responds to data memory requests (loads and stores)
// =============================================================================

class memory_driver extends uvm_driver #(memory_item);
    
    // UVM Factory registration
    `uvm_component_utils(memory_driver)
    
    // Virtual interface handle
    virtual cv32e40p_if.driver vif;
    
    // Configuration object
    alu_tb_config cfg;
    
    // Data memory storage
    bit [7:0] data_memory [bit [31:0]];
    
    // Driver state
    bit reset_active;
    int transaction_count;
    
    // Statistics
    int read_count;
    int write_count;
    int error_count;
    
    // Constructor
    function new(string name = "memory_driver", uvm_component parent = null);
        super.new(name, parent);
        transaction_count = 0;
        read_count = 0;
        write_count = 0;
        error_count = 0;
        reset_active = 1;
    endfunction
    
    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Get configuration object
        if (!uvm_config_db#(alu_tb_config)::get(this, "", "cfg", cfg)) begin
            `uvm_fatal("NOCFG", "Configuration object not found")
        end
        
        // Get virtual interface
        if (!uvm_config_db#(virtual cv32e40p_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", "Virtual interface not found")
        end
    endfunction
    
    // Connect phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        initialize_memory();
    endfunction
    
    // Initialize data memory
    function void initialize_memory();
        // Initialize data memory with some pattern for testing
        for (int i = 0; i < cfg.data_memory_size; i++) begin
            data_memory[cfg.data_base_addr + i] = i[7:0];
        end
        `uvm_info("MDRV", "Data memory initialized", UVM_MEDIUM)
    endfunction
    
    // Reset driver state
    task reset_driver();
        reset_active = 1;
        transaction_count = 0;
        
        // Initialize interface signals
        vif.data_gnt_i = 1'b0;
        vif.data_rvalid_i = 1'b0;
        vif.data_rdata_i = 32'h0;
        vif.data_err_i = 1'b0;
        
        `uvm_info("MDRV", "Memory driver reset completed", UVM_MEDIUM)
    endtask
    
    // Wait for reset deassertion
    task wait_for_reset_release();
        @(posedge vif.rst_n);
        reset_active = 0;
        `uvm_info("MDRV", "Reset released, memory driver active", UVM_MEDIUM)
    endtask
    
    // Main driver run task
    task run_phase(uvm_phase phase);
        fork
            reset_monitor();
            memory_response_driver();
        join
    endtask
    
    // Monitor reset signal
    task reset_monitor();
        forever begin
            @(negedge vif.rst_n);
            reset_driver();
            wait_for_reset_release();
        end
    endtask
    
    // Handle memory requests
    task memory_response_driver();
        forever begin
            @(posedge vif.clk);
            
            if (reset_active) continue;
            
            // Handle data memory request
            if (vif.data_req_o && !vif.data_gnt_i) begin
                handle_memory_transaction();
            end
        end
    endtask
    
    // Handle a complete memory transaction
    task handle_memory_transaction();
        bit [31:0] address;
        bit [31:0] write_data;
        bit [3:0]  byte_enable;
        bit        is_write;
        bit [31:0] read_data;
        bit        error;
        
        // Capture request
        address = vif.data_addr_o;
        write_data = vif.data_wdata_o;
        byte_enable = vif.data_be_o;
        is_write = vif.data_we_o;
        
        // Grant the request
        @(posedge vif.clk);
        vif.data_gnt_i <= 1'b1;
        
        // Perform the memory operation
        if (is_write) begin
            error = perform_write(address, write_data, byte_enable);
            write_count++;
        end else begin
            {error, read_data} = perform_read(address, byte_enable);
            read_count++;
        end
        
        // Provide response after one cycle
        @(posedge vif.clk);
        vif.data_gnt_i <= 1'b0;
        vif.data_rvalid_i <= 1'b1;
        
        if (!is_write) begin
            vif.data_rdata_i <= read_data;
        end
        vif.data_err_i <= error;
        
        if (error) error_count++;
        
        `uvm_info("MDRV", $sformatf("%s transaction: addr=0x%08h, be=0b%04b, data=0x%08h, error=%b",
                  is_write ? "WRITE" : "READ", address, byte_enable, 
                  is_write ? write_data : read_data, error), UVM_HIGH)
        
        @(posedge vif.clk);
        vif.data_rvalid_i <= 1'b0;
        vif.data_rdata_i <= 32'h0;
        vif.data_err_i <= 1'b0;
        
        transaction_count++;
    endtask
    
    // Perform memory write operation
    function bit perform_write(bit [31:0] addr, bit [31:0] data, bit [3:0] be);
        bit error = 0;
        
        // Check address bounds
        if (addr < cfg.data_base_addr || addr >= (cfg.data_base_addr + cfg.data_memory_size)) begin
            `uvm_warning("MDRV", $sformatf("Write to out-of-bounds address 0x%08h", addr))
            return 1; // Return error
        end
        
        // Check alignment
        if (!check_alignment(addr, be)) begin
            `uvm_error("MDRV", $sformatf("Misaligned write: addr=0x%08h, be=0b%04b", addr, be))
            return 1; // Return error
        end
        
        // Perform byte-wise write based on byte enable
        if (be[0]) data_memory[addr + 0] = data[7:0];
        if (be[1]) data_memory[addr + 1] = data[15:8];
        if (be[2]) data_memory[addr + 2] = data[23:16];
        if (be[3]) data_memory[addr + 3] = data[31:24];
        
        return error;
    endfunction
    
    // Perform memory read operation
    function {bit, bit [31:0]} perform_read(bit [31:0] addr, bit [3:0] be);
        bit error = 0;
        bit [31:0] data = 32'h0;
        
        // Check address bounds
        if (addr < cfg.data_base_addr || addr >= (cfg.data_base_addr + cfg.data_memory_size)) begin
            `uvm_warning("MDRV", $sformatf("Read from out-of-bounds address 0x%08h", addr))
            return {1'b1, 32'h0}; // Return error and zero data
        end
        
        // Check alignment
        if (!check_alignment(addr, be)) begin
            `uvm_error("MDRV", $sformatf("Misaligned read: addr=0x%08h, be=0b%04b", addr, be))
            return {1'b1, 32'h0}; // Return error and zero data
        end
        
        // Perform byte-wise read based on byte enable
        if (be[0]) data[7:0] = data_memory.exists(addr + 0) ? data_memory[addr + 0] : 8'h0;
        if (be[1]) data[15:8] = data_memory.exists(addr + 1) ? data_memory[addr + 1] : 8'h0;
        if (be[2]) data[23:16] = data_memory.exists(addr + 2) ? data_memory[addr + 2] : 8'h0;
        if (be[3]) data[31:24] = data_memory.exists(addr + 3) ? data_memory[addr + 3] : 8'h0;
        
        return {error, data};
    endfunction
    
    // Check address alignment based on byte enable
    function bit check_alignment(bit [31:0] addr, bit [3:0] be);
        case (be)
            4'b0001, 4'b0010, 4'b0100, 4'b1000: return 1; // Byte accesses always aligned
            4'b0011: return (addr[0] == 0); // Halfword aligned
            4'b1100: return (addr[0] == 0); // Halfword aligned
            4'b1111: return (addr[1:0] == 0); // Word aligned
            default: return 0; // Invalid byte enable pattern
        endcase
    endfunction
    
    // Preload data into memory
    function void preload_data(bit [31:0] addr, bit [31:0] data);
        if (addr[1:0] != 2'b00) begin
            `uvm_error("MDRV", $sformatf("Preload address 0x%08h not word-aligned", addr))
            return;
        end
        
        data_memory[addr + 0] = data[7:0];
        data_memory[addr + 1] = data[15:8];
        data_memory[addr + 2] = data[23:16];
        data_memory[addr + 3] = data[31:24];
        
        `uvm_info("MDRV", $sformatf("Preloaded data 0x%08h at address 0x%08h", data, addr), UVM_HIGH)
    endfunction
    
    // Get statistics
    function void print_statistics();
        `uvm_info("MDRV", "=== Memory Driver Statistics ===", UVM_LOW)
        `uvm_info("MDRV", $sformatf("Total transactions: %0d", transaction_count), UVM_LOW)
        `uvm_info("MDRV", $sformatf("Read transactions: %0d", read_count), UVM_LOW)
        `uvm_info("MDRV", $sformatf("Write transactions: %0d", write_count), UVM_LOW)
        `uvm_info("MDRV", $sformatf("Error transactions: %0d", error_count), UVM_LOW)
        `uvm_info("MDRV", "===============================", UVM_LOW)
    endfunction

endclass : memory_driver