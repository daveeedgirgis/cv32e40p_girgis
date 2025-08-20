// =============================================================================
// ALU Sequence Library - Stage 2 Advanced
//
// Comprehensive UVM sequences for sophisticated ALU verification
// Includes constrained random, directed, and performance-oriented sequences
// =============================================================================

// =============================================================================
// BASE SEQUENCE CLASSES
// =============================================================================

// Enhanced base sequence with Stage 2 capabilities
class alu_base_sequence extends uvm_sequence #(alu_sequence_item);
    
    `uvm_object_utils(alu_base_sequence)
    
    // Configuration parameters
    int num_transactions = 100;  // Increased for Stage 2
    bit enable_coverage = 1;
    bit enable_logging = 1;
    
    // Statistics tracking
    int transaction_count = 0;
    int error_count = 0;
    
    function new(string name = "alu_base_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        `uvm_info("ALU_SEQ", $sformatf("Starting Stage 2 sequence '%s' with %0d transactions", 
                 get_name(), num_transactions), UVM_LOW)
        
        for (int i = 0; i < num_transactions; i++) begin
            alu_sequence_item item;
            
            item = alu_sequence_item::type_id::create($sformatf("item_%0d", i));
            start_item(item);
            
            if (!item.randomize()) begin
                `uvm_error("ALU_SEQ", $sformatf("Randomization failed for transaction %0d", i))
                error_count++;
                continue;
            end
            
            finish_item(item);
            transaction_count++;
            
            if (enable_logging && (i % 10 == 0)) begin
                `uvm_info("ALU_SEQ", $sformatf("Progress: %0d/%0d - %s", 
                         i+1, num_transactions, item.convert2string()), UVM_MEDIUM)
            end
        end
        
        `uvm_info("ALU_SEQ", $sformatf("Sequence '%s' completed: %0d transactions, %0d errors", 
                 get_name(), transaction_count, error_count), UVM_LOW)
    endtask

endclass : alu_base_sequence

// =============================================================================
// CONSTRAINED RANDOM SEQUENCES
// =============================================================================

// Exhaustive ALU operation sequence with smart constraints
class alu_exhaustive_sequence extends alu_base_sequence;
    
    `uvm_object_utils(alu_exhaustive_sequence)
    
    function new(string name = "alu_exhaustive_sequence");
        super.new(name);
        num_transactions = 500;  // Comprehensive coverage
    endfunction
    
    virtual task body();
        `uvm_info("ALU_SEQ", "Starting exhaustive ALU sequence with all operations", UVM_LOW)
        
        // First pass: Cover all operations with random data
        for (int i = 0; i < num_transactions; i++) begin
            alu_sequence_item item;
            
            item = alu_sequence_item::type_id::create($sformatf("exhaustive_item_%0d", i));
            start_item(item);
            
            if (!item.randomize()) begin
                `uvm_error("ALU_SEQ", $sformatf("Exhaustive randomization failed for transaction %0d", i))
                continue;
            end
            
            finish_item(item);
            
            if (i % 50 == 0) begin
                `uvm_info("ALU_SEQ", $sformatf("Exhaustive progress: %0d/%0d - %s", 
                         i+1, num_transactions, item.convert2string()), UVM_MEDIUM)
            end
        end
        
        `uvm_info("ALU_SEQ", "Exhaustive ALU sequence completed", UVM_LOW)
    endtask

endclass : alu_exhaustive_sequence

