#!/usr/bin/env python3
"""
=============================================================================
Instruction Distribution Generator - Stage 2
=============================================================================

Advanced script for generating assembly files with target instruction distributions
for CV32E40P ALU verification. Supports configurable distributions, dependency
analysis, and realistic data flow patterns.

Author: Stage 2 Verification Team
Date: 2024
=============================================================================
"""

import json
import random
import argparse
import sys
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass
from enum import Enum
import os

# =============================================================================
# CONFIGURATION AND DATA STRUCTURES
# =============================================================================

class InstructionCategory(Enum):
    """Instruction categories for distribution analysis"""
    ARITHMETIC = "arithmetic"
    LOGIC = "logic"
    SHIFT = "shift"
    COMPARISON = "comparison"
    IMMEDIATE = "immediate"
    CUSTOM = "custom"

@dataclass
class InstructionSpec:
    """Specification for a single instruction"""
    name: str
    category: InstructionCategory
    opcode: str
    format: str  # R-type, I-type, etc.
    description: str
    weight: float = 1.0

@dataclass
class DistributionConfig:
    """Configuration for instruction distribution"""
    total_instructions: int
    seed: int
    output_file: str
    distribution: Dict[InstructionCategory, float]
    enable_dependencies: bool = True
    enable_realistic_data: bool = True
    register_reuse_probability: float = 0.3

# =============================================================================
# INSTRUCTION SET DEFINITION
# =============================================================================

class CV32E40P_InstructionSet:
    """CV32E40P instruction set definition based on RISC-V RV32I + extensions"""
    
    def __init__(self):
        self.instructions = {
            # Arithmetic Instructions
            "ADD": InstructionSpec("ADD", InstructionCategory.ARITHMETIC, "0110011", "R", "Add registers"),
            "SUB": InstructionSpec("SUB", InstructionCategory.ARITHMETIC, "0110011", "R", "Subtract registers"),
            "ADDI": InstructionSpec("ADDI", InstructionCategory.IMMEDIATE, "0010011", "I", "Add immediate"),
            
            # Logic Instructions
            "AND": InstructionSpec("AND", InstructionCategory.LOGIC, "0110011", "R", "Bitwise AND"),
            "OR": InstructionSpec("OR", InstructionCategory.LOGIC, "0110011", "R", "Bitwise OR"),
            "XOR": InstructionSpec("XOR", InstructionCategory.LOGIC, "0110011", "R", "Bitwise XOR"),
            "ANDI": InstructionSpec("ANDI", InstructionCategory.IMMEDIATE, "0010011", "I", "AND immediate"),
            "ORI": InstructionSpec("ORI", InstructionCategory.IMMEDIATE, "0010011", "I", "OR immediate"),
            "XORI": InstructionSpec("XORI", InstructionCategory.IMMEDIATE, "0010011", "I", "XOR immediate"),
            
            # Shift Instructions
            "SLL": InstructionSpec("SLL", InstructionCategory.SHIFT, "0110011", "R", "Shift left logical"),
            "SRL": InstructionSpec("SRL", InstructionCategory.SHIFT, "0110011", "R", "Shift right logical"),
            "SRA": InstructionSpec("SRA", InstructionCategory.SHIFT, "0110011", "R", "Shift right arithmetic"),
            "SLLI": InstructionSpec("SLLI", InstructionCategory.IMMEDIATE, "0010011", "I", "Shift left logical immediate"),
            "SRLI": InstructionSpec("SRLI", InstructionCategory.IMMEDIATE, "0010011", "I", "Shift right logical immediate"),
            "SRAI": InstructionSpec("SRAI", InstructionCategory.IMMEDIATE, "0010011", "I", "Shift right arithmetic immediate"),
            
            # Comparison Instructions
            "SLT": InstructionSpec("SLT", InstructionCategory.COMPARISON, "0110011", "R", "Set less than"),
            "SLTU": InstructionSpec("SLTU", InstructionCategory.COMPARISON, "0110011", "R", "Set less than unsigned"),
            "SLTI": InstructionSpec("SLTI", InstructionCategory.IMMEDIATE, "0010011", "I", "Set less than immediate"),
            "SLTIU": InstructionSpec("SLTIU", InstructionCategory.IMMEDIATE, "0010011", "I", "Set less than immediate unsigned"),
        }
        
        # Set default weights based on embedded software analysis
        self._set_default_weights()
    
    def _set_default_weights(self):
        """Set realistic weights based on embedded software patterns"""
        # High-frequency instructions
        self.instructions["ADD"].weight = 25.0
        self.instructions["ADDI"].weight = 20.0
        self.instructions["SUB"].weight = 15.0
        
        # Medium-frequency instructions
        self.instructions["AND"].weight = 8.0
        self.instructions["OR"].weight = 8.0
        self.instructions["ANDI"].weight = 6.0
        self.instructions["ORI"].weight = 6.0
        
        # Lower-frequency instructions
        self.instructions["XOR"].weight = 4.0
        self.instructions["XORI"].weight = 3.0
        self.instructions["SLL"].weight = 3.0
        self.instructions["SRL"].weight = 3.0
        self.instructions["SRA"].weight = 2.0
        
        # Specialized instructions
        self.instructions["SLT"].weight = 1.5
        self.instructions["SLTU"].weight = 1.0
        self.instructions["SLTI"].weight = 1.0
        self.instructions["SLTIU"].weight = 0.5
        
        # Immediate shift operations
        self.instructions["SLLI"].weight = 2.0
        self.instructions["SRLI"].weight = 2.0
        self.instructions["SRAI"].weight = 1.0
    
    def get_instructions_by_category(self, category: InstructionCategory) -> List[InstructionSpec]:
        """Get all instructions in a specific category"""
        return [inst for inst in self.instructions.values() if inst.category == category]
    
    def get_weighted_instruction_list(self) -> List[Tuple[str, float]]:
        """Get list of (instruction_name, weight) tuples"""
        return [(name, spec.weight) for name, spec in self.instructions.items()]

