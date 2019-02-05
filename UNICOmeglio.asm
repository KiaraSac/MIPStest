.data
valuesS:	.word 1,9,89,88,79,23,4,11
valuesP:	.word -8,90,95,-78,0,66,60,18,56,28
valuesD:	.word 0xB34, 0xB21, 0xB10, 0xA07, 0xA07, 0xB11, 0xB11, 0xB11
filePathS:	.asciiz   "correttezzasterzoOUT.txt"
filePathP:	.asciiz   "correttezzapendenzaOUT.txt"
filePathD:	.asciiz   "correttezzadistanzaOUT.txt"
.align 2
risS:	.space 32
risP:	.space 40
risD:	.space 32

.text
	
	
#vvvvSTERZOvvvvvvv
	li $s0,0        	#inizializzazione offset (istante t)
	la $t5,risS
	li $t8,0	#offset stringa risultati
SgetVal:	beq $s0,32,pendenza	#se s0= (numero di valori)*4 allora li ho letti tutti e smetto [32=(8)*4]
	lw $s2,valuesS($s0)	#in s2 metto il valore all'istante t(attuale)
	beqz $s0,Scorr1	#controllo se è il primo valore
	#***** if((val-preVal>10)||(val-preVal<-10))
	sub $t1,$s2,$s1	#esegue la sottrazione tra il valore attuale e quello all'istante precedente
	sgt $t2,$t1,10	#t2=1 se val-preVal>10
	slti $t3,$t1,-10	#t3=1 se val-preVal<-10
	or $t1,$t3,$t2	#t1 contiene il risultato del confronto
	#*******
	beqz $t1,Scorr1
	j Scorr0
	
#stVal:	move $s1,$s2	#sposto il valore corrente in s1 che conterrà il valore all'istante t-1
#	addi $s0,$s0,4	#incrementa l'istante
#	j SgetVal		#non stampo nulla perchè non lo posso confrontare


Scorr0:	#mette a 0
	li $t4,48		#48(base 10) è "0" in ASCII
	sb $t4,risS($t8)	#carica "0" 
	addi $t8,$t8,2		#incremento l'offset (stringa risultati)
	addi $s0,$s0,4	#incrementa l'istante
	move $s1,$s2	#mette il valore attuale in s1 che contiene il "valore precedente"
	j SgetVal		
Scorr1:	#mette a 1 
	li $t4,49		#49(base 10) è "1" in ASCII
	sb $t4,risS($t8)	#carica "1"
	addi $t8,$t8,2		#incremento l'offset (stringa risultati)
	addi $s0,$s0,4	#incrementa l'istante
	move $s1,$s2	#mette il valore attuale in s1 che contiene il "valore precedente"
	j SgetVal
	
#^^^^^^^^^FINE STERZO^^^^^^^^^

#vvvvvvvvvPENDENZAvvvvvvvvvvv
pendenza:	li $s0,0        	#inizializzazione offset (istante t)
	la $t5,risP
	li $t8,0
PgetVal:	beq $s0,40,distanza	#se s0= (numero di valori)*4 allora li ho letti tutti e smetto [36=(8)*4]
	lw $s2,valuesP($s0)	#in s2 metto il valore all'istante t(attuale)
	#***** if((val>-60)&&(val<60))
	sgt $t1,$s2,-60	#t1=1 se val>-60
	slti $t2,$s2,60	#t2=1 se val<60
	and $t3,$t1,$t2	#t3 contiene il risultato del confronto
	#*******
	beqz $t3,Pcorr0
	j Pcorr1	

Pcorr0:	#mette a 0
	li $t4,48		#48(base 10) è "0" in ASCII
	sb $t4,risP($t8)	#carica "0" 
	addi $t8,$t8,2		#incremento l'offset (stringa risultati)
	addi $s0,$s0,4	#incrementa l'istante
	j PgetVal		
Pcorr1:	#mette a 1 
	li $t4,49		#49(base 10) è "1" in ASCII
	sb $t4,risP($t8)	#carica "1"
	addi $t8,$t8,2		#incremento l'offset (stringa risultati)
	addi $s0,$s0,4	#incrementa l'istante
	j PgetVal
	
#^^^^^^^FINE PENDENZA^^^^^^^^^

#vvvvvvDISTANZAvvvvvvvvvvv

distanza:	
	li $s0,0        	#inizializzazione offset (istante t)
	la $t5,risD
	li $t8,0
