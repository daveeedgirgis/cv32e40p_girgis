# CV32E40P ALU Verification Troubleshooting Guide

## 🔧 Common Issues and Solutions

This guide provides comprehensive troubleshooting information for the CV32E40P ALU verification environment.

---

## 🚨 Environment Setup Issues

### Issue: VCS Not Found
```
[ERROR] vcs could not be found. Please ensure it's in your PATH.
```

**Root Cause**: VCS executable not in system PATH

**Solutions**:
```bash
# Option 1: Set environment variables
export VCS_HOME="/home/ubuntu/tools/synopsys/tools/vcs/W-2024.09-SP1"
export PATH="$VCS_HOME/bin:$PATH"

# Option 2: Add to shell profile
echo 'export VCS_HOME="/home/ubuntu/tools/synopsys/tools/vcs/W-2024.09-SP1"' >> ~/.bashrc
echo 'export PATH="$VCS_HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Option 3: Verify installation
which vcs
vcs -help
```

**Verification**:
```bash
cd verification_new
./scripts/compile_test.sh
```

---

### Issue: UVM Library Not Found
```
[ERROR] UVM_HOME not found: /opt/synopsys/vcs/etc/uvm
```

**Root Cause**: UVM library path incorrect

**Solutions**:
```bash
# Set correct UVM path
export UVM_HOME="/home/ubuntu/tools/synopsys/tools/vcs/W-2024.09-SP1/etc/uvm-1.2"

# Verify UVM installation
ls -la $UVM_HOME
ls -la $UVM_HOME/src/
```

**Alternative UVM Paths**:
- `/opt/synopsys/vcs/etc/uvm-1.2`
- `/usr/synopsys/vcs/etc/uvm`
- `$VCS_HOME/etc/uvm-1.2`

---

### Issue: License Problems
```
Error: License checkout failed for feature 'VCS'
```

**Solutions**:
```bash
# Check license server
lmstat -a

# Check specific feature
lmstat -f VCS

# Set license file
export LM_LICENSE_FILE="port@server:$LM_LICENSE_FILE"

# Use license wait option (already in scripts)
+vcs+lic+wait
```

---

## 🔨 Compilation Issues

### Issue: Unresolved Modules
```
Error-[URMI] Unresolved modules
Module definition of 'cv32e40p_clock_gate' is not found
```

**Root Cause**: Missing RTL modules or incorrect compilation order

**Solutions**:
```bash
# Check if behavioral clock gate exists
ls -la verification_new/rtl_sim/cv32e40p_clock_gate.sv

# If missing, create it (should be automatic)
mkdir -p verification_new/rtl_sim

# Verify file list order in run_vcs.sh
grep -A 20 "cat > files.f" scripts/run_vcs.sh
```

**File List Order Should Be**:
1. Package files first
2. Behavioral models
3. RTL modules
4. Interfaces
5. UVM package
6. Testbench top

---

### Issue: Package Import Errors
```
Error: Package 'cv32e40p_pkg' not found
```

**Root Cause**: RTL package files not in compilation list

**Solutions**:
```bash
# Check RTL package files exist
ls -la ../rtl/include/cv32e40p_pkg.sv
ls -la ../rtl/include/cv32e40p_apu_core_pkg.sv
ls -la ../rtl/include/cv32e40p_fpu_pkg.sv

# Verify they're in file list
grep "cv32e40p_pkg" scripts/run_vcs.sh
```

---

### Issue: Interface Type Mismatch
```
Error-[ICTTFC] Incompatible complex type usage
The type of the actual is 'virtual interface cv32e40p_if.mem_driver'
```

**Root Cause**: Interface modport mismatch (should be fixed in current version)

**Solutions**:
```bash
# Check interface declarations in driver/monitor
grep "virtual.*cv32e40p_if" uvm_tb/env/alu_driver.sv
grep "virtual.*alu_monitor_if" uvm_tb/env/alu_monitor.sv

# Should NOT have modports in variable declarations
# Correct: virtual cv32e40p_if vif;
# Wrong:   virtual cv32e40p_if.mem_driver vif;
```

---

## 🏃 Runtime Issues

### Issue: UVM Fatal Errors
```
UVM_FATAL [NULLITM] attempting to start a null item from sequence
```

**Root Cause**: Sequence item not properly created (should be fixed)

**Solutions**:
```bash
# Check sequence implementation
grep -A 5 "start_item" uvm_tb/env/alu_sequence_lib.sv

# Should have:
# item = alu_sequence_item::type_id::create("item");
# start_item(item);
```

---

### Issue: Simulation Hangs
```
Simulation appears to hang with no output
```

**Root Cause**: Usually clock/reset issues or infinite loops

