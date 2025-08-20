// =============================================================================
// ALU Monitor Interface - Stage 1
//
// SystemVerilog interface for monitoring ALU signals within the CV32E40P processor
// Based on actual CV32E40P RTL hierarchy and signal names from cv32e40p_ex_stage.sv
// Used for verification of ALU operations and results
// =============================================================================

import cv32e40p_pkg::*;

interface alu_monitor_if (
    input logic clk,
    input logic rst_n
);

    // ALU input signals (from ID stage to EX stage)
    logic               alu_en;                 // ALU enable signal
    alu_opcode_e        alu_operator;           // ALU operation code
    logic [31:0]        alu_operand_a;          // ALU operand A
    logic [31:0]        alu_operand_b;          // ALU operand B  
    logic [31:0]        alu_operand_c;          // ALU operand C (for special operations)
    
    // ALU control signals
    logic [1:0]         alu_vec_mode;           // Vector mode (VEC_MODE32, VEC_MODE16, VEC_MODE8)
    logic [4:0]         bmask_a;                // Bit mask A
    logic [4:0]         bmask_b;                // Bit mask B
    logic [1:0]         imm_vec_ext;            // Immediate vector extension
    logic               alu_is_clpx;            // Complex number operation
    logic               alu_is_subrot;          // Sub-rotation operation
    logic [1:0]         alu_clpx_shift;         // Complex shift amount
    
    // ALU output signals
    logic [31:0]        alu_result;             // ALU computation result
    logic               alu_cmp_result;         // ALU comparison result
    logic               alu_ready;              // ALU ready signal
    
    // Pipeline control signals for timing correlation
    logic               id_valid;               // ID stage valid
    logic               ex_valid;               // EX stage valid
    logic               ex_ready;               // EX stage ready
    
    // Instruction information for correlation
    logic [31:0]        instruction;            // Current instruction
    logic [31:0]        pc_id;                  // Program counter in ID stage
    logic               instr_valid;            // Instruction valid
    
    // Register file write signals for result checking
    logic               regfile_we_wb;          // Register file write enable (WB stage)
    logic [5:0]         regfile_waddr_wb;       // Register file write address (WB stage)
    logic [31:0]        regfile_wdata_wb;       // Register file write data (WB stage)
    
    // Modport for monitor component
    modport monitor (
        input clk, rst_n,
        input alu_en, alu_operator, alu_operand_a, alu_operand_b, alu_operand_c,
        input alu_vec_mode, bmask_a, bmask_b, imm_vec_ext, alu_is_clpx, alu_is_subrot, alu_clpx_shift,
        input alu_result, alu_cmp_result, alu_ready,
        input id_valid, ex_valid, ex_ready,
        input instruction, pc_id, instr_valid,
        input regfile_we_wb, regfile_waddr_wb, regfile_wdata_wb
    );
    
    // Modport for testbench connections (drives signals from DUT internals)
    modport tb (
        input clk, rst_n,
        output alu_en, alu_operator, alu_operand_a, alu_operand_b, alu_operand_c,
        output alu_vec_mode, bmask_a, bmask_b, imm_vec_ext, alu_is_clpx, alu_is_subrot, alu_clpx_shift,
        output alu_result, alu_cmp_result, alu_ready,
        output id_valid, ex_valid, ex_ready,
        output instruction, pc_id, instr_valid,
        output regfile_we_wb, regfile_waddr_wb, regfile_wdata_wb
    );
    
    // Helper function to decode ALU operation name for debugging
    function string get_alu_op_name();
        case (alu_operator)
            ALU_ADD:    return "ADD";
            ALU_SUB:    return "SUB";
            ALU_ADDU:   return "ADDU";
            ALU_SUBU:   return "SUBU";
            ALU_ADDR:   return "ADDR";
            ALU_SUBR:   return "SUBR";
            ALU_ADDUR:  return "ADDUR";
            ALU_SUBUR:  return "SUBUR";
            ALU_XOR:    return "XOR";
            ALU_OR:     return "OR";
            ALU_AND:    return "AND";
            ALU_SRA:    return "SRA";
            ALU_SRL:    return "SRL";
            ALU_ROR:    return "ROR";
            ALU_SLL:    return "SLL";
            ALU_BEXT:   return "BEXT";
            ALU_BEXTU:  return "BEXTU";
            ALU_BINS:   return "BINS";
            ALU_BCLR:   return "BCLR";
            ALU_BSET:   return "BSET";
            ALU_BREV:   return "BREV";
            ALU_FF1:    return "FF1";
            ALU_FL1:    return "FL1";
            ALU_CNT:    return "CNT";
            ALU_CLB:    return "CLB";
            ALU_EXTS:   return "EXTS";
            ALU_EXT:    return "EXT";
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
            ALU_INS:    return "INS";
            ALU_MIN:    return "MIN";
            ALU_MINU:   return "MINU";
            ALU_MAX:    return "MAX";
            ALU_MAXU:   return "MAXU";
            ALU_DIVU:   return "DIVU";
            ALU_DIV:    return "DIV";
            ALU_REMU:   return "REMU";
            ALU_REM:    return "REM";
            ALU_SHUF:   return "SHUF";
            ALU_SHUF2:  return "SHUF2";
            ALU_PCKLO:  return "PCKLO";
            ALU_PCKHI:  return "PCKHI";
            default:    return "UNKNOWN";
        endcase
    endfunction
    
    // Helper function to check if current operation is an ALU operation
    function bit is_alu_operation();
        return alu_en && id_valid;
    endfunction
    
    // Helper function to check if operation is arithmetic
    function bit is_arithmetic_operation();
        case (alu_operator)
            ALU_ADD, ALU_SUB, ALU_ADDU, ALU_SUBU, 
            ALU_ADDR, ALU_SUBR, ALU_ADDUR, ALU_SUBUR: return 1'b1;
            default: return 1'b0;
        endcase
    endfunction
    
    // Helper function to check if operation is logical
    function bit is_logical_operation();
        case (alu_operator)
            ALU_AND, ALU_OR, ALU_XOR: return 1'b1;
            default: return 1'b0;
        endcase
    endfunction
    
    // Helper function to check if operation is shift
    function bit is_shift_operation();
        case (alu_operator)
            ALU_SLL, ALU_SRL, ALU_SRA, ALU_ROR: return 1'b1;
            default: return 1'b0;
        endcase
    endfunction
    
    // Helper function to check if operation is comparison
    function bit is_comparison_operation();
        case (alu_operator)
            ALU_LTS, ALU_LTU, ALU_LES, ALU_LEU,
            ALU_GTS, ALU_GTU, ALU_GES, ALU_GEU,
            ALU_EQ, ALU_NE, ALU_SLTS, ALU_SLTU,
            ALU_SLETS, ALU_SLETU: return 1'b1;
            default: return 1'b0;
        endcase
    endfunction
    
    // Helper function to get vector mode name
    function string get_vector_mode_name();
        case (alu_vec_mode)
            VEC_MODE32: return "VEC32";
            VEC_MODE16: return "VEC16";
            VEC_MODE8:  return "VEC8";
            default:    return "UNKNOWN";
        endcase
    endfunction
    
    // Helper function to format ALU operation for logging
    function string format_alu_operation();
        string s;
        s = $sformatf("ALU Op: %s", get_alu_op_name());
        s = {s, $sformatf(" | A=0x%08h(%0d)", alu_operand_a, $signed(alu_operand_a))};
        s = {s, $sformatf(" | B=0x%08h(%0d)", alu_operand_b, $signed(alu_operand_b))};
        if (alu_operand_c != 32'h0) begin
            s = {s, $sformatf(" | C=0x%08h(%0d)", alu_operand_c, $signed(alu_operand_c))};
        end
        s = {s, $sformatf(" | Result=0x%08h(%0d)", alu_result, $signed(alu_result))};
        if (is_comparison_operation()) begin
            s = {s, $sformatf(" | Cmp=%b", alu_cmp_result)};
        end
        s = {s, $sformatf(" | PC=0x%08h", pc_id)};
        return s;
    endfunction
    
    // Function to calculate expected result for basic operations (for checking)
    function logic [31:0] calculate_expected_result();
        case (alu_operator)
            ALU_ADD:  return alu_operand_a + alu_operand_b;
            ALU_SUB:  return alu_operand_a - alu_operand_b;
            ALU_ADDU: return alu_operand_a + alu_operand_b;  // Same as ADD for 32-bit
            ALU_SUBU: return alu_operand_a - alu_operand_b;  // Same as SUB for 32-bit
            ALU_AND:  return alu_operand_a & alu_operand_b;
            ALU_OR:   return alu_operand_a | alu_operand_b;
            ALU_XOR:  return alu_operand_a ^ alu_operand_b;
            ALU_SLL:  return alu_operand_a << alu_operand_b[4:0];
            ALU_SRL:  return alu_operand_a >> alu_operand_b[4:0];
            ALU_SRA:  return $signed(alu_operand_a) >>> alu_operand_b[4:0];
            ALU_SLTS: return ($signed(alu_operand_a) < $signed(alu_operand_b)) ? 32'h1 : 32'h0;
            ALU_SLTU: return (alu_operand_a < alu_operand_b) ? 32'h1 : 32'h0;
            default:  return 32'hDEADBEEF;  // Indicate unsupported operation
        endcase
    endfunction
    
    // Function to calculate expected comparison result
    function logic calculate_expected_comparison();
        case (alu_operator)
            ALU_LTS:   return $signed(alu_operand_a) < $signed(alu_operand_b);
            ALU_LTU:   return alu_operand_a < alu_operand_b;
            ALU_LES:   return $signed(alu_operand_a) <= $signed(alu_operand_b);
            ALU_LEU:   return alu_operand_a <= alu_operand_b;
            ALU_GTS:   return $signed(alu_operand_a) > $signed(alu_operand_b);
            ALU_GTU:   return alu_operand_a > alu_operand_b;
            ALU_GES:   return $signed(alu_operand_a) >= $signed(alu_operand_b);
            ALU_GEU:   return alu_operand_a >= alu_operand_b;
            ALU_EQ:    return alu_operand_a == alu_operand_b;
            ALU_NE:    return alu_operand_a != alu_operand_b;
            ALU_SLTS:  return $signed(alu_operand_a) < $signed(alu_operand_b);
            ALU_SLTU:  return alu_operand_a < alu_operand_b;
            ALU_SLETS: return $signed(alu_operand_a) <= $signed(alu_operand_b);
            ALU_SLETU: return alu_operand_a <= alu_operand_b;
            default:   return 1'b0;
        endcase
    endfunction
    
    // Assertion to check ALU enable and valid correlation
    property alu_enable_valid_correlation;
        @(posedge clk) disable iff (!rst_n)
        alu_en |-> id_valid;
    endproperty
    
    // Assertion to check ALU ready behavior
    property alu_ready_behavior;
        @(posedge clk) disable iff (!rst_n)
        alu_en && id_valid |-> ##[1:$] alu_ready;
    endproperty
    
    // Enable assertions if configured
    `ifdef ENABLE_ASSERTIONS
        assert_alu_enable_valid: assert property (alu_enable_valid_correlation)
            else $error("ALU enable without valid ID stage");
            
        assert_alu_ready: assert property (alu_ready_behavior)
            else $error("ALU operation did not complete");
    `endif

endinterface : alu_monitor_if