# =============================================================================
# REGISTER AND DATA MANAGEMENT
# =============================================================================

class RegisterManager:
    """Manages register allocation and dependency tracking"""
    
    def __init__(self):
        # RISC-V has 32 registers (x0-x31), x0 is always zero
        self.registers = [f"x{i}" for i in range(32)]
        self.available_registers = [f"x{i}" for i in range(1, 32)]  # x0 is read-only
        self.register_values = {}  # Track register contents for dependencies
        self.register_usage_count = {reg: 0 for reg in self.registers}
    
    def get_random_register(self, exclude_zero: bool = True) -> str:
        """Get a random register, optionally excluding x0"""
        if exclude_zero:
            return random.choice(self.available_registers)
        else:
            return random.choice(self.registers)
    
    def get_source_registers(self, count: int = 2) -> List[str]:
        """Get source registers, potentially with dependencies"""
        return [self.get_random_register() for _ in range(count)]
    
    def get_destination_register(self) -> str:
        """Get destination register"""
        reg = self.get_random_register()
        self.register_usage_count[reg] += 1
        return reg
    
    def update_register_value(self, reg: str, value_description: str):
        """Update register value tracking"""
        self.register_values[reg] = value_description

class DataGenerator:
    """Generates realistic data patterns for instructions"""
    
    def __init__(self, seed: int):
        random.seed(seed)
        self.small_values = list(range(0, 1000))
        self.boundary_values = [0, 1, 0x7FFFFFFF, 0x80000000, 0xFFFFFFFF]
        self.powers_of_two = [2**i for i in range(32)]
    
    def get_immediate_value(self, instruction: str) -> int:
        """Generate appropriate immediate value for instruction"""
        if instruction in ["SLLI", "SRLI", "SRAI"]:
            # Shift amounts: 0-31
            return random.randint(0, 31)
        elif instruction in ["ADDI", "ANDI", "ORI", "XORI"]:
            # 12-bit signed immediate: -2048 to 2047
            return random.randint(-2048, 2047)
        elif instruction in ["SLTI", "SLTIU"]:
            # Comparison immediate
            return random.randint(-1000, 1000)
        else:
            return random.randint(0, 4095)
    
    def get_realistic_immediate(self, pattern: str = "mixed") -> int:
        """Generate realistic immediate values based on pattern"""
        if pattern == "small":
            return random.choice(self.small_values[:100])
        elif pattern == "boundary":
            return random.choice(self.boundary_values)
        elif pattern == "power_of_two":
            return random.choice(self.powers_of_two)
        else:  # mixed
            choice = random.random()
            if choice < 0.6:
                return random.choice(self.small_values[:100])
            elif choice < 0.8:
                return random.randint(-2048, 2047)
            else:
                return random.choice(self.boundary_values)

# =============================================================================
# ASSEMBLY GENERATOR
# =============================================================================

