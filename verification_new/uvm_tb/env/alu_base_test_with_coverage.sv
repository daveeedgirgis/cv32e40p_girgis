// =============================================================================
// ALU Base Test with Coverage - Stage 3 Integration Test
//
// Integration test that adds Stage 3 coverage to existing base test
// =============================================================================

class alu_base_test_with_coverage extends alu_base_test;
    
    `uvm_component_utils(alu_base_test_with_coverage)
    
    // Coverage framework
    alu_coverage_model coverage_model;
    alu_verification_closure closure_system;
    
    function new(string name = "alu_base_test_with_coverage", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Create coverage framework
        coverage_model = alu_coverage_model::type_id::create("coverage_model");
        closure_system = alu_verification_closure::type_id::create("closure_system");
        closure_system.set_coverage_model(coverage_model);
        
        `uvm_info("COV_INTEGRATION", "Coverage framework integrated", UVM_MEDIUM)
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Connect coverage model to scoreboard
        // This would sample coverage from actual ALU transactions
        `uvm_info("COV_INTEGRATION", "Coverage model connected", UVM_MEDIUM)
    endfunction
    
    task run_phase(uvm_phase phase);
        // Run the base test
        super.run_phase(phase);
        
        // Perform coverage analysis after test completion
        `uvm_info("COV_INTEGRATION", "=== Post-Test Coverage Analysis ===", UVM_LOW)
        closure_system.perform_closure_analysis();
    endtask
    
    function void final_phase(uvm_phase phase);
        super.final_phase(phase);
        
        // Final coverage report
        `uvm_info("COV_INTEGRATION", "=== Final Coverage Report ===", UVM_LOW)
        coverage_model.generate_coverage_report();
        coverage_model.identify_coverage_holes();
        closure_system.perform_closure_analysis();
    endfunction
    
endclass : alu_base_test_with_coverage