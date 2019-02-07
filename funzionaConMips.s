.data

valuesS:	.word	1, 12, 18, 29, 1, 60, 68, 70
valuesP:	.word	70, -100, 50, 10, -1000, 30, 18, 0
valuesD:	.word	0xB21, 0xB21, 0xB21, 0xA10, 0xA70, 0xA0a, 0xB10, 0xB4f
filePathS:	.asciiz	"correttezzasterzoOUT.txt"
filePathP:	.asciiz	"correttezzapendenzaOUT.txt"
filePathD:	.asciiz	"correttezzadistanzaOUT.txt"
filePathP1:	.asciiz	"corrP1.txt"
filePathP2:	.asciiz	"corrP2.txt"
filePathP3:	.asciiz	"corrP3.txt"
.align 2
risS:	.space 15
risP:	.space 15
risD:	.space 15

risP1:	.space	15
risP2:	.space	15
risP3:	.space	15
.align 2
JAT:	.space	16 	#jump address table da 4 posti

.text
.globl main
main:		addi $sp, $sp, -4
		sw $ra, 0($sp)
	#salvare tutti i registri s usatir
		jal checkToBuffer
		jal sensorWrite
		
		la $a0,filePathP1
		jal openFile
		move $s0,$v0
		
		la $a0,filePathP2
		jal openFile
		move $s1,$v0
	
		la $a0,filePathP3
		jal openFile
		move $s2,$v0
	
		move $a0,$s0
		move $a1,$s1
		move $a2,$s2
	
		jal initPol
		j exit
	#apertura file singolo modulare
	#lettura file singolo modulare
	#traduzione e scrittura su buffer

checkToBuffer:	
		addi $sp, $sp, -16
		sw $s0, 0($sp)
		sw $s1, 4($sp)
		sw $s2, 8($sp)
		sw $s3, 12($sp)
		li $s0,0
		li $t5,0
		
SgetVal:#da salvare se traformata in jal: $s0,1,2, $ra
		beq $s0,32,pendenza	#se s0= (numero di valori)*4 allora li ho letti tutti e smetto [32=(8)*4]
		lw $s2,valuesS($s0)	#in s2 metto il valore all'istante t(attuale)
		beqz $s0,stVal	#controllo se il primo valore
		li $t4,32		#siccome non e' il primo stampa uno spazio...
		sb $t4,risS($t5)
		addi $t5,$t5,1	#... e aumento il contatore
	#***** if((val-preVal>10)||(val-preVal<-10))
		sub $t1,$s2,$s1	#esegue la sottrazione tra il valore attuale e quello all'istante precedente
		sgt $t2,$t1,10	#t2=1 se val-preVal>10
		slti $t3,$t1,-10	#t3=1 se val-preVal<-10
		or $t1,$t3,$t2	#t1 contiene il risultato del confronto
	#*******
		beqz $t1,Scorr1
		j Scorr0
		
	
stVal:		move $s1,$s2	#sposto il valore corrente in s1 che conterr il valore all'istante t-1
		j Scorr1		#non stampo nulla perch non lo posso confrontare


Scorr0:	#mette a 0
		li $t4,48		#48(base 10) "0" in ASCII
		sb $t4,risS($t5)	#carica "0"
		addi $t5,$t5,1
		addi $s0,$s0,4	#incrementa l'istante
		move $s1,$s2	#mette il valore attuale in s1 che contiene il "valore precedente"
		j SgetVal		
Scorr1:	#mette a 1 
		li $t4, 49		#49(base 10) "1" in ASCII
		sb $t4,risS($t5)	#carica "1"
		addi $t5,$t5,1
		addi $s0,$s0,4	#incrementa l'istante
		move $s1,$s2	#mette il valore attuale in s1 che contiene il "valore precedente"
		j SgetVal
	
#^^^^^^^^^FINE STERZO^^^^^^^^^

#vvvvvvvvvPENDENZAvvvvvvvvvvv
pendenza:	li $s0,0        	#inizializzazione offset (istante t)
		li $t5,0