// Data pattern focused sequence
class alu_data_pattern_sequence extends alu_base_sequence;
    
    `uvm_object_utils(alu_data_pattern_sequence)
    
    data_pattern_e target_patterns[$] = {
        PATTERN_BOUNDARY,
        PATTERN_WALKING_ONES,
        PATTERN_WALKING_ZEROS,
        PATTERN_ALTERNATING,
        PATTERN_POWERS_OF_TWO
    };
    
    function new(string name = "alu_data_pattern_sequence");
        super.new(name);
        num_transactions = 200;
    endfunction
    
    virtual task body();
        `uvm_info("ALU_SEQ", "Starting data pattern sequence", UVM_LOW)
        
        // Test each pattern systematically
        foreach (target_patterns[i]) begin
            data_pattern_e current_pattern = target_patterns[i];
            // Calculate pattern transactions (avoid variable declaration in task)
            
            `uvm_info("ALU_SEQ", $sformatf("Testing pattern: %s (%0d transactions)", 
                     current_pattern.name(), num_transactions / target_patterns.size()), UVM_LOW)
            
            for (int j = 0; j < (num_transactions / target_patterns.size()); j++) begin
                alu_sequence_item item;
                
                item = alu_sequence_item::type_id::create($sformatf("pattern_%s_%0d", current_pattern.name(), j));
                start_item(item);
                
                if (!item.randomize() with {
                    data_pattern == current_pattern;
                }) begin
                    `uvm_error("ALU_SEQ", $sformatf("Pattern randomization failed: %s", current_pattern.name()))
                    continue;
                end
                
                finish_item(item);
                
                if (j % 20 == 0) begin
                    `uvm_info("ALU_SEQ", $sformatf("Pattern %s: %0d/%0d - %s", 
                             current_pattern.name(), j+1, (num_transactions / target_patterns.size()), item.convert2string()), UVM_HIGH)
                end
            end
        end
        
        `uvm_info("ALU_SEQ", "Data pattern sequence completed", UVM_LOW)
    endtask

endclass : alu_data_pattern_sequence

