// =============================================================================
// ALU Testbench Configuration Class
//
// Configuration object that controls all aspects of the ALU verification
// environment including test parameters, coverage settings, and operation modes
// =============================================================================

class alu_tb_config extends uvm_object;
    
    // UVM Factory registration
    `uvm_object_utils(alu_tb_config)
    
    // Test Control Parameters
    int num_instructions = 1000;           // Number of instructions to execute per test
    int test_timeout_cycles = 10000;       // Maximum cycles before test timeout
    bit enable_scoreboard = 1;             // Enable/disable scoreboard checking
    bit enable_coverage = 1;               // Enable/disable functional coverage
    
    // ALU Operation Control
    bit enable_arithmetic_ops = 1;         // Enable ADD, SUB, etc.
    bit enable_logic_ops = 1;              // Enable AND, OR, XOR
    bit enable_shift_ops = 1;              // Enable SLL, SRL, SRA, ROR
    bit enable_comparison_ops = 1;          // Enable LT, EQ, GT, etc.
    bit enable_bit_manipulation = 1;       // Enable BSET, BCLR, etc.
    bit enable_division_ops = 1;           // Enable DIV, REM operations
    bit enable_pulp_extensions = 0;        // Enable PULP custom operations
    
    // Operand Generation Control
    int operand_min_value = -2147483648;   // Minimum 32-bit signed value
    int operand_max_value = 2147483647;    // Maximum 32-bit signed value
    bit enable_corner_cases = 1;          // Include special values (0, max, min)
    bit enable_random_operands = 1;       // Generate random operand values
    
    // Memory Configuration
    bit [31:0] instruction_base_addr = 32'h80; // Base address for instructions
    bit [31:0] data_base_addr = 32'h1000;      // Base address for data
    int instruction_memory_size = 4096;        // Size of instruction memory in bytes
    int data_memory_size = 4096;               // Size of data memory in bytes
    
    // Coverage Configuration
    bit enable_instruction_coverage = 1;   // Cover instruction types
    bit enable_operand_coverage = 1;       // Cover operand value ranges
    bit enable_result_coverage = 1;        // Cover result value ranges
    bit enable_sequence_coverage = 1;      // Cover instruction sequences
    
    // Debug and Logging Control
    uvm_verbosity verbosity_level = UVM_MEDIUM;  // Default verbosity
    bit enable_waveform_dump = 1;                // Enable waveform generation
    bit enable_transaction_logging = 1;          // Log all transactions
    bit enable_alu_signal_logging = 1;           // Log ALU internal signals
    
    // Randomization Control
    int random_seed = 1;                   // Seed for randomization
    bit use_fixed_seed = 0;                // Use fixed seed for reproducibility
    
    // Instruction Mix Configuration
    // Weights for different instruction types (higher = more likely)
    int arithmetic_weight = 30;
    int logic_weight = 20;
    int shift_weight = 15;
    int comparison_weight = 20;
    int load_store_weight = 10;
    int branch_weight = 5;
    
    // Constructor
    function new(string name = "alu_tb_config");
        super.new(name);
    endfunction
    
    // Function to validate configuration settings
    function bit validate_config();
        bit valid = 1;
        
        // Check basic parameters
        if (num_instructions <= 0) begin
            `uvm_error("CONFIG", "num_instructions must be positive")
            valid = 0;
        end
        
        if (test_timeout_cycles <= num_instructions) begin
            `uvm_error("CONFIG", "test_timeout_cycles should be larger than num_instructions")
            valid = 0;
        end
        
        // Check memory configuration
        if (instruction_memory_size < (num_instructions * 4)) begin
            `uvm_warning("CONFIG", "instruction_memory_size may be too small for test")
        end
        
        // Check that at least one operation type is enabled
        if (!enable_arithmetic_ops && !enable_logic_ops && !enable_shift_ops && 
            !enable_comparison_ops && !enable_bit_manipulation && !enable_division_ops) begin
            `uvm_error("CONFIG", "At least one ALU operation type must be enabled")
            valid = 0;
        end
        
        return valid;
    endfunction
    
    // Function to print configuration summary
    function void print_config();
        `uvm_info("CONFIG", "=== ALU Testbench Configuration ===", UVM_LOW)
        `uvm_info("CONFIG", $sformatf("Number of instructions: %0d", num_instructions), UVM_LOW)
        `uvm_info("CONFIG", $sformatf("Test timeout cycles: %0d", test_timeout_cycles), UVM_LOW)
        `uvm_info("CONFIG", $sformatf("Scoreboard enabled: %0b", enable_scoreboard), UVM_LOW)
        `uvm_info("CONFIG", $sformatf("Coverage enabled: %0b", enable_coverage), UVM_LOW)
        `uvm_info("CONFIG", "--- Operation Types Enabled ---", UVM_LOW)
        `uvm_info("CONFIG", $sformatf("Arithmetic: %0b", enable_arithmetic_ops), UVM_LOW)
        `uvm_info("CONFIG", $sformatf("Logic: %0b", enable_logic_ops), UVM_LOW)
        `uvm_info("CONFIG", $sformatf("Shift: %0b", enable_shift_ops), UVM_LOW)
        `uvm_info("CONFIG", $sformatf("Comparison: %0b", enable_comparison_ops), UVM_LOW)
        `uvm_info("CONFIG", $sformatf("Bit Manipulation: %0b", enable_bit_manipulation), UVM_LOW)
        `uvm_info("CONFIG", $sformatf("Division: %0b", enable_division_ops), UVM_LOW)
        `uvm_info("CONFIG", $sformatf("PULP Extensions: %0b", enable_pulp_extensions), UVM_LOW)
        `uvm_info("CONFIG", "===================================", UVM_LOW)
    endfunction
    
    // Function to get enabled operation types
    function alu_opcode_e get_random_enabled_operation();
        alu_opcode_e enabled_ops[$];
        
        // Build list of enabled operations
        if (enable_arithmetic_ops) begin
            enabled_ops.push_back(ALU_ADD);
            enabled_ops.push_back(ALU_SUB);
            enabled_ops.push_back(ALU_ADDU);
            enabled_ops.push_back(ALU_SUBU);
        end
        
        if (enable_logic_ops) begin
            enabled_ops.push_back(ALU_AND);
            enabled_ops.push_back(ALU_OR);
            enabled_ops.push_back(ALU_XOR);
        end
        
        if (enable_shift_ops) begin
            enabled_ops.push_back(ALU_SLL);
            enabled_ops.push_back(ALU_SRL);
            enabled_ops.push_back(ALU_SRA);
            enabled_ops.push_back(ALU_ROR);
        end
        
        if (enable_comparison_ops) begin
            enabled_ops.push_back(ALU_LTS);
            enabled_ops.push_back(ALU_LTU);
            enabled_ops.push_back(ALU_GTS);
            enabled_ops.push_back(ALU_GTU);
            enabled_ops.push_back(ALU_EQ);
            enabled_ops.push_back(ALU_NE);
        end
        
        if (enable_division_ops) begin
            enabled_ops.push_back(ALU_DIV);
            enabled_ops.push_back(ALU_DIVU);
            enabled_ops.push_back(ALU_REM);
            enabled_ops.push_back(ALU_REMU);
        end
        
        if (enabled_ops.size() == 0) begin
            `uvm_fatal("CONFIG", "No ALU operations enabled")
        end
        
        // Return random operation from enabled list
        return enabled_ops[$urandom_range(enabled_ops.size()-1)];
    endfunction

endclass : alu_tb_config