	AREA	Demo, CODE, READONLY
	IMPORT	main
	EXPORT	start

; The task is to write a program to convert a signed binary 32-bit integer 
; to its decimal form and to display it on the ARM Board.
; Use the four LEDs to display the least significant four bits of each decimal 
; digit's ASCII code, in turn, for a brief period -- about a second. 
; To denote a binary "1", turn the corresponding LED on. 
; To denote a binary "0", turn the corresponding LED of

start

IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C


	LDR		r5,=IO1DIR
	LDR		r7,=0x000f0000	;select P1.19--P1.16
	STR		r7,[r5]		;make them outputs
	LDR		r5,=IO1SET ; r5 points to the SET register
	STR		r7,[r5]		;set them to turn the LEDs off
	LDR		r6,=IO1CLR ; r6 points to the CLEAR register
	
	LDR 	r0, =value ; r0 points to memory location of value
	LDR 	r1, [r0] ; Load value into r1
	LDR		r2, =table ; point to memory location of table
	
loop	
	MOV		r4, #0 ; count
subtractloop 
	CMP		r1, #0
	BLT 	tooFar ; If number goes negative (less than 0)
	LDR		r3, [r2] ; Get power of 10 from table
	CMP		r3, #0 ; stopping condition
	BEQ 	restart
	SUBS	r1, r1, r3
	ADD		r4, #1; count ++
	B		subtractloop
tooFar
	ADD		r1, r3 ; went too far, add back number
	SUB		r4, #1 ; decrease count
	
	STR		r7,[r5]		; turn the LEDs off
	CMP		r4, #0
	BNE		continue
	LDR 	r4, =0x0000000f
continue
	MOV		r4, r4, LSL #16 ; Shift value to be displayed into correct bit position
	STR		r4, [r6] ; Load value into LED's, turn on LED's
	
	;delay for about a half second
	;LDR		r4,=1000000
;dloop
	;SUBS	r4,r4,#1
	;BNE		dloop

	ADD		r2, #4 ; get next power of 10
	B		loop  

restart
	LDR 	r1, [r0] ; Load value into r1
	LDR		r2, =table ; point to memory location of table
	B		loop ; this program will loop forever
		
stop B	stop

value	
	DCD 0x00000419
table	
	DCD 0x000003E8 ; 1000
	DCD 0x00000064 ; 100
	DCD 0x0000000A ; 10
	DCD 0x00000001 ; 1
	DCD 0x00000000 ; stopping condition

	END	