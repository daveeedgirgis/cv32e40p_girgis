# =============================================================================
# Generated Assembly File - Stage 2 Instruction Distribution
# =============================================================================
# Total Instructions: 100
# Seed: 12345
# Target Distribution:
#   arithmetic: 40 (40.0%)
#   immediate: 25 (25.0%)
#   logic: 15 (15.0%)
#   shift: 10 (10.0%)
#   comparison: 10 (10.0%)
# =============================================================================

.section .text
.global _start

_start:
    addi x2, x1, 1980  # Add immediate
    add x20, x31, x14  # Add registers
    sra x18, x7, x12  # Shift right arithmetic
    sra x23, x4, x18  # Shift right arithmetic
    sll x16, x6, x29  # Shift left logical
    sub x8, x7, x6  # Subtract registers
    add x5, x18, x3  # Add registers
    or x1, x5, x1  # Bitwise OR
    ori x29, x6, -1263  # OR immediate
    addi x25, x13, -1507  # Add immediate
    sub x31, x15, x14  # Subtract registers
    slt x30, x29, x6  # Set less than
    add x11, x6, x13  # Add registers
    addi x19, x22, -9  # Add immediate
    sra x17, x23, x14  # Shift right arithmetic
    add x3, x21, x15  # Add registers
    sub x21, x20, x19  # Subtract registers
    add x5, x17, x29  # Add registers
    addi x19, x10, -1022  # Add immediate
    add x23, x25, x22  # Add registers
    slli x2, x9, 27  # Shift left logical immediate
    add x26, x17, x18  # Add registers
    add x21, x25, x3  # Add registers
    addi x29, x23, -1759  # Add immediate
    sll x15, x22, x12  # Shift left logical
    add x15, x20, x9  # Add registers
    slt x16, x16, x2  # Set less than
    add x1, x8, x12  # Add registers
    slt x1, x22, x21  # Set less than
    xori x3, x1, -1139  # XOR immediate
    andi x7, x28, 1203  # AND immediate
    add x9, x12, x7  # Add registers
    xor x24, x11, x28  # Bitwise XOR
    add x20, x10, x12  # Add registers
    sub x2, x14, x7  # Subtract registers
    add x5, x27, x10  # Add registers
    addi x14, x7, -1935  # Add immediate
    add x31, x17, x2  # Add registers
    or x11, x13, x11  # Bitwise OR
    sltu x8, x4, x16  # Set less than unsigned
    sll x7, x9, x19  # Shift left logical
    add x6, x24, x10  # Add registers
    and x28, x3, x4  # Bitwise AND
    andi x18, x17, 1311  # AND immediate
    sub x1, x25, x17  # Subtract registers
    and x18, x11, x19  # Bitwise AND
    sltu x29, x6, x15  # Set less than unsigned
    or x1, x12, x22  # Bitwise OR
    and x13, x12, x22  # Bitwise AND
    sub x22, x20, x1  # Subtract registers
    # Progress: 50/100 instructions

    slt x15, x2, x11  # Set less than
    sll x26, x10, x5  # Shift left logical
    add x20, x2, x19  # Add registers
    addi x31, x4, -1259  # Add immediate
    add x2, x31, x2  # Add registers
    addi x7, x17, -1258  # Add immediate
    addi x16, x2, 1420  # Add immediate
    add x8, x11, x24  # Add registers
    sra x13, x19, x18  # Shift right arithmetic
    sll x22, x16, x30  # Shift left logical
    addi x7, x18, -296  # Add immediate
    add x24, x15, x28  # Add registers
    ori x21, x7, -1449  # OR immediate
    or x25, x3, x18  # Bitwise OR
    xor x4, x9, x19  # Bitwise XOR
    addi x9, x8, 2028  # Add immediate
    add x23, x15, x22  # Add registers
    addi x8, x21, 1643  # Add immediate
    slli x30, x17, 6  # Shift left logical immediate
    slt x17, x30, x18  # Set less than
    sub x12, x8, x13  # Subtract registers
    add x3, x14, x15  # Add registers
    add x8, x15, x10  # Add registers
    add x4, x6, x7  # Add registers
    ori x30, x13, 100  # OR immediate
    or x21, x25, x26  # Bitwise OR
    addi x1, x17, 215  # Add immediate
    and x31, x16, x29  # Bitwise AND
    add x21, x7, x26  # Add registers
    andi x1, x24, 1209  # AND immediate
    add x30, x18, x9  # Add registers
    and x30, x26, x7  # Bitwise AND
    and x18, x1, x1  # Bitwise AND
    add x19, x26, x30  # Add registers
    sra x11, x7, x5  # Shift right arithmetic
    xor x20, x10, x17  # Bitwise XOR
    add x7, x14, x13  # Add registers
    sltu x19, x13, x26  # Set less than unsigned
    sub x24, x22, x26  # Subtract registers
    slt x18, x9, x17  # Set less than
    add x3, x22, x16  # Add registers
    slti x23, x16, 877  # Set less than immediate
    or x29, x14, x2  # Bitwise OR
    sub x24, x29, x27  # Subtract registers
    add x22, x11, x29  # Add registers
    addi x13, x16, -1289  # Add immediate
    sub x23, x21, x4  # Subtract registers
    sub x8, x20, x1  # Subtract registers
    sltu x5, x21, x1  # Set less than unsigned
    addi x27, x22, 162  # Add immediate
    # Progress: 100/100 instructions


    # End of generated instructions
    nop
    nop

# =============================================================================
# Generation Statistics:
#   arithmetic: 40 (40.0%)
#   logic: 15 (15.0%)
#   shift: 10 (10.0%)
#   comparison: 10 (10.0%)
#   immediate: 25 (25.0%)
#   custom: 0 (0.0%)
# =============================================================================