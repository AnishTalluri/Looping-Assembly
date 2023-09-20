##########################################################################
# Created by:  Talluri, Anish
#              1967545
#              23 May 2023
#
# Assignment:  Lab 3: Looping with RISC-V Assembly
#              CSE 12, Computer Systems and Assembly Language
#	       UC Santa Cruz, Fall 2022
#
# Description: This program asks the user to input a positive number of 
#              rows and outputs a "tattooed right-angled triangle" with 
#              $*$* patters, with each row ending in 0 and increasing in 
#              characters as it goes down each row.
#
# Notes:       This program is intended to be run from the RARS IDE.
##########################################################################
# PSEUDOCODE (Written in Python):
#	def main():
#	    height = int(input("Enter the height of the pattern (must be greater than 0): "))
#
#	    if height <= 0:
#	        print("Invalid Entry!")
#	        return
#
#	    num_of_lines = 0
#	    while num_of_lines < height:
#	        print("$", end="")
#        
#	        inner_count = 0
#	        while inner_count < num_of_lines:
#	            print("*$", end="")
#	            inner_count += 1
#        
#	        print("0")
#	        num_of_lines += 1
#
#	if __name__ == '__main__':
#	    main()
##########################################################################


.macro exit #macro to exit program
	li a7, 10
	ecall
	.end_macro	

.macro print_str(%string1) #macro to print any string
	li a7,4 
	la a0, %string1
	ecall
	.end_macro
	
	
.macro read_n(%x)#macro to input integer n into register x
	li a7, 5
	ecall 		
	#a0 now contains user input
	addi %x, a0, 0
	.end_macro
	
.macro print_n(%x)#macro to input integer n into register x
	addi a0,%x, 0
	li a7, 1
	ecall
.end_macro

.macro 	file_open_for_write_append(%str)
	la a0, %str
	li a1, 1
	li a7, 1024
	ecall
.end_macro
	
.macro  initialise_buffer_counter
	#buffer begins at location 0x10040000
	#location 0x10040000 to keep track of which address we store each character byte to 
	#actual buffer to store the characters begins at 0x10040008
	
	#initialize mem[0x10040000] to 0x10040008
	addi sp, sp, -16
	sd t0, 0(sp)
	sd t1, 8(sp)
	
	li t0, 0x10040000
	li t1, 0x10040008
	sd t1, 0(t0)
	
	ld t0, 0(sp)
	ld t1, 8(sp)
	addi sp, sp, 16
	.end_macro
	

.macro write_to_buffer(%char)
	#NOTE:this macro can add ONLY 1 character byte at a time to the file buffer!
	
	addi sp, sp, -16
	sd t0, 0(sp)
	sd t4, 8(sp)
	
	
	li t0, 0x10040000
	ld t4, 0(t0)#t4 is starting address
	#t4 now points to location where we store the current %char byte
	
	#store character to file buffer
	li t0, %char
	sb t0, 0(t4)
	
	#update address location for next character to be stored in file buffer
	li t0, 0x10040000
	addi t4, t4, 1
	sd t4, 0(t0)
	
	ld t0, 0(sp)
	ld t4, 8(sp)
	addi sp, sp, 16
	.end_macro

.macro fileRead(%file_descriptor_register, %file_buffer_address)
#macro reads upto first 10,000 characters from file
	addi a0, %file_descriptor_register, 0
	li a1, %file_buffer_address
	li a2, 10000
	li a7, 63
	ecall
.end_macro 

.macro fileWrite(%file_descriptor_register, %file_buffer_address,%file_buffer_address_pointer)
#macro writes contents of file buffer to file
	addi a0, %file_descriptor_register, 0
	li a1, %file_buffer_address
	li a7, 64
	
	#a2 needs to contains number of bytes sent to file
	li a2, %file_buffer_address_pointer
	ld a2, 0(a2)
	sub a2, a2, a1
	
	ecall
.end_macro 

