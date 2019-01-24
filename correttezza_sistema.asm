.data
corrS:		.word 0,0,0,0,1,1,1,1
corrP:		.word 0,0,1,1,0,0,1,1
corrD:		.word 0,1,0,1,0,1,0,1
filePathP1:	.asciiz   "corrP1.txt"
filePathP2:	.asciiz   "corrP2.txt"
filePathP3:	.asciiz   "corrP3.txt"
.align 2
risP1:		.space 32
risP2:		.space 32
risP3:		.space 32
JAT:		.space 16 	#jump address table da 4 posti

.text
	li $s0,0        	#inizializzazione offset (istante t)		
#*******open file*********
	la $a0,filePathP1
	jal openFile
	move $s2,$v0	
	
	la $a0,filePathP2
	jal openFile
	move $s3,$v0
	
	la $a0,filePathP3
	jal openFile
	move $s4,$v0
	
	j getVal
	
openFile:		#procedura per aprire i file
	li $a1,1
	li $v0,13
	syscall
	jr $ra	
#***************************

getVal:
	#preparo la jat
	la $t0,JAT
	la $t1,P0
	sw $t1,0($t0)
	la $t1,P1
	sw $t1,4($t0)
	la $t1,P2
	sw $t1,8($t0)
	la $t1,P3
	sw $t1,12($t0)
	
	beq $s0,32,write	#se s0= (numero di valori)*4 allora li ho letti tutti e smetto [32=(8)*4]
	lw $t1,corrS($s0)	#leggo i valori all'istante t
	lw $t2,corrP($s0)
	lw $t3,corrD($s0)
	add $t4,$t1,$t2		#sommo i tre valori letti
	add $s1,$t4,$t3		#il risultato della somma è in s1
	
#calcolo l'indirizzo
	add $t1, $s1, $s1
	add $t1, $t1, $t1	#s1*4 è l'offset
	add $t1, $t1, $t0	#sommo l'offset alla base della jat
	lw $t0, 0($t1)
	jr $t0
	
#casi
P0:	li $t5,48		#48(base 10) è "0" in ASCII
	sb $t5,risP1($s0)
	li $t5,48		
	sb $t5,risP2($s0)
	li $t5,48		
	sb $t5,risP3($s0)
	addi $s0,$s0,4		#incremento contatore
	j getVal
	
P1:	li $t5,48		
	sb $t5,risP1($s0)
	li $t5,48		
	sb $t5,risP2($s0)
	li $t5,49		
	sb $t5,risP3($s0)
	addi $s0,$s0,4		#incremento contatore
	j getVal
	
P2: 	li $t5,48		
	sb $t5,risP1($s0)
	li $t5,49		
	sb $t5,risP2($s0)
	li $t5,49		
	sb $t5,risP3($s0)
	addi $s0,$s0,4		#incremento contatore
	j getVal
	
P3: 	li $t5,49		
	sb $t5,risP1($s0)
	li $t5,49		
	sb $t5,risP2($s0)
	li $t5,49		
	sb $t5,risP3($s0)
	addi $s0,$s0,4		#incremento contatore
	j getVal

write:	move $a0,$s2
	la $a1,risP1
	jal writeClose
	
	move $a0,$s3
	la $a1,risP2
	jal writeClose
	
	move $a0,$s4
	la $a1,risP3
	jal writeClose	

	j exit
writeClose:
	li $v0, 15            # chiamata di sistema
    	li $a2, 32            # size del buffer (n° valori * 4)
    	syscall
   	li $v0, 16		# Close File Syscall
	syscall
	jr $ra
	
exit:	li $v0,10
	syscall