# 🔧 Regression Test Debug Guide

## 🚨 **Issue Identified**

The regression script is failing because individual tests are timing out without creating log files. This indicates the `run_vcs.sh` script is failing immediately.

## 🔍 **Root Cause Analysis**

Based on your output, the issue is:
1. **Tests timeout** without creating log files
2. **Only alu_base_test passes** (but with 0 minutes duration)
3. **All other tests fail** with "TIMEOUT (>60 minutes)"
4. **Log files are not created** (causing grep errors)

This suggests the `run_vcs.sh` script is failing before it can create output files.

---

## 🛠️ **Debugging Steps**

### **Step 1: Test Individual Test Execution**
```bash
# Use the debug script to test a single test
./scripts/debug_single_test.sh alu_base_test
```

### **Step 2: Check Basic Prerequisites**
```bash
# Verify VCS is available
which vcs

# Check if run_vcs.sh is executable
ls -la scripts/run_vcs.sh

# Test syntax check
./scripts/syntax_check.sh
```

### **Step 3: Manual Test Execution**
```bash
# Try running a test manually to see the actual error
./scripts/run_vcs.sh alu_base_test UVM_HIGH
```

---

## 🎯 **Most Likely Issues & Solutions**

### **Issue 1: Coverage Options Problem**
The regression script adds coverage options that might not be compatible:
```bash
# The script runs:
./scripts/run_vcs.sh alu_base_test UVM_HIGH RANDOM_SEED -cm_dir coverage/...

# But run_vcs.sh might not handle the -cm_dir option correctly
```

**Solution**: Test without coverage first:
```bash
./scripts/run_all_tests.sh --quick  # Without --coverage flag
```

### **Issue 2: Path Issues**
The script might have path resolution problems.

**Solution**: Run from the correct directory:
```bash
cd ~/git_repos/cv32e40p_girgis/verification_new
./scripts/run_all_tests.sh --quick
```

### **Issue 3: VCS Environment**
VCS environment variables might not be set correctly.

**Solution**: Check VCS setup:
```bash
echo $VCS_HOME
echo $UVM_HOME
vcs -help | head -5
```

---

## 🚀 **Quick Fix Approach**

### **Option 1: Test Without Coverage (Recommended)**
```bash
# Run quick tests without coverage to isolate the issue
./scripts/run_all_tests.sh --quick

# If this works, then the issue is coverage-related
# If this fails, then the issue is with basic test execution
```

### **Option 2: Debug Single Test**
```bash
# Test one specific test to see the actual error
./scripts/debug_single_test.sh alu_base_test

# This will show you the exact error message
```

### **Option 3: Manual Test Execution**
```bash
# Run a test manually to see what happens
cd ~/git_repos/cv32e40p_girgis/verification_new
./scripts/run_vcs.sh alu_base_test UVM_MEDIUM
```

---

## 🔧 **Modified Regression Script**

I've updated the regression script with better error handling:

### **Improvements Made:**
1. **Better error reporting** - Shows actual command being run
2. **Log file checking** - Handles missing log files gracefully
3. **Debug information** - More verbose output for troubleshooting

### **New Debug Features:**
- Shows the exact command being executed
- Checks if log files are created
- Better error classification (TIMEOUT vs FAILED vs SCRIPT ERROR)

---

## 📊 **Expected vs Actual Behavior**

### **Expected:**
```
[TEST] Running alu_base_test (Stage 1 - Basic)
[INFO] Expected: 100 transactions, ~3 minutes
[SUCCESS] alu_base_test PASSED (3m, 100 trans, 2 warnings)
```

### **Actual:**
```
[TEST] Running alu_base_test (Stage 1 - Basic)
[INFO] Expected: 100 transactions, ~3 minutes
grep: .../alu_base_test_20250820_153900.log: No such file or directory
[SUCCESS] alu_base_test PASSED (0m, N/A trans, 0 warnings)
```

**Analysis**: The test "passes" but with 0 minutes and no log file, indicating the script exits immediately without running VCS.

---

## 🎯 **Recommended Action Plan**

### **Immediate Steps:**
1. **Run debug script**:
   ```bash
   ./scripts/debug_single_test.sh alu_base_test
   ```

2. **Check the output** - This will show you the exact error

3. **Fix the underlying issue** (likely coverage options or path problems)

4. **Re-run regression** once individual tests work

### **For Stage 3:**
Once we fix the regression script, you'll have:
- ✅ **Complete test data** from all 12 tests
- ✅ **Coverage databases** (if coverage works)
- ✅ **Performance metrics** for analysis
- ✅ **Comprehensive logs** for tradeoff analysis

---

## 🚀 **Next Steps**

1. **Run the debug script** to identify the exact issue:
   ```bash
   ./scripts/debug_single_test.sh alu_base_test
   ```

2. **Share the output** so we can fix the specific problem

3. **Once fixed**, re-run the regression with coverage:
   ```bash
   ./scripts/run_all_tests.sh --coverage --verbose
   ```

The regression script concept is solid and will be **perfect for Stage 3** once we resolve this execution issue. The problem is likely a simple configuration or path issue that we can fix quickly.

**Let's debug this step by step!** 🔧