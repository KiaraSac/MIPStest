.data 
	string0: .asciiz "Inserire un carattere:  "
      	string1: .asciiz "\nCarattere inserito:  "
	string2: .asciiz "  uguale a b  "		
	string3: .asciiz "  diverso da b  "

.text 
.globl main

main:	li $v0,4	#stampa sringa 0
	la $a0,string0
	syscall 
	
	li $v0,12	#legge carattere
	syscall 
	
	move $t0,$v0	#v0 contiene il carattere, quindi sposta il contenuto in t0
	
	li $v0,4	#stampa sringa 1
	la $a0,string1
	syscall
	
	li $v0,11	#stampa il carattere
	move $a0,$t0
	syscall 
	
	beq $t0,'b',eq

	li $v0,4	#stampa sringa 3
	la $a0,string3
	syscall
	j exit 

 eq: 	li $v0,4	#stampa sringa 2
	la $a0,string2
	syscall
	
exit:	li $v0,10
	syscall 
	