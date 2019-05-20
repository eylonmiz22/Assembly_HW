#Eylon Mizrahi 206125411 and Yuval Trudel 312589096
.data
msg1:   .asciiz "\nThe options are: \n \n1. Enter a number (base 10) \n2. Replace a number (base 10) \n3. DEL a number (base 10) \n4. Find a number in the array (base 10) \n5. Find average (base 2-10) \n6. Find Max (base 2-10) \n7. Print the array elements (base 2-10)  \n8. END \n\n"
msg2: 	.asciiz "\nThe array is full.\n"
msg3:	.asciiz "\nWhat number to add ? \n "
msg4:	.asciiz "\nThe array is empty \n"
msg5:	.asciiz "\nWhat number to replace? \n"
msg6:	.asciiz "\nWhat number to delete? \n"
msg7:	.asciiz "\nWhat number to find? \n"
msg8:	.asciiz "\nWhich base would you like for the numbers? (2-10)\n" 
msg9:	.asciiz "\nThe number already exist in index:\n"
msg10:	.asciiz	"\nthe number added successfully"
msg11:	.asciiz "\nReplace the number "
msg12:	.asciiz "  (in index "
msg13:	.asciiz " ) with what number?\n"
msg14:	.asciiz "\nthe number replaceed successfully"
msg15:	.asciiz	"\nThe number already exist\n"
msg16:	.asciiz "\nThe number is't exist, thus it can't be deleted\n"
msg17:	.asciiz "\n"
msg18:	.asciiz "\nthe index of the max num is: "

array:  .space 120 #.word 0:30 array of 30 words
array1: .space 120 #.word 0:30 array of 30 words #enough memory space for all of the methods
jumpTable: .word L0,L1,L2,L3,L4,L5,L6,L7
num:    .byte 0 
size:   .byte 0 

.text 
.globl main

main:
	lw $a1,num
	la $a2,array
	la $a3,array1
menu:
	la $a0,msg1 	#get string address
	li $v0,4	#print string	
	syscall	
		
	li  $v0,5      	     #get a menu option from user(1 to 9)
	syscall
	
	la $t4,jumpTable    #load jump table pointer into $t4
        move $s3,$v0
        sub $s3,$s3,1
        sll $t1,$s3 , 2	    #calculate word address at K=4*k
	add $t0,$t1,$t4      # $t0 = Jump table*4
	lw   $t0, 0($t0)    # load the target address
	jr   $t0            # jump to case
	
	L0: 
	j add_number

	L1: 
	j replace

	L2: 
	j del

	L3: 
	j find	

	L4: 
	j average

	L5: 
	j max	

	L6: 
	j print_array

	L7: 
	li $v0, 10     # Exit program
	syscall

	
	
	
	
add_number:
	
        beq $a1,30,full
	
	la $a0,msg3 	#What number to add ?
	li $v0,4		
	syscall
	
	li  $v0,5      
	syscall
	
	move $t6,$v0 #move the num to $t6
	
	jal check
	
	move $s5,$v0
	bne $v0, -1, print_msg9  #the num already exist
	
	sb $t6,($a2)	#add num to the array
	addi $a2,$a2,4
	addi $a1,$a1,1
	
	la $a0,msg10 	#the number added successfully
	li $v0,4
	syscall
	
	j menu
	
		
replace:
	
	beqz $a1,empty
	
        la $a0,msg5 	#What number to replace?
	li $v0,4		
	syscall
	
	li $v0,5      
	syscall
	
	move $t6,$v0 #$t6 - the number from the user
	
	jal check
	
	beq $v0, -1,menu #if the num doesn't exist jump to the main
	move $s5,$v0 #backups the index of the number in the array
	la $a0,msg11 	
	li $v0,4		
	syscall
	 
	add $a0, $zero, $t6  # Get number read from previous syscall and put it in $a0, argument for next syscall
	addi $v0, $zero, 1   # Prepare syscall 0
	syscall              # System call
	
	la $a0,msg12 	
	li $v0,4		
	syscall
	 
	add $a0, $zero, $s5  # Get number read from previous syscall and put it in $a0, argument for next syscall
	addi $v0, $zero, 1   # Prepare syscall 0
	syscall 
	
	la $a0,msg13 	
	li $v0,4		
	syscall  
	
	li $v0,5      
	syscall
	
	move $t6,$v0 #$t6 - the number from the user
	
	jal check  
	
	
         bne $v0, -1, print_msg15  #the num already exist  
        
         sll $t8,$a1,2 #put in $t8 the size of the array in bytes
         sub $t9,$a2,$t8 #put in $t9 the first address of the array
        
         sll $t8,$s5,2 #put in $t8 the size of the array in bytes untill index $s5
         add $t9,$t9,$t8 #put in $t9 the the address to replace in the array
         
         sb $t6,($t9) #add num to the array
         
         la $a0,msg14 #the number replaceed successfully 	
	 li $v0,4		
	 syscall  
	 
         j menu
                        
