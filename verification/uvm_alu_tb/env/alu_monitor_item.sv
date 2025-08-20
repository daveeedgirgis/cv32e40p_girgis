// =============================================================================
// ALU Monitor Item
//
// UVM sequence item for capturing ALU operation details from the processor
// Used by the ALU monitor to record ALU activities for verification
// =============================================================================

class alu_monitor_item extends uvm_sequence_item;
    
    // UVM Factory registration
    `uvm_object_utils(alu_monitor_item)
    
    // ALU operation details
    alu_opcode_e    alu_operation;      // ALU operation performed
    bit [31:0]      operand_a;          // First operand
    bit [31:0]      operand_b;          // Second operand  
    bit [31:0]      operand_c;          // Third operand (for special operations)
    bit [31:0]      alu_result;         // ALU computation result
    bit             comparison_result;   // Comparison operation result
    
    // Control signals
    bit             alu_enable;         // ALU was enabled
    bit [1:0]       vector_mode;        // Vector operation mode
    bit [4:0]       bmask_a;            // Bit mask A
    bit [4:0]       bmask_b;            // Bit mask B
    bit [1:0]       imm_vec_ext;        // Immediate vector extension
    bit             is_clpx;            // Complex number operation
    bit             is_subrot;          // Subrotation operation
    bit [1:0]       clpx_shift;         // Complex shift amount
    
    // Pipeline information
    bit [31:0]      instruction;        // Original instruction
    bit [31:0]      pc;                 // Program counter
    bit             instruction_valid;   // Instruction is valid
    bit             pipeline_stall;     // Pipeline was stalled
    
    // Register writeback information
    bit             reg_write_enable;   // Register write enabled
    bit [5:0]       reg_write_addr;     // Register write address
    bit [31:0]      reg_write_data;     // Data written to register
    
    // Timing information
    time            start_time;         // When operation started
    time            end_time;           // When operation completed
    int             cycle_count;        // Number of cycles taken
    int             cycle_number;       // Absolute cycle number
    
    // Status flags
    bit             operation_valid;    // Operation is valid and should be checked
    bit             has_error;          // Error detected in operation
    string          error_message;      // Error description
    
    // Expected results (for comparison)
    bit [31:0]      expected_result;    // Expected ALU result
    bit             expected_comparison; // Expected comparison result
    bit             result_matches;     // Actual result matches expected
    
    // Constructor
    function new(string name = "alu_monitor_item");
        super.new(name);
        start_time = $time;
        cycle_count = 1;
        operation_valid = 0;
        has_error = 0;
        result_matches = 0;
        error_message = "";
    endfunction
    
    // Convert to string for debugging
    function string convert2string();
        string s;
        s = $sformatf("ALU Monitor Item:\n");
        s = {s, $sformatf("  Cycle: %0d\n", cycle_number)};
        s = {s, $sformatf("  PC: 0x%08h\n", pc)};
        s = {s, $sformatf("  Instruction: 0x%08h\n", instruction)};
        s = {s, $sformatf("  Operation: %s\n", get_operation_name())};
        s = {s, $sformatf("  Operand A: 0x%08h (%0d)\n", operand_a, $signed(operand_a))};
        s = {s, $sformatf("  Operand B: 0x%08h (%0d)\n", operand_b, $signed(operand_b))};
        s = {s, $sformatf("  Result: 0x%08h (%0d)\n", alu_result, $signed(alu_result))};
        s = {s, $sformatf("  Expected: 0x%08h (%0d)\n", expected_result, $signed(expected_result))};
        s = {s, $sformatf("  Match: %s\n", result_matches ? "PASS" : "FAIL")};
        if (is_comparison_operation()) begin
            s = {s, $sformatf("  Comparison: %b (expected: %b)\n", comparison_result, expected_comparison)};
        end
        if (reg_write_enable) begin
            s = {s, $sformatf("  Writeback: x%0d = 0x%08h\n", reg_write_addr, reg_write_data)};
        end
        if (has_error) begin
            s = {s, $sformatf("  ERROR: %s\n", error_message)};
        end
        return s;
    endfunction
    
    // Function to get operation name string
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
            ALU_LES:    return "LES";
            ALU_LEU:    return "LEU";
            ALU_GTS:    return "GTS";
            ALU_GTU:    return "GTU";
            ALU_GES:    return "GES";
            ALU_GEU:    return "GEU";
            ALU_EQ:     return "EQ";
            ALU_NE:     return "NE";
            ALU_SLTS:   return "SLTS";
            ALU_SLTU:   return "SLTU";
            ALU_SLETS:  return "SLETS";
            ALU_SLETU:  return "SLETU";
            ALU_ABS:    return "ABS";
            ALU_CLIP:   return "CLIP";
            ALU_CLIPU:  return "CLIPU";
            ALU_MIN:    return "MIN";
            ALU_MINU:   return "MINU";
            ALU_MAX:    return "MAX";
            ALU_MAXU:   return "MAXU";
            ALU_DIVU:   return "DIVU";
            ALU_DIV:    return "DIV";
            ALU_REMU:   return "REMU";
            ALU_REM:    return "REM";
            default:    return "UNKNOWN";
        endcase
    endfunction
    
    // Function to check if operation is a comparison
    function bit is_comparison_operation();
        return (alu_operation inside {ALU_LTS, ALU_LTU, ALU_LES, ALU_LEU, 
                                     ALU_GTS, ALU_GTU, ALU_GES, ALU_GEU,
                                     ALU_EQ, ALU_NE, ALU_SLTS, ALU_SLTU,
                                     ALU_SLETS, ALU_SLETU});
    endfunction
    
    // Function to check if operation is arithmetic
    function bit is_arithmetic_operation();
        return (alu_operation inside {ALU_ADD, ALU_SUB, ALU_ADDU, ALU_SUBU});
    endfunction
    
    // Function to check if operation is logical
    function bit is_logical_operation();
        return (alu_operation inside {ALU_AND, ALU_OR, ALU_XOR});
    endfunction
    
    // Function to check if operation is shift
    function bit is_shift_operation();
        return (alu_operation inside {ALU_SLL, ALU_SRL, ALU_SRA, ALU_ROR});
    endfunction
    
    // Function to calculate expected result
    function void calculate_expected_result();
        case (alu_operation)
            ALU_ADD:    expected_result = operand_a + operand_b;
            ALU_SUB:    expected_result = operand_a - operand_b;
            ALU_ADDU:   expected_result = operand_a + operand_b;
            ALU_SUBU:   expected_result = operand_a - operand_b;
            ALU_AND:    expected_result = operand_a & operand_b;
            ALU_OR:     expected_result = operand_a | operand_b;
            ALU_XOR:    expected_result = operand_a ^ operand_b;
            ALU_SLL:    expected_result = operand_a << operand_b[4:0];
            ALU_SRL:    expected_result = operand_a >> operand_b[4:0];
            ALU_SRA:    expected_result = $signed(operand_a) >>> operand_b[4:0];
            ALU_LTS: begin
                expected_result = ($signed(operand_a) < $signed(operand_b)) ? 1 : 0;
                expected_comparison = expected_result[0];
            end
            ALU_LTU: begin
                expected_result = (operand_a < operand_b) ? 1 : 0;
                expected_comparison = expected_result[0];
            end
            ALU_GTS: begin
                expected_result = ($signed(operand_a) > $signed(operand_b)) ? 1 : 0;
                expected_comparison = expected_result[0];
            end
            ALU_GTU: begin
                expected_result = (operand_a > operand_b) ? 1 : 0;
                expected_comparison = expected_result[0];
            end
            ALU_EQ: begin
                expected_result = (operand_a == operand_b) ? 1 : 0;
                expected_comparison = expected_result[0];
            end
            ALU_NE: begin
                expected_result = (operand_a != operand_b) ? 1 : 0;
                expected_comparison = expected_result[0];
            end
            ALU_SLTS:   expected_result = ($signed(operand_a) < $signed(operand_b)) ? 1 : 0;
            ALU_SLTU:   expected_result = (operand_a < operand_b) ? 1 : 0;
            default:    expected_result = 32'hDEADBEEF; // Unknown operation
        endcase
    endfunction
    
    // Function to check if result matches expected
    function void check_result();
        calculate_expected_result();
        result_matches = (alu_result == expected_result);
        
        if (is_comparison_operation()) begin
            result_matches = result_matches && (comparison_result == expected_comparison);
        end
        
        if (!result_matches) begin
            has_error = 1;
            error_message = $sformatf("Result mismatch: got 0x%08h, expected 0x%08h", 
                                    alu_result, expected_result);
        end
    endfunction
    
    // Function to mark operation as complete
    function void complete_operation();
        end_time = $time;
        check_result();
        operation_valid = 1;
    endfunction

endclass : alu_monitor_item