.macro print_file_contents(%ptr_register)
	li a7, 4
	addi a0, %ptr_register, 0
	ecall
	#entire file content is essentially stored as a string
.end_macro
	


.macro close_file(%file_descriptor_register)
	li a7, 57
	addi a0, %file_descriptor_register, 0
	ecall
.end_macro

.data
	prompt: .asciz  "Enter the height of the pattern (must be greater than 0):"
	invalidMsg: .asciz  "Invalid Entry!"
	newLine: .asciz  "\n"
	star_dollar: .asciz  "*$"
	dollar: .asciz  "$"
	star: .asciz "*"
	blankspace: .asciz " "
	outputMsg: .asciz  " display pattern saved to lab3_output.txt "
	filename: .asciz "lab3_output.txt"
	Zero:.asciz"0"
	
.text
	file_open_for_write_append(filename)
	#a0 now contaimns the file descriptor (i.e. ID no.)
	#save to t6 register
	addi t6, a0, 0
	
	initialise_buffer_counter
	
	#for utilsing macro write_to_buffer, here are tips:
	#0x2a is the ASCI code input for star(*)
	#0x24 is the ASCI code input for dollar($)
	#0x30  is the ASCI code input for  the character '0'
	#0x0a  is the ASCI code input for  newLine (/n)

	
	#START WRITING YOUR CODE FROM THIS LINE ONWARDS
	#DO NOT  use the registers a0, a1, a7, t6, sp anywhere in your code.
	
	#................ your code starts here..........................................................#

main:
	
	# Ask the user for the height of the pattern
	print_str(prompt)
	
	# Read the given input number
	read_n(t1)
	
	# Checks if t1 < 0 and if so jumps it to the "wrong_ht" label
	blt t1,zero, wrong_ht
	
	# Checks if t1 == 0 and if so jumps it to the "wrong_ht" label
	beqz t1, wrong_ht
	
	# Num_Of_Lines variable t0 = 0 for Outer Loop
	li t0, 0
	
	# Constant variable (t4) for if rows are greater than or same as 2
	li t4, 2
	

	# If t1 is a valid input then jump into first loop
	OuterLoopStart:
		
		# Exits outer loop if Num_Of_Lines (t0) > Rows (t1)
		beq t0,t1, OuterLoopExit
		
		# InnerCount variable t3 = 0
		li t3, 0
		
		# Print starting dollar sign (Row 1)
		print_str(dollar)
		write_to_buffer(0x24)
		
		
			# Start of inner loop in case there are more rows
			InnerLoopStart:
		
				# If InnerCount (t3) < Num_Of_Lines (t0)
				beq t3,t0, InnerLoopExit
			
				# Prints a star dollar
				print_str(star_dollar)
				write_to_buffer(0x2a)
				write_to_buffer(0x24)
			
				# Add to inner count variable
				addi t3, t3,1
			
				j InnerLoopStart
		
			InnerLoopExit:
			
				# Print Zerro at the end of each row
				print_str(Zero)
				write_to_buffer(0x30)
				# Print a newline for the start of a new row
				print_str(newLine)
				write_to_buffer(0x0a)
			
				# Update to the next line
				addi t0, t0,1
			
				# Branch to OuterLoopStart
				j OuterLoopStart
		
	OuterLoopExit:
		
		# Jump to Exit and end program
		j Exit
	
wrong_ht:

	# Tells the user they used an invalid input
	print_str(invalidMsg)
	print_str(newLine)
	write_to_buffer(0x0a)
	
	# Jumps back to the top of the main program
	j main
	
	#................ your code ends here..........................................................#
	
	#END YOUR CODE ABOVE THIS COMMENT
	#Don't change anything below this comment!
	
Exit:	
	#write null character to end of file
	write_to_buffer(0x00)
	
	#write file buffer to file
	fileWrite(t6, 0x10040008,0x10040000)
	addi t5, a0, 0
	
	print_str(newLine)
	print_str(outputMsg)
	
	exit
	
	
