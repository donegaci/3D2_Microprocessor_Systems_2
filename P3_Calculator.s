	AREA	Demo, CODE, READONLY	IMPORT	main	EXPORT	start		startIO1PIN	EQU	0xE0028010IO1DIR	EQU	0xE0028018IO1SET	EQU	0xE0028014IO1CLR	EQU	0xE002801C	LDR		r0,=IO1DIR	LDR		r1,=0x000f0000	;select P1.19--P1.16	STR		r1,[r0]		;make them outputs	LDR		r0,=IO1SET ; r0 points to the SET register	STR		r1,[r0]		;set them to turn the LEDs off	LDR		r2,=IO1CLR ; r2 points to the CLEAR register	LDR		r3,=IO1PIN ; r3 points to the pin register; R4 has the index of button pressed (bit position); r5 is used to display value on LED's; R6 holds operand 1; R7 holds operand 2	MOV r6, #0 ; Initialise operand1 to zero	MOV r7, #0 ; Initialise operand2 to zero	restart	BL	button_read		CMP r4, #0x00E00000 ; Check for n++	BNE next1	ADD R6, #1 ; increment the operand	MOV r5, r6, LSL #16 ; shift the value into LED bit positions	BL	display	B	donenext1		CMP	r4, #0x00D00000 ; Check for n--	BNE	next2	SUB R6, #1 ; increment the operand	MOV r5, r6, LSL #16 ; shift the value into LED bit positions	BL	display	B	done	next2		CMP r4, #0x00B00000 ; Check for ADD	BNE next3	; Move operand 1 into operand 2	ADD r7, r7, r6 ; operand 2 holds the sum	MOV r5, r7, LSL #16 ; shift the value into LED bit positions	BL	display	MOV r6, #0 	B 	done	next3	CMP r4, #0x00700000; Check for SUB	BNE done ; change this later	CMP r7, #0	BEQ first_sub	SUB r7, r7, r6 ; operand 2 holds the sum	MOV r5, r7, LSL #16 ; shift the value into LED bit positions	BL	display	MOV r6, #0 	B donefirst_sub	MOV r7, r6 ; This occurs when doing (0 - x)	B 	done	;next4	;CMP r4, #0x10B00000 ; Check for Clear	;BNE next5	;; do stuff	;B done	;next5	;CMP r4, #0x10700000; Check for ClearAll	;BNE done	;; clear both operands	;MOV r6, #0	;MOV	r7, #0done	B 	restartstop B	stop;-------------------------------------------------------------------------------button_read	STMFD sp!, {r5-r12} ; save registerspoll	LDR r4, [r3] ; Read the GPIO pin register	AND r4, r4, #0x00F00000 ; Mask the P1.20 - P1.23 buttons	CMP r4, #0x00F00000	BEQ poll	LDMFD sp!, {r5-r12} ; restore registers	BX lr ; return to caller	;-------------------------------------------------------------------------------display	STMFD sp!, {r4-r12} ; save registers	STR	r1,[r0] ; turn the LEDs off	STR r5, [r2] ; display on LEDs	LDMFD sp!, {r4-r12} ; restore registers	BX lr ; return to caller;-------------------------------------------------------------------------------	END	