.data
saluto: .asciiz "is there anyone in there?"

.text 
.globl main

main:	la $t0,saluto	#puntatore a carattere
	li $t1,0	#contatore lunghezza
	
nextCh:	lb $t2,($t0)	#leggi carattere (1 byte)
	beq $t2,$zero,fine
	addi $t1,$t1,1	#incremento contatore
	addi $t0,$t0,1	#incremento posizione
	j nextCh

fine:	li $v0,1
	move $a0,$t1
	syscall
	
	li $v0,10
	syscall 
	
	
	
	
