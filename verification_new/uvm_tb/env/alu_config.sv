// =============================================================================
// ALU Configuration Class - Stage 1
//
// UVM configuration object that controls all aspects of ALU verification
// Reads from YAML configuration file and provides centralized test control
// =============================================================================

class alu_config extends uvm_object;
    
    // UVM Factory registration
    `uvm_object_utils(alu_config)
    
    // Test Control Parameters
    int unsigned        num_instructions;           // Number of instructions to execute
    int unsigned        test_timeout_cycles;        // Maximum simulation cycles
    int unsigned        random_seed;                // Random seed for reproducibility
    uvm_verbosity       verbosity_level;           // UVM verbosity level
    bit                 enable_scoreboard;          // Enable result checking
    bit                 enable_coverage;            // Enable coverage collection
    bit                 stop_on_error;              // Stop on first error
    
    // ALU Operation Control - Which operations to enable
    bit                 enable_arithmetic;          // ADD, SUB, ADDU, SUBU
    bit                 enable_logic;               // AND, OR, XOR
    bit                 enable_shift;               // SLL, SRL, SRA, ROR
    bit                 enable_comparison;          // LT, LTU, EQ, NE, etc.
    bit                 enable_bit_manipulation;    // BSET, BCLR, BEXT (PULP)
    bit                 enable_division;            // DIV, REM (multicycle)
    bit                 enable_min_max;             // MIN, MAX operations
    bit                 enable_abs_clip;            // ABS, CLIP operations
    
    // Instruction Mix Weights - Control frequency of operations
    int unsigned        arithmetic_weight;          // Weight for arithmetic ops
    int unsigned        logic_weight;               // Weight for logic ops
    int unsigned        shift_weight;               // Weight for shift ops
    int unsigned        comparison_weight;          // Weight for comparison ops
    int unsigned        immediate_weight;           // Weight for immediate ops
    
    // Operand Generation Control
    bit                 enable_corner_cases;        // Include corner case values
    bit                 enable_random_operands;     // Generate random values
    int                 operand_min_value;          // Minimum operand value
    int                 operand_max_value;          // Maximum operand value
    int unsigned        corner_case_percentage;     // Percentage of corner cases
    logic [31:0]        corner_case_values[];       // Array of corner case values
    
    // Memory Configuration
    logic [31:0]        instruction_base_addr;      // Base address for instructions
    logic [31:0]        data_base_addr;             // Base address for data
    int unsigned        instruction_memory_size;    // Instruction memory size
    int unsigned        data_memory_size;           // Data memory size
    int unsigned        memory_latency_cycles;      // Memory response latency
    
    // Coverage Configuration
    bit                 enable_instruction_coverage; // Cover instruction types
    bit                 enable_operand_coverage;     // Cover operand ranges
    bit                 enable_result_coverage;      // Cover result ranges
    bit                 enable_operation_coverage;   // Cover ALU operations
    bit                 enable_cross_coverage;       // Cross coverage
    int unsigned        functional_coverage_goal;    // Target functional coverage %
    int unsigned        code_coverage_goal;          // Target code coverage %
    
    // Debug and Logging Control
    bit                 enable_waveform_dump;        // Generate waveforms
    string              waveform_format;             // "vcd" or "fsdb"
    bit                 enable_transaction_logging;  // Log UVM transactions
    bit                 enable_alu_signal_logging;   // Log ALU signals
    bit                 enable_instruction_trace;    // Trace instructions
    string              log_file_name;               // Main log file
    
    // Performance Monitoring
    bit                 enable_performance_monitoring; // Monitor performance
    int unsigned        report_interval_instructions;  // Progress report interval
    
    // Virtual interface handles (set by testbench)
    virtual cv32e40p_if     processor_vif;          // Processor interface
    virtual alu_monitor_if  alu_monitor_vif;        // ALU monitor interface
    
    // Constructor
    function new(string name = "alu_config");
        super.new(name);
        
        // Set default values
        set_default_values();
    endfunction
    
    // Set default configuration values
    function void set_default_values();
        // Test control defaults
        num_instructions = 1000;
        test_timeout_cycles = 100000;
        random_seed = 1;
        verbosity_level = UVM_MEDIUM;
        enable_scoreboard = 1;
        enable_coverage = 1;
        stop_on_error = 0;
        
        // ALU operation defaults - enable basic operations for Stage 1
        enable_arithmetic = 1;
        enable_logic = 1;
        enable_shift = 1;
        enable_comparison = 1;
        enable_bit_manipulation = 0;    // Disable advanced PULP operations
        enable_division = 0;            // Disable slow operations
        enable_min_max = 0;
        enable_abs_clip = 0;
        
        // Instruction mix defaults
        arithmetic_weight = 30;
        logic_weight = 25;
        shift_weight = 20;
        comparison_weight = 15;
        immediate_weight = 10;
        
        // Operand generation defaults
        enable_corner_cases = 1;
        enable_random_operands = 1;
        operand_min_value = -2147483648;  // 32-bit signed minimum
        operand_max_value = 2147483647;   // 32-bit signed maximum
        corner_case_percentage = 15;
        
        // Initialize corner case values
        corner_case_values = new[7];
        corner_case_values[0] = 32'h00000000;  // Zero
        corner_case_values[1] = 32'hFFFFFFFF;  // All ones (-1)
        corner_case_values[2] = 32'h7FFFFFFF;  // Max positive
        corner_case_values[3] = 32'h80000000;  // Max negative
        corner_case_values[4] = 32'h00000001;  // One
        corner_case_values[5] = 32'h55555555;  // Alternating pattern
        corner_case_values[6] = 32'hAAAAAAAA;  // Alternating pattern
        
        // Memory defaults
        instruction_base_addr = 32'h00000080;
        data_base_addr = 32'h00001000;
        instruction_memory_size = 8192;
        data_memory_size = 8192;
        memory_latency_cycles = 1;
        
        // Coverage defaults
        enable_instruction_coverage = 1;
        enable_operand_coverage = 1;
        enable_result_coverage = 1;
        enable_operation_coverage = 1;
        enable_cross_coverage = 1;
        functional_coverage_goal = 95;
        code_coverage_goal = 90;
        
        // Debug defaults
        enable_waveform_dump = 1;
        waveform_format = "fsdb";
        enable_transaction_logging = 1;
        enable_alu_signal_logging = 1;
        enable_instruction_trace = 1;
        log_file_name = "alu_test.log";
        
        // Performance defaults
        enable_performance_monitoring = 1;
        report_interval_instructions = 1000;
    endfunction
    
    // Load configuration from YAML file (simplified for Stage 1)
    function void load_from_yaml(string yaml_file);
        // For Stage 1, we'll use default values
        // In Stage 2/3, we can add Python script integration for YAML parsing
        `uvm_info("ALU_CONFIG", $sformatf("Using default configuration (YAML parsing in Stage 2)"), UVM_LOW)
    endfunction
    
    // Validate configuration parameters
    function bit validate_config();
        bit valid = 1;
        
        // Check basic parameters
        if (num_instructions == 0) begin
            `uvm_error("ALU_CONFIG", "num_instructions must be > 0")
            valid = 0;
        end
        
        if (test_timeout_cycles < num_instructions * 10) begin
            `uvm_warning("ALU_CONFIG", "test_timeout_cycles may be too small")
        end
        
        // Check that at least one operation type is enabled
        if (!(enable_arithmetic || enable_logic || enable_shift || enable_comparison)) begin
            `uvm_error("ALU_CONFIG", "At least one ALU operation type must be enabled")
            valid = 0;
        end
        
        // Check weight values
        if ((arithmetic_weight + logic_weight + shift_weight + comparison_weight) == 0) begin
            `uvm_error("ALU_CONFIG", "Total instruction weights cannot be zero")
            valid = 0;
        end
        
        // Check operand ranges
        if (operand_min_value >= operand_max_value) begin
            `uvm_error("ALU_CONFIG", "operand_min_value must be < operand_max_value")
            valid = 0;
        end
        
        // Check corner case percentage
        if (corner_case_percentage > 100) begin
            `uvm_error("ALU_CONFIG", "corner_case_percentage must be <= 100")
            valid = 0;
        end
        
        // Check memory configuration
        if (instruction_memory_size == 0 || data_memory_size == 0) begin
            `uvm_error("ALU_CONFIG", "Memory sizes must be > 0")
            valid = 0;
        end
        
        // Check coverage goals
        if (functional_coverage_goal > 100 || code_coverage_goal > 100) begin
            `uvm_warning("ALU_CONFIG", "Coverage goals > 100% are not realistic")
        end
        
        return valid;
    endfunction
    
    // Print configuration summary
    function void print_config();
        `uvm_info("ALU_CONFIG", "=== ALU Testbench Configuration ===", UVM_LOW)
        `uvm_info("ALU_CONFIG", $sformatf("Instructions: %0d", num_instructions), UVM_LOW)
        `uvm_info("ALU_CONFIG", $sformatf("Timeout: %0d cycles", test_timeout_cycles), UVM_LOW)
        `uvm_info("ALU_CONFIG", $sformatf("Random seed: %0d", random_seed), UVM_LOW)
        `uvm_info("ALU_CONFIG", $sformatf("Verbosity: %s", verbosity_level.name()), UVM_LOW)
        
        `uvm_info("ALU_CONFIG", "--- Enabled Operations ---", UVM_LOW)
        if (enable_arithmetic) `uvm_info("ALU_CONFIG", "✓ Arithmetic operations", UVM_LOW)
        if (enable_logic) `uvm_info("ALU_CONFIG", "✓ Logic operations", UVM_LOW)
        if (enable_shift) `uvm_info("ALU_CONFIG", "✓ Shift operations", UVM_LOW)
        if (enable_comparison) `uvm_info("ALU_CONFIG", "✓ Comparison operations", UVM_LOW)
        if (enable_bit_manipulation) `uvm_info("ALU_CONFIG", "✓ Bit manipulation", UVM_LOW)
        if (enable_division) `uvm_info("ALU_CONFIG", "✓ Division operations", UVM_LOW)
        
        `uvm_info("ALU_CONFIG", "--- Instruction Weights ---", UVM_LOW)
        `uvm_info("ALU_CONFIG", $sformatf("Arithmetic: %0d", arithmetic_weight), UVM_LOW)
        `uvm_info("ALU_CONFIG", $sformatf("Logic: %0d", logic_weight), UVM_LOW)
        `uvm_info("ALU_CONFIG", $sformatf("Shift: %0d", shift_weight), UVM_LOW)
        `uvm_info("ALU_CONFIG", $sformatf("Comparison: %0d", comparison_weight), UVM_LOW)
        
        `uvm_info("ALU_CONFIG", "--- Coverage Settings ---", UVM_LOW)
        `uvm_info("ALU_CONFIG", $sformatf("Functional goal: %0d%%", functional_coverage_goal), UVM_LOW)
        `uvm_info("ALU_CONFIG", $sformatf("Code goal: %0d%%", code_coverage_goal), UVM_LOW)
        
        `uvm_info("ALU_CONFIG", "--- Debug Settings ---", UVM_LOW)
        if (enable_waveform_dump) `uvm_info("ALU_CONFIG", $sformatf("✓ Waveforms (%s)", waveform_format), UVM_LOW)
        if (enable_transaction_logging) `uvm_info("ALU_CONFIG", "✓ Transaction logging", UVM_LOW)
        if (enable_instruction_trace) `uvm_info("ALU_CONFIG", "✓ Instruction trace", UVM_LOW)
        
        `uvm_info("ALU_CONFIG", "=====================================", UVM_LOW)
    endfunction
    
    // Get total instruction weight for normalization
    function int unsigned get_total_weight();
        return arithmetic_weight + logic_weight + shift_weight + comparison_weight + immediate_weight;
    endfunction
    
    // Check if specific operation type is enabled
    function bit is_operation_enabled(string op_type);
        case (op_type.tolower())
            "arithmetic": return enable_arithmetic;
            "logic": return enable_logic;
            "shift": return enable_shift;
            "comparison": return enable_comparison;
            "bit_manipulation": return enable_bit_manipulation;
            "division": return enable_division;
            "min_max": return enable_min_max;
            "abs_clip": return enable_abs_clip;
            default: return 0;
        endcase
    endfunction
    
    // Get random corner case value
    function logic [31:0] get_random_corner_case();
        int index = $urandom_range(corner_case_values.size() - 1);
        return corner_case_values[index];
    endfunction
    
    // Convert to string for debugging
    function string convert2string();
        string s;
        s = $sformatf("ALU Config: instr=%0d, timeout=%0d, seed=%0d", 
                     num_instructions, test_timeout_cycles, random_seed);
        return s;
    endfunction

endclass : alu_config