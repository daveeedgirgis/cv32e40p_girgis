// =============================================================================
// ALU Sequence Item - Stage 1
//
// UVM sequence item for ALU operations - simplified for Stage 1 testing
// =============================================================================

class alu_sequence_item extends uvm_sequence_item;
    
    // UVM Factory registration
    `uvm_object_utils(alu_sequence_item)
    
    // Basic ALU operation fields
    rand alu_opcode_e   operation;
    rand logic [31:0]   operand_a;
    rand logic [31:0]   operand_b;
    
    // Expected result (calculated after randomization)
    logic [31:0]        expected_result;
    
    // Constraints for Stage 1 testing
    constraint operation_constraint {
        operation inside {ALU_ADD, ALU_SUB, ALU_AND, ALU_OR, ALU_XOR, ALU_SLL, ALU_SRL, ALU_SRA};
    }
    
    constraint operand_constraint {
        operand_a inside {[0:1000], 32'h0, 32'hFFFFFFFF, 32'h7FFFFFFF, 32'h80000000};
        operand_b inside {[0:31], 32'h0, 32'hFFFFFFFF, 32'h7FFFFFFF, 32'h80000000};
    }
    
    // Constructor
    function new(string name = "alu_sequence_item");
        super.new(name);
    endfunction
    
    // Post-randomize to calculate expected result
    function void post_randomize();
        calculate_expected_result();
    endfunction
    
    // Calculate expected result
    function void calculate_expected_result();
        case (operation)
            ALU_ADD:  expected_result = operand_a + operand_b;
            ALU_SUB:  expected_result = operand_a - operand_b;
            ALU_AND:  expected_result = operand_a & operand_b;
            ALU_OR:   expected_result = operand_a | operand_b;
            ALU_XOR:  expected_result = operand_a ^ operand_b;
            ALU_SLL:  expected_result = operand_a << operand_b[4:0];
            ALU_SRL:  expected_result = operand_a >> operand_b[4:0];
            ALU_SRA:  expected_result = $signed(operand_a) >>> operand_b[4:0];
            default:  expected_result = 32'hDEADBEEF;
        endcase
    endfunction
    
    // Convert to string
    function string convert2string();
        return $sformatf("ALU_SEQ_ITEM: %s(0x%08h, 0x%08h) = 0x%08h", 
                        operation.name(), operand_a, operand_b, expected_result);
    endfunction

endclass : alu_sequence_item