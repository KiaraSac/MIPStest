


.data
prompt:	.asciiz "come ti chiami?"
msg:	.ascii "hello"
buffer:	.space 256


.text 
.globl main

main:	li $v0,4
	la $a0,prompt
	syscall 	#print_string
	
	li $v0,8	#legge il nome
	la $a0,buffer
	li $a1,256
	syscall 	
	
	li $v0,4	#stampa hello+nome
	la $a0,msg
	syscall 
	
	li $v0,10
	syscall 
