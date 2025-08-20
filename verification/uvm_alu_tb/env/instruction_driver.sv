// =============================================================================
// Instruction Driver
//
// UVM driver that handles instruction memory interface for the CV32E40P
// Responds to instruction fetch requests and provides instructions
// =============================================================================

class instruction_driver extends uvm_driver #(instruction_item);
    
    // UVM Factory registration
    `uvm_component_utils(instruction_driver)
    
    // Virtual interface handle
    virtual cv32e40p_if.driver vif;
    
    // Configuration object
    alu_tb_config cfg;
    
    // Instruction memory storage
    bit [31:0] instruction_memory [bit [31:0]];
    
    // Driver state
    bit [31:0] current_pc;
    bit        reset_active;
    int        instruction_count;
    
    // Constructor
    function new(string name = "instruction_driver", uvm_component parent = null);
        super.new(name, parent);
        instruction_count = 0;
        current_pc = 0;
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
    
    // Initialize instruction memory with default values
    function void initialize_memory();
        // Fill memory with NOPs initially
        for (int i = 0; i < cfg.instruction_memory_size; i += 4) begin
            instruction_memory[cfg.instruction_base_addr + i] = 32'h00000013; // NOP (addi x0, x0, 0)
        end
        `uvm_info("IDRV", "Instruction memory initialized with NOPs", UVM_MEDIUM)
    endfunction
    
    // Load instruction into memory
    function void load_instruction(bit [31:0] address, bit [31:0] instruction);
        if (address[1:0] != 2'b00) begin
            `uvm_error("IDRV", $sformatf("Instruction address 0x%08h not word-aligned", address))
            return;
        end
        
        instruction_memory[address] = instruction;
        `uvm_info("IDRV", $sformatf("Loaded instruction 0x%08h at address 0x%08h", 
                  instruction, address), UVM_HIGH)
    endfunction
    
    // Load sequence of instructions
    function void load_instruction_sequence(instruction_item instructions[$]);
        bit [31:0] addr = cfg.instruction_base_addr;
        
        foreach (instructions[i]) begin
            load_instruction(addr, instructions[i].instruction);
            instructions[i].pc = addr;
            addr += 4;
        end
        
        // Add a final instruction to stop simulation (infinite loop)
        load_instruction(addr, 32'h0000006f); // JAL x0, 0 (infinite loop)
        
        `uvm_info("IDRV", $sformatf("Loaded %0d instructions starting at 0x%08h", 
                  instructions.size(), cfg.instruction_base_addr), UVM_LOW)
    endfunction
    
    // Reset driver state
    task reset_driver();
        reset_active = 1;
        current_pc = cfg.instruction_base_addr;
        instruction_count = 0;
        
        // Initialize interface signals
        vif.instr_gnt_i = 1'b0;
        vif.instr_rvalid_i = 1'b0;
        vif.instr_rdata_i = 32'h0;
        vif.instr_err_i = 1'b0;
        
        `uvm_info("IDRV", "Driver reset completed", UVM_MEDIUM)
    endtask
    
    // Wait for reset deassertion
    task wait_for_reset_release();
        @(posedge vif.rst_n);
        reset_active = 0;
        `uvm_info("IDRV", "Reset released, driver active", UVM_MEDIUM)
    endtask
    
    // Main driver run task
    task run_phase(uvm_phase phase);
        fork
            reset_monitor();
            instruction_response_driver();
            sequence_driver();
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
    
    // Handle instruction fetch requests
    task instruction_response_driver();
        forever begin
            @(posedge vif.clk);
            
            if (reset_active) continue;
            
            // Handle instruction request
            if (vif.instr_req_o && !vif.instr_gnt_i) begin
                // Grant the request
                @(posedge vif.clk);
                vif.instr_gnt_i <= 1'b1;
                
                // Provide response after one cycle
                @(posedge vif.clk);
                vif.instr_gnt_i <= 1'b0;
                vif.instr_rvalid_i <= 1'b1;
                
                // Fetch instruction from memory
                if (instruction_memory.exists(vif.instr_addr_o)) begin
                    vif.instr_rdata_i <= instruction_memory[vif.instr_addr_o];
                    vif.instr_err_i <= 1'b0;
                    `uvm_info("IDRV", $sformatf("Fetched instruction 0x%08h from PC 0x%08h", 
                              instruction_memory[vif.instr_addr_o], vif.instr_addr_o), UVM_HIGH)
                end else begin
                    vif.instr_rdata_i <= 32'h00000013; // NOP for unmapped addresses
                    vif.instr_err_i <= 1'b0;
                    `uvm_warning("IDRV", $sformatf("Unmapped instruction fetch from 0x%08h, returning NOP", 
                                 vif.instr_addr_o))
                end
                
                @(posedge vif.clk);
                vif.instr_rvalid_i <= 1'b0;
                vif.instr_rdata_i <= 32'h0;
                
                instruction_count++;
            end
        end
    endtask
    
    // Drive instruction sequences
    task sequence_driver();
        instruction_item instruction_queue[$];
        
        forever begin
            // Wait for sequence item
            seq_item_port.get_next_item(req);
            
            `uvm_info("IDRV", $sformatf("Received instruction item:\n%s", req.convert2string()), UVM_HIGH)
            
            // Add instruction to queue for loading
            instruction_queue.push_back(req);
            
            // If we have enough instructions or this is the last item, load them
            if (instruction_queue.size() >= 10 || req.instr_type == req.INSTR_TYPE_NOP) begin
                load_instruction_sequence(instruction_queue);
                instruction_queue.delete();
            end
            
            seq_item_port.item_done();
        end
    endtask
    
    // Get current instruction count
    function int get_instruction_count();
        return instruction_count;
    endfunction
    
    // Function to check if specific address contains valid instruction
    function bit has_instruction_at_address(bit [31:0] addr);
        return instruction_memory.exists(addr);
    endfunction
    
    // Get instruction at specific address
    function bit [31:0] get_instruction_at_address(bit [31:0] addr);
        if (instruction_memory.exists(addr)) begin
            return instruction_memory[addr];
        end else begin
            return 32'h00000013; // Return NOP for unmapped addresses
        end
    endfunction

endclass : instruction_driver