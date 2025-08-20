// =============================================================================
// ALU Coverage Model - Stage 3
//
// Custom coverage model designed specifically for CV32E40P ALU verification
// Based on analysis of Stage 1 & 2 stimulus generation effectiveness
// =============================================================================

// =============================================================================
// COVERAGE MODEL RATIONALE
// =============================================================================
/*
DESIGN DECISIONS & RATIONALE:

1. OPERATION-CENTRIC APPROACH
   - Focus on ALU operations as primary coverage dimension
   - Rationale: ALU operations are the core functionality being verified
   - Each operation has different complexity and corner cases

2. BOUNDARY-FOCUSED DATA COVERAGE
   - Emphasize boundary values over exhaustive data combinations
   - Rationale: Most bugs occur at boundaries (0, max, min, overflow points)
   - More efficient than exhaustive operand combinations

3. CROSS-COVERAGE STRATEGY
   - Operation × Data Pattern combinations
   - Rationale: Different operations interact differently with data patterns
   - Critical for finding operation-specific edge cases

4. PRACTICAL COVERAGE GOALS
   - 100% operation coverage (mandatory)
   - 90% data pattern coverage (practical)
   - 85% cross coverage (achievable)
   - Rationale: Based on industry standards and resource constraints

5. EMBEDDED SOFTWARE FOCUS
   - Weight coverage based on real-world usage patterns
   - Rationale: Verification should reflect actual software behavior
   - ADD/SUB operations more critical than exotic operations
*/

