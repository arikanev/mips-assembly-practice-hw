# Homework #2
# Ariel Kanevsky
# XXXXXXXXX

.text
.globl start


start:

    prompt:
        
        la $a0, start_prompt
        li $v0, 4
        syscall
        
        li $v0, 5
        syscall
        
        move $s7, $v0 # Save input val for later use when encoding in BE or LE.
        
        li $t0, 2
        beq $v0, $t0, quit
        li $t0, 1
        beq $t0, $v0, le_prompt
        beqz $v0, be_prompt
        
        la $a0, invalid_inp
        li $v0, 4
        syscall
        
        j prompt
   
    # Quit.
    quit:
       li $v0, 10
       syscall
   
    # Else, print encoding in UTF-16BE.
    be_prompt:
       la $a0, utfbe_prompt
       li $v0, 4
       syscall
       
       j outfile

    le_prompt:      
       la $a0, utfle_prompt
       li $v0, 4
       syscall
       
       j outfile
    
   
    outfile:
       la $a0, outfile_prompt
       li $v0, 4
       syscall

    outfile_enter_path:   
       li $v0, 8
       la $a0, outfpath_buffer
       li $a1, 101
       syscall
       
       # Remove null char from end of file dir string.
       li $t0, 0 # Counter.
       li $t1, 100 # Max number of bytes for removal.
    
    remove_null_outfile:       
       lb $t2, outfpath_buffer($t0) # Load X byte of filedir string.
       addi $t0, $t0, 1 # Increment the byte index.
       bnez $t2, remove_null_outfile # Repeat-> Load next byte of filedir string.
       beq $t0, $t1, open_file_write # If the byte at $t2 equals zero, and this is the 100th byte, we've reached end of file. Skip setting last byte to zero.
       addiu $t0, $t0, -2 # Set byte index to the last byte.
       sb $0, outfpath_buffer($t0) # Set final byte of file dir to 0.
    
    open_file_write:   
       li $v0, 13
       li $a1, 9 # Write only with create and append.
       li $a2, 0 # Mode is ignored.
       syscall
       
       move $s4, $v0 # Set $s4 equal to file descriptor for later use.
       
       bltz $v0, outfile_err
       j main

    outfile_err:
       la $a0, outfile_prompt
       li $v0, 4
       syscall
   
   j outfile_enter_path

