# Generating powers of n such that 2^n = 128

.text 
# $s0 = result, $s1 = n (pow)
# $s2 = max (128)
li $s0, 1
li $s1, 0
li $s2, 128


while:    
    sll $s0, $s0, 1 # Same as multiplying by 2.
    addi $s1, $s1, 1
    beq $s0, $s2, exit
    j while

exit:
    li $v0, 10
    syscall