class AssemblyGenerator:
    """Generates assembly code with target distribution"""
    
    def __init__(self, config: DistributionConfig):
        self.config = config
        self.instruction_set = CV32E40P_InstructionSet()
        self.register_manager = RegisterManager()
        self.data_generator = DataGenerator(config.seed)
        self.generated_instructions = []
        self.statistics = {category: 0 for category in InstructionCategory}
        
        random.seed(config.seed)
    
    def calculate_instruction_counts(self) -> Dict[InstructionCategory, int]:
        """Calculate target instruction counts based on distribution"""
        counts = {}
        total = self.config.total_instructions
        
        for category, percentage in self.config.distribution.items():
            counts[category] = int(total * percentage)
        
        # Adjust for rounding errors
        actual_total = sum(counts.values())
        if actual_total < total:
            # Add remaining instructions to most common category
            max_category = max(self.config.distribution.keys(), 
                             key=lambda k: self.config.distribution[k])
            counts[max_category] += total - actual_total
        
        return counts
    
    def select_instruction_from_category(self, category: InstructionCategory) -> InstructionSpec:
        """Select weighted random instruction from category"""
        category_instructions = self.instruction_set.get_instructions_by_category(category)
        if not category_instructions:
            raise ValueError(f"No instructions found for category {category}")
        
        # Weighted selection
        weights = [inst.weight for inst in category_instructions]
        return random.choices(category_instructions, weights=weights)[0]
    
    def generate_r_type_instruction(self, instruction: InstructionSpec) -> str:
        """Generate R-type instruction (reg = reg op reg)"""
        rd = self.register_manager.get_destination_register()
        rs1, rs2 = self.register_manager.get_source_registers(2)
        
        asm_line = f"    {instruction.name.lower()} {rd}, {rs1}, {rs2}"
        comment = f"  # {instruction.description}"
        
        # Update register tracking
        self.register_manager.update_register_value(rd, f"{rs1} {instruction.name} {rs2}")
        
        return asm_line + comment
    
    def generate_i_type_instruction(self, instruction: InstructionSpec) -> str:
        """Generate I-type instruction (reg = reg op immediate)"""
        rd = self.register_manager.get_destination_register()
        rs1 = self.register_manager.get_source_registers(1)[0]
        imm = self.data_generator.get_immediate_value(instruction.name)
        
        asm_line = f"    {instruction.name.lower()} {rd}, {rs1}, {imm}"
        comment = f"  # {instruction.description}"
        
        # Update register tracking
        self.register_manager.update_register_value(rd, f"{rs1} {instruction.name} {imm}")
        
        return asm_line + comment
    
    def generate_instruction(self, category: InstructionCategory) -> str:
        """Generate single instruction from category"""
        instruction = self.select_instruction_from_category(category)
        
        if instruction.format == "R":
            return self.generate_r_type_instruction(instruction)
        elif instruction.format == "I":
            return self.generate_i_type_instruction(instruction)
        else:
            raise ValueError(f"Unsupported instruction format: {instruction.format}")
    
    def generate_assembly_file(self) -> str:
        """Generate complete assembly file"""
        instruction_counts = self.calculate_instruction_counts()
        
        # Generate header
        assembly_lines = [
            "# =============================================================================",
            "# Generated Assembly File - Stage 2 Instruction Distribution",
            "# =============================================================================",
            f"# Total Instructions: {self.config.total_instructions}",
            f"# Seed: {self.config.seed}",
            f"# Target Distribution:",
        ]
        
        for category, count in instruction_counts.items():
            percentage = (count / self.config.total_instructions) * 100
            assembly_lines.append(f"#   {category.value}: {count} ({percentage:.1f}%)")
        
        assembly_lines.extend([
            "# =============================================================================",
            "",
            ".section .text",
            ".global _start",
            "",
            "_start:",
        ])
        
        # Generate instructions in mixed order for realism
        instruction_queue = []
        for category, count in instruction_counts.items():
            for _ in range(count):
                instruction_queue.append(category)
        
        # Shuffle for realistic instruction interleaving
        random.shuffle(instruction_queue)
        
        # Generate each instruction
        for i, category in enumerate(instruction_queue):
            try:
                instruction_line = self.generate_instruction(category)
                assembly_lines.append(instruction_line)
                self.statistics[category] += 1
                
                # Add periodic comments for readability
                if (i + 1) % 50 == 0:
                    assembly_lines.append(f"    # Progress: {i + 1}/{len(instruction_queue)} instructions")
                    assembly_lines.append("")
                
            except Exception as e:
                print(f"Error generating instruction {i}: {e}")
                continue
        
        # Add footer
        assembly_lines.extend([
            "",
            "    # End of generated instructions",
            "    nop",
            "    nop",
            "",
            "# =============================================================================",
            "# Generation Statistics:",
        ])
        
        for category, count in self.statistics.items():
            percentage = (count / sum(self.statistics.values())) * 100 if sum(self.statistics.values()) > 0 else 0
            assembly_lines.append(f"#   {category.value}: {count} ({percentage:.1f}%)")
        
        assembly_lines.append("# =============================================================================")
        
        return "\n".join(assembly_lines)
    
    def save_assembly_file(self, content: str):
        """Save assembly content to file"""
        try:
            with open(self.config.output_file, 'w') as f:
                f.write(content)
            print(f"Assembly file generated: {self.config.output_file}")
        except Exception as e:
            print(f"Error saving file: {e}")
            sys.exit(1)

