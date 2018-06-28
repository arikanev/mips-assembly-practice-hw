# Lets sum numbers 0-9.

.text 

    add $s0, $0, $0 # i loop counter. Starts at 0.
    move $s1, $s0 # current sum. Starts at 0.
    addi $s2, $s2, 10 # max value/value to stop at (10).
    
    for:
        beq $s0, $s2, exit
        add $s1, $s1, $s0 # add current i loop counter value to sum.
        addi $s0, $s0, 1 # increment i loop counter.     
        j for
    
    exit:
        addi $v0, $v0, 10
        syscall
    