// Mixed workload sequence simulating realistic software patterns
class alu_mixed_workload_sequence extends alu_base_sequence;
    
    `uvm_object_utils(alu_mixed_workload_sequence)
    
    function new(string name = "alu_mixed_workload_sequence");
        super.new(name);
        num_transactions = 1000;  // Large workload
    endfunction
    
    virtual task body();
        `uvm_info("ALU_SEQ", "Starting mixed workload sequence (realistic software simulation)", UVM_LOW)
        
        for (int i = 0; i < num_transactions; i++) begin
            alu_sequence_item item;
            
            item = alu_sequence_item::type_id::create($sformatf("mixed_item_%0d", i));
            start_item(item);
            
            // Use realistic scenario weighting
            if (!item.randomize() with {
                scenario == SCENARIO_REALISTIC;
                data_pattern dist {
                    PATTERN_SMALL_VALUES := 60,
                    PATTERN_RANDOM := 30,
                    PATTERN_BOUNDARY := 10
                };
            }) begin
                `uvm_error("ALU_SEQ", $sformatf("Mixed workload randomization failed for transaction %0d", i))
                continue;
            end
            
            finish_item(item);
            
            if (i % 100 == 0) begin
                `uvm_info("ALU_SEQ", $sformatf("Mixed workload progress: %0d/%0d - %s", 
                         i+1, num_transactions, item.convert2string()), UVM_MEDIUM)
            end
        end
        
        `uvm_info("ALU_SEQ", "Mixed workload sequence completed", UVM_LOW)
    endtask

endclass : alu_mixed_workload_sequence

// =============================================================================
// DIRECTED TEST SEQUENCES
// =============================================================================

// Pipeline hazard sequence for performance analysis
class alu_pipeline_hazard_sequence extends alu_base_sequence;
    
    `uvm_object_utils(alu_pipeline_hazard_sequence)
    
    // Hazard patterns to test
    typedef enum {
        RAW_HAZARD,    // Read After Write
        WAR_HAZARD,    // Write After Read  
        WAW_HAZARD,    // Write After Write
        DEPENDENCY_CHAIN
    } hazard_type_e;
    
    function new(string name = "alu_pipeline_hazard_sequence");
        super.new(name);
        num_transactions = 300;
    endfunction
    
    virtual task body();
        `uvm_info("ALU_SEQ", "Starting pipeline hazard sequence", UVM_LOW)
        
        // Test different hazard scenarios
        test_raw_hazards();
        test_dependency_chains();
        test_mixed_hazards();
        
        `uvm_info("ALU_SEQ", "Pipeline hazard sequence completed", UVM_LOW)
    endtask
    
    // Test Read-After-Write hazards
    task test_raw_hazards();
        `uvm_info("ALU_SEQ", "Testing RAW hazards", UVM_MEDIUM)
        
        for (int i = 0; i < 50; i++) begin
            alu_sequence_item item1, item2;
            
            // First operation
            item1 = alu_sequence_item::type_id::create($sformatf("raw_item1_%0d", i));
            start_item(item1);
            if (!item1.randomize() with {
                operation inside {ALU_ADD, ALU_SUB};
                scenario == SCENARIO_PERFORMANCE;
            }) begin
                `uvm_error("ALU_SEQ", "RAW hazard item1 randomization failed")
                continue;
            end
            finish_item(item1);
            
            // Dependent operation (uses result of first)
            item2 = alu_sequence_item::type_id::create($sformatf("raw_item2_%0d", i));
            start_item(item2);
            if (!item2.randomize() with {
                operation inside {ALU_AND, ALU_OR};
                operand_a == item1.expected_result;  // Create dependency
                scenario == SCENARIO_PERFORMANCE;
            }) begin
                `uvm_error("ALU_SEQ", "RAW hazard item2 randomization failed")
                continue;
            end
            finish_item(item2);
        end
    endtask
    
    // Test instruction dependency chains
    task test_dependency_chains();
        `uvm_info("ALU_SEQ", "Testing dependency chains", UVM_MEDIUM)
        
        for (int chain = 0; chain < 20; chain++) begin
            // Create 5-instruction dependency chain using individual variables
            alu_sequence_item item0, item1, item2, item3, item4;
            
            // Instruction 0 - independent
            item0 = alu_sequence_item::type_id::create($sformatf("chain_%0d_item_0", chain));
            start_item(item0);
            if (!item0.randomize() with {
                operation inside {ALU_ADD, ALU_SUB};
                scenario == SCENARIO_PERFORMANCE;
            }) begin
                `uvm_error("ALU_SEQ", "Chain item 0 randomization failed")
                continue;
            end
            finish_item(item0);
            
            // Instruction 1 - depends on item0
            item1 = alu_sequence_item::type_id::create($sformatf("chain_%0d_item_1", chain));
            start_item(item1);
            if (!item1.randomize() with {
                operation inside {ALU_AND, ALU_OR, ALU_XOR};
                operand_a == item0.expected_result;
                scenario == SCENARIO_PERFORMANCE;
            }) begin
                `uvm_error("ALU_SEQ", "Chain item 1 randomization failed")
                continue;
            end
            finish_item(item1);
            
            // Instruction 2 - depends on item1
            item2 = alu_sequence_item::type_id::create($sformatf("chain_%0d_item_2", chain));
            start_item(item2);
            if (!item2.randomize() with {
                operation inside {ALU_AND, ALU_OR, ALU_XOR};
                operand_a == item1.expected_result;
                scenario == SCENARIO_PERFORMANCE;
            }) begin
                `uvm_error("ALU_SEQ", "Chain item 2 randomization failed")
                continue;
            end
            finish_item(item2);
            
            // Instruction 3 - depends on item2
            item3 = alu_sequence_item::type_id::create($sformatf("chain_%0d_item_3", chain));
            start_item(item3);
            if (!item3.randomize() with {
                operation inside {ALU_AND, ALU_OR, ALU_XOR};
                operand_a == item2.expected_result;
                scenario == SCENARIO_PERFORMANCE;
            }) begin
                `uvm_error("ALU_SEQ", "Chain item 3 randomization failed")
                continue;
            end
            finish_item(item3);
            
            // Instruction 4 - depends on item3
            item4 = alu_sequence_item::type_id::create($sformatf("chain_%0d_item_4", chain));
            start_item(item4);
            if (!item4.randomize() with {
                operation inside {ALU_AND, ALU_OR, ALU_XOR};
                operand_a == item3.expected_result;
                scenario == SCENARIO_PERFORMANCE;
            }) begin
                `uvm_error("ALU_SEQ", "Chain item 4 randomization failed")
                continue;
            end
            finish_item(item4);
        end
    endtask
    
    // Test mixed hazard scenarios
    task test_mixed_hazards();
        `uvm_info("ALU_SEQ", "Testing mixed hazard scenarios", UVM_MEDIUM)
        
        for (int i = 0; i < 30; i++) begin
            alu_sequence_item item;
            
            item = alu_sequence_item::type_id::create($sformatf("mixed_hazard_%0d", i));
            start_item(item);
            
            if (!item.randomize() with {
                scenario == SCENARIO_PERFORMANCE;
                data_pattern == PATTERN_RANDOM;
            }) begin
                `uvm_error("ALU_SEQ", "Mixed hazard randomization failed")
                continue;
            end
            
            finish_item(item);
        end
    endtask

endclass : alu_pipeline_hazard_sequence

// Corner case sequence for boundary condition testing
class alu_corner_case_sequence extends alu_base_sequence;
    
    `uvm_object_utils(alu_corner_case_sequence)
    
    function new(string name = "alu_corner_case_sequence");
        super.new(name);
        num_transactions = 200;
    endfunction
    
    virtual task body();
        `uvm_info("ALU_SEQ", "Starting corner case sequence", UVM_LOW)
        
        test_overflow_conditions();
        test_underflow_conditions();
        test_zero_conditions();
        test_max_min_values();
        test_shift_edge_cases();
        
        `uvm_info("ALU_SEQ", "Corner case sequence completed", UVM_LOW)
    endtask
    
    // Test arithmetic overflow conditions
    task test_overflow_conditions();
        `uvm_info("ALU_SEQ", "Testing overflow conditions", UVM_MEDIUM)
        
        for (int i = 0; i < 20; i++) begin
            alu_sequence_item item;
            
            item = alu_sequence_item::type_id::create($sformatf("overflow_%0d", i));
            start_item(item);
            
            if (!item.randomize() with {
                operation == ALU_ADD;
                operand_a inside {[32'h7FFFF000:32'h7FFFFFFF]};
                operand_b inside {[32'h00000001:32'h00001000]};
                scenario == SCENARIO_CORNER_CASE;
                enable_overflow_test == 1;
            }) begin
                `uvm_error("ALU_SEQ", "Overflow test randomization failed")
                continue;
            end
            
            finish_item(item);
        end
    endtask
    
    // Test arithmetic underflow conditions
    task test_underflow_conditions();
        `uvm_info("ALU_SEQ", "Testing underflow conditions", UVM_MEDIUM)
        
        for (int i = 0; i < 20; i++) begin
            alu_sequence_item item;
            
            item = alu_sequence_item::type_id::create($sformatf("underflow_%0d", i));
            start_item(item);
            
            if (!item.randomize() with {
                operation == ALU_SUB;
                operand_a inside {[32'h80000000:32'h80001000]};
                operand_b inside {[32'h00000001:32'h00001000]};
                scenario == SCENARIO_CORNER_CASE;
                enable_underflow_test == 1;
            }) begin
                `uvm_error("ALU_SEQ", "Underflow test randomization failed")
                continue;
            end
            
            finish_item(item);
        end
    endtask
    
    // Test zero result conditions
    task test_zero_conditions();
        `uvm_info("ALU_SEQ", "Testing zero result conditions", UVM_MEDIUM)
        
        for (int i = 0; i < 30; i++) begin
            alu_sequence_item item;
            
            item = alu_sequence_item::type_id::create($sformatf("zero_%0d", i));
            start_item(item);
            
            if (!item.randomize() with {
                (operation == ALU_SUB && operand_a == operand_b) ||
                (operation == ALU_AND && (operand_a == 0 || operand_b == 0)) ||
                (operation == ALU_XOR && operand_a == operand_b);
                scenario == SCENARIO_CORNER_CASE;
            }) begin
                `uvm_error("ALU_SEQ", "Zero condition randomization failed")
                continue;
            end
            
            finish_item(item);
        end
    endtask
    
    // Test maximum and minimum values
    task test_max_min_values();
        `uvm_info("ALU_SEQ", "Testing max/min values", UVM_MEDIUM)
        
        // Test all combinations of boundary values
        for (int i = 0; i < 5; i++) begin
            for (int j = 0; j < 5; j++) begin
                alu_sequence_item item;
                
                item = alu_sequence_item::type_id::create($sformatf("maxmin_%0d_%0d", i, j));
                start_item(item);
                
                // Use direct values in constraints based on indices
                if (i == 0 && j == 0) begin
                    if (!item.randomize() with {
                        operand_a == 32'h00000000; operand_b == 32'h00000000;
                        scenario == SCENARIO_CORNER_CASE;
                    }) `uvm_error("ALU_SEQ", "Randomization failed")
                end else if (i == 0 && j == 1) begin
                    if (!item.randomize() with {
                        operand_a == 32'h00000000; operand_b == 32'h00000001;
                        scenario == SCENARIO_CORNER_CASE;
                    }) `uvm_error("ALU_SEQ", "Randomization failed")
                end else if (i == 0 && j == 2) begin
                    if (!item.randomize() with {
                        operand_a == 32'h00000000; operand_b == 32'h7FFFFFFF;
                        scenario == SCENARIO_CORNER_CASE;
                    }) `uvm_error("ALU_SEQ", "Randomization failed")
                end else if (i == 0 && j == 3) begin
                    if (!item.randomize() with {
                        operand_a == 32'h00000000; operand_b == 32'h80000000;
                        scenario == SCENARIO_CORNER_CASE;
                    }) `uvm_error("ALU_SEQ", "Randomization failed")
                end else if (i == 0 && j == 4) begin
                    if (!item.randomize() with {
                        operand_a == 32'h00000000; operand_b == 32'hFFFFFFFF;
                        scenario == SCENARIO_CORNER_CASE;
                    }) `uvm_error("ALU_SEQ", "Randomization failed")
                end else if (i == 1 && j == 0) begin
                    if (!item.randomize() with {
                        operand_a == 32'h00000001; operand_b == 32'h00000000;
                        scenario == SCENARIO_CORNER_CASE;
                    }) `uvm_error("ALU_SEQ", "Randomization failed")
                end else if (i == 1 && j == 1) begin
                    if (!item.randomize() with {
                        operand_a == 32'h00000001; operand_b == 32'h00000001;
                        scenario == SCENARIO_CORNER_CASE;
                    }) `uvm_error("ALU_SEQ", "Randomization failed")
                end else if (i == 1 && j == 2) begin
                    if (!item.randomize() with {
                        operand_a == 32'h00000001; operand_b == 32'h7FFFFFFF;
                        scenario == SCENARIO_CORNER_CASE;
                    }) `uvm_error("ALU_SEQ", "Randomization failed")
                end else if (i == 1 && j == 3) begin
                    if (!item.randomize() with {
                        operand_a == 32'h00000001; operand_b == 32'h80000000;
                        scenario == SCENARIO_CORNER_CASE;
                    }) `uvm_error("ALU_SEQ", "Randomization failed")
                end else if (i == 1 && j == 4) begin
                    if (!item.randomize() with {
                        operand_a == 32'h00000001; operand_b == 32'hFFFFFFFF;
                        scenario == SCENARIO_CORNER_CASE;
                    }) `uvm_error("ALU_SEQ", "Randomization failed")
                end else if (i == 2 && j == 0) begin
                    if (!item.randomize() with {
                        operand_a == 32'h7FFFFFFF; operand_b == 32'h00000000;
                        scenario == SCENARIO_CORNER_CASE;
                    }) `uvm_error("ALU_SEQ", "Randomization failed")
                end else if (i == 2 && j == 1) begin
                    if (!item.randomize() with {
                        operand_a == 32'h7FFFFFFF; operand_b == 32'h00000001;
                        scenario == SCENARIO_CORNER_CASE;
                    }) `uvm_error("ALU_SEQ", "Randomization failed")
                end else if (i == 2 && j == 2) begin
                    if (!item.randomize() with {
                        operand_a == 32'h7FFFFFFF; operand_b == 32'h7FFFFFFF;
                        scenario == SCENARIO_CORNER_CASE;
                    }) `uvm_error("ALU_SEQ", "Randomization failed")
                end else if (i == 2 && j == 3) begin
                    if (!item.randomize() with {
                        operand_a == 32'h7FFFFFFF; operand_b == 32'h80000000;
                        scenario == SCENARIO_CORNER_CASE;
                    }) `uvm_error("ALU_SEQ", "Randomization failed")
                end else if (i == 2 && j == 4) begin
                    if (!item.randomize() with {
                        operand_a == 32'h7FFFFFFF; operand_b == 32'hFFFFFFFF;
                        scenario == SCENARIO_CORNER_CASE;
                    }) `uvm_error("ALU_SEQ", "Randomization failed")
                end else if (i == 3 && j == 0) begin
                    if (!item.randomize() with {
                        operand_a == 32'h80000000; operand_b == 32'h00000000;
                        scenario == SCENARIO_CORNER_CASE;
                    }) `uvm_error("ALU_SEQ", "Randomization failed")
                end else if (i == 3 && j == 1) begin
                    if (!item.randomize() with {
                        operand_a == 32'h80000000; operand_b == 32'h00000001;
                        scenario == SCENARIO_CORNER_CASE;
                    }) `uvm_error("ALU_SEQ", "Randomization failed")
                end else if (i == 3 && j == 2) begin
                    if (!item.randomize() with {
                        operand_a == 32'h80000000; operand_b == 32'h7FFFFFFF;
                        scenario == SCENARIO_CORNER_CASE;
                    }) `uvm_error("ALU_SEQ", "Randomization failed")
                end else if (i == 3 && j == 3) begin
                    if (!item.randomize() with {
                        operand_a == 32'h80000000; operand_b == 32'h80000000;
                        scenario == SCENARIO_CORNER_CASE;
                    }) `uvm_error("ALU_SEQ", "Randomization failed")
                end else if (i == 3 && j == 4) begin
                    if (!item.randomize() with {
                        operand_a == 32'h80000000; operand_b == 32'hFFFFFFFF;
                        scenario == SCENARIO_CORNER_CASE;
                    }) `uvm_error("ALU_SEQ", "Randomization failed")
                end else if (i == 4 && j == 0) begin
                    if (!item.randomize() with {
                        operand_a == 32'hFFFFFFFF; operand_b == 32'h00000000;
                        scenario == SCENARIO_CORNER_CASE;
                    }) `uvm_error("ALU_SEQ", "Randomization failed")
                end else if (i == 4 && j == 1) begin
                    if (!item.randomize() with {
                        operand_a == 32'hFFFFFFFF; operand_b == 32'h00000001;
                        scenario == SCENARIO_CORNER_CASE;
                    }) `uvm_error("ALU_SEQ", "Randomization failed")
                end else if (i == 4 && j == 2) begin
                    if (!item.randomize() with {
                        operand_a == 32'hFFFFFFFF; operand_b == 32'h7FFFFFFF;
                        scenario == SCENARIO_CORNER_CASE;
                    }) `uvm_error("ALU_SEQ", "Randomization failed")
                end else if (i == 4 && j == 3) begin
                    if (!item.randomize() with {
                        operand_a == 32'hFFFFFFFF; operand_b == 32'h80000000;
                        scenario == SCENARIO_CORNER_CASE;
                    }) `uvm_error("ALU_SEQ", "Randomization failed")
                end else if (i == 4 && j == 4) begin
                    if (!item.randomize() with {
                        operand_a == 32'hFFFFFFFF; operand_b == 32'hFFFFFFFF;
                        scenario == SCENARIO_CORNER_CASE;
                    }) `uvm_error("ALU_SEQ", "Randomization failed")
                end
                
                finish_item(item);
            end
        end
    endtask
    
    // Test shift operation edge cases
    task test_shift_edge_cases();
        `uvm_info("ALU_SEQ", "Testing shift edge cases", UVM_MEDIUM)
        
        for (int i = 0; i < 40; i++) begin
            alu_sequence_item item;
            
            item = alu_sequence_item::type_id::create($sformatf("shift_edge_%0d", i));
            start_item(item);
            
            if (!item.randomize() with {
                operation inside {ALU_SLL, ALU_SRL, ALU_SRA};
                operand_b inside {0, 1, 31, 32, 63};  // Edge shift amounts
                scenario == SCENARIO_CORNER_CASE;
            }) begin
                `uvm_error("ALU_SEQ", "Shift edge case randomization failed")
                continue;
            end
            
            finish_item(item);
        end
    endtask

