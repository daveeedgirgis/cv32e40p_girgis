#!/bin/bash
# Simple test to isolate the issue

echo "=== SIMPLE TEST DEBUG ==="
echo "Current directory: $(pwd)"
echo "Script directory: $(dirname $0)"
echo ""

# Test 1: Direct execution
echo "Test 1: Direct execution from current directory"
echo "Command: ./scripts/run_vcs.sh alu_base_test UVM_MEDIUM"
echo ""

# Create a simple log file to capture output
SIMPLE_LOG="/tmp/simple_test_$(date +%s).log"
echo "Capturing output to: $SIMPLE_LOG"

if ./scripts/run_vcs.sh alu_base_test UVM_MEDIUM > "$SIMPLE_LOG" 2>&1; then
    echo "✅ SUCCESS: Test completed"
    echo "Log file size: $(wc -l < "$SIMPLE_LOG") lines"
    echo ""
    echo "Last 10 lines of output:"
    tail -10 "$SIMPLE_LOG"
else
    echo "❌ FAILED: Test failed"
    echo "Exit code: $?"
    echo ""
    echo "First 20 lines of output:"
    head -20 "$SIMPLE_LOG"
    echo ""
    echo "Last 20 lines of output:"
    tail -20 "$SIMPLE_LOG"
fi

echo ""
echo "Full log available at: $SIMPLE_LOG"