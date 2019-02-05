.data

valuesS:	.word	1, 9
valuesP:	.word	70
valuesD:	.word	0xB21, 0xB21, 0xB21
filePathS:	.asciiz	"correttezzasterzoOUT.txt"
filePathP:	.asciiz	"correttezzapendenzaOUT.txt"
filePathD:	.asciiz	"correttezzadistanzaOUT.txt"
.align 2
risS:	.space 32
risP:	.space 40
risD:	.space 32

.text
.globl main

#vvvvSTERZOvvvvvvv
main:
	
		addi $sp, $sp, -4
		sw $ra, 0($sp)
	#salvare tutti i registri s usati
		jal init
		jal fineVal
		j exit
	#apertura file singolo modulare
	#lettura file singolo modulare
	#traduzione e scrittura su buffer

init:	
		addi $sp, $sp, -16
		sw $s0, 0($sp)
		sw $s1, 4($sp)
		sw $s2, 8($sp)
		sw $s3, 12($sp)
		li $s0,0
SgetVal:#da salvare se traformata in jal: $s0,1,2, $ra
		beq $s0,8,pendenza	#se s0= (numero di valori)*4 allora li ho letti tutti e smetto [32=(8)*4]
		lw $s2,valuesS($s0)	#in s2 metto 	il valore all'istante t(attuale)
		beqz $s0,stVal	#controllo se il primo valore
	#***** if((val-preVal>10)||(val-preVal<-10))
		sub $t1,$s2,$s1	#esegue la sottrazione tra il valore attuale e quello all'istante precedente
		sgt $t2,$t1,10	#t2=1 se val-preVal>10
		slti $t3,$t1,-10	#t3=1 se val-preVal<-10
		or $t1,$t3,$t2	#t1 contiene il risultato del confronto
	#*******
		beqz $t1,Scorr1
		j Scorr0
	
stVal:	move $s1,$s2	#sposto il valore corrente in s1 che conterr il valore all'istante t-1
		j Scorr1		#non stampo nulla perch non lo posso confrontare


Scorr0:	#mette a 0
		li $t4,48		#48(base 10) "0" in ASCII
		sb $t4,risS($s0)	#carica "0" 
		addi $s0,$s0,4	#incrementa l'istante
		move $s1,$s2	#mette il valore attuale in s1 che contiene il "valore precedente"
		j SgetVal		
Scorr1:	#mette a 1 
		li $t4,49		#49(base 10) "1" in ASCII
		sb $t4,risS($s0)	#carica "1"
		addi $s0,$s0,4	#incrementa l'istante
		move $s1,$s2	#mette il valore attuale in s1 che contiene il "valore precedente"
		j SgetVal
	
#^^^^^^^^^FINE STERZO^^^^^^^^^

#vvvvvvvvvPENDENZAvvvvvvvvvvv
pendenza:	li $s0,0        	#inizializzazione offset (istante t)
PgetVal:	beq $s0,4,distanza	#se s0= (numero di valori)*4 allora li ho letti tutti e smetto [36=(8)*4]
		lw $s2,valuesP($s0)	#in s2 metto il valore all'istante t(attuale)
	#***** if((val>-60)&&(val<60))
		sgt $t1,$s2,-60	#t1=1 se val>-60
		slti $t2,$s2,60	#t2=1 se val<60
		and $t3,$t1,$t2	#t3 contiene il risultato del confronto
	#*******
		beqz $t3,Pcorr0
		j Pcorr1	

Pcorr0:	#mette a 0
		li $t4,48		#48(base 10) "0" in ASCII
		sb $t4,risP($s0)	#carica "0" 
		addi $s0,$s0,4	#incrementa l'istante
		j PgetVal		
Pcorr1:	#mette a 1 
		li $t4,49		#49(base 10) "1" in ASCII
		sb $t4,risP($s0)	#carica "1"
		addi $s0,$s0,4	#incrementa l'istante
		j PgetVal
	
#^^^^^^^FINE PENDENZA^^^^^^^^^

#vvvvvvDISTANZAvvvvvvvvvvv

distanza:	li $s0,0        	#inizializzazione offset (istante t)
DgetVal:	la $t0,valuesD($s0)
		lb $s1,0($t0)	#metto in s1 la cifra
		lb $s2,1($t0)	#metto in s2 la lettera
		#t0 non mi serve pi, quindi lo posso riutilizzare
		beq $s0,12,goback	#se s0= numero di valori*4 allora li ho letti tutti e smetto [32=8*4]
		sgt $t0,$s1,0	#controllo se la cifra <= 0
		beqz $t0,Dcorr0	#se la distanza zero, corr=0
		sgt $t1,$s1,0x32	#t1 a 1 se la distanza maggiore i 50
		beq $t1,1,Dcorr0	#salta se la distanza >50
		beq $s2,0xa,Dcorr1	#se un ostacolo fisso allora corretto
##################
obstB:
	#sw $a1,8($sp)	#
	#sw $a2,4($sp)	#
	#sw $ra,0($sp)	#salva l'idirizzo di ritorno
		beq $s3,$s1,inCont	#se i valori sono uguali...
		move $s3,$s1	#in s3 c' il valore all'istante precedente
		li $t3,1		#inizializzo il contatore (t3)
		j Dcorr1	#torno da dove sono venuta
inCont:	addi $t3,$t3,1	#incremento il contatore
		slti $t2,$t3,3
		beqz $t2,Dcorr0
		j Dcorr1
	
	
Dcorr0:	#mette a 0
		li $t4,48		#48(base 10) "0" in ASCII
		sb $t4,risD($s0)
		addi $s0,$s0,4
		j DgetVal
Dcorr1:	#mette a 1 
		li $t4,49		#49(base 10) "1" in ASCII
		sb $t4,risD($s0)
		addi $s0,$s0,4
		j DgetVal
		

goback:	lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		addi $sp, $sp, 16
		
		jr $ra
	
	
fineVal:   #ho letto tutti i valore e posso scrivere il risultato
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
    	li $a2, 32            # size del buffer (n valori * 4)
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
    	li $a2, 32            # size del buffer (n valori * 4)
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
    	li $a2, 40            # size del buffer (n valori * 4)
    	syscall
    
		li $v0, 16		# Close File Syscall
		move $a0, $t0
		syscall
		
		jr $ra
		
#***********************************************
	
exit:	lw $ra, 0($sp)
		addi $sp, $sp, 4
	
		jr $ra
