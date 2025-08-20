// =============================================================================
// CV32E40P Clock Gate - Behavioral Model for Simulation
//
// Simple behavioral clock gate for simulation purposes
// In real implementation, this would be replaced with technology-specific
// clock gating cells from the foundry library
// =============================================================================

module cv32e40p_clock_gate (
    input  logic clk_i,        // Input clock
    input  logic en_i,         // Clock enable
    input  logic scan_cg_en_i, // Scan clock gate enable (for DFT)
    output logic clk_o         // Gated output clock
);

    // Behavioral clock gating
    // In simulation, we use a simple AND gate with proper timing
    // In synthesis, this would be replaced with a proper clock gate cell
    
    logic en_latched;
    
    // Latch the enable signal on the negative edge to avoid glitches
    always_latch begin
        if (!clk_i) begin
            en_latched <= en_i || scan_cg_en_i;
        end
    end
    
    // Gate the clock
    assign clk_o = clk_i && en_latched;
    
    // Simulation assertions to check proper usage
    `ifdef SIMULATION
        // Check that enable doesn't change during high clock
        property enable_stable;
            @(posedge clk_i) disable iff (scan_cg_en_i)
            $stable(en_i);
        endproperty
        
        // Warning for enable changes during high clock (not fatal for behavioral model)
        assert property (enable_stable) else
            $warning("Clock gate enable changed during high clock - may cause glitches in real hardware");
    `endif

endmodule : cv32e40p_clock_gate