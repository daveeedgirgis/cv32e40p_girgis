#!/bin/bash
# Quick test of just Stage 1 tests to isolate the issue

echo "Testing Stage 1 tests individually..."

echo "=== Testing alu_base_test ==="
./scripts/run_vcs.sh alu_base_test UVM_MEDIUM
echo ""

echo "=== Testing alu_arith_test ==="
./scripts/run_vcs.sh alu_arith_test UVM_MEDIUM
echo ""

echo "=== Testing alu_logic_test ==="
./scripts/run_vcs.sh alu_logic_test UVM_MEDIUM
echo ""

echo "=== Testing alu_shift_test ==="
./scripts/run_vcs.sh alu_shift_test UVM_MEDIUM
echo ""

echo "Stage 1 test complete!"