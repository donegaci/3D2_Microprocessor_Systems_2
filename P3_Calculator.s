	AREA	AsmTemplate, CODE, READONLY
	IMPORT	main
	EXPORT	start

; ASSINGMENT DESCRIPTION
; The task is to write a program that implements a calculator using the four 
; LEDs on the ARM Board and the four push-buttons below them. 
; The LEDs are connected to P1.16 to P1.19 and the buttons are connected to P1.20 to P1.23.
; Briefly, the idea is that you can enter 4-bit binary numbers using the leftmost two buttons,
; and you can specify the operations to be performed (Add, Subtract, Clear, Clear All) 
; using the rightmost two buttons.

start
IO1PIN  EQU 0xE0028010
IO1SET	EQU 0xE0028014
IO1DIR	EQU 0xE0028018
IO1CLR	EQU 0xE002801C


	LDR r0, =0 ;n
	LDR r4, =0x00F00000 ;Button position
	LDR r7, =0

	LDR r1, =IO1DIR
	LDR r9, =IO1PIN
	STR r4, [r9]
	LDR r2, =0x000F0000 ;select P1.19 -> P1.16 LEDs
	STR r2, [r1]	;make them outputs
	LDR r1, =IO1SET
	STR r2, [r1]	;set them to turn the LEDS off
	LDR r2, =IO1CLR
	LDR r4, =0 ;Operator code
	
restart
	BL button_read
	
;==========================================================
	;Button comparison
	;Incrementer
	CMP r4, #0x00E00000 ; Check for n++
	BNE next1
	ADD r0, #1 ; increment the operand
	BL switcher
	BL displayNumber
	BL stopper
	B	done
	
	;Decrementer
next1	
	CMP	r4, #0x00D00000 ; Check for n--
	BNE	next2
	SUB r0, #1 ; decrement the operand
	BL switcher
	BL displayNumber
	BL stopper
	B	done
	
	;Adder
next2	
	CMP r4, #0x00B00000 ; Check for ADD
	BNE next3
	; Move operand 1 into operand 2
	ADD r7, r7, r0 ; operand 2 holds the sum
	MOV r0, r7
	BL switcher
	BL displayNumber
	BL stopper
	MOV r0, #0
	B done
	
	;Subtractor
next3
	CMP r4, #0x00700000; Check for SUB
	BNE next4
	CMP r7, #0
	BEQ first_sub
	SUB r7, r7, r0 ; operand 2 holds the sum
continue	
	MOV r0, r7
	BL switcher
	BL displayNumber
	BL stopper
	MOV r0, #0 
	B done
first_sub
	MOV r7, r0 ; This occurs when doing (0 - x)
	B continue
	
	;Clear last Operand
next4
	CMP r4, #0x00400000
	BNE next5
	MOV r0, r7 ;Restore value
	MOV r7, #0
	BL switcher
	BL displayNumber
	BL stopper
	BL poll
	B done
	
	;Clear all Operand
next5
	CMP r4, #0x00800000
	BNE done
	MOV r7, #0
	MOV r0, #0
	BL switcher
	BL displayNumber
	BL stopper
	B done

done
	B restart
	
stop	B	stop

;==========================================================
button_read
	STMFD sp!, {r5-r8, r10-r12} ; save registers
poll
	LDR r4, [r9] ; Read the GPIO pin register
	AND r4, r4, #0x00F00000 ; Mask the P1.20 - P1.23 buttons
	CMP r4, #0x00F00000
	BEQ poll
	
	;Button has been pressed
	;Determining duration of button pressed
	LDR r10, =4000000 ;roughly 2 seconds
	
	;;Button 1.22 duration detector
	CMP r4, #0x00B00000
	BNE skip1
timer1
	LDR r4, [r9] ; Read the GPIO pin register
	AND r4, r4, #0x00F00000 ; Mask the P1.20 - P1.23 buttons
	CMP r4, #0x00F00000 ;Has button been let go
	BEQ plus
	SUBS r10, r10, #1
	BNE timer1
	EOR r4, r4, #0x00F00000 ;Geting the negative of the index
	B skip
	
	;Button 1.23 duration detector
skip1
	CMP r4, #0x00700000
	BNE skip
timer2
	LDR r4, [r9] ; Read the GPIO pin register
	AND r4, r4, #0x00F00000 ; Mask the P1.20 - P1.23 buttons
	CMP r4, #0x00F00000 ;Has button been let go
	BEQ minus
	SUBS r10, r10, #1
	BNE timer2
	EOR r4, r4, #0x00F00000
	B skip

minus
	LDR r4, =0x00700000
	B skip

plus
	LDR r4, =0x00B00000
	B skip

skip
	LDMFD sp!, {r5-r8, r10-r12} ; restore registers
	BX lr ; return to caller

	; END of subroutine

;==========================================================
	;Extra functions

displayNumber
	MOV r3, r0, LSL #16 ;r3 is now what r0 is but in the LED positions
	STR r3, [r2] ;Turn on the LEDs
	BX LR

switcher
	;Used to turn off all LEDs
	LDR r3, =0x000F0000
	STR r3, [r1]
	BX LR

	;Used to gate button speed
stopper
	STMFD sp!, {LR}
sigh
	LDR r4, [r9] ; Read the GPIO pin register
	AND r4, r4, #0x00F00000 ; Mask the P1.20 - P1.23 buttons
	CMP r4, #0x00F00000 ;Has button been let go
	BNE sigh
	LDR r3, =4000000
counter
	SUBS r3, r3, #1
	BNE counter
	LDMFD sp!, {PC}
	BX LR
	
	
	END