# =============================================================================
# MAIN EXECUTION
# =============================================================================

def load_config_file(config_path: str) -> DistributionConfig:
    """Load configuration from JSON file"""
    try:
        with open(config_path, 'r') as f:
            config_data = json.load(f)
        
        # Convert string keys to enum
        distribution = {}
        for key, value in config_data.get("distribution", {}).items():
            try:
                category = InstructionCategory(key)
                distribution[category] = value
            except ValueError:
                print(f"Warning: Unknown instruction category '{key}' in config")
        
        return DistributionConfig(
            total_instructions=config_data.get("total_instructions", 1000),
            seed=config_data.get("seed", 12345),
            output_file=config_data.get("output_file", "generated_test.s"),
            distribution=distribution,
            enable_dependencies=config_data.get("enable_dependencies", True),
            enable_realistic_data=config_data.get("enable_realistic_data", True),
            register_reuse_probability=config_data.get("register_reuse_probability", 0.3)
        )
    except Exception as e:
        print(f"Error loading config file: {e}")
        sys.exit(1)

def create_default_config() -> DistributionConfig:
    """Create default configuration for embedded workload"""
    return DistributionConfig(
        total_instructions=1000,
        seed=12345,
        output_file="generated_test.s",
        distribution={
            InstructionCategory.ARITHMETIC: 0.40,  # 40% arithmetic
            InstructionCategory.IMMEDIATE: 0.25,   # 25% immediate operations
            InstructionCategory.LOGIC: 0.15,       # 15% logic operations
            InstructionCategory.SHIFT: 0.10,       # 10% shift operations
            InstructionCategory.COMPARISON: 0.10,  # 10% comparison operations
        },
        enable_dependencies=True,
        enable_realistic_data=True,
        register_reuse_probability=0.3
    )

def main():
    """Main execution function"""
    parser = argparse.ArgumentParser(
        description="Generate assembly files with target instruction distributions for CV32E40P verification"
    )
    parser.add_argument("-c", "--config", help="JSON configuration file")
    parser.add_argument("-o", "--output", help="Output assembly file", default="generated_test.s")
    parser.add_argument("-n", "--num-instructions", type=int, help="Number of instructions to generate", default=1000)
    parser.add_argument("-s", "--seed", type=int, help="Random seed", default=12345)
    parser.add_argument("--create-config", help="Create sample configuration file", metavar="FILENAME")
    
    args = parser.parse_args()
    
    # Create sample configuration if requested
    if args.create_config:
        sample_config = {
            "total_instructions": 1000,
            "seed": 12345,
            "output_file": "generated_test.s",
            "distribution": {
                "arithmetic": 0.40,
                "immediate": 0.25,
                "logic": 0.15,
                "shift": 0.10,
                "comparison": 0.10
            },
            "enable_dependencies": True,
            "enable_realistic_data": True,
            "register_reuse_probability": 0.3
        }
        
        try:
            with open(args.create_config, 'w') as f:
                json.dump(sample_config, f, indent=2)
            print(f"Sample configuration created: {args.create_config}")
            return
        except Exception as e:
            print(f"Error creating config file: {e}")
            sys.exit(1)
    
    # Load or create configuration
    if args.config:
        config = load_config_file(args.config)
    else:
        config = create_default_config()
        config.output_file = args.output
        config.total_instructions = args.num_instructions
        config.seed = args.seed
    
    # Generate assembly file
    print(f"Generating {config.total_instructions} instructions with seed {config.seed}")
    print("Target distribution:")
    for category, percentage in config.distribution.items():
        count = int(config.total_instructions * percentage)
        print(f"  {category.value}: {count} ({percentage*100:.1f}%)")
    
    generator = AssemblyGenerator(config)
    assembly_content = generator.generate_assembly_file()
    generator.save_assembly_file(assembly_content)
    
    print("\nActual distribution:")
    total_generated = sum(generator.statistics.values())
    for category, count in generator.statistics.items():
        percentage = (count / total_generated) * 100 if total_generated > 0 else 0
        print(f"  {category.value}: {count} ({percentage:.1f}%)")
    
    print(f"\nAssembly generation completed successfully!")

if __name__ == "__main__":
    main()