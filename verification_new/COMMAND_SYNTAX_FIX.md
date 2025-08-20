# ⚠️ IMPORTANT: Command Syntax Correction

## 🚨 **CRITICAL FIX APPLIED**

The documentation has been updated to fix the command syntax error that was causing test failures.

## ❌ **WRONG SYNTAX (Causes Errors)**
```bash
./scripts/run_vcs.sh +UVM_TESTNAME=alu_performance_test
```

**Error Result:**
```
UVM_FATAL @ 0: reporter [INVTST] Requested test from command line +UVM_TESTNAME=+UVM_TESTNAME=alu_performance_test not found.
```

## ✅ **CORRECT SYNTAX (Works Perfectly)**
```bash
./scripts/run_vcs.sh alu_performance_test
```

**Success Result:**
```
[INFO] === CV32E40P ALU Testbench - Stage 1 ===
[INFO] Test: alu_performance_test
[SUCCESS] Compilation completed successfully
[INFO] Starting simulation...
[SUCCESS] *** PERFORMANCE TEST PASSED ***
```

## 📋 **All Correct Commands**

### **Stage 1 Tests (Basic)**
```bash
./scripts/run_vcs.sh                    # Default test (alu_base_test)
./scripts/run_vcs.sh alu_arith_test     # Arithmetic operations
./scripts/run_vcs.sh alu_logic_test     # Logic operations
./scripts/run_vcs.sh alu_shift_test     # Shift operations
```

### **Stage 2 Tests (Advanced)**
```bash
./scripts/run_vcs.sh alu_data_pattern_test      # 8 data patterns (5 min)
./scripts/run_vcs.sh alu_corner_case_test       # Edge conditions (5 min)
./scripts/run_vcs.sh alu_performance_test       # IPC analysis (15 min)
./scripts/run_vcs.sh alu_exhaustive_test        # Full coverage (10 min)
./scripts/run_vcs.sh alu_mixed_workload_test    # Realistic patterns (20 min)
./scripts/run_vcs.sh alu_pipeline_hazard_test   # Hazard detection (15 min)
./scripts/run_vcs.sh alu_stress_test            # Reliability (45 min)
./scripts/run_vcs.sh alu_comprehensive_stage2_test  # All phases (30 min)
```

### **With Custom Options**
```bash
# Custom verbosity
./scripts/run_vcs.sh alu_performance_test UVM_LOW
./scripts/run_vcs.sh alu_performance_test UVM_HIGH

# Custom seed
./scripts/run_vcs.sh alu_performance_test UVM_MEDIUM 12345

# Debug mode
./scripts/run_vcs.sh alu_corner_case_test UVM_HIGH 123 +define+DEBUG_MODE
```

## 🔧 **Why This Happened**

The script `run_vcs.sh` automatically adds the `+UVM_TESTNAME=` prefix:

```bash
# Inside run_vcs.sh (line 213):
RUNTIME_OPTS="$RUNTIME_OPTS +UVM_TESTNAME=$TEST_NAME"
```

When you provide `+UVM_TESTNAME=alu_performance_test`, it becomes:
```bash
+UVM_TESTNAME=+UVM_TESTNAME=alu_performance_test  # Double prefix = ERROR
```

## 📚 **Updated Documentation Files**

The following files have been corrected:
- ✅ `STAGE2_DETAILED_GUIDE.md` - Complete Stage 2 usage guide
- ✅ `QUICK_REFERENCE.md` - Quick command reference
- ✅ `WHAT_YOU_CAN_RUN.md` - Comprehensive command guide
- ✅ `COMMAND_SYNTAX_FIX.md` - This correction summary

## 🎯 **Next Steps**

Now you can run any test successfully:

```bash
# Try the performance test that failed before:
./scripts/run_vcs.sh alu_performance_test

# Or start with a quick test:
./scripts/run_vcs.sh alu_data_pattern_test
```

**All Stage 2 tests are now ready to run with the correct syntax!** 🎉