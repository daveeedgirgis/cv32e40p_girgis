// =============================================================================
// Memory Sequence Item
//
// UVM sequence item for memory transactions (instruction and data memory)
// Used for OBI (Open Bus Interface) transactions with the CV32E40P
// =============================================================================

class memory_item extends uvm_sequence_item;
    
    // UVM Factory registration
    `uvm_object_utils(memory_item)
    
    // Memory transaction types
    typedef enum {
        MEM_READ,
        MEM_WRITE
    } mem_trans_type_e;
    
    // Transaction fields
    rand mem_trans_type_e trans_type;   // Read or write transaction
    rand bit [31:0] address;            // Memory address
    rand bit [31:0] data;               // Data for write, or expected data for read
    rand bit [3:0]  byte_enable;        // Byte enable signals
    
    // Response fields
    bit [31:0] read_data;               // Actual data read from memory
    bit        error;                   // Error response
    bit        granted;                 // Transaction was granted
    
    // Timing fields
    int        request_cycle;           // Cycle when request was made
    int        grant_cycle;             // Cycle when grant was received
    int        response_cycle;          // Cycle when response was received
    int        latency_cycles;          // Total transaction latency
    
    // Control fields
    bit        is_instruction_fetch;    // True for instruction memory access
    bit        immediate_grant;         // Grant immediately without delay
    bit        immediate_response;      // Respond immediately without delay
    
    // Constraints
    constraint address_alignment {
        // Word addresses should be 4-byte aligned
        if (byte_enable == 4'b1111) {
            address[1:0] == 2'b00;
        }
        // Halfword addresses should be 2-byte aligned
        else if (byte_enable inside {4'b0011, 4'b1100}) {
            address[0] == 1'b0;
        }
    }
    
    constraint byte_enable_valid {
        // Valid byte enable patterns
        byte_enable inside {
            4'b0001,  // Byte 0
            4'b0010,  // Byte 1
            4'b0100,  // Byte 2
            4'b1000,  // Byte 3
            4'b0011,  // Halfword 0
            4'b1100,  // Halfword 1
            4'b1111   // Full word
        };
    }
    
    constraint instruction_constraints {
        if (is_instruction_fetch) {
            // Instructions must be word-aligned and word-sized
            byte_enable == 4'b1111;
            address[1:0] == 2'b00;
            trans_type == MEM_READ;
        }
    }
    
    // Constructor
    function new(string name = "memory_item");
        super.new(name);
        error = 0;
        granted = 0;
        immediate_grant = 1;
        immediate_response = 1;
        is_instruction_fetch = 0;
    endfunction
    
    // Convert to string for debugging
    function string convert2string();
        string s;
        s = $sformatf("Memory Item:\n");
        s = {s, $sformatf("  Type: %s\n", trans_type.name())};
        s = {s, $sformatf("  Address: 0x%08h\n", address)};
        if (trans_type == MEM_WRITE) begin
            s = {s, $sformatf("  Write Data: 0x%08h\n", data)};
        end else begin
            s = {s, $sformatf("  Read Data: 0x%08h\n", read_data)};
        end
        s = {s, $sformatf("  Byte Enable: 0b%04b\n", byte_enable)};
        s = {s, $sformatf("  Instruction Fetch: %b\n", is_instruction_fetch)};
        if (granted) begin
            s = {s, $sformatf("  Latency: %0d cycles\n", latency_cycles)};
        end
        if (error) begin
            s = {s, "  ERROR: Transaction failed\n"};
        end
        return s;
    endfunction
    
    // Function to create instruction fetch transaction
    function void create_instruction_fetch(bit [31:0] pc);
        trans_type = MEM_READ;
        address = pc;
        byte_enable = 4'b1111;
        is_instruction_fetch = 1;
        immediate_grant = 1;
        immediate_response = 1;
    endfunction
    
    // Function to create data read transaction
    function void create_data_read(bit [31:0] addr, bit [3:0] be = 4'b1111);
        trans_type = MEM_READ;
        address = addr;
        byte_enable = be;
        is_instruction_fetch = 0;
        immediate_grant = 1;
        immediate_response = 1;
    endfunction
    
    // Function to create data write transaction
    function void create_data_write(bit [31:0] addr, bit [31:0] wdata, bit [3:0] be = 4'b1111);
        trans_type = MEM_WRITE;
        address = addr;
        data = wdata;
        byte_enable = be;
        is_instruction_fetch = 0;
        immediate_grant = 1;
        immediate_response = 1;
    endfunction
    
    // Function to check if transaction is valid
    function bit is_valid();
        // Check address alignment
        case (byte_enable)
            4'b1111: return (address[1:0] == 2'b00);  // Word aligned
            4'b0011, 4'b1100: return (address[0] == 1'b0);  // Halfword aligned
            4'b0001, 4'b0010, 4'b0100, 4'b1000: return 1;  // Byte can be any address
            default: return 0;  // Invalid byte enable
        endcase
    endfunction
    
    // Function to get transfer size in bytes
    function int get_transfer_size();
        case (byte_enable)
            4'b1111: return 4;  // Word
            4'b0011, 4'b1100: return 2;  // Halfword
            4'b0001, 4'b0010, 4'b0100, 4'b1000: return 1;  // Byte
            default: return 0;  // Invalid
        endcase
    endfunction
    
    // Function to calculate latency
    function void calculate_latency();
        if (granted && response_cycle > request_cycle) begin
            latency_cycles = response_cycle - request_cycle;
        end else begin
            latency_cycles = 0;
        end
    endfunction

endclass : memory_item