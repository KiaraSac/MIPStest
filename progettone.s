#GRUPPO DI LAVORO
# Gianmarco Franchi	Email: gianmarco.franchi1@stud.unifi.it
# Niccolo' Mazzi	Email: niccolo.mazzi@stud.unifi.it
# Chiara Saccone Territo'	Email: chiara.saccone@stud.unifi.it
#
#DATA DI CONSEGNA
# 10 Febbraio 2019

.data

#file dai quali vengono  lettii valori
filePath_S_IN:	.asciiz "sterzoIN.txt"
filePath_P_IN: 	.asciiz "pendenzaIN.txt"
filePath_D_IN: 	.asciiz "distanzaIN.txt"
#file sui quali vengono stampati i valori di correttezza dei sensori
filePath_S_OUT:	.asciiz	"correttezzaSterzoOUT.txt"
filePath_P_OUT:	.asciiz	"correttezzaPendenzaOUT.txt"
filePath_D_OUT:	.asciiz	"correttezzaDistanzaOUT.txt"
#file sui quali vengono stampati i valori delle politiche di correttezza
filePathP1:	.asciiz	"correttezzaP1.txt"
filePathP2:	.asciiz	"correttezzaP2.txt"
filePathP3:	.asciiz	"correttezzaP3.txt"
.align 2
#buffer che contiene i valori convertiti da ASCII a numeri
valuesS:	.space 512
valuesP:	.space 512
valuesD:	.space 512
#buffer che sul quale vengono salvati i valori di correttezza dei sensori
risS:		.space 200
risP:		.space 200
risD:		.space 200
#buffer per salvare il contenuto dei file
B_sterzo:	.space 512
B_pendenza:	.space 512
B_distanza:	.space 512
#buffer che sul quale vengono salvati i valori di correttezza del sistema
risP1:	.space	200
risP2:	.space	200
risP3:	.space	200
.align 2
JAT:	.space	16 	#jump address table da 4 posti

.text
.globl main
main:	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
#***************apertura, lettura e conversione dei file	
	la $a0,filePath_S_IN	#file da aprire
	jal openFile		
	move $a0,$v0		#salvo il descrittore
	la $a1,B_sterzo		#passo come parametro il buffer dove salvare i valori letti
	jal readFile
	move $t0,$v0		#salvo il numero di caratteri letti
	li $v0,16		#chiudo il file
	syscall
	move $a1,$t0		
	la $a0,B_sterzo		#buffer da convertire
	la $a2,valuesS		#buffer dove scrivere i numeri
	jal conversionePS

	la $a0,filePath_P_IN
	jal openFile
	move $a0,$v0
	la $a1,B_pendenza
	jal readFile
	move $t0,$v0		#salvo il numero di caratteri letti
	li $v0,16		#chiudo il file
	syscall
	move $a1,$t0		#e lo passo come parametro
	la $a0,B_pendenza	#buffer da convertire
	la $a2,valuesP
	jal conversionePS
	
	la $a0,filePath_D_IN
	jal openFile
	move $a0,$v0
	la $a1,B_distanza
	jal readFile
	move $t0,$v0
	li $v0,16		#chiudo il file
	syscall
	move $a1,$t0		#e lo passo come parametro
	la $a0,B_distanza	#buffer da convertire
	la $a2,valuesD
	jal conversioneD		
#****************************************				
	jal checkToBuffer	#procedura che analizza i valori per determinarne la correttezza
	jal sensorWrite		#procedura per scrivere su file i valori di correttezza in precedenza determinati
#***************apertura file per correttezza sistema		
	la $a0,filePathP1
	jal openFileW		#procedura per aprire file in modalita scrittura
	move $s0,$v0
		
	la $a0,filePathP2
	jal openFileW
	move $s1,$v0
	
	la $a0,filePathP3
	jal openFileW
	move $s2,$v0
#****************************************
#***************analisi della correttezza del sistema e scrittura su file dei valori
	move $a0,$s0
	move $a1,$s1
	move $a2,$s2
	jal initPol
#****************************************
	j exit		#fine del main, esco dal programma	