class alu_coverage_model extends uvm_object;
    
    `uvm_object_utils(alu_coverage_model)
    
    // Coverage configuration
    bit coverage_enable = 1;
    bit detailed_logging = 0;
    
    // Coverage statistics
    int operation_hits[alu_opcode_e];
    int pattern_hits[data_pattern_e];
    int total_transactions = 0;
    
    // =============================================================================
    // PRIMARY FUNCTIONAL COVERAGE
    // =============================================================================
    
    // Core ALU Operation Coverage
    covergroup alu_operation_cg;
        option.per_instance = 1;
        option.name = "alu_operation_coverage";
        
        // Operation coverage with realistic weighting
        operation_cp: coverpoint operation {
            // High-priority operations (common in embedded software)
            bins arithmetic_add = {ALU_ADD};
            bins arithmetic_sub = {ALU_SUB};
            
            // Medium-priority operations (bit manipulation)
            bins logic_and = {ALU_AND};
            bins logic_or = {ALU_OR};
            bins logic_xor = {ALU_XOR};
            
            // Lower-priority operations (less common but important)
            bins shift_left = {ALU_SLL};
            bins shift_right_logical = {ALU_SRL};
            bins shift_right_arithmetic = {ALU_SRA};
            
            // Comparison operations (control flow critical)
            bins compare_signed = {ALU_SLTS};
            bins compare_unsigned = {ALU_SLTU};
            
            // Illegal operations (should not occur)
            illegal_bins unsupported = default;
        }
        
        // Weight operations based on embedded software analysis
        operation_weight_cp: coverpoint operation {
            bins frequent_ops = {ALU_ADD, ALU_SUB} with (item.weight = 3);
            bins common_ops = {ALU_AND, ALU_OR, ALU_XOR} with (item.weight = 2);
            bins occasional_ops = {ALU_SLL, ALU_SRL, ALU_SRA, ALU_SLTS, ALU_SLTU} with (item.weight = 1);
        }
    endgroup
    
    // =============================================================================
    // DATA PATTERN COVERAGE
    // =============================================================================
    
    // Operand A Coverage (focused on boundary conditions)
    covergroup operand_a_cg;
        option.per_instance = 1;
        option.name = "operand_a_coverage";
        
        operand_a_cp: coverpoint operand_a {
            // Critical boundary values
            bins zero = {32'h00000000};
            bins one = {32'h00000001};
            bins max_positive = {32'h7FFFFFFF};
            bins min_negative = {32'h80000000};
            bins all_ones = {32'hFFFFFFFF};
            
            // Power of 2 values (important for shifts and bit operations)
            bins powers_of_two[] = {32'h00000001, 32'h00000002, 32'h00000004, 32'h00000008,
                                   32'h00000010, 32'h00000020, 32'h00000040, 32'h00000080,
                                   32'h00000100, 32'h00000200, 32'h00000400, 32'h00000800,
                                   32'h00001000, 32'h00002000, 32'h00004000, 32'h00008000,
                                   32'h00010000, 32'h00020000, 32'h00040000, 32'h00080000,
                                   32'h00100000, 32'h00200000, 32'h00400000, 32'h00800000,
                                   32'h01000000, 32'h02000000, 32'h04000000, 32'h08000000,
                                   32'h10000000, 32'h20000000, 32'h40000000, 32'h80000000};
            
            // Small positive values (common in embedded software)
            bins small_positive = {[32'h00000002:32'h000000FF]};
            
            // Large positive values
            bins large_positive = {[32'h00000100:32'h7FFFFFFE]};
            
            // Small negative values (two's complement)
            bins small_negative = {[32'hFFFFFF00:32'hFFFFFFFE]};
            
            // Large negative values
            bins large_negative = {[32'h80000001:32'hFFFFFEFF]};
            
            // Alternating bit patterns (stress test for bit operations)
            bins alternating_01 = {32'h55555555};
            bins alternating_10 = {32'hAAAAAAAA};
        }
    endgroup
    
    // Operand B Coverage (similar to operand A but with shift-specific considerations)
    covergroup operand_b_cg;
        option.per_instance = 1;
        option.name = "operand_b_coverage";
        
        operand_b_cp: coverpoint operand_b {
            // Same boundary values as operand A
            bins zero = {32'h00000000};
            bins one = {32'h00000001};
            bins max_positive = {32'h7FFFFFFF};
            bins min_negative = {32'h80000000};
            bins all_ones = {32'hFFFFFFFF};
            
            // Shift amounts (only lower 5 bits matter for shifts)
            bins shift_amounts[] = {[0:31]};
            
            // Small values for arithmetic
            bins small_values = {[32'h00000002:32'h000000FF]};
            
            // Other ranges similar to operand A
            bins large_positive = {[32'h00000100:32'h7FFFFFFE]};
            bins small_negative = {[32'hFFFFFF00:32'hFFFFFFFE]};
            bins large_negative = {[32'h80000001:32'hFFFFFEFF]};
        }
    endgroup
    
    // =============================================================================
    // STAGE 2 DATA PATTERN COVERAGE
    // =============================================================================
    
    // Coverage for Stage 2 data patterns
    covergroup data_pattern_cg;
        option.per_instance = 1;
        option.name = "data_pattern_coverage";
        
        pattern_cp: coverpoint data_pattern {
            bins random_pattern = {PATTERN_RANDOM};
            bins boundary_pattern = {PATTERN_BOUNDARY};
            bins walking_ones = {PATTERN_WALKING_ONES};
            bins walking_zeros = {PATTERN_WALKING_ZEROS};
            bins alternating_pattern = {PATTERN_ALTERNATING};
            bins small_values = {PATTERN_SMALL_VALUES};
            bins large_values = {PATTERN_LARGE_VALUES};
            bins powers_of_two = {PATTERN_POWERS_OF_TWO};
        }
        
        // Pattern effectiveness (based on error detection)
        pattern_effectiveness_cp: coverpoint data_pattern {
            bins high_effectiveness = {PATTERN_BOUNDARY, PATTERN_WALKING_ONES, PATTERN_WALKING_ZEROS} 
                                     with (item.weight = 3);
            bins medium_effectiveness = {PATTERN_ALTERNATING, PATTERN_POWERS_OF_TWO} 
                                       with (item.weight = 2);
            bins baseline_effectiveness = {PATTERN_RANDOM, PATTERN_SMALL_VALUES, PATTERN_LARGE_VALUES} 
                                         with (item.weight = 1);
        }
    endgroup
    
    // =============================================================================
    // CROSS COVERAGE - CRITICAL COMBINATIONS
    // =============================================================================
    
    // Operation × Data Pattern Cross Coverage
    covergroup operation_pattern_cross_cg;
        option.per_instance = 1;
        option.name = "operation_pattern_cross_coverage";
        
        operation_cp: coverpoint operation {
            bins arithmetic = {ALU_ADD, ALU_SUB};
            bins logical = {ALU_AND, ALU_OR, ALU_XOR};
            bins shift = {ALU_SLL, ALU_SRL, ALU_SRA};
            bins compare = {ALU_SLTS, ALU_SLTU};
        }
        
        pattern_cp: coverpoint data_pattern {
            bins boundary = {PATTERN_BOUNDARY};
            bins walking = {PATTERN_WALKING_ONES, PATTERN_WALKING_ZEROS};
            bins special = {PATTERN_ALTERNATING, PATTERN_POWERS_OF_TWO};
            bins typical = {PATTERN_RANDOM, PATTERN_SMALL_VALUES, PATTERN_LARGE_VALUES};
        }
        
        // Critical cross combinations
        op_pattern_cross: cross operation_cp, pattern_cp {
            // High-priority combinations (most likely to find bugs)
            bins arithmetic_boundary = binsof(operation_cp.arithmetic) && binsof(pattern_cp.boundary);
            bins shift_walking = binsof(operation_cp.shift) && binsof(pattern_cp.walking);
            bins logical_special = binsof(operation_cp.logical) && binsof(pattern_cp.special);
            
            // Ignore less critical combinations to focus coverage effort
            ignore_bins low_priority = binsof(operation_cp.compare) && binsof(pattern_cp.typical);
        }
    endgroup
    
    // Operation × Operand Boundary Cross Coverage
    covergroup operation_boundary_cross_cg;
        option.per_instance = 1;
        option.name = "operation_boundary_cross_coverage";
        
        operation_cp: coverpoint operation;
        
        operand_a_boundary_cp: coverpoint operand_a {
            bins zero = {32'h00000000};
            bins max_pos = {32'h7FFFFFFF};
            bins min_neg = {32'h80000000};
            bins all_ones = {32'hFFFFFFFF};
        }
        
        operand_b_boundary_cp: coverpoint operand_b {
            bins zero = {32'h00000000};
            bins max_pos = {32'h7FFFFFFF};
            bins min_neg = {32'h80000000};
            bins all_ones = {32'hFFFFFFFF};
        }
        
        // Critical boundary combinations
        op_boundary_cross: cross operation_cp, operand_a_boundary_cp, operand_b_boundary_cp {
            // Focus on overflow/underflow conditions
            bins add_overflow = binsof(operation_cp) intersect {ALU_ADD} &&
                               binsof(operand_a_boundary_cp.max_pos) &&
                               binsof(operand_b_boundary_cp.max_pos);
            
            bins sub_underflow = binsof(operation_cp) intersect {ALU_SUB} &&
                                binsof(operand_a_boundary_cp.min_neg) &&
                                binsof(operand_b_boundary_cp.max_pos);
            
            // Ignore less critical three-way combinations to keep coverage manageable
            ignore_bins excessive_combinations = 
                binsof(operation_cp) intersect {ALU_AND, ALU_OR, ALU_XOR} &&
                binsof(operand_a_boundary_cp.zero) &&
                binsof(operand_b_boundary_cp.zero);
        }
    endgroup
    
    // =============================================================================
    // COVERAGE COLLECTION VARIABLES
    // =============================================================================
    
    // Current transaction data
    alu_opcode_e operation;
    logic [31:0] operand_a;
    logic [31:0] operand_b;
    logic [31:0] result;
    data_pattern_e data_pattern;
    test_scenario_e scenario;
    
    // =============================================================================
    // CONSTRUCTOR AND METHODS
    // =============================================================================
    
    function new(string name = "alu_coverage_model");
        super.new(name);
        
        // Create coverage groups
        alu_operation_cg = new();
        operand_a_cg = new();
        operand_b_cg = new();
        data_pattern_cg = new();
        operation_pattern_cross_cg = new();
        operation_boundary_cross_cg = new();
        
        // Initialize statistics
        foreach(operation_hits[op]) operation_hits[op] = 0;
        foreach(pattern_hits[pat]) pattern_hits[pat] = 0;
    endfunction
    
    // Sample coverage for a transaction
    function void sample_transaction(alu_transaction trans);
        if (!coverage_enable) return;
        
        // Update current transaction data
        this.operation = trans.operation;
        this.operand_a = trans.operand_a;
        this.operand_b = trans.operand_b;
        this.result = trans.result;
        this.data_pattern = trans.data_pattern;
        this.scenario = trans.scenario;
        
        // Sample all coverage groups
        alu_operation_cg.sample();
        operand_a_cg.sample();
        operand_b_cg.sample();
        data_pattern_cg.sample();
        operation_pattern_cross_cg.sample();
        operation_boundary_cross_cg.sample();
        
        // Update statistics
        operation_hits[trans.operation]++;
        pattern_hits[trans.data_pattern]++;
        total_transactions++;
        
        if (detailed_logging) begin
            `uvm_info("COV_MODEL", $sformatf("Sampled: %s with %s pattern", 
                     trans.operation.name(), trans.data_pattern.name()), UVM_HIGH)
        end
    endfunction
    
    // Get coverage statistics
    function real get_operation_coverage();
        return alu_operation_cg.get_coverage();
    endfunction
    
    function real get_data_pattern_coverage();
        return data_pattern_cg.get_coverage();
    endfunction
    
    function real get_cross_coverage();
        return (operation_pattern_cross_cg.get_coverage() + 
                operation_boundary_cross_cg.get_coverage()) / 2.0;
    endfunction
    
    function real get_overall_coverage();
        return (get_operation_coverage() + 
                get_data_pattern_coverage() + 
                get_cross_coverage()) / 3.0;
    endfunction
    
    // Generate coverage report
    function void generate_coverage_report();
        `uvm_info("COV_REPORT", "=== ALU COVERAGE ANALYSIS REPORT ===", UVM_LOW)
        `uvm_info("COV_REPORT", $sformatf("Total Transactions: %0d", total_transactions), UVM_LOW)
        `uvm_info("COV_REPORT", $sformatf("Operation Coverage: %0.2f%%", get_operation_coverage()), UVM_LOW)
        `uvm_info("COV_REPORT", $sformatf("Data Pattern Coverage: %0.2f%%", get_data_pattern_coverage()), UVM_LOW)
        `uvm_info("COV_REPORT", $sformatf("Cross Coverage: %0.2f%%", get_cross_coverage()), UVM_LOW)
        `uvm_info("COV_REPORT", $sformatf("Overall Coverage: %0.2f%%", get_overall_coverage()), UVM_LOW)
        
        // Operation hit statistics
        `uvm_info("COV_REPORT", "=== OPERATION HIT STATISTICS ===", UVM_LOW)
        foreach(operation_hits[op]) begin
            if (operation_hits[op] > 0) begin
                `uvm_info("COV_REPORT", $sformatf("%s: %0d hits", op.name(), operation_hits[op]), UVM_LOW)
            end
        end
        
        // Pattern hit statistics
        `uvm_info("COV_REPORT", "=== DATA PATTERN HIT STATISTICS ===", UVM_LOW)
        foreach(pattern_hits[pat]) begin
            if (pattern_hits[pat] > 0) begin
                `uvm_info("COV_REPORT", $sformatf("%s: %0d hits", pat.name(), pattern_hits[pat]), UVM_LOW)
            end
        end
    endfunction
    
    // Identify coverage holes
    function void identify_coverage_holes();
        `uvm_info("COV_HOLES", "=== COVERAGE HOLE ANALYSIS ===", UVM_LOW)
        
        // Check for uncovered operations
        foreach(operation_hits[op]) begin
            if (operation_hits[op] == 0) begin
                `uvm_warning("COV_HOLES", $sformatf("Operation %s not covered", op.name()))
            end
        end
        
        // Check for uncovered patterns
        foreach(pattern_hits[pat]) begin
            if (pattern_hits[pat] == 0) begin
                `uvm_warning("COV_HOLES", $sformatf("Pattern %s not covered", pat.name()))
            end
        end
        
        // Coverage goals assessment
        real op_cov = get_operation_coverage();
        real pat_cov = get_data_pattern_coverage();
        real cross_cov = get_cross_coverage();
        
        if (op_cov < 100.0) begin
            `uvm_warning("COV_HOLES", $sformatf("Operation coverage below 100%% (%.2f%%)", op_cov))
        end
        
        if (pat_cov < 90.0) begin
            `uvm_warning("COV_HOLES", $sformatf("Pattern coverage below 90%% (%.2f%%)", pat_cov))
        end
        
        if (cross_cov < 85.0) begin
            `uvm_warning("COV_HOLES", $sformatf("Cross coverage below 85%% (%.2f%%)", cross_cov))
        end
    endfunction
    
endclass : alu_coverage_model