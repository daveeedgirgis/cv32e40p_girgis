# 🚀 Comprehensive Regression Testing Guide

## 📋 **Overview**

The `run_all_tests.sh` script runs all Stage 1 and Stage 2 tests systematically, producing detailed logs and analysis perfect for Stage 3 coverage analysis.

## ⚡ **Quick Start**

### **Quick Test Suite** (~15 minutes)
```bash
./scripts/run_all_tests.sh --quick
```
**Runs:** Stage 1 (4 tests) + Stage 2 Quick (3 tests) = **7 tests total**

### **Full Test Suite** (~2 hours)
```bash
./scripts/run_all_tests.sh --full
```
**Runs:** All Stage 1 + All Stage 2 tests = **12 tests total**

### **With Coverage Collection** (for Stage 3)
```bash
./scripts/run_all_tests.sh --coverage --verbose
```
**Perfect for Stage 3 coverage analysis!**

---

## 🎯 **Test Suite Breakdown**

### **Stage 1 Tests (Foundation)**
| Test | Duration | Transactions | Purpose |
|------|----------|--------------|---------|
| `alu_base_test` | 3 min | 100 | Basic functionality |
| `alu_arith_test` | 5 min | 200 | Arithmetic operations |
| `alu_logic_test` | 5 min | 200 | Logic operations |
| `alu_shift_test` | 5 min | 200 | Shift operations |
| **Total Stage 1** | **18 min** | **700** | **Foundation validation** |

### **Stage 2 Quick Tests**
| Test | Duration | Transactions | Purpose |
|------|----------|--------------|---------|
| `alu_data_pattern_test` | 5 min | 500 | 8 data patterns |
| `alu_corner_case_test` | 5 min | 400 | Edge conditions |
| `alu_exhaustive_test` | 10 min | 1000 | Full operation coverage |
| **Total Stage 2 Quick** | **20 min** | **1900** | **Advanced validation** |

### **Stage 2 Comprehensive Tests**
| Test | Duration | Transactions | Purpose |
|------|----------|--------------|---------|
| `alu_performance_test` | 15 min | 2000 | IPC analysis |
| `alu_mixed_workload_test` | 20 min | 2000 | Realistic patterns |
| `alu_pipeline_hazard_test` | 15 min | 600 | Hazard detection |
| `alu_comprehensive_stage2_test` | 30 min | 3000 | All phases |
| **Total Stage 2 Comprehensive** | **80 min** | **7600** | **Full verification** |

### **Stage 2 Stress Tests**
| Test | Duration | Transactions | Purpose |
|------|----------|--------------|---------|
| `alu_stress_test` | 45 min | 10000 | Reliability testing |
| **Total Stage 2 Stress** | **45 min** | **10000** | **Stress validation** |

---

## 📊 **Expected Results**

### **Quick Mode Results** (~15 minutes)
```
Total Tests: 7
Expected Transactions: ~2,600
Expected Success Rate: 100%
Stage 3 Readiness: GOOD
```

### **Full Mode Results** (~2 hours)
```
Total Tests: 12
Expected Transactions: ~20,300
Expected Success Rate: 100%
Stage 3 Readiness: EXCELLENT
```

---

## 🔧 **Command Options**

### **Basic Usage**
```bash
./scripts/run_all_tests.sh [OPTIONS]
```

### **Available Options**
| Option | Description | Use Case |
|--------|-------------|----------|
| `-q, --quick` | Quick tests only (~15 min) | Fast validation |
| `-f, --full` | Full test suite (~2 hours) | Comprehensive testing |
| `-c, --coverage` | Enable coverage collection | **Stage 3 preparation** |
| `-v, --verbose` | High verbosity (UVM_HIGH) | Debugging |
| `-h, --help` | Show help | Documentation |

### **Example Commands**
```bash
# Quick validation
./scripts/run_all_tests.sh --quick

# Full regression with coverage (perfect for Stage 3)
./scripts/run_all_tests.sh --coverage --verbose

# Quick tests with verbose output
./scripts/run_all_tests.sh -q -v

# Full suite (default)
./scripts/run_all_tests.sh
```

---

## 📁 **Output Files**

### **Directory Structure**
```
verification_new/
├── logs/regression_YYYYMMDD_HHMMSS/
│   ├── alu_base_test_YYYYMMDD_HHMMSS.log
│   ├── alu_performance_test_YYYYMMDD_HHMMSS.log
│   └── ... (individual test logs)
├── results/regression_YYYYMMDD_HHMMSS/
│   └── regression_summary_YYYYMMDD_HHMMSS.log
└── coverage/regression_YYYYMMDD_HHMMSS/
    ├── alu_base_test.vdb/
    ├── alu_performance_test.vdb/
    └── ... (coverage databases)
```