#vvvvvvvvvvvvvv PROCEDURA CONVERSIONE FILE (sterzo e pendenza)
#parametri:	$a0--> indirizzo del buffer da dove leggere i caratteri
#		$a1-->numero di caratteri letti, per condizione d'uscita
#		$a2-->indirizzo del buffer dove scrivere i valori convertiti
#valore di ritorno:	void
conversionePS:
	addi $sp, $sp, -4
	sw $ra, 0($sp)			# Preservo il registro ra (return address)
	la $t1, 0($a2)			#puntatore indirizzo di scrittura
	li $t2, 0
# Inizio ciclo di conversione
convertiNumero:
	li $t4, 0			#inizializzo il numero convertito
	li $t5, 0			#inizializzo il flag del segno
	beq $t2, $a1, fineValPS		#verifico condizione di uscita (contatore < a1)
	
nextVal:
	lb $t3, 0($a0)			#carico un carattere
	beq $t2, $a1, controlNeg	# controllo se is l'ultimo carattere
	addi $a0, $a0, 1
	addi $t2, $t2, 1

	beq $t3, 32, controlNeg		#se e' uno spazio ho letto il numero, dunque controllo se e' negativo
	beq $t3, 45, isNeg		#se leggo un "-" asserisco il flag del segno
	addi $t3, $t3, -48		#conversione da ASCII a decimale del singolo carattere
	mul $t4, $t4, 10		
	add $t4, $t4, $t3
	j nextVal
	
isNeg:	li $t5, 1			#asseriso il flag
	j nextVal
	
controlNeg:
	beq $t5, $zero, isPos		#se il flag e' 0 il numero e' positivo e quindi salto il cambio di segno
	sub $t4, $zero, $t4		#cambio di segno per numeri negativi
	
isPos:	sw $t4, 0($t1)			#carica numero convertito sul buffer
	addi $t1, $t1, 4
	j convertiNumero	

fineValPS:
	lw $ra, 0($sp)			#ripristino ra
	addi $sp, $sp, 4
	
	jr $ra
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^	

#vvvvvvvvvvvvvv PROCEDURA CONVERSIONE FILE (distanza)
#
#parametri:	$a0--> indirizzo del buffer da dove leggere i caratteri
#		$a1-->numero di caratteri letti, per condizione d'uscita
#		$a2-->indirizzo del buffer dove scrivere i valori convertiti
#
#valore di ritorno:	void
conversioneD:
	addi $sp, $sp, -4
	sw $ra, 0($sp)			#preservo il registro ra
	la $t1, 0($a2)
	
	li $t2, 0			
	li $t6, 0			#inizializzo i due contatori
ciclo_numero:
	li $t4, 0			#inizializzo il registro che conterra' il numero convertito
	beq $t2, $a1, fineValD		#verifico se ho letto tutti i caratteri
nextValD:
	lb $t3, 0($a0)			#leggo un carattere dal buffer
	addi $a0, $a0, 1		#incremento puntatore buffer
	addi $t6, $t6, 1		#incremento contatore 1..4
	beq $t2, $a1, storeNum		#ripeto la condizione di uscita nel caso in cui sono arrivato al 100esimo numero
	addi $t2, $t2, 1		#incremento contatore carattere

	#con t6 determino quale carattere devo convertire
	beq $t6, 1, AorB		#conversione del tipo di ostacolo
	beq $t6, 2, MSD			#conversione cifra più significativa (Most Significant Digit)
	beq $t6, 3, LSD			#conversione cifra più significativa (Least Significant Digit)
	bge $t6, 4, storeNum		#se t6=4 significa che ho letto lo spazio e dunque carico il valore convertito
	addi $t6, $t6, 1	
		
AorB:	move $t5, $t3			#in t5 carico la codifica ASCII della lettera
	j nextValD
	
MSD:	bgt $t3, 57, isChar		#se il valore ASCII e' >57 significa che la cifra esadecimale e' una lettera
	addi $t3, $t3, -48		#altrimenti e' un numero, per cui faccio la conversione semplice ASCII -> decimale
	
numFinal:
	mul $t3, $t3, 16		# Il carattere e' la cifra piu' significativa per cui va moltiplicato per 16
	add $t4, $t4, $t3
	j nextValD
	
isChar:	addi $t3, $t3, -55		# Per la conversione da lettera esadecimale a numero basta sottrarre 55
	j numFinal
	