DgetVal:		
	la $t0,valuesD($s0)
	lb $s1,0($t0)	#metto in s1 la cifra
	lb $s2,1($t0)	#metto in s2 la lettera
			#t0 non mi serve più, quindi lo posso riutilizzare
	beq $s0,32,fineVal	#se s0= numero di valori*4 allora li ho letti tutti e smetto [32=8*4]
	sgt $t0,$s1,0	#controllo se la cifra è <= 0
	beqz $t0,Dcorr0	#se la distanza è zero, corr=0
	sgt $t1,$s1,0x32	#t1 a 1 se la distanza è maggiore i 50
	beq $t1,1,Dcorr0	#salta se la distanza è >50
	beq $s2,0xa,Dcorr1	#se è un ostacolo fisso allora è corretto
	move $a0,$s1	#in a0 metto la cifra
	move $a1,$s0	#in a1 metto l'istante
	jal obstB
	j Dcorr1
	
	
Dcorr0:	#mette a 0
	li $t4,48		#48(base 10) è "0" in ASCII
	sb $t4,risD($t8)
	addi $t8,$t8,2		#incremento l'offset (stringa risultati)
	addi $s0,$s0,4
	j DgetVal
Dcorr1:	#mette a 1 
	li $t4,49		#49(base 10) è "1" in ASCII
	sb $t4,risD($t8)
	addi $t8,$t8,2		#incremento l'offset (stringa risultati)
	addi $s0,$s0,4
	j DgetVal
	
 
obstB:	addi $sp,$sp,-16	#alloco 4 word nello stack
	addi $fp,$sp,16	#inizializzo il frame pointer
	sw $fp,16($sp)	#carico nello stack
	#sw $a1,8($sp)	#
	#sw $a2,4($sp)	#
	 #sw $ra,0($sp)	#salva l'idirizzo di ritorno
	bnez $a1,control	#se l'istante è zero vuol dire che è il primo valore letto
	move $s3,$a0	#in s3 c'è il valore all'istante precedente
	li $t3,1		#inizializzo il contatore (t3)
	sw $t3,12($sp)	#salvo il contatore nello stack
	jr $ra		#torno da dove sono venuta
control:	beq $s3,$a0,inCont	#se i valori sono uguali...
	move $s3,$a0	#il nuovo valore da confrontare è in s3
	li $t3,1		#contatore a 1
	sw $t3,12($sp)	#aggiorno il contatore nello stack
	jr $ra		#torno da dove sono venuta
inCont:	addi $t3,$t3,1	#incremento il contatore
	slti $t2,$t3,3
	beqz $t2,Dcorr0
	jr $ra
	
fineVal:   #ho letto tutti i valore e posso scrivere il risultato
#*******STAMPA VALORI*************
	# apri file ( siccome non esiste lo crea
	li $v0,13          	# chiamata di systema per aprire
      	la $a0,filePathD     	# carica il percorso di scrittura
      	li $a1,1            	# flag di scrittura
      	syscall
      	move $s6,$v0        	# salvo il percorso 

    	#scrivo nel file la stringa
    	li $v0, 15            # chiamata di sistema
    	move $a0, $s6         # pass il percorso dove scrivere
    	la $a1, risD      	# passa inidirizzo di inizio della stringa
    	li $a2, 32            # size del buffer (n° valori * 4)
    	syscall
    
   	li $v0, 16		# Close File Syscall
	syscall
	
	# apri file ( siccome non esiste lo crea
	li $v0,13          	# chiamata di systema per aprire
      	la $a0,filePathS     	# carica il percorso di scrittura
      	li $a1,1            	# flag di scrittura
      	syscall
      	move $s6,$v0        	# salvo il percorso 

    	#scrivo nel file la stringa
    	li $v0, 15            # chiamata di sistema
    	move $a0, $s6         # pass il percorso dove scrivere
    	la $a1, risS      	# passa inidirizzo di inizio della stringa
    	li $a2, 32            # size del buffer (n° valori * 4)
    	syscall
    
   	li $v0, 16		# Close File Syscall
	syscall
	
	# apri file ( siccome non esiste lo crea
	li $v0,13          	# chiamata di systema per aprire
      	la $a0,filePathP     	# carica il percorso di scrittura
      	li $a1,1            	# flag di scrittura
      	syscall
      	move $s6,$v0        	# salvo il percorso 

    	#scrivo nel file la stringa
    	li $v0, 15            # chiamata di sistema
    	move $a0, $s6         # pass il percorso dove scrivere
    	la $a1, risP      	# passa inidirizzo di inizio della stringa
    	li $a2, 40            # size del buffer (n° valori * 4)
    	syscall
    
   	li $v0, 16		# Close File Syscall
	syscall
#***********************************************
	li $v0,10
	syscall