### **Key Files Generated**
1. **Individual Test Logs** - Detailed execution logs for each test
2. **Regression Summary** - Comprehensive markdown report with all results
3. **Coverage Databases** - VCS coverage data (if `--coverage` enabled)
4. **Python Analysis Script** - Automated analysis tool

---

## 📈 **Analysis Tools**

### **Automatic Python Analysis**
```bash
# Generated automatically by the script
python3 scripts/analyze_regression.py \
    --results-dir results/regression_YYYYMMDD_HHMMSS \
    --logs-dir logs/regression_YYYYMMDD_HHMMSS
```

### **Coverage Analysis** (if enabled)
```bash
# Merge all coverage databases
urg -dir coverage/regression_YYYYMMDD_HHMMSS/*.vdb \
    -report merged_coverage

# View coverage report
firefox merged_coverage/index.html
```

---

## 🎯 **Stage 3 Benefits**

### **Why This is Perfect for Stage 3:**

#### **1. Comprehensive Data Collection**
- **20,300+ transactions** across diverse test scenarios
- **Individual test logs** with detailed UVM messages
- **Performance metrics** (IPC measurements)
- **Coverage databases** ready for analysis

#### **2. Systematic Analysis**
- **Automated parsing** of test results
- **Python analysis tools** for data extraction
- **Structured reporting** for coverage model development
- **Tradeoff analysis data** from different test types

#### **3. Coverage Model Input**
- **Operation coverage data** from all tests
- **Data pattern effectiveness** measurements
- **Performance impact analysis** of different stimulus types
- **Error rate analysis** for verification quality assessment

#### **4. Verification Closure Data**
- **Success rate metrics** for verification confidence
- **Transaction volume analysis** for coverage goals
- **Test efficiency measurements** for resource planning
- **Regression baseline** for future development

---

## 🚀 **Running for Stage 3**

### **Recommended Command for Stage 3:**
```bash
./scripts/run_all_tests.sh --coverage --verbose
```

### **What This Provides:**
1. **Complete test execution** with all 12 tests
2. **Detailed coverage databases** for each test
3. **Verbose logging** for detailed analysis
4. **Performance metrics** for stimulus efficiency analysis
5. **Comprehensive summary** for coverage model development

### **Expected Stage 3 Deliverables:**
- **Coverage analysis** based on 20,300+ transactions
- **Stimulus effectiveness** evaluation from diverse test types
- **Tradeoff analysis** using performance and coverage data
- **Verification closure methodology** based on regression results

---

## 📊 **Sample Output**

### **During Execution:**
```
[HEADER] ==========================================
[HEADER]   CV32E40P ALU Verification Suite
[HEADER]      COMPREHENSIVE REGRESSION TESTING
[HEADER] ==========================================

[INFO] Mode: Full
[INFO] Coverage: Enabled
[INFO] Verbosity: High

[HEADER] === STAGE 1 TESTS (Basic UVM Foundation) ===
[TEST] Running alu_base_test (Stage 1 - Basic)
[SUCCESS] alu_base_test PASSED (3m, 100 trans, 2 warnings)

[TEST] Running alu_performance_test (Stage 2 - Performance)
[SUCCESS] alu_performance_test PASSED (15m, 2000 trans, 5 warnings)
```

### **Final Summary:**
```
[HEADER] ==========================================
[HEADER]            REGRESSION COMPLETE
[HEADER] ==========================================

[INFO] Suite Duration: 125 minutes
[INFO] Tests Run: 12
[SUCCESS] Passed: 12
[INFO] Success Rate: 100%
[INFO] Total Transactions: 20300

[HEADER] STAGE 3 READINESS:
[SUCCESS] ✅ EXCELLENT - Ready for comprehensive coverage analysis
[INFO]    • All tests passed
[INFO]    • High transaction volume (20300)
[INFO]    • Diverse test coverage

[HEADER] NEXT STEPS:
[INFO] 1. Review summary: results/regression_summary_20250820_151325.log
[INFO] 2. Analyze results: python3 scripts/analyze_regression.py --results-dir 'results/regression_20250820_151325' --logs-dir 'logs/regression_20250820_151325'
[INFO] 3. Merge coverage: urg -dir coverage/regression_20250820_151325/*.vdb -report merged_coverage
[INFO] 4. Use data for Stage 3 coverage model development
```

---

## 🎉 **Perfect for Stage 3!**

This regression testing script provides **exactly** what you need for Stage 3 coverage analysis:

✅ **Comprehensive test data** from all verification scenarios  
✅ **Detailed logs** for stimulus analysis  
✅ **Coverage databases** ready for analysis  
✅ **Performance metrics** for efficiency evaluation  
✅ **Automated analysis tools** for data extraction  
✅ **Structured reporting** for coverage model development  

**Run this before Stage 3 to get the complete dataset needed for coverage analysis and verification closure!**