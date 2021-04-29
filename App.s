			AREA	AsmTemplate, CODE, READONLY
			IMPORT	main

			EXPORT	start
start

IO1DIR		EQU	0xE0028018
IO1SET		EQU	0xE0028014
IO1CLR		EQU	0xE002801C

			LDR	r1, =IO1DIR
			LDR	r2, =0x000f0000		; Select P1.19--P1.16
			str	r2, [r1]			; Make them outputs
			ldr	r1, =IO1SET
			str	r2, [r1]			; Set them to turn the LEDs off
			ldr	r2, =IO1CLR
		
			; r1 points to the SET register
			; r2 points to the CLEAR register
	
loop		ldr	r3, =0			; Initial number
			ldr	r4, =nums			; Magnitudes of 10
	
			ldr	r5, =0x80000000		; Checks the MSB of r5
			AND	r5, r5, r3;			; 
			CMP	r5, #0x0			; if (r5 == 0) 			//If positive
			BNE	else1				; {
			ldr	r5, =0xA			; 		r5 = "+"
			str	r5, [sp, #4]!		; 		Memory.word[sp] = r5; address = address + 4;
			B	endif1				; }
else1								; else { 			//If negative
			ldr	r5, =0xB			; 		r5 = "-"
			str	r5, [sp, #4]!		; 		Memory.word[sp] = r5; address = address + 4;
			MVN	r3, r3				; 		2's Compliment of
			ADD	r3, r3, #0x1		;			   r3
endif1								; }
	
	
	
dowh1		ldr	r5, [r4], #4		; do{		r5 = Memory.word 
			ldr	r6, =0x0			; 		r6 = 0
dowh2		sub	r3, r3, r5			; 		do{ 	r3 = r3 - r5
			add	r6, r6, #1			;				r6 = r6 + 1
			cmp	r3, #0				; 		} while (r3 > 0)
			bge	dowh2				; 
			add	r3, r3, r5			; 		r3 = r3 + r5
			sub	r6, r6, #1			; 		r6 = r6 - 1
			cmp	r6, #0x0			; 		if (r6 != 0) {
			bne	endif2				; 				r6 = "1111" 
			ldr	r6, =0xF			;		}
endif2		str	r6, [sp, #4]!		;		Memory.word[sp] = r6; address = address + 4;
			
			cmp	r5, #0x1			; } while (r5 != 1)
			bne	dowh1				;
			ldr	r6, =0x0			; r6 = 0
			str	r6, [sp, #4]!		; Memory.word[sp] = r6; address = address + 4; // Termination Condition
			sub	sp, sp, #0x2C		; address = address - 40
	
	
	
			ldr	r5, =0x0		; flag
dowh3		ldr	r3, [sp], #4	;
			cmp	r3, #0xF		; if(x == 0)
			bne	else3			;
			cmp	r5, #0x1		; if(flag)
			bne	endif6			; {
			BL	sub1			; printf(0)
endif6		B	endif3			; }
	
else3		cmp	r3, #0xA		; else if(x == +)
			bne	else4			; {
			BL	sub1			; printf(+)
			B	endif4			;}
	
else4		cmp	r3, #0xB		; else if(x == -)
			bne	else5			; {
			BL sub1				; prinf(-)
			B endif5			; }
	
else5		ldr	r5, =0x1		; else{ flag = true;
			BL	sub1			; print(num) }
endif5
endif4	
endif3
			cmp	r6, #0x0		; End of Sequence
			bne	dowh3
			b	loop			; Loop Indefinitely 
stop		B	stop



sub1	
			ldr r6, =0x00000000
			ldr	r7, =0x00100000			; Start with P1.19
			ldr	r8, =0x00010000			; End with P1.16
		
dowh5		mov	r7, r7, LSR #1
			ldr	r4, =0x0				; do{		R4 = 0
			movs r3, r3, LSR #1			; 		R3 = R3/2
			adc r4, r4, #0				; 		R4 = R4 + Carry
			cmp	r4, #0x1				; 		if (r4 == 1){
			bne	endif7					; 			r6 = r6 + mask
			add r6, r6, r7				; 			Shift down to the next bit. P1.19 -> P1.18 etc
endif7									; 		}
			cmp r7, r8					; } while (P1.19 -> P1.18 -> ... P1.16)
			bne dowh5					; 
		
			str	r6, [r2]				; Clear the bit -> turn on the LED

			ldr	r4, =16000000		
dowh6		subs r4, r4, #1				; Delay for about a second
			bne	dowh6

			str	r6, [r1]				; Set the bit -> turn off the LED
		
			ldr	r4, =16000000		
dowh7		subs r4, r4, #1				; Delay for about a second
			bne	dowh7
			BX	lr
			
		

			AREA	mydata, DATA, READWRITE
		
nums		DCD	0x3B9ACA00, 0x05F5E100, 0x00989680, 0x000F4240
			DCD	0x000186A0, 0x00002710, 0x000003E8, 0x00000064
			DCD	0x0000000A, 0x00000001
			END