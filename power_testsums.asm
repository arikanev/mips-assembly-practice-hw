# Sum the powers of 2 from 1 to 256.

.text
    
    addi $s0, $0, 1 # initial loop-counter (1).
    add $s1, $0, $0 # initial sum (0).
    addi $s2, $0, 257 # max / value to branch at (257).
    
    for:
        
        slt $s3, $s0, $s2 # set $s3 to 1 if loop counter is less than 257. Otherwise set $s3 to 0.
        beq $s3, $0, exit # exit if $s3 is 0 (i.e if loop counter is 257). 
        add $s1, $s1, $s0 # add curr power to overall sum. not invoked if it is >256-thloop.
        sll $s0, $s0, 1 # sll by 1 bit, equivalent to mult by 2. not invoked if it is >256-th loop.
        j for

    exit:
        
        addi $v0, $v0, 10
        syscall