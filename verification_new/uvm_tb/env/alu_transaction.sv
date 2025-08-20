// =============================================================================
// ALU Transaction Class - Stage 1
//
// Base transaction class for ALU operations
// Contains all information about an ALU operation for monitoring and checking
// =============================================================================

class alu_transaction extends uvm_sequence_item;
    
    // UVM Factory registration
    `uvm_object_utils(alu_transaction)
    
    // ALU Operation Information
    alu_opcode_e        alu_operation;          // ALU operation code
    logic [31:0]        operand_a;              // First operand
    logic [31:0]        operand_b;              // Second operand
    logic [31:0]        operand_c;              // Third operand (for special ops)
    
    // ALU Control Signals
    logic [1:0]         vector_mode;            // Vector mode
    logic [4:0]         bmask_a;                // Bit mask A
    logic [4:0]         bmask_b;                // Bit mask B
    logic [1:0]         imm_vec_ext;            // Immediate vector extension
    logic               is_clpx;                // Complex operation
    logic               is_subrot;              // Sub-rotation
    logic [1:0]         clpx_shift;             // Complex shift
    
    // ALU Results
    logic [31:0]        alu_result;             // ALU computation result
    logic               comparison_result;      // Comparison result
    logic               ready;                  // ALU ready signal
    
    // Timing Information
    time                start_time;             // Operation start time
    time                end_time;               // Operation end time
    int                 cycle_count;            // Number of cycles taken
    
    // Instruction Context
    logic [31:0]        instruction;            // Associated instruction
    logic [31:0]        pc;                     // Program counter
    logic               valid;                  // Transaction valid
    
    // Expected Results (for checking)
    logic [31:0]        expected_result;        // Expected ALU result
    logic               expected_comparison;    // Expected comparison result
    
    // Status and Error Information
    bit                 completed;              // Operation completed
    bit                 has_error;              // Error detected
    string              error_message;          // Error description
    
    // Constructor
    function new(string name = "alu_transaction");
        super.new(name);
        
        // Initialize default values
        alu_operation = ALU_ADD;
        operand_a = 32'h0;
        operand_b = 32'h0;
        operand_c = 32'h0;
        vector_mode = VEC_MODE32;
        bmask_a = 5'h0;
        bmask_b = 5'h0;
        imm_vec_ext = 2'h0;
        is_clpx = 1'b0;
        is_subrot = 1'b0;
        clpx_shift = 2'h0;
        alu_result = 32'h0;
        comparison_result = 1'b0;
        ready = 1'b0;
        start_time = 0;
        end_time = 0;
        cycle_count = 0;
        instruction = 32'h0;
        pc = 32'h0;
        valid = 1'b0;
        expected_result = 32'h0;
        expected_comparison = 1'b0;
        completed = 1'b0;
        has_error = 1'b0;
        error_message = "";
    endfunction
    
    // Convert to string for debugging
    function string convert2string();
        string s;
        s = $sformatf("ALU Transaction:\n");
        s = {s, $sformatf("  Operation: %s\n", get_operation_name())};
        s = {s, $sformatf("  Operand A: 0x%08h (%0d)\n", operand_a, $signed(operand_a))};
        s = {s, $sformatf("  Operand B: 0x%08h (%0d)\n", operand_b, $signed(operand_b))};
        if (operand_c != 32'h0) begin
            s = {s, $sformatf("  Operand C: 0x%08h (%0d)\n", operand_c, $signed(operand_c))};
        end
        s = {s, $sformatf("  Result: 0x%08h (%0d)\n", alu_result, $signed(alu_result))};
        if (is_comparison_operation()) begin
            s = {s, $sformatf("  Comparison: %b\n", comparison_result)};
        end
        s = {s, $sformatf("  PC: 0x%08h\n", pc)};
        s = {s, $sformatf("  Cycles: %0d\n", cycle_count)};
        if (has_error) begin
            s = {s, $sformatf("  ERROR: %s\n", error_message)};
        end
        return s;
    endfunction
    
    // Get operation name string
    function string get_operation_name();
        case (alu_operation)
            ALU_ADD:    return "ADD";
            ALU_SUB:    return "SUB";
            ALU_ADDU:   return "ADDU";
            ALU_SUBU:   return "SUBU";
            ALU_XOR:    return "XOR";
            ALU_OR:     return "OR";
            ALU_AND:    return "AND";
            ALU_SRA:    return "SRA";
            ALU_SRL:    return "SRL";
            ALU_ROR:    return "ROR";
            ALU_SLL:    return "SLL";
            ALU_LTS:    return "LTS";
            ALU_LTU:    return "LTU";
            ALU_EQ:     return "EQ";
            ALU_NE:     return "NE";
            ALU_SLTS:   return "SLTS";
            ALU_SLTU:   return "SLTU";
            default:    return "UNKNOWN";
        endcase
    endfunction
    
    // Check if operation is arithmetic
    function bit is_arithmetic_operation();
        case (alu_operation)
            ALU_ADD, ALU_SUB, ALU_ADDU, ALU_SUBU: return 1'b1;
            default: return 1'b0;
        endcase
    endfunction
    
    // Check if operation is logical
    function bit is_logical_operation();
        case (alu_operation)
            ALU_AND, ALU_OR, ALU_XOR: return 1'b1;
            default: return 1'b0;
        endcase
    endfunction
    
    // Check if operation is shift
    function bit is_shift_operation();
        case (alu_operation)
            ALU_SLL, ALU_SRL, ALU_SRA, ALU_ROR: return 1'b1;
            default: return 1'b0;
        endcase
    endfunction
    
    // Check if operation is comparison
    function bit is_comparison_operation();
        case (alu_operation)
            ALU_LTS, ALU_LTU, ALU_EQ, ALU_NE, ALU_SLTS, ALU_SLTU: return 1'b1;
            default: return 1'b0;
        endcase
    endfunction
    
    // Calculate expected result
    function void calculate_expected_result();
        case (alu_operation)
            ALU_ADD:  expected_result = operand_a + operand_b;
            ALU_SUB:  expected_result = operand_a - operand_b;
            ALU_ADDU: expected_result = operand_a + operand_b;
            ALU_SUBU: expected_result = operand_a - operand_b;
            ALU_AND:  expected_result = operand_a & operand_b;
            ALU_OR:   expected_result = operand_a | operand_b;
            ALU_XOR:  expected_result = operand_a ^ operand_b;
            ALU_SLL:  expected_result = operand_a << operand_b[4:0];
            ALU_SRL:  expected_result = operand_a >> operand_b[4:0];
            ALU_SRA:  expected_result = $signed(operand_a) >>> operand_b[4:0];
            ALU_SLTS: expected_result = ($signed(operand_a) < $signed(operand_b)) ? 32'h1 : 32'h0;
            ALU_SLTU: expected_result = (operand_a < operand_b) ? 32'h1 : 32'h0;
            default:  expected_result = 32'hDEADBEEF;
        endcase
        
        // Calculate expected comparison result
        case (alu_operation)
            ALU_LTS:  expected_comparison = $signed(operand_a) < $signed(operand_b);
            ALU_LTU:  expected_comparison = operand_a < operand_b;
            ALU_EQ:   expected_comparison = operand_a == operand_b;
            ALU_NE:   expected_comparison = operand_a != operand_b;
            ALU_SLTS: expected_comparison = $signed(operand_a) < $signed(operand_b);
            ALU_SLTU: expected_comparison = operand_a < operand_b;
            default:  expected_comparison = 1'b0;
        endcase
    endfunction
    
    // Check if results match expected values
    function bit check_results();
        bit result_ok = 1;
        
        calculate_expected_result();
        
        // Check ALU result
        if (alu_result !== expected_result) begin
            has_error = 1;
            error_message = $sformatf("Result mismatch: got 0x%08h, expected 0x%08h", 
                                    alu_result, expected_result);
            result_ok = 0;
        end
        
        // Check comparison result for comparison operations
        if (is_comparison_operation() && (comparison_result !== expected_comparison)) begin
            has_error = 1;
            error_message = {error_message, $sformatf(" | Comparison mismatch: got %b, expected %b", 
                                                    comparison_result, expected_comparison)};
            result_ok = 0;
        end
        
        return result_ok;
    endfunction
    
    // Mark transaction as completed
    function void complete_transaction();
        completed = 1;
        end_time = $time;
        cycle_count = (end_time - start_time) / 10; // Assuming 10ns clock period
    endfunction
    
    // Copy function for UVM
    function void do_copy(uvm_object rhs);
        alu_transaction rhs_txn;
        if (!$cast(rhs_txn, rhs)) begin
            `uvm_fatal("ALU_TXN", "Cast failed in do_copy")
        end
        
        super.do_copy(rhs);
        
        alu_operation = rhs_txn.alu_operation;
        operand_a = rhs_txn.operand_a;
        operand_b = rhs_txn.operand_b;
        operand_c = rhs_txn.operand_c;
        vector_mode = rhs_txn.vector_mode;
        bmask_a = rhs_txn.bmask_a;
        bmask_b = rhs_txn.bmask_b;
        imm_vec_ext = rhs_txn.imm_vec_ext;
        is_clpx = rhs_txn.is_clpx;
        is_subrot = rhs_txn.is_subrot;
        clpx_shift = rhs_txn.clpx_shift;
        alu_result = rhs_txn.alu_result;
        comparison_result = rhs_txn.comparison_result;
        ready = rhs_txn.ready;
        start_time = rhs_txn.start_time;
        end_time = rhs_txn.end_time;
        cycle_count = rhs_txn.cycle_count;
        instruction = rhs_txn.instruction;
        pc = rhs_txn.pc;
        valid = rhs_txn.valid;
        expected_result = rhs_txn.expected_result;
        expected_comparison = rhs_txn.expected_comparison;
        completed = rhs_txn.completed;
        has_error = rhs_txn.has_error;
        error_message = rhs_txn.error_message;
    endfunction

endclass : alu_transaction