// =============================================================================
// Instruction Sequence Item
//
// UVM sequence item representing a RISC-V instruction to be executed
// Contains instruction encoding and metadata for ALU-focused testing
// =============================================================================

class instruction_item extends uvm_sequence_item;
    
    // UVM Factory registration
    `uvm_object_utils(instruction_item)
    
    // Instruction fields
    rand bit [31:0] instruction;        // 32-bit instruction encoding
    rand bit [31:0] pc;                 // Program counter value
    rand bit [31:0] operand_a;          // Source operand A value
    rand bit [31:0] operand_b;          // Source operand B value
    rand bit [31:0] operand_c;          // Source operand C value (for special ops)
    
    // Instruction type information
    rand instruction_type_e instr_type; // Type of instruction
    rand alu_opcode_e expected_alu_op;  // Expected ALU operation
    
    // Expected results for checking
    bit [31:0] expected_result;         // Expected computation result
    bit        expected_comparison;     // Expected comparison result
    
    // Control flags
    bit is_alu_instruction;             // True if instruction uses ALU
    bit requires_writeback;             // True if result should be written to register
    bit [4:0] dest_register;            // Destination register address
    
    // Timing information
    time timestamp;                     // When instruction was created
    int cycle_count;                    // Expected execution cycles
    
    // Instruction type enumeration
    typedef enum {
        INSTR_TYPE_ARITHMETIC,    // ADD, SUB, ADDI, etc.
        INSTR_TYPE_LOGIC,         // AND, OR, XOR, ANDI, etc.
        INSTR_TYPE_SHIFT,         // SLL, SRL, SRA, etc.
        INSTR_TYPE_COMPARISON,    // SLT, SLTU, etc.
        INSTR_TYPE_LOAD,          // LW, LH, LB, etc.
        INSTR_TYPE_STORE,         // SW, SH, SB, etc.
        INSTR_TYPE_BRANCH,        // BEQ, BNE, BLT, etc.
        INSTR_TYPE_JUMP,          // JAL, JALR
        INSTR_TYPE_UPPER,         // LUI, AUIPC
        INSTR_TYPE_SYSTEM,        // ECALL, EBREAK, CSR
        INSTR_TYPE_NOP            // No operation
    } instruction_type_e;
    
    // Constraints for meaningful instruction generation
    constraint operand_values {
        // Reasonable operand value ranges
        operand_a inside {[0:1000], [32'hFFFFF000:32'hFFFFFFFF]};
        operand_b inside {[0:1000], [1:32], [32'hFFFFF000:32'hFFFFFFFF]};
        
        // For shift operations, limit shift amount
        if (instr_type == INSTR_TYPE_SHIFT) {
            operand_b inside {[0:31]};
        }
        
        // PC should be aligned
        pc[1:0] == 2'b00;
    }
    
    constraint instruction_type_dist {
        // Distribution for instruction types (favor ALU operations)
        instr_type dist {
            INSTR_TYPE_ARITHMETIC := 30,
            INSTR_TYPE_LOGIC      := 20,
            INSTR_TYPE_SHIFT      := 15,
            INSTR_TYPE_COMPARISON := 20,
            INSTR_TYPE_LOAD       := 5,
            INSTR_TYPE_STORE      := 5,
            INSTR_TYPE_BRANCH     := 3,
            INSTR_TYPE_JUMP       := 1,
            INSTR_TYPE_UPPER      := 1
        };
    }
    
    // Constructor
    function new(string name = "instruction_item");
        super.new(name);
        timestamp = $time;
        cycle_count = 1;  // Default single cycle
        is_alu_instruction = 0;
        requires_writeback = 0;
    endfunction
    
    // Convert to string for debugging
    function string convert2string();
        string s;
        s = $sformatf("Instruction Item:\n");
        s = {s, $sformatf("  PC: 0x%08h\n", pc)};
        s = {s, $sformatf("  Instruction: 0x%08h\n", instruction)};
        s = {s, $sformatf("  Type: %s\n", instr_type.name())};
        s = {s, $sformatf("  Operand A: 0x%08h (%0d)\n", operand_a, $signed(operand_a))};
        s = {s, $sformatf("  Operand B: 0x%08h (%0d)\n", operand_b, $signed(operand_b))};
        if (is_alu_instruction) begin
            s = {s, $sformatf("  ALU Op: %s\n", expected_alu_op.name())};
            s = {s, $sformatf("  Expected Result: 0x%08h (%0d)\n", expected_result, $signed(expected_result))};
        end
        if (requires_writeback) begin
            s = {s, $sformatf("  Dest Register: x%0d\n", dest_register)};
        end
        return s;
    endfunction
    
    // Function to encode R-type instruction (register-register operations)
    function void encode_r_type(bit [6:0] opcode, bit [4:0] rd, bit [2:0] funct3, 
                                bit [4:0] rs1, bit [4:0] rs2, bit [6:0] funct7);
        instruction = {funct7, rs2, rs1, funct3, rd, opcode};
        requires_writeback = (rd != 0);
        dest_register = rd;
        is_alu_instruction = 1;
    endfunction
    
    // Function to encode I-type instruction (immediate operations)
    function void encode_i_type(bit [6:0] opcode, bit [4:0] rd, bit [2:0] funct3,
                                bit [4:0] rs1, bit [11:0] imm);
        instruction = {imm, rs1, funct3, rd, opcode};
        requires_writeback = (rd != 0);
        dest_register = rd;
        is_alu_instruction = 1;
        operand_b = {{20{imm[11]}}, imm}; // Sign-extend immediate
    endfunction
    
    // Function to generate ADD instruction
    function void generate_add_instruction();
        encode_r_type(7'b0110011, $urandom_range(31), 3'b000, 
                     $urandom_range(31), $urandom_range(31), 7'b0000000);
        instr_type = INSTR_TYPE_ARITHMETIC;
        expected_alu_op = ALU_ADD;
        expected_result = operand_a + operand_b;
    endfunction
    
    // Function to generate SUB instruction
    function void generate_sub_instruction();
        encode_r_type(7'b0110011, $urandom_range(31), 3'b000,
                     $urandom_range(31), $urandom_range(31), 7'b0100000);
        instr_type = INSTR_TYPE_ARITHMETIC;
        expected_alu_op = ALU_SUB;
        expected_result = operand_a - operand_b;
    endfunction
    
    // Function to generate AND instruction
    function void generate_and_instruction();
        encode_r_type(7'b0110011, $urandom_range(31), 3'b111,
                     $urandom_range(31), $urandom_range(31), 7'b0000000);
        instr_type = INSTR_TYPE_LOGIC;
        expected_alu_op = ALU_AND;
        expected_result = operand_a & operand_b;
    endfunction
    
    // Function to generate OR instruction
    function void generate_or_instruction();
        encode_r_type(7'b0110011, $urandom_range(31), 3'b110,
                     $urandom_range(31), $urandom_range(31), 7'b0000000);
        instr_type = INSTR_TYPE_LOGIC;
        expected_alu_op = ALU_OR;
        expected_result = operand_a | operand_b;
    endfunction
    
    // Function to generate XOR instruction
    function void generate_xor_instruction();
        encode_r_type(7'b0110011, $urandom_range(31), 3'b100,
                     $urandom_range(31), $urandom_range(31), 7'b0000000);
        instr_type = INSTR_TYPE_LOGIC;
        expected_alu_op = ALU_XOR;
        expected_result = operand_a ^ operand_b;
    endfunction
    
    // Function to generate SLL instruction
    function void generate_sll_instruction();
        encode_r_type(7'b0110011, $urandom_range(31), 3'b001,
                     $urandom_range(31), $urandom_range(31), 7'b0000000);
        instr_type = INSTR_TYPE_SHIFT;
        expected_alu_op = ALU_SLL;
        expected_result = operand_a << operand_b[4:0];
    endfunction
    
    // Function to generate SRL instruction
    function void generate_srl_instruction();
        encode_r_type(7'b0110011, $urandom_range(31), 3'b101,
                     $urandom_range(31), $urandom_range(31), 7'b0000000);
        instr_type = INSTR_TYPE_SHIFT;
        expected_alu_op = ALU_SRL;
        expected_result = operand_a >> operand_b[4:0];
    endfunction
    
    // Function to generate SRA instruction
    function void generate_sra_instruction();
        encode_r_type(7'b0110011, $urandom_range(31), 3'b101,
                     $urandom_range(31), $urandom_range(31), 7'b0100000);
        instr_type = INSTR_TYPE_SHIFT;
        expected_alu_op = ALU_SRA;
        expected_result = $signed(operand_a) >>> operand_b[4:0];
    endfunction
    
    // Function to generate SLT instruction
    function void generate_slt_instruction();
        encode_r_type(7'b0110011, $urandom_range(31), 3'b010,
                     $urandom_range(31), $urandom_range(31), 7'b0000000);
        instr_type = INSTR_TYPE_COMPARISON;
        expected_alu_op = ALU_SLTS;
        expected_result = ($signed(operand_a) < $signed(operand_b)) ? 1 : 0;
    endfunction
    
    // Function to generate SLTU instruction
    function void generate_sltu_instruction();
        encode_r_type(7'b0110011, $urandom_range(31), 3'b011,
                     $urandom_range(31), $urandom_range(31), 7'b0000000);
        instr_type = INSTR_TYPE_COMPARISON;
        expected_alu_op = ALU_SLTU;
        expected_result = (operand_a < operand_b) ? 1 : 0;
    endfunction
    
    // Function to automatically generate instruction based on type
    function void generate_instruction_by_type();
        case (instr_type)
            INSTR_TYPE_ARITHMETIC: begin
                case ($urandom_range(1))
                    0: generate_add_instruction();
                    1: generate_sub_instruction();
                endcase
            end
            INSTR_TYPE_LOGIC: begin
                case ($urandom_range(2))
                    0: generate_and_instruction();
                    1: generate_or_instruction();
                    2: generate_xor_instruction();
                endcase
            end
            INSTR_TYPE_SHIFT: begin
                case ($urandom_range(2))
                    0: generate_sll_instruction();
                    1: generate_srl_instruction();
                    2: generate_sra_instruction();
                endcase
            end
            INSTR_TYPE_COMPARISON: begin
                case ($urandom_range(1))
                    0: generate_slt_instruction();
                    1: generate_sltu_instruction();
                endcase
            end
            default: begin
                // Default to ADD for unsupported types
                generate_add_instruction();
            end
        endcase
    endfunction
    
    // Post-randomize function to generate instruction encoding
    function void post_randomize();
        generate_instruction_by_type();
    endfunction

endclass : instruction_item