PgetVal:	beq $s0,32,distanza	#se s0= (numero di valori)*4 allora li ho letti tutti e smetto [36=(8)*4]
		lw $s2,valuesP($s0)	#in s2 metto il valore all'istante t(attuale)
	#***** if((val>-60)&&(val<60))
		sgt $t1,$s2,-60	#t1=1 se val>-60
		slti $t2,$s2,60	#t2=1 se val<60
		and $t3,$t1,$t2	#t3 contiene il risultato del confronto
	#*******
		beq $s0, 0, verifyP
		li $t4,32		#siccome non e' il primo stampa uno spazio...
		sb $t4,risP($t5)
		addi $t5,$t5,1	#... e aumento il contatore
verifyP:	beqz $t3,Pcorr0
		j Pcorr1	

Pcorr0:	#mette a 0
		li $t4,48		#48(base 10) "0" in ASCII
		sb $t4,risP($t5)	#carica "0" 
		addi $t5,$t5,1	#offset carattere per la stampa
		addi $s0,$s0,4	#incrementa l'istante
		j PgetVal		
Pcorr1:	#mette a 1 
		li $t4,49		#49(base 10) "1" in ASCII
		sb $t4,risP($t5)	#carica "1"
		addi $t5,$t5,1 #offset carattere per la stampa
		addi $s0,$s0,4	#incrementa l'istante
		j PgetVal
	
#^^^^^^^FINE PENDENZA^^^^^^^^^

#vvvvvvDISTANZAvvvvvvvvvvv

distanza:	li $s0,0        	#inizializzazione offset (istante t)
		li $t5,0
DgetVal:	la $t0,valuesD($s0)
		lb $s1,0($t0)	#metto in s1 la cifra
		lb $s2,1($t0)	#metto in s2 la lettera
		#t0 non mi serve pi, quindi lo posso riutilizzare
		beq $s0,32,goback	#se s0= numero di valori*4 allora li ho letti tutti e smetto [32=8*4]
		sgt $t0,$s1,0	#controllo se la cifra <= 0
		beqz $t0,Dcorr0	#se la distanza zero, corr=0
		sgt $t1,$s1,0x32	#t1 a 1 se la distanza maggiore i 50
		
		beq $s0, 0, verifyD
		li $t4,32		#siccome non e' il primo stampa uno spazio...
		sb $t4,risD($t5)
		addi $t5,$t5,1	#... e aumento il contatore
		
verifyD:	beq $t1,1,Dcorr0	#salta se la distanza >50
		beq $s2,0xa,Dcorr1	#se un ostacolo fisso allora corretto
##################
obstB:		beq $s3,$s1,inCont	#se i valori sono uguali...
		move $s3,$s1	#in s3 c' il valore all'istante precedente
		li $t3,1		#inizializzo il contatore (t3)
		j Dcorr1	#torno da dove sono venuta
inCont:		addi $t3,$t3,1	#incremento il contatore
		slti $t2,$t3,3
		beqz $t2,Dcorr0
		j Dcorr1
	
	
Dcorr0:	#mette a 0
		li $t4,48		#48(base 10) "0" in ASCII
		sb $t4,risD($t5)
		addi $t5,$t5,1
		addi $s0,$s0,4
		j DgetVal
Dcorr1:	#mette a 1 
		li $t4,49		#49(base 10) "1" in ASCII
		sb $t4,risD($t5)
		addi $t5,$t5,1
		addi $s0,$s0,4
		j DgetVal
		

goback:		#dealloco il buffer
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		addi $sp, $sp, 16
		
		jr $ra
	
	
sensorWrite:   #ho letto tutti i valore e posso scrivere il risultato
	#*******STAMPA VALORI*************
	# apri file ( siccome non esiste lo crea
	li $v0,13          	# chiamata di systema per aprire
      	la $a0,filePathD     	# carica il percorso di scrittura
      	li $a1,1            	# flag di scrittura
      	syscall
      	move $t0,$v0        	# salvo il percorso 

    	#scrivo nel file la stringa
    	li $v0, 15            # chiamata di sistema
    	move $a0, $t0         # pass il percorso dove scrivere
    	la $a1, risD      	# passa inidirizzo di inizio della stringa
    	li $a2, 15            # size del buffer (n valori * 4)
    	syscall
    
	li $v0, 16		# Close File Syscall
	move $a0, $t0
	syscall
	
	# apri file ( siccome non esiste lo crea
	li $v0,13          	# chiamata di systema per aprire
      	la $a0,filePathS     	# carica il percorso di scrittura
      	li $a1,1            	# flag di scrittura
      	syscall
      	move $t0,$v0        	# salvo il percorso 

    	#scrivo nel file la stringa
	li $v0, 15            # chiamata di sistema
    	move $a0, $t0         # pass il percorso dove scrivere
    	la $a1, risS      	# passa inidirizzo di inizio della stringa
    	li $a2, 15            # size del buffer (n valori * 4)
    	syscall
    
	li $v0, 16		# Close File Syscall
	move $a0, $t0
	syscall
	
	# apri file ( siccome non esiste lo crea
	li $v0,13          	# chiamata di systema per aprire
      	la $a0,filePathP     	# carica il percorso di scrittura
      	li $a1,1            	# flag di scrittura
      	syscall
      	move $t0,$v0        	# salvo il percorso 

    	#scrivo nel file la stringa
    	li $v0, 15            # chiamata di sistema
    	move $a0, $t0         # pass il percorso dove scrivere
    	la $a1, risP      	# passa inidirizzo di inizio della stringa
    	li $a2, 15          # size del buffer (n valori * 4)
    	syscall
    
	li $v0, 16		# Close File Syscall
	move $a0, $t0
	syscall
	
	jr $ra
		
