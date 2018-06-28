.text

# We want to simulate how the 32-bit target address of a j instruction is formed.

lw $s0, pc # Simulating program counter address.
lw $s1, imm_addr # Simulating 16 bit 2's complement immediate address.

sll $s1, $s1, 6 # Shift left logical by 6, Same as multiplying by 64.
andi $s0, $s0, 0xF # Mask out all but the first 4 bits in the PC.
or $s1, $s1, $s0 # Concatenate The isolated 4 PC bits to the beginning of the address. Can use OR to combine, since the unwanted values in both registers are zeroed out now.

li $v0, 35
la $a0, ($s1)
syscall

.data
.align 2
pc: .word 0xF0A53CFF
imm_addr: .word 0x01F5C84F