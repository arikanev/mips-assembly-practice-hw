# Homework 1#
# name: Ariel Kanevsky#
# sbuid: 110486172 #

.text
.globl main

# AbCd result:
# 2's complement: 	23200612	0x01620364	00000001011000100000001101100100	23200612
# 1's complement: 	23200612	0x01620364	00000001011000100000001101100100	23200612
# Sign Magnitude: 	23200612	0x01620364	00000001011000100000001101100100	23200612
# Neg 2's complement: 	-23200612	0xfe9dfc9b	11111110100111011111110010011011	-23200612
# 16-bit 2's comp: 	868	        0x00000364	00000000000000000000001101100100	868


main:
    # Print prompt.
    la $a0, prompt
    li $v0, 4
    syscall
    
    # Read integer.
    li $v0, 5
    syscall
    move $s0, $v0

    # Print two's complement.
    la $a0, twos
    li $v0, 4
    syscall
    
    move $a0, $s0
    li $v0, 1  # Print raw value of integer.
    syscall
    
    la $a0, tab
    li $v0, 4  # Print tab for spacing.
    syscall
    
    move $a0, $s0
    li $v0, 34  # Print hexadecimal value of integer.
    syscall
    
    la $a0, tab
    li $v0, 4  # Print tab for spacing.
    syscall
    
    move $a0, $s0
    li $v0, 35  # Print binary value of integer.
    syscall
    
    la $a0, tab
    li $v0, 4  # Print tab for spacing.
    syscall
    
    move $a0, $s0
    li $v0, 1  # Print two's complement value of integer.
    syscall
    
    
    # Print one's complement.
    la $a0, ones
    li $v0, 4
    syscall
    
    move $a0, $s0
    li $v0, 1  # Print raw value of integer.
    syscall
    
    la $a0, tab
    li $v0, 4  # Print tab for spacing.
    syscall
    
    bltz $s0, neg_case # Branch to neg_case if $s0 is less than zero.

    move $a0, $s0
    li $v0, 34  # Print hexadecimal value of integer.
    syscall
    
    move $t0, $s0
    j skip_neg_case     # Jump to instruction.
    
    neg_case:
        li $t1, 1
        sub $t0, $s0, $t1
        move $a0, $t0
        li $v0, 34  # Print hexadecimal value of integer.
        syscall
    
    skip_neg_case:
    la $a0, tab
    li $v0, 4  # Print tab for spacing.
    syscall
    
    move $a0, $t0
    li $v0, 35  # Print binary value of integer.
    syscall
    
    la $a0, tab
    li $v0, 4  # Print tab for spacing.
    syscall
    
    move $a0, $t0
    li $v0, 1  # Print two's complement value of integer.
    syscall
    

    # Print sign magnitude.
    la $a0, sign
    li $v0, 4
    syscall
    
    move $a0, $s0
    li $v0, 1  # Print raw value of integer.
    syscall
    
    la $a0, tab
    li $v0, 4  # Print tab for spacing.
    syscall
    
    bltz $s0, neg_case2 # Branch to neg_case if $s0 is less than zero.

    move $a0, $s0
    li $v0, 34  # Print hexadecimal value of integer.
    syscall
    
    move $t0, $s0
    move $t1, $s0
    j skip_neg_case2     # Jump to instruction.
    
    neg_case2:
        li $t3, 0x7FFFFFFF
        xor $t1, $t0, $t3
        move $a0, $t1
        li $v0, 34  # Print hexadecimal value of integer.
        syscall
    
    skip_neg_case2:
    la $a0, tab
    li $v0, 4  # Print tab for spacing.
    syscall
    
    move $a0, $t1
    li $v0, 35  # Print binary value of integer.
    syscall
    
    la $a0, tab
    li $v0, 4  # Print tab for spacing.
    syscall
    
    move $a0, $t1
    li $v0, 1  # Print two's complement value of integer.
    syscall
    
    
    # Print Neg 2's complement.
    la $a0, neg2s
    li $v0, 4
    syscall
    
    li $t4, 0xFFFFFFFF
    xor $s0, $s0, $t4
    addi $s0, $s0, 0x0001
    move $a0, $s0
    li $v0, 1  # Print raw value of negated integer.
    syscall
    
    la $a0, tab
    li $v0, 4  # Print tab for spacing.
    syscall
    
    move $t0, $s0
    bltz $s0, neg_case3 # Branch to neg_case if $s0 is less than zero.

    move $a0, $s0
    li $v0, 34  # Print hexadecimal value of integer.
    syscall
    
    j skip_neg_case3     # Jump to instruction.
    
    neg_case3:
        move $a0, $t0
        li $v0, 34  # Print hexadecimal value of integer.
        syscall
    
    skip_neg_case3:
    la $a0, tab
    li $v0, 4  # Print tab for spacing.
    syscall
    
    move $a0, $t0
    li $v0, 35  # Print binary value of integer.
    syscall
    
    la $a0, tab
    li $v0, 4  # Print tab for spacing.
    syscall
    
    move $a0, $t0
    li $v0, 1  # Print two's complement value of integer.
    syscall
    
    # Print 16-bit 2's complement.
    la $a0, sxtnbit2s
    li $v0, 4
    syscall

    andi $s0, $s0, 0xFFFF
    sub $s1, $0, $s0
    move $a0, $s1
    li $v0, 1  # Print raw value of 16-bit integer.
    syscall
    
    li $t4, 0xFFFFFFFF
    li $t5, 0x00000001
    sub $s0, $s0, $t5
    xor $s0, $s0, $t4
    andi $s0, $s0, 0xFFFF
    la $a0, tab
    li $v0, 4  # Print tab for spacing.
    syscall
    
    move $t0, $s0
    bltz $s0, neg_case4 # Branch to neg_case if $s0 is less than zero.

    move $a0, $s0
    li $v0, 34  # Print hexadecimal value of integer.
    syscall
    
    j skip_neg_case4     # Jump to instruction.
    
    neg_case4:
        move $a0, $t0
        li $v0, 34  # Print hexadecimal value of integer.
        syscall
    
    skip_neg_case4:
    la $a0, tab
    li $v0, 4  # Print tab for spacing.
    syscall
    
    move $a0, $t0
    li $v0, 35  # Print binary value of integer.
    syscall
    
    la $a0, tab
    li $v0, 4  # Print tab for spacing.
    syscall
    
    move $a0, $t0
    li $v0, 1  # Print two's complement value of integer.
    syscall
    
    li $v0, 10  # Exit
    syscall


.data
tab: .asciiz "\t"
prompt: .asciiz "Enter an integer number:\n"

twos: .asciiz "\n2's complement: \t"
ones: .asciiz "\n1's complement: \t"
sign: .asciiz "\nSign Magnitude: \t"
neg2s: .asciiz "\nNeg 2's complement: \t"
sxtnbit2s: .asciiz "\n16-bit 2's comp: \t"