del:

	beqz $a1,empty

	la $a0,msg6 	#What number to delete?
	li $v0,4		
	syscall
	
	li $v0,5      
	syscall
	
	move $t6,$v0
	
	jal check
	
	beq $v0,-1,print_msg16
	jal reduction
	sb $0,($s7) #overrides the last value of the array
	addi $a1,$a1,-1
	addi $a2,$a2,-4
	j menu

find:
	 
	la $a0,msg7 	#What number to find?
	li $v0,4		
	syscall
	
	li $v0,5      
	syscall
	
	jal check
	
	beq $v0,-1,print_msg16
	
	move $s5,$v0 
	
	la $a0,msg9 	#The number already exist in index:
	li $v0,4
	syscall
	
	add $a0, $zero, $s5  # Get number read from previous syscall and put it in $a0, argument for next syscall
	addi $v0, $zero, 1   # Prepare syscall 0
	syscall              # System call
	
	j menu
	
average:
	li $t7,0 #index of the array
	li $s0,0 #$s0 - the sum of the numbers in the array
	li $s1,0 #$s1 - the average
	sll $t8,$a1,2 #put in $t8 the size of the array in bytes
        sub $t9,$a2,$t8 #put in $t9 the first address of the array
        beqz $a1,empty
        
   loop1:
   	beq $t7,$a1,div_numbers #If count is at the end of the array    
     	lb $t5,($t9) #load into $t5 the value that exist in address of $t9
     	add $s0,$s0,$t5 
     	addi $t7,$t7,1
        addi $t9,$t9,4
        j loop1
   div_numbers:
   	   div $s1,$s0,$a1
   	   
   	   sub $sp,$sp,4 #backups the values in the stack memory
	   sw $a1,($sp)
	   sub $sp,$sp,4
	   sw $a2,($sp)
	   
   	   move $a1,$s1 #a1 = average to print
   	   la $a0,msg8 	#Which base would you like for the numbers? (2-10) 
	   li $v0,4 		
	   syscall
	   li $v0,5      
	   syscall
	   move $a2,$v0 #a2 = the base
	   
   	   j print_num
   	   
	j pop
	   
max:
	li $t3,0
	li $t7,0 #the index of array
	sub $k1,$a1,1 #maximum index to check
	
	sll $t8,$a1,2 #put in $t8 the size of the array in bytes
        sub $t9,$a2,$t8 #put in $t9 the first address of the array
        
        sub $sp,$sp,4 #backups the values in the stack memory
	sw $a1,($sp)
	sub $sp,$sp,4
	sw $a2,($sp)
	
	lb $a1,($t9) #$s5 = the max value
	la $a0,msg8 	#Which base would you like for the numbers? (2-10) 
	li $v0,4 		
	syscall
	   
	li $v0,5      
	syscall 
	
	move $a2,$v0
loop6:
        bgt $t7,$k1,print_num
        lb $t3,($t9)
        blt $t3,$a1, keep
        move $a1,$t3
   keep:
        addi $t7,$t7,1
        addi $t9,$t9,4
        j loop6
        
        la $a0,msg17 	#\n 
	li $v0,4 		
	syscall
	
	jal print_num
	move $t6,$a1
	
	lw $a2,($sp) #pop
	addiu $sp,$sp,4
	lw $a1,($sp)
	addiu $sp,$sp,4
	
	jal check
	
	move $t7,$v0
	la $a0,msg18 	 
	li $v0,4 		
	syscall
	add $a0, $zero, $t7  # Get number read from previous syscall and put it in $a0, argument for next syscall
	addi $v0, $zero, 1   # Prepare syscall 0
	syscall              # System call
	li $t3,0
	