LSD:	bgt $t3, 57, conv_char_d	# Se il valore ASCII e' >57 significa che la cifra esadecimale e' una lettera
	addi $t3, $t3, -48		# Altrimenti e' un numero, per cui faccio la conversione da ASCII a decimale
	
endOfConversion:
	add $t4, $t4, $t3		# Il carattere e' la cifra meno significativa per cui va solo sommato
	j nextValD
	
conv_char_d:
	addi $t3, $t3, -55		# Per la conversione da lettera esadecimale a numero basta sottrarre 55
	j endOfConversion
	
storeNum:
	sb $t5, 0($t1)			#carico la lettera nel buffer
	sb $t4, 1($t1)			#carico la cifra sul buffer nella posizione successiva a quella della lettera
	addi $t1, $t1, 4		#incremento il contatore per scrittura
	
	li $t4, 0
	li $t6, 0			# Resetto i registri necessari
	j ciclo_numero

fineValD: 
	lw $ra, 0($sp)			# Ripristino il registro s0
	addi $sp, $sp, 4
	
	jr $ra	
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

#vvvvvvvvvvvvvv PROCEDURA CONTROLLO CORRETTEZZA SENSORI
checkToBuffer:	
	addi $sp, $sp, -16
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	li $s0,0
	li $t5,0
#vvvvvvvSTERZOvvvvvvv
SgetVal:beq $s0,400,pendenza	#se s0= 400(numero di valori *4) allora li ho letti tutti e smetto
	lw $s2,valuesS($s0)	#in s2 metto il valore all'istante t(attuale)
	beqz $s0,stVal		#controllo se il primo valore
	li $t4,32		#siccome non e' il primo stampa uno spazio...
	sb $t4,risS($t5)
	addi $t5,$t5,1		#... e aumento il contatore
#*******if((val-preVal>10)||(val-preVal<-10))
	sub $t1,$s2,$s1		#esegue la sottrazione tra il valore attuale e quello all'istante precedente
	sgt $t2,$t1,10		#t2=1 se val-preVal>10
	slti $t3,$t1,-10	#t3=1 se val-preVal<-10
	or $t1,$t3,$t2		#t1 contiene il risultato del confronto
#***********************
	beqz $t1,Scorr1
	j Scorr0
		
stVal:	move $s1,$s2		#sposto il valore corrente in s1 che conterr il valore all'istante t-1
	j Scorr1		#non stampo nulla perch non lo posso confrontare

Scorr0:	#mette a 0
	li $t4,48		#48(base 10) "0" in ASCII
	sb $t4,risS($t5)	#carica "0"
	addi $t5,$t5,1
	addi $s0,$s0,4		#incrementa l'istante
	move $s1,$s2		#mette il valore attuale in s1 che contiene il "valore precedente"
	j SgetVal		
Scorr1:	#mette a 1 
	li $t4, 49		#49(base 10) "1" in ASCII
	sb $t4,risS($t5)	#carica "1"
	addi $t5,$t5,1
	addi $s0,$s0,4		#incrementa l'istante
	move $s1,$s2		#mette il valore attuale in s1 che contiene il "valore precedente"
	j SgetVal
	
#^^^^^^^^^FINE STERZO^^^^^^^^^

#vvvvvvvvvPENDENZAvvvvvvvvvvv
pendenza:	
	li $s0,0        	#inizializzazione offset (istante t)
	li $t5,0
PgetVal:beq $s0,400,distanza	#se s0= 400(numero di valori *4) allora li ho letti tutti e smetto
	lw $s2,valuesP($s0)	#in s2 metto il valore all'istante t(attuale)
#*******if((val>-60)&&(val<60))
	sgt $t1,$s2,-60		#t1=1 se val>-60
	slti $t2,$s2,60		#t2=1 se val<60
	and $t3,$t1,$t2		#t3 contiene il risultato del confronto
#*********************
	beq $s0, 0, verifyP
	li $t4,32		#siccome non e' il primo stampa uno spazio...
	sb $t4,risP($t5)
	addi $t5,$t5,1		#... e aumento il contatore
verifyP:beqz $t3,Pcorr0
	j Pcorr1	

Pcorr0:	#mette a 0
	li $t4,48		#48(base 10) "0" in ASCII
	sb $t4,risP($t5)	#carica "0" 
	addi $t5,$t5,1		#offset carattere per la stampa
	addi $s0,$s0,4		#incrementa l'istante
	j PgetVal		
