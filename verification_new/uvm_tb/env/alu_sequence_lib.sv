// =============================================================================
// ALU Sequence Library - Stage 1
//
// Basic UVM sequences for ALU testing - simplified for Stage 1
// =============================================================================

// Base sequence class
class alu_base_sequence extends uvm_sequence #(alu_sequence_item);
    
    `uvm_object_utils(alu_base_sequence)
    
    // Number of transactions to generate
    int num_transactions = 10;
    
    function new(string name = "alu_base_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        `uvm_info("ALU_SEQ", $sformatf("Starting sequence with %0d transactions", num_transactions), UVM_LOW)
        
        for (int i = 0; i < num_transactions; i++) begin
            alu_sequence_item item;
            
            item = alu_sequence_item::type_id::create("item");
            start_item(item);
            if (!item.randomize()) begin
                `uvm_error("ALU_SEQ", "Randomization failed")
            end
            finish_item(item);
            
            `uvm_info("ALU_SEQ", $sformatf("Generated: %s", item.convert2string()), UVM_HIGH)
        end
        
        `uvm_info("ALU_SEQ", "Sequence completed", UVM_LOW)
    endtask

endclass : alu_base_sequence

// Arithmetic-focused sequence
class alu_arithmetic_sequence extends alu_base_sequence;
    
    `uvm_object_utils(alu_arithmetic_sequence)
    
    function new(string name = "alu_arithmetic_sequence");
        super.new(name);
        num_transactions = 20;
    endfunction
    
    virtual task body();
        `uvm_info("ALU_SEQ", "Starting arithmetic sequence", UVM_LOW)
        
        for (int i = 0; i < num_transactions; i++) begin
            alu_sequence_item item;
            
            item = alu_sequence_item::type_id::create("item");
            start_item(item);
            if (!item.randomize() with {
                operation inside {ALU_ADD, ALU_SUB};
            }) begin
                `uvm_error("ALU_SEQ", "Arithmetic randomization failed")
            end
            finish_item(item);
            
            `uvm_info("ALU_SEQ", $sformatf("Arithmetic: %s", item.convert2string()), UVM_HIGH)
        end
        
        `uvm_info("ALU_SEQ", "Arithmetic sequence completed", UVM_LOW)
    endtask

endclass : alu_arithmetic_sequence