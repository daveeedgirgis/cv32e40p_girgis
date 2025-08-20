// =============================================================================
// Basic ALU Sequence
//
// Simple UVM sequence that generates basic ALU-focused instructions
// Used for initial testing and basic functionality verification
// =============================================================================

class basic_alu_sequence extends uvm_sequence #(instruction_item);
    
    // UVM Factory registration
    `uvm_object_utils(basic_alu_sequence)
    
    // Configuration handle
    alu_tb_config cfg;
    
    // Sequence parameters
    int num_instructions = 10;
    
    // Constructor
    function new(string name = "basic_alu_sequence");
        super.new(name);
    endfunction
    
    // Pre-body task to get configuration
    task pre_body();
        super.pre_body();
        if (!uvm_config_db#(alu_tb_config)::get(m_sequencer, "", "cfg", cfg)) begin
            `uvm_warning("SEQ", "No configuration object found, using defaults")
            cfg = alu_tb_config::type_id::create("default_cfg");
        end
        
        if (cfg != null) begin
            num_instructions = cfg.num_instructions;
        end
    endtask
    
    // Main sequence body
    task body();
        `uvm_info("SEQ", $sformatf("Starting basic ALU sequence with %0d instructions", num_instructions), UVM_MEDIUM)
        
        // Generate a mix of ALU instructions
        for (int i = 0; i < num_instructions; i++) begin
            req = instruction_item::type_id::create("instr_item");
            start_item(req);
            
            // Randomize instruction with basic constraints
            if (!req.randomize()) begin
                `uvm_error("SEQ", "Failed to randomize instruction item")
            end
            
            `uvm_info("SEQ", $sformatf("Generated instruction %0d:\n%s", i, req.convert2string()), UVM_HIGH)
            
            finish_item(req);
        end
        
        `uvm_info("SEQ", "Completed basic ALU sequence", UVM_MEDIUM)
    endtask

endclass : basic_alu_sequence