Pcorr1:	#mette a 1 
	li $t4,49		#49(base 10) "1" in ASCII
	sb $t4,risP($t5)	#carica "1"
	addi $t5,$t5,1 		#offset carattere per la stampa
	addi $s0,$s0,4		#incrementa l'istante
	j PgetVal
#^^^^^^^FINE PENDENZA^^^^^^^^^

#vvvvvvDISTANZAvvvvvvvvvvv
distanza:
	li $s0,0        	#inizializzazione offset (istante t)
	li $t5,0
DgetVal:la $t0,valuesD($s0)
	lb $s1,1($t0)		#metto in s1 la cifra
	lb $s2,0($t0)		#metto in s2 la lettera
	#t0 non mi serve più, quindi lo posso riutilizzare
	beq $s0,400,goback	#se s0= 400(numero di valori *4) allora li ho letti tutti e smetto
	beq $s0, 0, verifyD
	li $t4,32		#siccome non e' il primo stampa uno spazio...
	sb $t4,risD($t5)
	addi $t5,$t5,1		#... e aumento il contatore
verifyD:sgt $t0,$s1,0		#controllo se la cifra <= 0
	beqz $t0,Dcorr0		#se la distanza zero, corr=0
	sgt $t1,$s1,0x32	#t1 a 1 se la distanza maggiore i 50			
	beq $t1,1,Dcorr0	#salta se la distanza >50
	beq $s2,0xa,Dcorr1	#se un ostacolo fisso allora corretto

obstB:	beq $s3,$s1,inCont	#se i valori sono uguali...
	move $s3,$s1		#in s3 c' il valore all'istante precedente
	li $t3,1		#inizializzo il contatore (t3)
	j Dcorr1		#torno da dove sono venuta
inCont:	addi $t3,$t3,1		#incremento il contatore
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
	
goback:	#dealloco lo stack
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	addi $sp, $sp, 16
		
	jr $ra
#vvvvvvvvvv PROCEDURA SCRITTURA VALORI DI CORRETTEZZA vvvvvvvvvv	
sensorWrite:   #ho letto tutti i valore e posso scrivere il risultato

	# apri file
	li $v0,13		# chiamata di systema per aprire
      	la $a0,filePath_D_OUT  	# carica il percorso di scrittura
      	li $a1,1            	# flag di scrittura
      	syscall
      	move $t0,$v0        	# salvo il percorso 
    	#scrivo nel file la stringa
    	li $v0, 15            	# chiamata di sistema
    	move $a0, $t0         	# pass il percorso dove scrivere
    	la $a1, risD      	# passa inidirizzo di inizio della stringa
    	li $a2, 200            	# size del buffer (n valori * 2)
    	syscall
    
	li $v0, 16		# Close File Syscall
	move $a0, $t0
	syscall
	
	# apri file
	li $v0,13          	# chiamata di systema per aprire
      	la $a0,filePath_S_OUT   # carica il percorso di scrittura
      	li $a1,1            	# flag di scrittura
      	syscall
      	move $t0,$v0        	# salvo il percorso 
    	#scrivo nel file la stringa
	li $v0, 15            	# chiamata di sistema
    	move $a0, $t0         	# passa il percorso dove scrivere
    	la $a1, risS      	# passa inidirizzo di inizio della stringa
    	li $a2, 200            	# size del buffer (n valori * 2)
    	syscall
    
	li $v0, 16		# Close File Syscall
	move $a0, $t0
	syscall
	
	# apri file
	li $v0,13          	# chiamata di systema per aprire
      	la $a0,filePath_P_OUT   # carica il percorso di scrittura
      	li $a1,1            	# flag di scrittura
      	syscall
      	move $t0,$v0        	# salvo il percorso 

    	#scrivo nel file la stringa
    	li $v0, 15            	# chiamata di sistema
    	move $a0, $t0         	# pass il percorso dove scrivere
    	la $a1, risP      	# passa inidirizzo di inizio della stringa
    	li $a2, 200          	# size del buffer (n valori * 2)
    	syscall
    
	li $v0, 16		# Close File Syscall
	move $a0, $t0
	syscall
	jr $ra

