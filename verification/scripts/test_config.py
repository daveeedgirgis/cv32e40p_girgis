#!/usr/bin/env python3
"""
Configuration Test Script

Tests the YAML configuration file for proper structure and valid values
"""

import yaml
import sys
import os

def print_info(msg):
    print(f"\033[34m[INFO]\033[0m {msg}")

def print_success(msg):
    print(f"\033[32m[SUCCESS]\033[0m {msg}")

def print_warning(msg):
    print(f"\033[33m[WARNING]\033[0m {msg}")

def print_error(msg):
    print(f"\033[31m[ERROR]\033[0m {msg}")

def test_configuration():
    """Test the YAML configuration file"""
    
    script_dir = os.path.dirname(os.path.abspath(__file__))
    verification_dir = os.path.dirname(script_dir)
    config_file = os.path.join(verification_dir, "uvm_alu_tb", "config", "alu_test_config.yaml")
    
    print_info("=== Configuration File Test ===")
    print_info(f"Testing configuration file: {config_file}")
    
    if not os.path.exists(config_file):
        print_error(f"Configuration file not found: {config_file}")
        return False
    
    try:
        with open(config_file, 'r') as f:
            config = yaml.safe_load(f)
        print_success("YAML file parsed successfully")
    except yaml.YAMLError as e:
        print_error(f"YAML parsing error: {e}")
        return False
    except Exception as e:
        print_error(f"Error reading file: {e}")
        return False
    
    # Test required sections
    required_sections = [
        'test_control',
        'alu_operations', 
        'instruction_weights',
        'operand_control',
        'memory_config',
        'coverage_config',
        'debug_config',
        'simulation_config',
        'file_lists',
        'test_config'
    ]
    
    errors = 0
    for section in required_sections:
        if section in config:
            print_success(f"Found required section: {section}")
        else:
            print_error(f"Missing required section: {section}")
            errors += 1
    
    # Test specific configuration values
    if 'test_control' in config:
        tc = config['test_control']
        
        # Test numeric values
        if isinstance(tc.get('num_instructions'), int) and tc['num_instructions'] > 0:
            print_success(f"Valid num_instructions: {tc['num_instructions']}")
        else:
            print_warning("Invalid or missing num_instructions")
            errors += 1
            
        if isinstance(tc.get('test_timeout_cycles'), int) and tc['test_timeout_cycles'] > 0:
            print_success(f"Valid test_timeout_cycles: {tc['test_timeout_cycles']}")
        else:
            print_warning("Invalid or missing test_timeout_cycles")
            errors += 1
    
    # Test ALU operations
    if 'alu_operations' in config:
        alu_ops = config['alu_operations']
        operation_types = [
            'enable_arithmetic',
            'enable_logic', 
            'enable_shift',
            'enable_comparison'
        ]
        
        for op_type in operation_types:
            if op_type in alu_ops and isinstance(alu_ops[op_type], bool):
                print_success(f"Valid {op_type}: {alu_ops[op_type]}")
            else:
                print_warning(f"Invalid or missing {op_type}")
                errors += 1
    
    # Test file lists
    if 'file_lists' in config:
        file_lists = config['file_lists']
        if 'rtl_files' in file_lists and isinstance(file_lists['rtl_files'], list):
            rtl_count = len(file_lists['rtl_files'])
            print_success(f"RTL file list found with {rtl_count} files")
        else:
            print_warning("Missing or invalid RTL file list")
            errors += 1
            
        if 'verification_files' in file_lists and isinstance(file_lists['verification_files'], list):
            verif_count = len(file_lists['verification_files'])
            print_success(f"Verification file list found with {verif_count} files")
        else:
            print_warning("Missing or invalid verification file list")
            errors += 1
    
    # Test available tests
    if 'test_config' in config and 'available_tests' in config['test_config']:
        tests = config['test_config']['available_tests']
        if isinstance(tests, list) and len(tests) > 0:
            print_success(f"Found {len(tests)} available test configurations")
            for test in tests:
                if 'name' in test and 'description' in test:
                    print_info(f"  - {test['name']}: {test['description']}")
                else:
                    print_warning(f"Test missing name or description: {test}")
                    errors += 1
        else:
            print_warning("No available tests found")
            errors += 1
    
    # Summary
    print_info("=== Configuration Test Summary ===")
    if errors == 0:
        print_success("Configuration file validation PASSED")
        print_info("Configuration is ready for use")
        return True
    else:
        print_error(f"Configuration file validation FAILED with {errors} errors")
        return False

def main():
    """Main function"""
    success = test_configuration()
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()