print_array:
	   li $k0,0 #$k0 = index
	   move $s5,$a1
	   move $s0,$s5
	   addi $s0,$s0,-1  #$s0 = NUM - 1
           sll $t8,$a1,2 #put in $t8 the size of the array in bytes
           sub $t9,$a2,$t8 #put in $t9 the first address of the array 
           
	   sub $sp,$sp,4 #backups the values in the stack memory
	   sw $a1,($sp)
	   sub $sp,$sp,4
	   sw $a2,($sp)
	  
	   la $a0,msg8 	#Which base would you like for the numbers? (2-10) 
	   li $v0,4 		
	   syscall
	   
	   li $v0,5      
	   syscall 
	   
	   move $a2,$v0
	   
	   la $a0,msg17 	#\n 
	   li $v0,4 		
	   syscall 
loop5:
	   beq $k0,$s5,pop
	   lb $a1,($t9)
	   jal print_num
	   beq $k0,$s0,loop7
	   li $a0,','
	   li $v0,11
	   syscall
loop7:
	   addi $t9,$t9,4
	   addi $k0,$k0,1
	   j loop5
pop:
        lw $a2,($sp)
	addiu $sp,$sp,4
	lw $a1,($sp)
	addiu $sp,$sp,4
	j menu	
	
full: 
        la $a0,msg2 	#The array is full.
	li $v0,4		
	syscall
	j menu 
empty:
	la $a0,msg4 	#The array is empty.
	li $v0,4		
	syscall
	j menu 
 
check:       
         sll $t8,$a1,2 #put in $t8 the size of the array in bytes
         sub $t9,$a2,$t8 #put in $t9 the first address of the array 
         
     loop: bgt $t7,$a1,not_exist #If count is at the end of the array    
     	   lb $t5,($t9) #load into $t5 the value that exist in address of $t9
           beq $t6,$t5,already_exist
           addi $t9,$t9,4
	   addi $t7,$t7,1
         
         j loop
                
not_exist: 	
	 
	 li $t7,0
	 li $v0,-1
	 jr $ra
	          	
already_exist:
      move $v0,$t7
      li $t7,0
      jr $ra

print_msg9:
	la $a0,msg9 	#The number already exist in index:
	li $v0,4
	syscall
	 
	add $a0, $zero, $s5  # Get number read from previous syscall and put it in $a0, argument for next syscall
	addi $v0, $zero, 1   # Prepare syscall 0
	syscall              # System call
	             
	j menu	
		
print_num:
	li $t7,0 		#$t7 - index of the array to print
	li $v0,1
	bgt $a1,$0,loop2
	li $v1,-1
	mult $a1,$v1
	li $v1,0
	mflo $a1
	li $a0,'-'
	li $v0,11
	syscall
	li $a0,0
	li $v0,1
loop2:
	beqz $a1,print
	div $a1,$a2
	mflo $a1             	#save the quotient in t3
	mfhi $s4                #save the reminder in t5
	sb $s4,($a3)
	addi $a3,$a3,4
	addi $t7,$t7,1
	j loop2
print:
	beq $t7,0,return_to
	sb $0,($a3) #resets the values of array1 (put zero)
	addi $t7,$t7,-1
	addi $a3,$a3,-4
	lb $a0,($a3)
	syscall
	j print
	
	
reduction:
	 li $t8,0
	 li $t9,0
	 sll $t8,$a1,2 #put in $t8 the size of the array in bytes
         sub $t9,$a2,$t8 #put in $t9 the first address of the array
        
         sll $t8,$v0,2 #put in $t8 the size of the array in bytes untill index $s5
         add $t9,$t9,$t8 #put in $t9 the the address to remove in the array
   loop4:
    	  beq $v0,$a1,return_to
    	  move $s7,$t9
    	  addi $s7,$s7,4 #$s7 - the next address in the array
    	  lb $v1,($s7) #$v1 - the value of the next address in the array
    	  sb $v1,($t9) #overrides the present value in the present address in the array, by $v1
    	  addi $v0,$v0,1 #$v0 is the index from the period of the requested value
    	  addi $t9,$t9,4
    	  j loop4
return_to:
 	jr $ra
 	
print_msg15:

	la $a0,msg15 	#The number already exist
	li $v0,4
	syscall
	
	
print_msg16:	
	la $a0,msg16 	#The number is't exist, thus it can't be deleted
	li $v0,4
	syscall	
	
	j menu	
	
	
	