main:

        li $v0, 0
    prompt_user:
    
        bltz $v0, reprompt_user
        # Print prompt.
        la $a0, infile_prompt
        li $v0, 4
        syscall

    read_input:
        # Read input string.
        li $v0, 8 
        la $a0, infpath_buffer
        li $a1, 101
        syscall
    
    # Remove null char from end of file dir string.
       li $t0, 0 # Counter.
       li $t1, 100 # Max number of bytes for removal.
    
    remove_null_infile:       
       lb $t2, infpath_buffer($t0) # Load X byte of filedir string.
       addi $t0, $t0, 1 # Increment the byte index.
       bnez $t2, remove_null_infile # Repeat-> Load next byte of filedir string.
       beq $t0, $t1, open_file_read # If the byte at $t2 equals zero, and this is the 100th byte, we've reached end of file. Skip setting last byte to zero.
       addiu $t0, $t0, -2 # Set byte index to the last byte.
       sb $0, infpath_buffer($t0) # Set final byte of file dir to 0.
        
    open_file_read:
        # Open file.
        li $v0, 13
        # Note: filename string is already in $a0.
        li $a1, 0  # Flag for reading.
        li $a2, 0  # Mode is ignored.
        syscall
 
        j validate_file

    reprompt_user:
        # Print prompt.
        la $a0, reprompt
        li $v0, 4
        syscall
        
        j read_input
        

    validate_file:
        # Check if $v0 is less than zero.
        bltz $v0, prompt_user
        
     
        # Move the file descriptor.
        move $s3, $v0 # Copy the file descriptor to saved register for later use in file reading.
        move $a0, $s3 # Copy the file descriptor to $a0 argument register  for initial file read access.

        li $v0, 14
        la $a1, bom
        li $a2, 3
        syscall
        bltz $v0, byte_read_err
        
        li $t0, 0xBFBBEF # Load the UTF-8 BOM.
        la $s0, bom
        lw $t1, 0($s0) # Load word from address with 0-offset.
        bne $t0, $t1, bom_err # Check that first 3 bytes are equivalent to UTF-8 BOM
        
        j process_first_byte
 
    process_first_byte:   
        li $v0, 14 # System call code for read file.
        move $a0, $s3 # Place File descriptor in arg register.
        la $a1, char # Read into 1 byte memory allocated address.
        li $a2, 1 # Read only up to 1 byte.
        syscall # Envoke.
        bltz $v0, byte_read_err # If syscode call 14 return value is negative, there is error in reading file.
        beqz $v0, finished # Syscode call 14 return value is 0, we have reached the end of readble file.
        
        la $s0, char # Load address stored in label char to saved register #s0
        lbu $t0, 0($s0) # Load the unsigned byte written to memory address labeled via char. This is the beginning of the glyph.
        
        # We want to check if the MSB is 0 or not.
        srl $t9, $t0, 7 # Shift to the right by 7.
        bnez $t9, process_second_byte
        
        # If no branch, the char is made up of 1 byte. Remaining 7 bits
        andi $t0, $t0, 0x0000007F
 
        sb $t0, byte_1
 
        # Print one_byte label
        la $a0, one_byte
        li $v0, 4
        syscall
        
        # Print the code point of the char. (Hex value of the above 7 bits.)
        la $t0, byte_1
        lbu $a0, 0($t0)
        li $v0, 34
        syscall
        
        la $a0, tab
        li $v0, 4
        syscall
        
        # Print u
        la $a0, u
        li $v0, 4
        syscall
        
        # Print the code point of the char.
        lbu $a0, 0($t0)
        li $v0, 34
        syscall
        
        beqz $s7, big_endian
    
    little_endian:  
        # Little Endian   
        li $v0, 15
        move $a0, $s4
        la $a1, ($t0)
        li $a2, 1
        syscall
        
        li $v0, 15
        sb $0, zero
        la $a1, zero
        syscall
        
        # Begin processing next glyph with process_first_byte
        j process_first_byte
        
    big_endian:
        # Big Endian   
        li $v0, 15
        sb $0, zero
        la $a1, zero
        move $a0, $s4
        li $a2, 1
        syscall
        
        li $v0, 15
        la $a1, ($t0)
        syscall

        # Begin processing next glyph with process_first_byte
        j process_first_byte
        
    process_second_byte:
        li $v0, 14
        move $a0, $s3 # Place file descriptor in arg register.
        la $a1, char # Allocate byte space at char label address to read into.
        li $a2, 1 # Set maximum bytes readable.
        syscall # Envoke.
        bltz $v0, byte_read_err # If syscode call 14 return value is less than zero, error in reading file.
        beqz $v0, finished # Syscode call 14 value is 0, we have read the end of the readable file.
        
        la $s0, char # Load address stored in label char to saved register #s0
        lbu $t1, 0($s0) # Load unsigned byte from memory address labeled via char. Second byte of the glyph.
        
        # Lets check if top 3 bits are 110.
        # Lets first shift the bits in glyph 1 right by 5. 00000110 Then compare them to 0x00000006
        srl $t9, $t0, 5 # Shift right by 5.
        li $t8, 0x00000006
        bne $t9, $t8, process_third_byte
        
        sb $t0, byte_1 # Store byte in byte_1.
        sb $t1, byte_2 # Store byte in byte_2.
        
        # If branching did not occur, concatenate 5 bits from first byte ($t0) with 6 bits from second ($t1)(Our glyph contains two bytes). 
        # Zero the first 3 MSBs (bits) in byte 1 of glyph. Then, shift left by 6 bits b/c
        andi $t0, $t0, 0x0000001F
        sll $t0, $t0, 6
        # Zero the first 2 MSBs (bits) in byte 2 of glyph.
        andi $t1, $t1, 0x0000003F
        # Logical OR both bytes to create the UTF-8 Codepoint.
        or $s0, $t0, $t1
        
        la $a0, two_byte
        li $v0, 4
        syscall
        
        la $t0, byte_1
        lbu $a0, 0($t0)
        li $v0, 34
        syscall
        
        la $a0, tab
        li $v0, 4
        syscall
        
        la $t0, byte_2
        lbu $a0, 0($t0)
        li $v0, 34
        syscall
        
        la $a0, tab
        li $v0, 4
        syscall
        
        la $a0, u
        li $v0, 4
        syscall
        
        move $a0, $s0
        li $v0, 34
        syscall
        
        # Lets split the utf-8 codepoint into two seperate bytes for easy combination into utf-16le or utf-16be.
        
        # Shift right logical by 8 bits to isolate top byte (byte_1)
        srl $s1, $s0, 8
        sb $s1, byte_1
        
        # Mask all but the first 8 bits to isolate bottom byte (byte_2)
        andi $s1, $s0, 0x000000FF
        sb $s1, byte_2

        beqz $s7, big_endian_2B
    
    little_endian_2B:  
        # Little Endian   
        li $v0, 15
        move $a0, $s4
        la $t0, byte_2
        la $a1, ($t0) # byte 2 first (in MSB)
        li $a2, 1
        syscall
        
        li $v0, 15
        la $t0, byte_1
        la $a1, ($t0)
        syscall
        
        # Begin processing next glyph with process_first_byte
        j process_first_byte
        
    big_endian_2B:
        # Big Endian   
        li $v0, 15
        la $t0, byte_1
        la $a1, ($t0)
        move $a0, $s4
        li $a2, 1
        syscall
        
        li $v0, 15
        la $t0, byte_2
        la $a1, ($t0)
        syscall

        
        j process_first_byte

    process_third_byte:

        li $v0, 14
        move $a0, $s3 # File descriptor into arg register 0.
        la $a1, char # Allocate byte space at char label for reading into.
        li $a2, 1 # Read 1 byte max.
        syscall # Envoke.
        bltz $v0, byte_read_err # If the syscode 14 func return value is negative, error reading file.
        beqz $v0, finished # If syscode call return value is zero, end of file.
        
        la $s0, char # Load address stored in label char to saved register #s0
        lbu $t2, 0($s0) # Load unsigned byte from memory address denoted by label char into $t2. Third byte of glyph
        
        # Check if the top 4 bits are 1110
        srl $t9, $t0, 4
        li $t8, 0x0000000E
        bne $t9, $t8, process_fourth_byte
        
        sb $t0, byte_1  # Save for printing.
        sb $t1, byte_2  # Save for printing.
        sb $t2, byte_3  # Save for printing.
        
        # If branching did not occur, concatenate 4 bits from first byte ($t0) with 6 bits from second byte ($t1) and 6 bits from third ($t2)(Our glyph contains three bytes). 
        # Zero the first 4 MSBs (bits) in byte 1 of glyph. Then, shift left by 12 bits.
        andi $t0, $t0, 0x0000001F
        sll $t0, $t0, 12
        # Zero the first 2 MSBs (bits) in byte 2 of glyph. Then, shift left by 6 bits.
        andi $t1, $t1, 0x0000003F
        sll $t1, $t1, 6
        # Zero the first 2 MSBs in byte 3 of glyph.
        andi $t2, $t2, 0x0000003F
        # Logical OR all 3 bytes to create the UTF-8 Codepoint.
        or $s0, $t1, $t2
        or $s0, $s0, $t0
        
        la $a0, three_byte
        li $v0, 4
        syscall
        
        la $t0, byte_1
        lbu $a0, 0($t0)
        li $v0, 34
        syscall
        
        la $a0, tab
        li $v0, 4
        syscall
        
        la $t0, byte_2
        lbu $a0, 0($t0)
        li $v0, 34
        syscall
        
        la $a0, tab
        li $v0, 4
        syscall
        
        la $t0, byte_3
        lbu $a0, 0($t0)
        li $v0, 34
        syscall
        
        la $a0, tab
        li $v0, 4
        syscall
        
        la $a0, u
        li $v0, 4
        syscall
        
        move $a0, $s0
        li $v0, 34
        syscall
        
        # Lets split the utf-8 codepoint into two seperate bytes for easy combination into utf-16le or utf-16be.
        
        # Shift right logical by 8 bits to isolate top byte (byte_1)
        srl $s1, $s0, 8
        sb $s1, byte_1
        
        # Mask all but the first 8 bits to isolate bottom byte (byte_2)
        andi $s1, $s0, 0x000000FF
        sb $s1, byte_2

        beqz $s7, big_endian_3B
    
    little_endian_3B:  
        # Little Endian   
        li $v0, 15
        move $a0, $s4
        la $t0, byte_2
        la $a1, ($t0) # byte 2 first (in MSB)
        li $a2, 1
        syscall
        
        li $v0, 15
        la $t0, byte_1
        la $a1, ($t0)
        syscall
        
        # Begin processing next glyph with process_first_byte
        j process_first_byte
        
    big_endian_3B:
        # Big Endian   
        li $v0, 15
        la $t0, byte_1
        la $a1, ($t0)
        move $a0, $s4
        li $a2, 1
        syscall
        
        li $v0, 15
        la $t0, byte_2
        la $a1, ($t0)
        syscall

        j process_first_byte
        
    process_fourth_byte:
        li $v0, 14
        move $a0, $s3
        la $a1, char
        li $a2, 1
        syscall
        bltz $v0, byte_read_err
        beqz $v0, finished
        
        la $s0, char # Load address stored in label char to saved register #s0
        lbu $t3, 0($s0)
        
        # Check if the top 5 bits are 11110
        srl $t9, $t0, 3
        li $t8, 0x0000001E
        bne $t9, $t8, byte_read_err
        
        sb $t0, byte_1  # Save for printing.
        sb $t1, byte_2  # Save for printing.
        sb $t2, byte_3  # Save for printing.
        sb $t3, byte_4  # Save for printing.
        
        # If branching did not occur, concatenate 3 bits from first byte ($t0) with 6 bits from second byte ($t1) and 6 bits from third ($t2) and 6 bits from fourth ($t3)(Our glyph contains four bytes). 
        # Zero the higher 5 MSBs (bits) in byte 1 of glyph. Then, shift left by 18 bits.
        andi $t0, $t0, 0x00000007
        sll $t0, $t0, 18
        # Zero the first 2 MSBs (bits) in byte 2 of glyph. Then, shift left by 12 bits.
        andi $t1, $t1, 0x0000003F
        sll $t1, $t1, 12
        # Zero the first 2 MSBs in byte 3 of glyph. Then, shift left by 6 bits.
        andi $t2, $t2, 0x0000003F
        sll $t2, $t2, 6
        # Zero the first 2 MSBs in byte 4 of glyph.
        andi $t3, $t3, 0x0000003F
        # Logical OR all 4 bytes to create the UTF-8 Codepoint.
        or $s0, $t2, $t3
        or $s1, $t0, $t1
        or $s0, $s0, $s1
        
        la $a0, four_byte
        li $v0, 4
        syscall
        
        la $t0, byte_1
        lbu $a0, 0($t0)
        li $v0, 34
        syscall
        
        la $a0, tab
        li $v0, 4
        syscall
        
        la $t0, byte_2
        lbu $a0, 0($t0)
        li $v0, 34
        syscall
        
        la $a0, tab
        li $v0, 4
        syscall
        
        la $t0, byte_3
        lbu $a0, 0($t0)
        li $v0, 34
        syscall
        
        la $a0, tab
        li $v0, 4
        syscall
        
        la $t0, byte_4
        lbu $a0, 0($t0)
        li $v0, 34
        syscall
        
        la $a0, tab
        li $v0, 4
        syscall
        
        la $a0, u
        li $v0, 4
        syscall
        
        move $a0, $s0
        li $v0, 34
        syscall
        
        # Subtract 0x00010000 from code point
        addiu $s0, $s0, -65536

        # Shift right logical by 10 bits to get higher 10 bits of code point.
        srl $s1, $s0, 10
        
        # Bitwise and to obtain lower 10 bits of code point.
        andi $s0, $s0, 0x000003FF
        
        # Obtain code unit w1. Higher bits + 0xD800
        addiu $s1, $s1, 0x0000D800
        la $t0, code_unit1
        sh $s1, 0($t0)
        
        # Obtain code unit w2. Lower bits + 0xDC00
        addiu $s0, $s0, 0x0000DC00
        la $t0, code_unit2
        sh $s0, 0($t0)

        beqz $s7, big_endian_4B
    
    little_endian_4B:  
        # Little Endian   
        li $v0, 15
        move $a0, $s4
        la $t0, code_unit2
        la $a1, ($t0) # byte 2 first (in MSB)
        li $a2, 1
        syscall
        
        li $v0, 15
        la $t0, code_unit1
        la $a1, ($t0)
        syscall
        
        # Begin processing next glyph with process_first_byte
        j process_first_byte
        
    big_endian_4B:
        # Big Endian   
        li $v0, 15
        la $t0, code_unit1
        la $a1, ($t0)
        move $a0, $s4
        li $a2, 1
        syscall
        
        li $v0, 15
        la $t0, code_unit2
        la $a1, ($t0)
        syscall        
        
        j process_first_byte

    bom_err:
        la $a0, bomerrprompt
        li $v0, 4
        syscall
        
        j main
        
    byte_read_err:
        la $a0, byteerrprompt
        li $v0, 4
        syscall
        
        j main
    
    finished:
        # Close original utf-8 file.
        move $a0, $s3
        li $v0, 16
        syscall
        
        # Close utf-16 file.
        move $a0, $s4
        li $v0, 16
        syscall

        li $v0, 10
        syscall

