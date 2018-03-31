.data
array:	.byte 1,1,3,5,8,13,21,34,55,89
string:	.asciiz "\nposizione: "
.text
.globl main

main:	la $s0,array	#indirizzo partenza array
	la $a0,string
	li,$v0,4
	syscall		#chiede la posizione
	li,$v0,5
	syscall		#legge la posizione
	move $s1,$v0	#posizione in s1
	add $t0,$s1,$s0
	lb $s2,0($t0)	#prendo l'elemento
	move $a0,$s2	
	li $v0,1
	syscall 