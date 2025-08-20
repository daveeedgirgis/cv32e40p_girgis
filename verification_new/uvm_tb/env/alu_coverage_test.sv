// =============================================================================
// ALU Coverage Model Test - Stage 3
//
// Simple test to validate the coverage model and closure methodology
// =============================================================================

class alu_coverage_test extends alu_base_test;
    
    `uvm_component_utils(alu_coverage_test)
    
    // Coverage model and closure instances
    alu_coverage_model coverage_model;
    alu_verification_closure closure_system;
    
    function new(string name = "alu_coverage_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Create coverage model
        coverage_model = alu_coverage_model::type_id::create("coverage_model");
        
        // Create closure system
        closure_system = alu_verification_closure::type_id::create("closure_system");
        closure_system.set_coverage_model(coverage_model);
        
        `uvm_info("COV_TEST", "Coverage test components created", UVM_MEDIUM)
    endfunction
    
    task run_phase(uvm_phase phase);
        alu_transaction trans;
        int num_transactions = 50; // Small test
        
        phase.raise_objection(this);
        
        `uvm_info("COV_TEST", "=== Starting Coverage Model Test ===", UVM_LOW)
        
        // Generate some test transactions
        for (int i = 0; i < num_transactions; i++) begin
            trans = alu_transaction::type_id::create($sformatf("trans_%0d", i));
            
            // Randomize transaction
            if (!trans.randomize()) begin
                `uvm_error("COV_TEST", "Transaction randomization failed")
            end
            
            // Sample coverage
            coverage_model.sample_transaction(trans);
            
            // Periodic closure analysis
            if (i % 10 == 9) begin
                closure_system.perform_closure_analysis();
            end
            
            #10ns; // Small delay
        end
        
        // Final coverage report
        `uvm_info("COV_TEST", "=== Final Coverage Analysis ===", UVM_LOW)
        coverage_model.generate_coverage_report();
        coverage_model.identify_coverage_holes();
        
        // Final closure analysis
        closure_system.perform_closure_analysis();
        
        `uvm_info("COV_TEST", "=== Coverage Test Complete ===", UVM_LOW)
        
        phase.drop_objection(this);
    endtask
    
endclass : alu_coverage_test