openFile:		#procedura per aprire i file
	li $v0,13
	li $a1,1
	li $a2,0
	syscall
	jr $ra	
#***************************
initPol:	li $s0,0        	#inizializzazione offset (istante t)
		li $t6,0		#contatore per scrivere
		addi $sp,$sp,-4
		sw $ra,0($sp)
		move $s2,$a0
		move $s3,$a1
		move $s4,$a2
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
	
getVal:		la $t0,JAT
		beq $s0,16,write	#se s0= (numero di valori)*2 allora li ho letti tutti e smetto
		beq $s0,0,verifyPol
		li $t5,32		#stampo lo spazio
		sb $t5,risP1($t6)
		sb $t5,risP2($t6)
		sb $t5,risP3($t6)
		addi $t6,$t6,1
verifyPol:	
		lb $t1,risS($s0)	#leggo i valori all'istante t
		lb $t2,risP($s0)
		lb $t3,risD($s0)
		add $t4,$t1,$t2		#sommo i tre valori letti
		add $s1,$t4,$t3		#il risultato della somma is in s1
		li $t7,144
		sub $s1,$s1,$t7
	
#calcolo l'indirizzo
		add $t1, $s1, $s1
		add $t1, $t1, $t1	#s1*4 is l'offset
		add $t1, $t1, $t0	#sommo l'offset alla base della jat
		lw $t0, 0($t1)
		jr $t0
	
#casi
P0:		li $t5,48		#48(base 10) is "0" in ASCII
		sb $t5,risP1($t6)
		li $t5,48		
		sb $t5,risP2($t6)
		li $t5,48		
		sb $t5,risP3($t6)
		addi $t6,$t6,1	
		addi $s0,$s0,2		#incremento contatore da trasformare in 8 visto che ci sara' un carattere spazio nel mezzo
		j getVal
	
P1:		li $t5,48		
		sb $t5,risP1($t6)
		li $t5,48		
		sb $t5,risP2($t6)
		li $t5,49		
		sb $t5,risP3($t6)
		addi $t6,$t6,1
		addi $s0,$s0,2		#incremento contatore
		j getVal
	
P2: 		li $t5,48		
		sb $t5,risP1($t6)
		li $t5,49		
		sb $t5,risP2($t6)
		li $t5,49		
		sb $t5,risP3($t6)
		addi $t6,$t6,1
		addi $s0,$s0,2		#incremento contatore
		j getVal
	
P3: 		li $t5,49		
		sb $t5,risP1($t6)
		li $t5,49		
		sb $t5,risP2($t6)
		li $t5,49		
		sb $t5,risP3($t6)
		addi $t6,$t6,1
		addi $s0,$s0,2		#incremento contatore
		j getVal

write:		move $a0,$s2
		la $a1,risP1
		jal writeClose
	
		move $a0,$s3
		la $a1,risP2
		jal writeClose
	
		move $a0,$s4
		la $a1,risP3
		jal writeClose	

		j exitPol
writeClose:
		li $v0,15            # chiamata di sistema
		li $a2,15            # size del buffer (n valori * 4)
		syscall
		li $v0, 16		# Close File Syscall
		syscall
		jr $ra
	
exitPol:	
		lw $ra,0($sp)
		addi $sp,$sp,4
		jr $ra

		
#***********************************************
	
exit:	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