# PROCEDURA PER APRIRE I FILE IN MODALITA SCRITTURA
openFileW:
	li $v0,13
	li $a1,1
	li $a2,0
	syscall
	jr $ra
	
# PROCEDURA PER APRIRE I FILE PER LA SOLA LETTURA							
openFile:
	li $v0,13
	li $a1,0
	li $a2,0
	syscall
	jr $ra	
	
# PROCEDURA PER LEGGERE I FILE
readFile:
	li $v0,14
	li $a2,512
	syscall
	jr $ra

#vvvvvvvvvvvvvv PROCEDURA CORRETTEZZA SISTEMA
#
#parametri:	$a0,1,2--> descrittore file correttezza P1,P2,P3	
#valore di ritorno:	void
#
initPol:		
	addi $sp,$sp,-24
	sw $ra,0($sp)
	sw $s0,4($sp)
	sw $s1,8($sp)
	sw $s2,12($sp)
	sw $s3,16($sp)
	sw $s4,20($sp)
		
	li $t6,0		#contatore per scrivere
	li $s0,0        	#inizializzazione offset (istante t)
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
	
getVal:	la $t0,JAT
	beq $s0,200,write	#se s0= (numero di valori)*2 allora li ho letti tutti e smetto
	beq $s0,0,verifyPol
	li $t5,32		#stampo lo spazio
	sb $t5,risP1($t6)
	sb $t5,risP2($t6)
	sb $t5,risP3($t6)
	addi $t6,$t6,1
verifyPol:	
	lb $t1,risS($s0)	#leggo i valori all'istante s0
	lb $t2,risP($s0)
	lb $t3,risD($s0)
	add $t4,$t1,$t2		#sommo i tre valori letti
	add $s1,$t4,$t3		#il risultato della somma in s1
	li $t7,144		#siccome ho sommato la codifica in decimale dei caratteri ASCII "0" o "1"
	sub $s1,$s1,$t7		#sottraggo 144=(48*3) per riportare il valore a 0 o 1 in decimale
	
#calcolo l'indirizzo
	add $t1, $s1, $s1
	add $t1, $t1, $t1	#s1*4 is l'offset
	add $t1, $t1, $t0	#sommo l'offset alla base della jat
	lw $t0, 0($t1)
	jr $t0
	
#casi
P0:	#tutti i valori letti sono 0
	li $t5,48		#48(base 10) is "0" in ASCII
	sb $t5,risP1($t6)
	li $t5,48		
	sb $t5,risP2($t6)
	li $t5,48		
	sb $t5,risP3($t6)
	addi $t6,$t6,1	
	addi $s0,$s0,2		#incremento contatore da trasformare in 8 visto che ci sara' un carattere spazio nel mezzo
	j getVal
	
P1:	#un valore e' 1 e gli alri 0
	li $t5,48		
	sb $t5,risP1($t6)
	li $t5,48		
	sb $t5,risP2($t6)
	li $t5,49		
	sb $t5,risP3($t6)
	addi $t6,$t6,1
	addi $s0,$s0,2		#incremento contatore
	j getVal
	
P2: 	#due valori sono 1 e l'altro 0
	li $t5,48		
	sb $t5,risP1($t6)
	li $t5,49		
	sb $t5,risP2($t6)
	li $t5,49		
	sb $t5,risP3($t6)
	addi $t6,$t6,1
	addi $s0,$s0,2		#incremento contatore
	j getVal
	
P3: 	#tutti e tre i valori sono 1
	li $t5,49		
	sb $t5,risP1($t6)
	li $t5,49		
	sb $t5,risP2($t6)
	li $t5,49		
	sb $t5,risP3($t6)
	addi $t6,$t6,1
	addi $s0,$s0,2		#incremento contatore
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

	j exitPol
writeClose:
	li $v0,15	# chiamata di sistema
	li $a2,200      # size del buffer (n valori * 2)
	syscall
	li $v0, 16	# Close File Syscall
	syscall
	jr $ra
	
exitPol:lw $ra,0($sp)
	lw $s0,4($sp)
	lw $s1,8($sp)
	lw $s2,12($sp)
	lw $s3,16($sp)
	lw $s4,20($sp)
	addi $sp,$sp,24
	jr $ra

#***********************************************
# Fine del programma
exit:	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	addi $sp, $sp, 16
	
	li $v0,10
	syscall
	
	#jr $ra
