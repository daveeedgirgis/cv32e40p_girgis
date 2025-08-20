// =============================================================================
// ALU Instruction Sequence
//
// Base sequence class for ALU-focused instruction generation
// Provides common functionality for all ALU test sequences
// =============================================================================

class alu_instruction_sequence extends uvm_sequence #(instruction_item);
    
    // UVM Factory registration
    `uvm_object_utils(alu_instruction_sequence)
    
    // Configuration handle
    alu_tb_config cfg;
    
    // Constructor
    function new(string name = "alu_instruction_sequence");
        super.new(name);
    endfunction
    
    // Pre-body task to get configuration
    task pre_body();
        super.pre_body();
        if (!uvm_config_db#(alu_tb_config)::get(m_sequencer, "", "cfg", cfg)) begin
            `uvm_fatal("SEQ", "Configuration object not found")
        end
    endtask
    
    // Helper function to create specific instruction types
    function instruction_item create_arithmetic_instruction();
        instruction_item item = instruction_item::type_id::create("arith_instr");
        item.instr_type = item.INSTR_TYPE_ARITHMETIC;
        void'(item.randomize());
        return item;
    endfunction
    
    function instruction_item create_logic_instruction();
        instruction_item item = instruction_item::type_id::create("logic_instr");
        item.instr_type = item.INSTR_TYPE_LOGIC;
        void'(item.randomize());
        return item;
    endfunction
    
    function instruction_item create_shift_instruction();
        instruction_item item = instruction_item::type_id::create("shift_instr");
        item.instr_type = item.INSTR_TYPE_SHIFT;
        void'(item.randomize());
        return item;
    endfunction
    
    function instruction_item create_comparison_instruction();
        instruction_item item = instruction_item::type_id::create("comp_instr");
        item.instr_type = item.INSTR_TYPE_COMPARISON;
        void'(item.randomize());
        return item;
    endfunction

endclass : alu_instruction_sequence