**Debug Steps**:
```bash
# 1. Enable maximum verbosity
./scripts/run_vcs.sh alu_base_test UVM_DEBUG

# 2. Add timeout
./scripts/run_vcs.sh alu_base_test UVM_MEDIUM 1 +UVM_TIMEOUT=1000000

# 3. Check clock generation
# Look for clock toggling in waveforms

# 4. Check reset sequence
# Verify reset is properly released
```

---

### Issue: No Transactions Generated
```
UVM_INFO [ALU_SCOREBOARD] Total transactions: 0
```

**Root Cause**: Driver not receiving sequence items or DUT not responding

**Debug Steps**:
```bash
# 1. Check sequence execution
grep "Starting sequence" logs/simulation.log

# 2. Check driver activity
grep "ALU_DRIVER" logs/simulation.log

# 3. Check monitor activity
grep "ALU_MONITOR" logs/simulation.log

# 4. Enable transaction logging
./scripts/run_vcs.sh alu_base_test UVM_HIGH
```

---

## 📊 Coverage Issues

### Issue: Coverage Database Corruption
```
URG-ERROR: Cannot read coverage database
```

**Solutions**:
```bash
# Remove corrupted database
rm -rf coverage.vdb

# Re-run simulation
./scripts/run_vcs.sh alu_base_test

# Check database integrity
urg -dir coverage.vdb -show summary
```

---

### Issue: Low Coverage Numbers
```
Line coverage: 15%
Functional coverage: 0%
```

**Root Cause**: Coverage not being collected properly

**Debug Steps**:
```bash
# 1. Check coverage compilation options
grep "\-cm" scripts/run_vcs.sh

# 2. Verify coverage runtime options
grep "\-cm" scripts/run_vcs.sh

# 3. Check if DUT is being exercised
# Look for ALU signal activity in waveforms

# 4. Enable coverage debug
# Add +cm_debug to runtime options
```

---

## 🌊 Waveform Issues

### Issue: Waveform Generation Fails
```
*Verdi* ERROR: Failed to create FSDB file: 'waves/alu_test.fsdb'
```

**Solutions**:
```bash
# Create waves directory
mkdir -p waves
chmod 755 waves

# Check disk space
df -h .

# Verify Verdi/FSDB support
which verdi
echo $VERDI_HOME
```

---

### Issue: No Signals in Waveforms
```
Waveform file created but contains no signals
```

**Solutions**:
```bash
# Check if dumping is enabled
grep "fsdbfile" scripts/run_vcs.sh

# Verify dump commands in testbench
grep "dump" uvm_tb/tb/alu_tb_top.sv

# Add manual dump commands if needed
$fsdbDumpfile("waves/debug.fsdb");
$fsdbDumpvars(0, alu_tb_top);
```

---

## 🔍 Debug Techniques

### Enable Maximum Debug Information

#### 1. Compilation Debug
```bash
# Add to COMPILE_OPTS in run_vcs.sh
-debug_access+all
-debug_region+cell+encrypt
-debug_pp
```

#### 2. Runtime Debug
```bash
# Add to RUNTIME_OPTS in run_vcs.sh
-ucli
-i debug.tcl
+vcs+dumparrays
+vcs+dumpports
```

#### 3. UVM Debug
```bash
# Maximum UVM verbosity
./scripts/run_vcs.sh alu_base_test UVM_DEBUG

# Enable UVM debug features
+UVM_VERBOSITY=UVM_DEBUG
+uvm_set_verbosity=*,*,UVM_DEBUG,time
```

---

### Custom Debug Prints

#### Add Debug Messages
```systemverilog
// In driver
`uvm_info("DEBUG_DRIVER", $sformatf("Driving item: %s", item.convert2string()), UVM_LOW)

// In monitor  
`uvm_info("DEBUG_MONITOR", $sformatf("Collected: op=%s, a=0x%h, b=0x%h, result=0x%h", 
          operation.name(), operand_a, operand_b, result), UVM_LOW)

// In scoreboard
`uvm_info("DEBUG_SCOREBOARD", $sformatf("Expected: 0x%h, Actual: 0x%h", 
          expected, actual), UVM_LOW)
```

#### Conditional Debug
```systemverilog
// Enable with +define+DEBUG_MODE
`ifdef DEBUG_MODE
    `uvm_info("DEBUG", "Detailed debug information", UVM_LOW)
`endif
```

---

### Interactive Debug

#### VCS Interactive Mode
```bash
# Compile with debug
vcs -debug_access+all -f files.f

# Run interactively
./simv -gui

# Or use command line debugger
./simv -ucli -i debug.tcl
```

#### Debug TCL Script Example
```tcl
# debug.tcl
run 1000ns
scope alu_tb_top.dut.core_i.ex_stage_i.alu_i
list
dump -add * -depth 1
run
```

