.text

li $s0, 255
li $s1, 1000
li $s2, 991

ble $s0, $s1, a_lte_b # A ($s0) is less than or equal to B ($s1).
ble $s0, $s2, max_c # We did not branch so max is either A or C. Branch if A ($s0) is less than or equal to C ($s2).
move $s3, $s0 # We did not branch so max is A. Move max (A) into $s3.
j done

a_lte_b:

    ble $s1, $s2, max_c # Branch if B ($s1) is less than or equal to C ($s2).
    move $s3, $s1 # We did not branch so B ($s1), is greater than C ($s2). Move max (B) into $s3.
    j done
 
max_c:
    
    move $s3, $s2 # Move max (C) into $s3.
    
done:
    
    li $v0, 10
    syscall