.data

start_prompt: .asciiz "Welcome! To encode in UTF-16BE enter 0, to encode in UTF-16LE enter 1, to quit enter 2: "
utfle_prompt: .asciiz "\nEncoding in UTF-16LE.\n"
utfbe_prompt: .asciiz "\nEncoding in UTF-16BE.\n"
invalid_inp: .asciiz "\nInvalid input.\n"
outfile_prompt: .asciiz "\nEnter the output file path to place the UTF-16 encoding: \n"
infile_prompt: .asciiz "\nEnter the input file path to a UTF-8 encoded file: \n"
reprompt: .asciiz "\nThe input file path was invalid, try re-entering the file-path: \n"
output_reprompt: .asciiz "\nThe output file path was invalid, try re-entering the file-path: \n"
bomerrprompt: .asciiz "\nThe BOM was not of UTF-8, try another file. \n"
byteerrprompt: .asciiz "\nError reading the bytes. Try another file. \n"
one_byte: .asciiz "\none byte: \t"
two_byte: .asciiz "\ntwo bytes: \t"
three_byte: .asciiz "\nthree bytes: \t"
four_byte: .asciiz "\nfour bytes: \t"
.align 2
outfpath_buffer: .space 100
.align 2
infpath_buffer: .space 100
output_char: .space 1
.align 2
bom: .space 3
char: .space 1
tab: .asciiz "\t"
u: .asciiz "U+"
.align 0
byte_1: .space 1
.align 0
byte_2: .space 1
.align 0
byte_3: .space 1
.align 0
byte_4: .space 1
.align 0
zero: .space 1
.align 1
code_unit1: .space 2
.align 1
code_unit2: .space 2