---

## 📋 Systematic Debug Process

### Step 1: Identify Problem Category
```bash
# Compilation issue?
./scripts/compile_test.sh

# Runtime issue?
grep "ERROR\|FATAL" logs/simulation.log

# Coverage issue?
ls -la coverage.vdb/

# Waveform issue?
ls -la waves/
```

### Step 2: Collect Information
```bash
# Environment info
echo $VCS_HOME
echo $UVM_HOME
which vcs
vcs -ID

# File structure
find . -name "*.sv" | wc -l
ls -la scripts/

# Log analysis
tail -50 logs/simulation.log
grep -i "error\|fatal\|warning" logs/simulation.log
```

### Step 3: Isolate Issue
```bash
# Test minimal case
./scripts/syntax_check.sh

# Test compilation only
./scripts/compile_test.sh

# Test with minimal verbosity
./scripts/run_vcs.sh alu_base_test UVM_LOW 1
```

### Step 4: Apply Solution
```bash
# Fix and verify
# ... apply specific solution ...

# Re-test
./scripts/stage1_test.sh
```

---

## 🚀 Performance Issues

### Issue: Slow Compilation
```
Compilation takes > 5 minutes
```

**Solutions**:
```bash
# Use parallel compilation
-j 4

# Optimize compilation options
-O3
-fast

# Reduce debug information for production runs
# Remove -debug_access+all for faster compilation
```

---

### Issue: Slow Simulation
```
Simulation runs very slowly
```

**Solutions**:
```bash
# Reduce verbosity
./scripts/run_vcs.sh alu_base_test UVM_LOW

# Disable waveform dumping
# Comment out fsdbfile options

# Use optimized runtime
+ntb_random_seed_automatic
-O3
```

---

### Issue: High Memory Usage
```
Simulation uses excessive memory
```

**Solutions**:
```bash
# Limit transaction history
# Modify scoreboard to limit stored transactions

# Use streaming for large datasets
# Process transactions immediately rather than storing

# Clean up objects
# Explicitly delete large objects when done
```

---

## 📞 Getting Help

### Information to Collect Before Asking for Help

1. **Environment Information**:
   ```bash
   echo "VCS_HOME: $VCS_HOME"
   echo "UVM_HOME: $UVM_HOME"
   vcs -ID
   uname -a
   ```

2. **Error Messages**:
   ```bash
   # Full error message from logs
   grep -A 10 -B 10 "ERROR\|FATAL" logs/simulation.log
   ```

3. **File Structure**:
   ```bash
   find . -name "*.sv" | head -20
   ls -la scripts/
   ```

4. **Test Command Used**:
   ```bash
   # Exact command that failed
   ./scripts/run_vcs.sh alu_base_test UVM_MEDIUM 1
   ```

### Self-Help Resources

1. **Check Documentation**:
   - `README.md` - Main documentation
   - `WHAT_YOU_CAN_RUN.md` - Command reference
   - `ARCHITECTURE.md` - Technical details

2. **Check Logs**:
   - `logs/simulation.log` - Main simulation log
   - `logs/compile.log` - Compilation log
   - `reports/` - Coverage and analysis reports

3. **Check Examples**:
   - Look at working test outputs in documentation
   - Compare with expected results

---

## ✅ Validation Checklist

### Before Reporting Issues

- [ ] Checked environment variables (VCS_HOME, UVM_HOME, PATH)
- [ ] Verified all files present (`./scripts/stage1_test.sh`)
- [ ] Checked basic syntax (`./scripts/syntax_check.sh`)
- [ ] Reviewed error logs thoroughly
- [ ] Tried with minimal test case
- [ ] Checked disk space and permissions
- [ ] Verified VCS license availability

### Common Quick Fixes

```bash
# Reset environment
source ~/.bashrc
export VCS_HOME="/home/ubuntu/tools/synopsys/tools/vcs/W-2024.09-SP1"
export UVM_HOME="$VCS_HOME/etc/uvm-1.2"
export PATH="$VCS_HOME/bin:$PATH"

# Clean and retry
rm -rf work_* *.vcd AN.DB coverage.vdb urgReport
rm -rf logs reports coverage waves
./scripts/run_vcs.sh

# Fix permissions
chmod +x scripts/*.sh
```

---

## 🎯 Summary

Most issues fall into these categories:
1. **Environment Setup** (70%) - VCS/UVM paths, licenses
2. **File Dependencies** (20%) - Missing files, wrong order
3. **Runtime Issues** (8%) - Clock/reset, sequence problems  
4. **Coverage/Debug** (2%) - Waveforms, coverage collection

The systematic debug process and solutions in this guide should resolve 95%+ of common issues. For complex problems, collect the information specified in the "Getting Help" section.