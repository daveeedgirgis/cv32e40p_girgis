// =============================================================================
// ALU Monitor Interface
//
// Interface to monitor ALU signals within the CV32E40P processor
// Used for verification of ALU operations and results
// =============================================================================

import cv32e40p_pkg::*;

interface alu_monitor_if (
    input logic clk,
    input logic rst_n
);

    // ALU input signals (monitored from processor internals)
    logic               alu_enable;
    alu_opcode_e        alu_operator;
    logic [31:0]        alu_operand_a;
    logic [31:0]        alu_operand_b;
    logic [31:0]        alu_operand_c;
    
    // ALU control signals
    logic [1:0]         vector_mode;
    logic [4:0]         bmask_a;
    logic [4:0]         bmask_b;
    logic [1:0]         imm_vec_ext;
    logic               is_clpx;
    logic               is_subrot;
    logic [1:0]         clpx_shift;
    
    // ALU output signals
    logic [31:0]        alu_result;
    logic               comparison_result;
    logic               alu_ready;
    logic               ex_ready;
    
    // Pipeline control signals
    logic               id_valid;
    logic               ex_valid;
    logic               ex_ready_internal;
    
    // Instruction information for correlation
    logic [31:0]        instruction;
    logic [31:0]        pc;
    logic               instr_valid;
    
    // Register file write signals for result checking
    logic               regfile_we;
    logic [5:0]         regfile_waddr;
    logic [31:0]        regfile_wdata;
    
    // Modport for monitor component
    modport monitor (
        input clk, rst_n,
        input alu_enable, alu_operator, alu_operand_a, alu_operand_b, alu_operand_c,
        input vector_mode, bmask_a, bmask_b, imm_vec_ext, is_clpx, is_subrot, clpx_shift,
        input alu_result, comparison_result, alu_ready, ex_ready,
        input id_valid, ex_valid, ex_ready_internal,
        input instruction, pc, instr_valid,
        input regfile_we, regfile_waddr, regfile_wdata
    );
    
    // Modport for testbench connections
    modport tb (
        input clk, rst_n,
        output alu_enable, alu_operator, alu_operand_a, alu_operand_b, alu_operand_c,
        output vector_mode, bmask_a, bmask_b, imm_vec_ext, is_clpx, is_subrot, clpx_shift,
        output alu_result, comparison_result, alu_ready, ex_ready,
        output id_valid, ex_valid, ex_ready_internal,
        output instruction, pc, instr_valid,
        output regfile_we, regfile_waddr, regfile_wdata
    );
    
    // Helper function to decode ALU operation name for debugging
    function string get_alu_op_name();
        case (alu_operator)
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
    
    // Helper function to check if current operation is an ALU operation
    function bit is_alu_operation();
        return alu_enable && id_valid;
    endfunction

endinterface : alu_monitor_if