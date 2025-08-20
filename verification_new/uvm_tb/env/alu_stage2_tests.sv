// =============================================================================
// ALU Stage 2 Test Classes
//
// Advanced test classes for comprehensive ALU verification using Stage 2
// sequences and sophisticated verification strategies
// =============================================================================

// =============================================================================
// BASE STAGE 2 TEST CLASS
// =============================================================================

class alu_stage2_base_test extends alu_base_test;
    
    `uvm_component_utils(alu_stage2_base_test)
    
    // Stage 2 configuration
    bit enable_advanced_coverage = 1;
    bit enable_performance_analysis = 1;
    bit enable_error_injection = 0;
    
    function new(string name = "alu_stage2_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Configure environment for Stage 2
        if (enable_advanced_coverage) begin
            uvm_config_db#(bit)::set(this, "*", "enable_coverage", 1);
        end
        
        if (enable_performance_analysis) begin
            uvm_config_db#(bit)::set(this, "*", "enable_performance", 1);
        end
        
        `uvm_info("STAGE2_TEST", "Stage 2 base test configured", UVM_LOW)
    endfunction
    
    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        `uvm_info("STAGE2_TEST", "Stage 2 test environment ready", UVM_LOW)
    endfunction

endclass : alu_stage2_base_test

// =============================================================================
// EXHAUSTIVE VERIFICATION TEST
// =============================================================================

class alu_exhaustive_test extends alu_stage2_base_test;
    
    `uvm_component_utils(alu_exhaustive_test)
    
    function new(string name = "alu_exhaustive_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        alu_exhaustive_sequence exhaustive_seq;
        
        phase.raise_objection(this);
        
        `uvm_info("EXHAUSTIVE_TEST", "Starting exhaustive ALU verification", UVM_LOW)
        
        exhaustive_seq = alu_exhaustive_sequence::type_id::create("exhaustive_seq");
        exhaustive_seq.num_transactions = 1000;  // Comprehensive testing
        
        exhaustive_seq.start(env.agent.sequencer);
        
        `uvm_info("EXHAUSTIVE_TEST", "Exhaustive ALU verification completed", UVM_LOW)
        
        phase.drop_objection(this);
    endtask

endclass : alu_exhaustive_test

// =============================================================================
// DATA PATTERN VERIFICATION TEST
// =============================================================================

class alu_data_pattern_test extends alu_stage2_base_test;
    
    `uvm_component_utils(alu_data_pattern_test)
    
    function new(string name = "alu_data_pattern_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        alu_data_pattern_sequence pattern_seq;
        
        phase.raise_objection(this);
        
        `uvm_info("PATTERN_TEST", "Starting data pattern verification", UVM_LOW)
        
        pattern_seq = alu_data_pattern_sequence::type_id::create("pattern_seq");
        pattern_seq.num_transactions = 500;
        
        pattern_seq.start(env.agent.sequencer);
        
        `uvm_info("PATTERN_TEST", "Data pattern verification completed", UVM_LOW)
        
        phase.drop_objection(this);
    endtask

endclass : alu_data_pattern_test

// =============================================================================
// MIXED WORKLOAD TEST
// =============================================================================

class alu_mixed_workload_test extends alu_stage2_base_test;
    
    `uvm_component_utils(alu_mixed_workload_test)
    
    function new(string name = "alu_mixed_workload_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        alu_mixed_workload_sequence workload_seq;
        
        phase.raise_objection(this);
        
        `uvm_info("WORKLOAD_TEST", "Starting mixed workload verification", UVM_LOW)
        
        workload_seq = alu_mixed_workload_sequence::type_id::create("workload_seq");
        workload_seq.num_transactions = 2000;  // Large realistic workload
        
        workload_seq.start(env.agent.sequencer);
        
        `uvm_info("WORKLOAD_TEST", "Mixed workload verification completed", UVM_LOW)
        
        phase.drop_objection(this);
    endtask

endclass : alu_mixed_workload_test

// =============================================================================
// PIPELINE HAZARD TEST
// =============================================================================

class alu_pipeline_hazard_test extends alu_stage2_base_test;
    
    `uvm_component_utils(alu_pipeline_hazard_test)
    
    function new(string name = "alu_pipeline_hazard_test", uvm_component parent = null);
        super.new(name, parent);
        enable_performance_analysis = 1;  // Essential for hazard analysis
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        alu_pipeline_hazard_sequence hazard_seq;
        
        phase.raise_objection(this);
        
        `uvm_info("HAZARD_TEST", "Starting pipeline hazard verification", UVM_LOW)
        
        hazard_seq = alu_pipeline_hazard_sequence::type_id::create("hazard_seq");
        hazard_seq.num_transactions = 600;
        
        hazard_seq.start(env.agent.sequencer);
        
        `uvm_info("HAZARD_TEST", "Pipeline hazard verification completed", UVM_LOW)
        
        phase.drop_objection(this);
    endtask

endclass : alu_pipeline_hazard_test

// =============================================================================
// CORNER CASE TEST
// =============================================================================

class alu_corner_case_test extends alu_stage2_base_test;
    
    `uvm_component_utils(alu_corner_case_test)
    
    function new(string name = "alu_corner_case_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        alu_corner_case_sequence corner_seq;
        
        phase.raise_objection(this);
        
        `uvm_info("CORNER_TEST", "Starting corner case verification", UVM_LOW)
        
        corner_seq = alu_corner_case_sequence::type_id::create("corner_seq");
        corner_seq.num_transactions = 400;
        
        corner_seq.start(env.agent.sequencer);
        
        `uvm_info("CORNER_TEST", "Corner case verification completed", UVM_LOW)
        
        phase.drop_objection(this);
    endtask

endclass : alu_corner_case_test

// =============================================================================
// PERFORMANCE ANALYSIS TEST
// =============================================================================

class alu_performance_test extends alu_stage2_base_test;
    
    `uvm_component_utils(alu_performance_test)
    
    function new(string name = "alu_performance_test", uvm_component parent = null);
        super.new(name, parent);
        enable_performance_analysis = 1;
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        alu_performance_sequence perf_seq;
        
        phase.raise_objection(this);
        
        `uvm_info("PERF_TEST", "Starting performance analysis", UVM_LOW)
        
        perf_seq = alu_performance_sequence::type_id::create("perf_seq");
        perf_seq.num_transactions = 2000;  // Large sample for accurate IPC
        
        perf_seq.start(env.agent.sequencer);
        
        // Report performance metrics
        `uvm_info("PERF_TEST", $sformatf("Performance Analysis Results:"), UVM_LOW)
        `uvm_info("PERF_TEST", $sformatf("  Instructions: %0d", perf_seq.instruction_count), UVM_LOW)
        `uvm_info("PERF_TEST", $sformatf("  Cycles: %0d", perf_seq.cycle_count), UVM_LOW)
        `uvm_info("PERF_TEST", $sformatf("  IPC: %0.3f", perf_seq.ipc_measurement), UVM_LOW)
        
        phase.drop_objection(this);
    endtask

endclass : alu_performance_test

// =============================================================================
// STRESS TEST
// =============================================================================

class alu_stress_test extends alu_stage2_base_test;
    
    `uvm_component_utils(alu_stress_test)
    
    function new(string name = "alu_stress_test", uvm_component parent = null);
        super.new(name, parent);
        enable_error_injection = 1;  // Enable error scenarios
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        alu_stress_sequence stress_seq;
        
        phase.raise_objection(this);
        
        `uvm_info("STRESS_TEST", "Starting stress test verification", UVM_LOW)
        
        stress_seq = alu_stress_sequence::type_id::create("stress_seq");
        stress_seq.num_transactions = 10000;  // High stress load
        
        stress_seq.start(env.agent.sequencer);
        
        `uvm_info("STRESS_TEST", "Stress test verification completed", UVM_LOW)
        
        phase.drop_objection(this);
    endtask

endclass : alu_stress_test

// =============================================================================
// COMPREHENSIVE STAGE 2 TEST
// =============================================================================

class alu_comprehensive_stage2_test extends alu_stage2_base_test;
    
    `uvm_component_utils(alu_comprehensive_stage2_test)
    
    function new(string name = "alu_comprehensive_stage2_test", uvm_component parent = null);
        super.new(name, parent);
        enable_advanced_coverage = 1;
        enable_performance_analysis = 1;
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        // Multiple sequence types for comprehensive verification
        alu_exhaustive_sequence exhaustive_seq;
        alu_data_pattern_sequence pattern_seq;
        alu_mixed_workload_sequence workload_seq;
        alu_corner_case_sequence corner_seq;
        alu_performance_sequence perf_seq;
        
        phase.raise_objection(this);
        
        `uvm_info("COMPREHENSIVE_TEST", "Starting comprehensive Stage 2 verification", UVM_LOW)
        
        // Phase 1: Exhaustive coverage
        `uvm_info("COMPREHENSIVE_TEST", "Phase 1: Exhaustive Coverage", UVM_LOW)
        exhaustive_seq = alu_exhaustive_sequence::type_id::create("exhaustive_seq");
        exhaustive_seq.num_transactions = 500;
        exhaustive_seq.start(env.agent.sequencer);
        
        // Phase 2: Data patterns
        `uvm_info("COMPREHENSIVE_TEST", "Phase 2: Data Pattern Testing", UVM_LOW)
        pattern_seq = alu_data_pattern_sequence::type_id::create("pattern_seq");
        pattern_seq.num_transactions = 300;
        pattern_seq.start(env.agent.sequencer);
        
        // Phase 3: Corner cases
        `uvm_info("COMPREHENSIVE_TEST", "Phase 3: Corner Case Testing", UVM_LOW)
        corner_seq = alu_corner_case_sequence::type_id::create("corner_seq");
        corner_seq.num_transactions = 200;
        corner_seq.start(env.agent.sequencer);
        
        // Phase 4: Performance analysis
        `uvm_info("COMPREHENSIVE_TEST", "Phase 4: Performance Analysis", UVM_LOW)
        perf_seq = alu_performance_sequence::type_id::create("perf_seq");
        perf_seq.num_transactions = 1000;
        perf_seq.start(env.agent.sequencer);
        
        // Phase 5: Mixed workload
        `uvm_info("COMPREHENSIVE_TEST", "Phase 5: Mixed Workload Testing", UVM_LOW)
        workload_seq = alu_mixed_workload_sequence::type_id::create("workload_seq");
        workload_seq.num_transactions = 1000;
        workload_seq.start(env.agent.sequencer);
        
        // Report final results
        `uvm_info("COMPREHENSIVE_TEST", "=== COMPREHENSIVE TEST RESULTS ===", UVM_LOW)
        `uvm_info("COMPREHENSIVE_TEST", $sformatf("Total transactions: %0d", 
                 exhaustive_seq.transaction_count + pattern_seq.transaction_count + 
                 corner_seq.transaction_count + perf_seq.instruction_count + 
                 workload_seq.transaction_count), UVM_LOW)
        `uvm_info("COMPREHENSIVE_TEST", $sformatf("Performance IPC: %0.3f", perf_seq.ipc_measurement), UVM_LOW)
        `uvm_info("COMPREHENSIVE_TEST", "Comprehensive Stage 2 verification completed", UVM_LOW)
        
        phase.drop_objection(this);
    endtask

endclass : alu_comprehensive_stage2_test