endclass : alu_corner_case_sequence

// Performance measurement sequence for IPC analysis
class alu_performance_sequence extends alu_base_sequence;
    
    `uvm_object_utils(alu_performance_sequence)
    
    // Performance metrics
    int cycle_count = 0;
    int instruction_count = 0;
    real ipc_measurement = 0.0;
    
    function new(string name = "alu_performance_sequence");
        super.new(name);
        num_transactions = 1000;  // Large sample for accurate IPC
    endfunction
    
    virtual task body();
        `uvm_info("ALU_SEQ", "Starting performance measurement sequence", UVM_LOW)
        
        // Record start time (use class variable or direct calculation)
        cycle_count = 0;  // Reset cycle count
        instruction_count = 0;  // Reset instruction count
        
        test_arithmetic_performance();
        test_logic_performance();
        test_shift_performance();
        test_mixed_performance();
        
        // Calculate performance metrics
        // Note: In real implementation, cycle_count would be updated by each test
        if (cycle_count > 0) begin
            ipc_measurement = real'(instruction_count) / real'(cycle_count);
        end else begin
            ipc_measurement = 0.0;
        end
        
        `uvm_info("ALU_SEQ", $sformatf("Performance Results: %0d instructions, %0d cycles, IPC = %0.3f", 
                 instruction_count, cycle_count, ipc_measurement), UVM_LOW)
        
        `uvm_info("ALU_SEQ", "Performance measurement sequence completed", UVM_LOW)
    endtask
    
    // Test arithmetic operation performance
    task test_arithmetic_performance();
        `uvm_info("ALU_SEQ", "Measuring arithmetic performance", UVM_MEDIUM)
        
        for (int i = 0; i < 250; i++) begin
            alu_sequence_item item;
            
            item = alu_sequence_item::type_id::create($sformatf("perf_arith_%0d", i));
            start_item(item);
            
            if (!item.randomize() with {
                operation inside {ALU_ADD, ALU_SUB};
                scenario == SCENARIO_PERFORMANCE;
                data_pattern == PATTERN_SMALL_VALUES;
            }) begin
                `uvm_error("ALU_SEQ", "Arithmetic performance randomization failed")
                continue;
            end
            
            finish_item(item);
            instruction_count++;
        end
    endtask
    
    // Test logic operation performance
    task test_logic_performance();
        `uvm_info("ALU_SEQ", "Measuring logic performance", UVM_MEDIUM)
        
        for (int i = 0; i < 250; i++) begin
            alu_sequence_item item;
            
            item = alu_sequence_item::type_id::create($sformatf("perf_logic_%0d", i));
            start_item(item);
            
            if (!item.randomize() with {
                operation inside {ALU_AND, ALU_OR, ALU_XOR};
                scenario == SCENARIO_PERFORMANCE;
                data_pattern == PATTERN_RANDOM;
            }) begin
                `uvm_error("ALU_SEQ", "Logic performance randomization failed")
                continue;
            end
            
            finish_item(item);
            instruction_count++;
        end
    endtask
    
    // Test shift operation performance
    task test_shift_performance();
        `uvm_info("ALU_SEQ", "Measuring shift performance", UVM_MEDIUM)
        
        for (int i = 0; i < 250; i++) begin
            alu_sequence_item item;
            
            item = alu_sequence_item::type_id::create($sformatf("perf_shift_%0d", i));
            start_item(item);
            
            if (!item.randomize() with {
                operation inside {ALU_SLL, ALU_SRL, ALU_SRA};
                scenario == SCENARIO_PERFORMANCE;
                operand_b inside {[0:31]};
            }) begin
                `uvm_error("ALU_SEQ", "Shift performance randomization failed")
                continue;
            end
            
            finish_item(item);
            instruction_count++;
        end
    endtask
    
    // Test mixed operation performance
    task test_mixed_performance();
        `uvm_info("ALU_SEQ", "Measuring mixed operation performance", UVM_MEDIUM)
        
        for (int i = 0; i < 250; i++) begin
            alu_sequence_item item;
            
            item = alu_sequence_item::type_id::create($sformatf("perf_mixed_%0d", i));
            start_item(item);
            
            if (!item.randomize() with {
                scenario == SCENARIO_PERFORMANCE;
            }) begin
                `uvm_error("ALU_SEQ", "Mixed performance randomization failed")
                continue;
            end
            
            finish_item(item);
            instruction_count++;
        end
    endtask

