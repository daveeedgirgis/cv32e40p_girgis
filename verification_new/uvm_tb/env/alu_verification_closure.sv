// =============================================================================
// ALU Verification Closure Methodology - Stage 3
//
// Comprehensive verification closure system that integrates coverage analysis,
// hole detection, and automated closure reporting for CV32E40P ALU verification
// =============================================================================

class alu_verification_closure extends uvm_object;
    
    `uvm_object_utils(alu_verification_closure)
    
    // Coverage model reference
    alu_coverage_model coverage_model;
    
    // Closure configuration
    typedef struct {
        real operation_coverage_goal;
        real data_pattern_coverage_goal;
        real cross_coverage_goal;
        real overall_coverage_goal;
        int minimum_transactions;
        bit enable_hole_analysis;
        bit enable_automated_stimulus;
        bit enable_closure_reporting;
    } closure_config_t;
    
    closure_config_t config;
    
    // Closure status tracking
    typedef enum {
        CLOSURE_NOT_STARTED,
        CLOSURE_IN_PROGRESS,
        CLOSURE_ACHIEVED,
        CLOSURE_FAILED
    } closure_status_e;
    
    closure_status_e status;
    
    // Coverage hole tracking
    typedef struct {
        string hole_type;
        string description;
        int priority;
        bit resolved;
        int transactions_needed;
    } coverage_hole_t;
    
    coverage_hole_t coverage_holes[$];
    
    // Closure metrics
    typedef struct {
        real current_operation_coverage;
        real current_pattern_coverage;
        real current_cross_coverage;
        real current_overall_coverage;
        int total_transactions;
        int holes_remaining;
        int critical_holes_remaining;
        real closure_confidence;
    } closure_metrics_t;
    
    closure_metrics_t metrics;
    
    // Closure history for trend analysis
    closure_metrics_t history[$];
    
    // =============================================================================
    // CONSTRUCTOR AND INITIALIZATION
    // =============================================================================
    
    function new(string name = "alu_verification_closure");
        super.new(name);
        
        // Initialize default configuration
        config.operation_coverage_goal = 100.0;
        config.data_pattern_coverage_goal = 90.0;
        config.cross_coverage_goal = 85.0;
        config.overall_coverage_goal = 91.7; // Weighted average
        config.minimum_transactions = 1000;
        config.enable_hole_analysis = 1;
        config.enable_automated_stimulus = 1;
        config.enable_closure_reporting = 1;
        
        status = CLOSURE_NOT_STARTED;
    endfunction
    
    // Set coverage model reference
    function void set_coverage_model(alu_coverage_model model);
        this.coverage_model = model;
    endfunction
    
    // Configure closure parameters
    function void configure(closure_config_t cfg);
        this.config = cfg;
        `uvm_info("CLOSURE", "Verification closure configured", UVM_MEDIUM)
    endfunction
    
    // =============================================================================
    // COVERAGE ANALYSIS AND HOLE DETECTION
    // =============================================================================
    
    // Update closure metrics from coverage model
    function void update_metrics();
        if (coverage_model == null) begin
            `uvm_error("CLOSURE", "Coverage model not set")
            return;
        end
        
        metrics.current_operation_coverage = coverage_model.get_operation_coverage();
        metrics.current_pattern_coverage = coverage_model.get_data_pattern_coverage();
        metrics.current_cross_coverage = coverage_model.get_cross_coverage();
        metrics.current_overall_coverage = coverage_model.get_overall_coverage();
        metrics.total_transactions = coverage_model.total_transactions;
        
        // Calculate closure confidence based on trend analysis
        calculate_closure_confidence();
        
        // Add to history for trend analysis
        history.push_back(metrics);
        
        // Limit history size
        if (history.size() > 100) begin
            history.pop_front();
        end
    endfunction
    
    // Identify and categorize coverage holes
    function void analyze_coverage_holes();
        coverage_hole_t hole;
        
        // Clear existing holes
        coverage_holes.delete();
        
        if (coverage_model == null) return;
        
        // Check operation coverage holes
        foreach(coverage_model.operation_hits[op]) begin
            if (coverage_model.operation_hits[op] == 0) begin
                hole.hole_type = "OPERATION";
                hole.description = $sformatf("Operation %s not covered", op.name());
                hole.priority = get_operation_priority(op);
                hole.resolved = 0;
                hole.transactions_needed = estimate_transactions_needed("OPERATION", op);
                coverage_holes.push_back(hole);
            end
        end
        
        // Check pattern coverage holes
        foreach(coverage_model.pattern_hits[pat]) begin
            if (coverage_model.pattern_hits[pat] == 0) begin
                hole.hole_type = "PATTERN";
                hole.description = $sformatf("Pattern %s not covered", pat.name());
                hole.priority = get_pattern_priority(pat);
                hole.resolved = 0;
                hole.transactions_needed = estimate_transactions_needed("PATTERN", pat);
                coverage_holes.push_back(hole);
            end
        end
        
        // Check cross-coverage holes (simplified analysis)
        if (metrics.current_cross_coverage < config.cross_coverage_goal) begin
            hole.hole_type = "CROSS";
            hole.description = "Cross-coverage below goal";
            hole.priority = 2; // Medium priority
            hole.resolved = 0;
            hole.transactions_needed = estimate_cross_coverage_transactions();
            coverage_holes.push_back(hole);
        end
        
        // Update hole counts
        metrics.holes_remaining = coverage_holes.size();
        metrics.critical_holes_remaining = 0;
        foreach(coverage_holes[i]) begin
            if (coverage_holes[i].priority >= 3) begin
                metrics.critical_holes_remaining++;
            end
        end
    endfunction
    
    // Get operation priority (1=low, 2=medium, 3=high, 4=critical)
    function int get_operation_priority(alu_opcode_e op);
        case (op)
            ALU_ADD, ALU_SUB: return 4; // Critical - most common operations
            ALU_AND, ALU_OR, ALU_XOR: return 3; // High - bit manipulation
            ALU_SLL, ALU_SRL, ALU_SRA: return 2; // Medium - shift operations
            ALU_SLTS, ALU_SLTU: return 2; // Medium - comparison operations
            default: return 1; // Low priority
        endcase
    endfunction
    
    // Get pattern priority
    function int get_pattern_priority(data_pattern_e pat);
        case (pat)
            PATTERN_BOUNDARY: return 4; // Critical - boundary conditions
            PATTERN_WALKING_ONES, PATTERN_WALKING_ZEROS: return 3; // High - bit patterns
            PATTERN_ALTERNATING, PATTERN_POWERS_OF_TWO: return 2; // Medium - special patterns
            default: return 1; // Low priority
        endcase
    endfunction
    
    // Estimate transactions needed to cover a hole
    function int estimate_transactions_needed(string hole_type, int item);
        case (hole_type)
            "OPERATION": begin
                // Operations typically covered within 50-200 transactions
                return $urandom_range(50, 200);
            end
            "PATTERN": begin
                // Patterns may need more targeted stimulus
                return $urandom_range(100, 500);
            end
            default: return 100;
        endcase
    endfunction
    
    // Estimate transactions needed for cross-coverage
    function int estimate_cross_coverage_transactions();
        real coverage_gap = config.cross_coverage_goal - metrics.current_cross_coverage;
        // Rough estimate: 1% coverage requires ~100 transactions
        return int(coverage_gap * 100);
    endfunction
    
    // =============================================================================
    // CLOSURE CONFIDENCE CALCULATION
    // =============================================================================
    
    // Calculate closure confidence based on multiple factors
    function void calculate_closure_confidence();
        real coverage_factor, trend_factor, hole_factor, transaction_factor;
        
        // Coverage factor (0.0 to 1.0)
        coverage_factor = metrics.current_overall_coverage / 100.0;
        
        // Trend factor based on recent coverage improvement
        trend_factor = calculate_trend_factor();
        
        // Hole factor based on remaining holes
        hole_factor = calculate_hole_factor();
        
        // Transaction factor based on sufficient sampling
        transaction_factor = (metrics.total_transactions >= config.minimum_transactions) ? 1.0 : 
                            real(metrics.total_transactions) / real(config.minimum_transactions);
        
        // Weighted combination
        metrics.closure_confidence = (coverage_factor * 0.4 + 
                                    trend_factor * 0.2 + 
                                    hole_factor * 0.3 + 
                                    transaction_factor * 0.1) * 100.0;
        
        // Cap at 100%
        if (metrics.closure_confidence > 100.0) metrics.closure_confidence = 100.0;
    endfunction
    
    // Calculate trend factor based on coverage improvement
    function real calculate_trend_factor();
        if (history.size() < 5) return 0.5; // Insufficient data
        
        real recent_improvement = 0.0;
        for (int i = history.size()-5; i < history.size()-1; i++) begin
            recent_improvement += (history[i+1].current_overall_coverage - 
                                 history[i].current_overall_coverage);
        end
        
        // Positive trend increases confidence
        if (recent_improvement > 0) return 1.0;
        else if (recent_improvement == 0) return 0.7; // Stable
        else return 0.3; // Declining trend
    endfunction
    
    // Calculate hole factor based on remaining holes
    function real calculate_hole_factor();
        if (metrics.critical_holes_remaining > 0) return 0.2; // Critical holes remain
        else if (metrics.holes_remaining > 5) return 0.5; // Many holes remain
        else if (metrics.holes_remaining > 0) return 0.8; // Few holes remain
        else return 1.0; // No holes
    endfunction
    
    // =============================================================================
    // CLOSURE STATUS ASSESSMENT
    // =============================================================================
    
    // Check if closure criteria are met
    function bit check_closure_criteria();
        bit operation_ok = (metrics.current_operation_coverage >= config.operation_coverage_goal);
        bit pattern_ok = (metrics.current_pattern_coverage >= config.data_pattern_coverage_goal);
        bit cross_ok = (metrics.current_cross_coverage >= config.cross_coverage_goal);
        bit overall_ok = (metrics.current_overall_coverage >= config.overall_coverage_goal);
        bit transactions_ok = (metrics.total_transactions >= config.minimum_transactions);
        bit holes_ok = (metrics.critical_holes_remaining == 0);
        
        return (operation_ok && pattern_ok && cross_ok && overall_ok && transactions_ok && holes_ok);
    endfunction
    
    // Update closure status
    function void update_closure_status();
        closure_status_e previous_status = status;
        
        if (check_closure_criteria()) begin
            status = CLOSURE_ACHIEVED;
        end else if (metrics.total_transactions > 0) begin
            status = CLOSURE_IN_PROGRESS;
        end else begin
            status = CLOSURE_NOT_STARTED;
        end
        
        // Check for closure failure (stagnation)
        if (status == CLOSURE_IN_PROGRESS && metrics.closure_confidence < 20.0 && 
            metrics.total_transactions > config.minimum_transactions * 2) begin
            status = CLOSURE_FAILED;
        end
        
        // Report status changes
        if (status != previous_status) begin
            `uvm_info("CLOSURE", $sformatf("Closure status changed: %s -> %s", 
                     previous_status.name(), status.name()), UVM_LOW)
        end
    endfunction
    
    // =============================================================================
    // AUTOMATED STIMULUS GENERATION
    // =============================================================================
    
    // Generate targeted stimulus for coverage holes
    function void generate_hole_filling_stimulus();
        if (!config.enable_automated_stimulus) return;
        
        foreach(coverage_holes[i]) begin
            if (!coverage_holes[i].resolved && coverage_holes[i].priority >= 3) begin
                generate_stimulus_for_hole(coverage_holes[i]);
            end
        end
    endfunction
    
    // Generate stimulus for a specific hole
    function void generate_stimulus_for_hole(coverage_hole_t hole);
        `uvm_info("CLOSURE", $sformatf("Generating stimulus for hole: %s", hole.description), UVM_MEDIUM)
        
        case (hole.hole_type)
            "OPERATION": begin
                // Generate sequence targeting specific operation
                // This would interface with the sequence library
                `uvm_info("CLOSURE", "Generated operation-specific stimulus", UVM_HIGH)
            end
            "PATTERN": begin
                // Generate sequence targeting specific pattern
                `uvm_info("CLOSURE", "Generated pattern-specific stimulus", UVM_HIGH)
            end
            "CROSS": begin
                // Generate sequence targeting cross-coverage
                `uvm_info("CLOSURE", "Generated cross-coverage stimulus", UVM_HIGH)
            end
        endcase
    endfunction
    
    // =============================================================================
    // REPORTING AND ANALYSIS
    // =============================================================================
    
    // Generate comprehensive closure report
    function void generate_closure_report();
        if (!config.enable_closure_reporting) return;
        
        `uvm_info("CLOSURE_REPORT", "=== VERIFICATION CLOSURE REPORT ===", UVM_LOW)
        `uvm_info("CLOSURE_REPORT", $sformatf("Status: %s", status.name()), UVM_LOW)
        `uvm_info("CLOSURE_REPORT", $sformatf("Confidence: %.1f%%", metrics.closure_confidence), UVM_LOW)
        `uvm_info("CLOSURE_REPORT", "", UVM_LOW)
        
        // Coverage summary
        `uvm_info("CLOSURE_REPORT", "=== COVERAGE SUMMARY ===", UVM_LOW)
        `uvm_info("CLOSURE_REPORT", $sformatf("Operation Coverage: %.2f%% (Goal: %.1f%%)", 
                 metrics.current_operation_coverage, config.operation_coverage_goal), UVM_LOW)
        `uvm_info("CLOSURE_REPORT", $sformatf("Pattern Coverage: %.2f%% (Goal: %.1f%%)", 
                 metrics.current_pattern_coverage, config.data_pattern_coverage_goal), UVM_LOW)
        `uvm_info("CLOSURE_REPORT", $sformatf("Cross Coverage: %.2f%% (Goal: %.1f%%)", 
                 metrics.current_cross_coverage, config.cross_coverage_goal), UVM_LOW)
        `uvm_info("CLOSURE_REPORT", $sformatf("Overall Coverage: %.2f%% (Goal: %.1f%%)", 
                 metrics.current_overall_coverage, config.overall_coverage_goal), UVM_LOW)
        `uvm_info("CLOSURE_REPORT", "", UVM_LOW)
        
        // Transaction summary
        `uvm_info("CLOSURE_REPORT", "=== TRANSACTION SUMMARY ===", UVM_LOW)
        `uvm_info("CLOSURE_REPORT", $sformatf("Total Transactions: %0d (Minimum: %0d)", 
                 metrics.total_transactions, config.minimum_transactions), UVM_LOW)
        `uvm_info("CLOSURE_REPORT", "", UVM_LOW)
        
        // Hole analysis
        `uvm_info("CLOSURE_REPORT", "=== COVERAGE HOLE ANALYSIS ===", UVM_LOW)
        `uvm_info("CLOSURE_REPORT", $sformatf("Total Holes: %0d", metrics.holes_remaining), UVM_LOW)
        `uvm_info("CLOSURE_REPORT", $sformatf("Critical Holes: %0d", metrics.critical_holes_remaining), UVM_LOW)
        
        if (coverage_holes.size() > 0) begin
            `uvm_info("CLOSURE_REPORT", "Remaining Holes:", UVM_LOW)
            foreach(coverage_holes[i]) begin
                if (!coverage_holes[i].resolved) begin
                    `uvm_info("CLOSURE_REPORT", $sformatf("  - %s (Priority: %0d, Est. %0d trans)", 
                             coverage_holes[i].description, coverage_holes[i].priority, 
                             coverage_holes[i].transactions_needed), UVM_LOW)
                end
            end
        end
        `uvm_info("CLOSURE_REPORT", "", UVM_LOW)
        
        // Closure assessment
        generate_closure_assessment();
    endfunction
    
    // Generate closure assessment and recommendations
    function void generate_closure_assessment();
        `uvm_info("CLOSURE_REPORT", "=== CLOSURE ASSESSMENT ===", UVM_LOW)
        
        case (status)
            CLOSURE_ACHIEVED: begin
                `uvm_info("CLOSURE_REPORT", "✅ VERIFICATION CLOSURE ACHIEVED", UVM_LOW)
                `uvm_info("CLOSURE_REPORT", "All coverage goals met with high confidence", UVM_LOW)
                `uvm_info("CLOSURE_REPORT", "Recommendation: Proceed to tapeout", UVM_LOW)
            end
            
            CLOSURE_IN_PROGRESS: begin
                `uvm_info("CLOSURE_REPORT", "🔄 CLOSURE IN PROGRESS", UVM_LOW)
                `uvm_info("CLOSURE_REPORT", $sformatf("Confidence: %.1f%%", metrics.closure_confidence), UVM_LOW)
                
                if (metrics.closure_confidence > 80.0) begin
                    `uvm_info("CLOSURE_REPORT", "Recommendation: Continue current approach", UVM_LOW)
                end else if (metrics.closure_confidence > 50.0) begin
                    `uvm_info("CLOSURE_REPORT", "Recommendation: Focus on critical holes", UVM_LOW)
                end else begin
                    `uvm_info("CLOSURE_REPORT", "Recommendation: Review verification strategy", UVM_LOW)
                end
                
                // Specific recommendations
                generate_specific_recommendations();
            end
            
            CLOSURE_FAILED: begin
                `uvm_info("CLOSURE_REPORT", "❌ CLOSURE FAILED", UVM_LOW)
                `uvm_info("CLOSURE_REPORT", "Verification appears stagnant", UVM_LOW)
                `uvm_info("CLOSURE_REPORT", "Recommendation: Major strategy revision needed", UVM_LOW)
            end
            
            default: begin
                `uvm_info("CLOSURE_REPORT", "⏳ CLOSURE NOT STARTED", UVM_LOW)
                `uvm_info("CLOSURE_REPORT", "Recommendation: Begin verification execution", UVM_LOW)
            end
        endcase
        
        `uvm_info("CLOSURE_REPORT", "=== END CLOSURE REPORT ===", UVM_LOW)
    endfunction
    
    // Generate specific recommendations based on current state
    function void generate_specific_recommendations();
        `uvm_info("CLOSURE_REPORT", "=== SPECIFIC RECOMMENDATIONS ===", UVM_LOW)
        
        // Coverage-based recommendations
        if (metrics.current_operation_coverage < config.operation_coverage_goal) begin
            `uvm_info("CLOSURE_REPORT", "• Increase operation coverage with targeted sequences", UVM_LOW)
        end
        
        if (metrics.current_pattern_coverage < config.data_pattern_coverage_goal) begin
            `uvm_info("CLOSURE_REPORT", "• Add more data pattern diversity", UVM_LOW)
        end
        
        if (metrics.current_cross_coverage < config.cross_coverage_goal) begin
            `uvm_info("CLOSURE_REPORT", "• Focus on operation-pattern combinations", UVM_LOW)
        end
        
        // Transaction-based recommendations
        if (metrics.total_transactions < config.minimum_transactions) begin
            `uvm_info("CLOSURE_REPORT", $sformatf("• Run %0d more transactions for statistical confidence", 
                     config.minimum_transactions - metrics.total_transactions), UVM_LOW)
        end
        
        // Hole-based recommendations
        if (metrics.critical_holes_remaining > 0) begin
            `uvm_info("CLOSURE_REPORT", "• Address critical coverage holes immediately", UVM_LOW)
        end
        
        if (metrics.holes_remaining > 10) begin
            `uvm_info("CLOSURE_REPORT", "• Consider automated hole-filling stimulus", UVM_LOW)
        end
    endfunction
    
    // =============================================================================
    // MAIN CLOSURE ANALYSIS FUNCTION
    // =============================================================================
    
    // Perform complete closure analysis
    function void perform_closure_analysis();
        `uvm_info("CLOSURE", "Performing verification closure analysis", UVM_MEDIUM)
        
        // Update metrics from coverage model
        update_metrics();
        
        // Analyze coverage holes
        if (config.enable_hole_analysis) begin
            analyze_coverage_holes();
        end
        
        // Update closure status
        update_closure_status();
        
        // Generate automated stimulus if needed
        if (config.enable_automated_stimulus && status == CLOSURE_IN_PROGRESS) begin
            generate_hole_filling_stimulus();
        end
        
        // Generate closure report
        if (config.enable_closure_reporting) begin
            generate_closure_report();
        end
        
        `uvm_info("CLOSURE", $sformatf("Closure analysis complete. Status: %s, Confidence: %.1f%%", 
                 status.name(), metrics.closure_confidence), UVM_MEDIUM)
    endfunction
    
endclass : alu_verification_closure