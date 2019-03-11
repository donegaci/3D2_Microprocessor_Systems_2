	AREA	Demo, CODE, READONLY
	IMPORT	main
	EXPORT	start
		

start

IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C


	LDR		r0,=IO1DIR
	LDR		r1,=0x000f0000	;select P1.19--P1.16
	STR		r1,[r0]		;make them outputs
	LDR		r0,=IO1SET ; r0 points to the SET register
	STR		r1,[r0]		;set them to turn the LEDs off
	LDR		r2,=IO1CLR ; r2 points to the CLEAR register

; R4 has the index of button pressed (bit position)
; R5 short=0, long=1
; R6 holds operand 1
; R7 holds operand 2
; r3 is used to display value on LED's
	

	
	MOV r6, #0 ; Initialise operand1 to zero
	MOV r7, #0 ; Initialise operand2 to zero

restart
	CMP r5, #0 ; short press
	BNE long_press
	
	CMP r4, #0x00100000 ; Check for n++
	BNE next1
	ADD R6, #1 ; increment the operand
	MOV r3, r6, LSL #16 ; shift the value into LED bit positions
	STR	r1,[r0] ; turn the LEDs off
	STR r3, [r2] ; display on LEDs
	B	done
next1	
	CMP	r4, #0x00200000 ; Check for n--
	BNE	next2
	SUB R6, #1 ; increment the operand
	MOV r3, r6, LSL #16 ; shift the value into LED bit positions
	STR	r1,[r0] ; turn the LEDs off
	STR r3, [r2] ; display on LEDs
	B	done
	
next2	
	CMP r4, #0x00400000 ; Check for ADD
	BNE next3
	; Move operand 1 into operand 2
	ADD r7, r7, r6 ; operand 2 holds the sum
	MOV r3, r7, LSL #16 ; shift the value into LED bit positions
	STR	r1,[r0] ; turn the LEDs off
	STR r3, [r2] ; display on LEDs
	MOV r6, #0 
	B 	done
	
next3
	CMP r4, #0x00800000; Check for SUB
	BNE done
	CMP r7, #0
	BEQ first_sub
	SUB r7, r7, r6 ; operand 2 holds the sum
	MOV r3, r7, LSL #16 ; shift the value into LED bit positions
	STR	r1,[r0] ; turn the LEDs off
	STR r3, [r2] ; display on LEDs
	MOV r6, #0 
	B done
first_sub
	MOV r7, r6 ; This occurs when doing (0 - x)
	B 	done
	
long_press
	CMP r4, #0x00400000 ; Check for Clear
	BNE next4
	; do stuff
	B done
	
next4
	CMP r4, #0x00800000; Check for ClearAll
	BNE done
	; clear both operands
	MOV r6, #0
	MOV	r7, #0

done
	B 	restart
	;Branch to poll()

stop B	stop


	END	