endclass : alu_performance_sequence

// Stress test sequence for resource exhaustion testing
class alu_stress_sequence extends alu_base_sequence;
    
    `uvm_object_utils(alu_stress_sequence)
    
    function new(string name = "alu_stress_sequence");
        super.new(name);
        num_transactions = 5000;  // High stress load
    endfunction
    
    virtual task body();
        `uvm_info("ALU_SEQ", "Starting stress test sequence", UVM_LOW)
        
        // High-intensity testing with all patterns and operations
        for (int i = 0; i < num_transactions; i++) begin
            alu_sequence_item item;
            
            item = alu_sequence_item::type_id::create($sformatf("stress_%0d", i));
            start_item(item);
            
            if (!item.randomize() with {
                scenario == SCENARIO_STRESS;
                enable_overflow_test dist {1 := 30, 0 := 70};
                enable_underflow_test dist {1 := 30, 0 := 70};
            }) begin
                `uvm_error("ALU_SEQ", $sformatf("Stress randomization failed for transaction %0d", i))
                continue;
            end
            
            finish_item(item);
            
            // Periodic progress reporting for long stress test
            if (i % 500 == 0) begin
                `uvm_info("ALU_SEQ", $sformatf("Stress test progress: %0d/%0d (%0.1f%%)", 
                         i, num_transactions, (real'(i)/real'(num_transactions))*100.0), UVM_LOW)
            end
        end
        
        `uvm_info("ALU_SEQ", "Stress test sequence completed", UVM_LOW)
    endtask

endclass : alu_stress_sequence