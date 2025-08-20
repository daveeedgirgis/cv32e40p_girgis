// =============================================================================
// ALU Sequence Item - Stage 2 Enhanced
//
// Advanced UVM sequence item for comprehensive ALU verification
// Supports all RV32I ALU operations with sophisticated constraint strategies
// =============================================================================

// Enumeration for data pattern types
typedef enum {
    PATTERN_RANDOM,
    PATTERN_BOUNDARY,
    PATTERN_WALKING_ONES,
    PATTERN_WALKING_ZEROS,
    PATTERN_ALTERNATING,
    PATTERN_SMALL_VALUES,
    PATTERN_LARGE_VALUES,
    PATTERN_POWERS_OF_TWO
} data_pattern_e;

// Enumeration for test scenarios
typedef enum {
    SCENARIO_BASIC,
    SCENARIO_CORNER_CASE,
    SCENARIO_PERFORMANCE,
    SCENARIO_STRESS,
    SCENARIO_REALISTIC
} test_scenario_e;

class alu_sequence_item extends uvm_sequence_item;
    
    // UVM Factory registration with field automation
    `uvm_object_utils_begin(alu_sequence_item)
        `uvm_field_enum(alu_opcode_e, operation, UVM_ALL_ON)
        `uvm_field_int(operand_a, UVM_ALL_ON)
        `uvm_field_int(operand_b, UVM_ALL_ON)
        `uvm_field_enum(data_pattern_e, data_pattern, UVM_ALL_ON)
        `uvm_field_enum(test_scenario_e, scenario, UVM_ALL_ON)
        `uvm_field_int(expected_result, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_object_utils_end
    
    // Core ALU operation fields
    rand alu_opcode_e   operation;
    rand logic [31:0]   operand_a;
    rand logic [31:0]   operand_b;
    
    // Stage 2 enhancements
    rand data_pattern_e data_pattern;
    rand test_scenario_e scenario;
    rand bit            enable_overflow_test;
    rand bit            enable_underflow_test;
    rand bit [4:0]      shift_amount;  // For shift operations
    
    // Results and metadata
    logic [31:0]        expected_result;
    logic               expected_overflow;
    logic               expected_underflow;
    logic               expected_zero;
    logic               expected_negative;
    
    // Stage 2 Advanced Constraints
    
    // Realistic operation distribution (based on embedded software analysis)
    constraint operation_distribution_c {
        operation dist {
            ALU_ADD    := 25,  // Most common arithmetic
            ALU_SUB    := 20,  // Second most common
            ALU_AND    := 12,  // Bit manipulation
            ALU_OR     := 12,  // Bit manipulation
            ALU_XOR    := 8,   // Less common but important
            ALU_SLL    := 8,   // Shift operations
            ALU_SRL    := 8,   // Shift operations
            ALU_SRA    := 4,   // Arithmetic shift less common
            ALU_SLTS   := 2,   // Comparison operations
            ALU_SLTU   := 1    // Unsigned comparison
        };
    }
    
    // Data pattern-driven constraints
    constraint data_pattern_c {
        data_pattern dist {
            PATTERN_RANDOM        := 40,
            PATTERN_BOUNDARY      := 20,
            PATTERN_SMALL_VALUES  := 15,
            PATTERN_WALKING_ONES  := 10,
            PATTERN_WALKING_ZEROS := 5,
            PATTERN_ALTERNATING   := 5,
            PATTERN_LARGE_VALUES  := 3,
            PATTERN_POWERS_OF_TWO := 2
        };
    }
    
    // Scenario-based constraint selection
    constraint scenario_c {
        scenario dist {
            SCENARIO_REALISTIC   := 50,
            SCENARIO_BASIC       := 20,
            SCENARIO_CORNER_CASE := 15,
            SCENARIO_PERFORMANCE := 10,
            SCENARIO_STRESS      := 5
        };
    }
    
    // Smart operand constraints based on data pattern
    constraint operand_pattern_c {
        if (data_pattern == PATTERN_BOUNDARY) {
            operand_a inside {32'h00000000, 32'h00000001, 32'h7FFFFFFF, 32'h80000000, 32'hFFFFFFFF};
            operand_b inside {32'h00000000, 32'h00000001, 32'h7FFFFFFF, 32'h80000000, 32'hFFFFFFFF};
        }
        else if (data_pattern == PATTERN_SMALL_VALUES) {
            operand_a inside {[0:1000]};
            operand_b inside {[0:100]};
        }
        else if (data_pattern == PATTERN_LARGE_VALUES) {
            operand_a inside {[32'h7FFFF000:32'hFFFFFFFF]};
            operand_b inside {[32'h7FFFF000:32'hFFFFFFFF]};
        }
        else if (data_pattern == PATTERN_POWERS_OF_TWO) {
            operand_a inside {32'h1, 32'h2, 32'h4, 32'h8, 32'h10, 32'h20, 32'h40, 32'h80,
                             32'h100, 32'h200, 32'h400, 32'h800, 32'h1000, 32'h2000, 32'h4000, 32'h8000,
                             32'h10000, 32'h20000, 32'h40000, 32'h80000, 32'h100000, 32'h200000,
                             32'h400000, 32'h800000, 32'h1000000, 32'h2000000, 32'h4000000, 32'h8000000,
                             32'h10000000, 32'h20000000, 32'h40000000, 32'h80000000};
            operand_b inside {32'h1, 32'h2, 32'h4, 32'h8, 32'h10, 32'h20, 32'h40, 32'h80,
                             32'h100, 32'h200, 32'h400, 32'h800, 32'h1000, 32'h2000, 32'h4000, 32'h8000,
                             32'h10000, 32'h20000, 32'h40000, 32'h80000, 32'h100000, 32'h200000,
                             32'h400000, 32'h800000, 32'h1000000, 32'h2000000, 32'h4000000, 32'h8000000,
                             32'h10000000, 32'h20000000, 32'h40000000, 32'h80000000};
        }
        else if (data_pattern == PATTERN_ALTERNATING) {
            operand_a inside {32'hAAAAAAAA, 32'h55555555};
            operand_b inside {32'hAAAAAAAA, 32'h55555555};
        }
    }
    
    // Shift-specific constraints
    constraint shift_constraint_c {
        if (operation inside {ALU_SLL, ALU_SRL, ALU_SRA}) {
            operand_b[31:5] == 0;  // Only lower 5 bits matter for shifts
            shift_amount == operand_b[4:0];
        }
        else {
            shift_amount inside {[0:31]};
        }
    }
    
    // Overflow/underflow test constraints
    constraint overflow_test_c {
        if (enable_overflow_test && operation == ALU_ADD) {
            operand_a inside {[32'h7FFFF000:32'h7FFFFFFF]};
            operand_b inside {[32'h00000001:32'h00001000]};
        }
        if (enable_underflow_test && operation == ALU_SUB) {
            operand_a inside {[32'h80000000:32'h80001000]};
            operand_b inside {[32'h00000001:32'h00001000]};
        }
    }
    
    // Constructor
    function new(string name = "alu_sequence_item");
        super.new(name);
    endfunction
    
    // Post-randomize to calculate expected results and apply data patterns
    function void post_randomize();
        apply_data_pattern();
        calculate_expected_result();
        calculate_flags();
    endfunction
    
    // Apply specific data patterns after randomization
    function void apply_data_pattern();
        case (data_pattern)
            PATTERN_WALKING_ONES: begin
                static int walk_pos = 0;
                operand_a = 32'h1 << (walk_pos % 32);
                operand_b = 32'h1 << ((walk_pos + 1) % 32);
                walk_pos++;
            end
            PATTERN_WALKING_ZEROS: begin
                static int walk_pos = 0;
                operand_a = ~(32'h1 << (walk_pos % 32));
                operand_b = ~(32'h1 << ((walk_pos + 1) % 32));
                walk_pos++;
            end
            // Other patterns handled by constraints
            default: ; // No additional processing needed
        endcase
    endfunction
    
    // Enhanced expected result calculation
    function void calculate_expected_result();
        logic [32:0] temp_result;  // 33-bit for overflow detection
        
        case (operation)
            ALU_ADD: begin
                temp_result = {1'b0, operand_a} + {1'b0, operand_b};
                expected_result = temp_result[31:0];
                expected_overflow = temp_result[32];
            end
            ALU_SUB: begin
                temp_result = {1'b0, operand_a} - {1'b0, operand_b};
                expected_result = temp_result[31:0];
                expected_underflow = temp_result[32];
            end
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
    endfunction
    
    // Calculate result flags
    function void calculate_flags();
        expected_zero = (expected_result == 32'h0);
        expected_negative = expected_result[31];
    endfunction
    
    // Enhanced string conversion with Stage 2 information
    function string convert2string();
        string result_str;
        result_str = $sformatf("ALU_SEQ_ITEM[%s]: %s(0x%08h, 0x%08h) = 0x%08h", 
                              scenario.name(), operation.name(), operand_a, operand_b, expected_result);
        result_str = {result_str, $sformatf(" | Pattern: %s", data_pattern.name())};
        if (expected_overflow) result_str = {result_str, " | OVERFLOW"};
        if (expected_underflow) result_str = {result_str, " | UNDERFLOW"};
        if (expected_zero) result_str = {result_str, " | ZERO"};
        if (expected_negative) result_str = {result_str, " | NEG"};
        return result_str;
    endfunction
    
    // Constraint control functions for dynamic constraint modification
    function void enable_corner_case_mode();
        operation_distribution_c.constraint_mode(0);
        data_pattern_c.constraint_mode(0);
        scenario = SCENARIO_CORNER_CASE;
        data_pattern = PATTERN_BOUNDARY;
    endfunction
    
    function void enable_performance_mode();
        scenario = SCENARIO_PERFORMANCE;
        data_pattern = PATTERN_SMALL_VALUES;
    endfunction
    
    function void enable_stress_mode();
        scenario = SCENARIO_STRESS;
        enable_overflow_test = 1;
        enable_underflow_test = 1;
    endfunction

endclass : alu_sequence_item