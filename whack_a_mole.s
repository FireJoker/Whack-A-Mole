; GPIO Test program - Dave Duguid, 2011
; Modified Trevor Douglas 2014

;;; Directives
		PRESERVE8
		THUMB       

;;; Equates

INITIAL_MSP	EQU		0x20001000	; Initial Main Stack Pointer Value

;PORT A GPIO - Base Addr: 0x40010800
GPIOA_CRL	EQU		0x40010800	; (0x00) Port Configuration Register for Px7 -> Px0
GPIOA_CRH	EQU		0x40010804	; (0x04) Port Configuration Register for Px15 -> Px8
GPIOA_IDR	EQU		0x40010808	; (0x08) Port Input Data Register
GPIOA_ODR	EQU		0x4001080C	; (0x0C) Port Output Data Register
GPIOA_BSRR	EQU		0x40010810	; (0x10) Port Bit Set/Reset Register
GPIOA_BRR	EQU		0x40010814	; (0x14) Port Bit Reset Register
GPIOA_LCKR	EQU		0x40010818	; (0x18) Port Configuration Lock Register

;PORT B GPIO - Base Addr: 0x40010C00
GPIOB_CRL	EQU		0x40010C00	; (0x00) Port Configuration Register for Px7 -> Px0
GPIOB_CRH	EQU		0x40010C04	; (0x04) Port Configuration Register for Px15 -> Px8
GPIOB_IDR	EQU		0x40010C08	; (0x08) Port Input Data Register
GPIOB_ODR	EQU		0x40010C0C	; (0x0C) Port Output Data Register
GPIOB_BSRR	EQU		0x40010C10	; (0x10) Port Bit Set/Reset Register
GPIOB_BRR	EQU		0x40010C14	; (0x14) Port Bit Reset Register
GPIOB_LCKR	EQU		0x40010C18	; (0x18) Port Configuration Lock Register

;The onboard LEDS are on port C bits 8 and 9
;PORT C GPIO - Base Addr: 0x40011000
GPIOC_CRL	EQU		0x40011000	; (0x00) Port Configuration Register for Px7 -> Px0
GPIOC_CRH	EQU		0x40011004	; (0x04) Port Configuration Register for Px15 -> Px8
GPIOC_IDR	EQU		0x40011008	; (0x08) Port Input Data Register
GPIOC_ODR	EQU		0x4001100C	; (0x0C) Port Output Data Register
GPIOC_BSRR	EQU		0x40011010	; (0x10) Port Bit Set/Reset Register
GPIOC_BRR	EQU		0x40011014	; (0x14) Port Bit Reset Register
GPIOC_LCKR	EQU		0x40011018	; (0x18) Port Configuration Lock Register

;Registers for configuring and enabling the clocks
;RCC Registers - Base Addr: 0x40021000
RCC_CR		EQU		0x40021000	; Clock Control Register
RCC_CFGR	EQU		0x40021004	; Clock Configuration Register
RCC_CIR		EQU		0x40021008	; Clock Interrupt Register
RCC_APB2RSTR	EQU	0x4002100C	; APB2 Peripheral Reset Register
RCC_APB1RSTR	EQU	0x40021010	; APB1 Peripheral Reset Register
RCC_AHBENR	EQU		0x40021014	; AHB Peripheral Clock Enable Register

RCC_APB2ENR	EQU		0x40021018	; APB2 Peripheral Clock Enable Register  -- Used

RCC_APB1ENR	EQU		0x4002101C	; APB1 Peripheral Clock Enable Register
RCC_BDCR	EQU		0x40021020	; Backup Domain Control Register
RCC_CSR		EQU		0x40021024	; Control/Status Register
RCC_CFGR2	EQU		0x4002102C	; Clock Configuration Register 2

; Times for delay routines
DT_PRE_GAME EQU 	30000		; Delaytime for PRE_GAME_DELAY
DT_END_GAME EQU 	300000		; Delaytime for END_GAME_DELAY
DT_RESTART	EQU		500000		; Delaytime betweening RESTART and PRE_GAME
DT_1_MIN	EQU		600			; Delaytime for GAME_SUCCESS; About 1 min
DT_10_SEC	EQU		100			; Delaytime for GAME_FAIL; About 30 sec

PrelimWait	EQU 	500000		; Delaytime for play game loop
ReactTime	EQU		450000		; Delaytime for allowed user to press; About 3 sec
WinningSignalTime	EQU	40000	; Delaytime for flashing winning signal
LosingSignalTime 	EQU	100000	; Delaytime for flashing losing signal

LevelUp		EQU		15000		; The number of reduce for each cycle
NumCycles	EQU 	15			; The number of cycles in a game
; Constant number for RNG
ALPHA	EQU		1664525
BETA 	EQU		1013904223

; Vector Table Mapped to Address 0 at Reset
            AREA    RESET, Data, READONLY
            EXPORT  __Vectors

__Vectors	DCD		INITIAL_MSP	; stack pointer value when stack is empty
        	DCD		SET_GAME	; reset vector
			
            AREA    MYCODE, CODE, READONLY
			EXPORT	SET_GAME
			ENTRY

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Project: Lab Final Project - Game: Whack A Mole 
;;; File: whack_a_mole.s
;;; Class: ENSE352
;;; Date: December, 6th, 2018
;;; Programmer: Changyao Li
;;; Description:
;;;		Write a Whack-a-mole game in assembly language.
;;;
	ALIGN
SET_GAME	PROC
	BL GPIO_ClockInit; Enable ports
	BL GPIO_init; Enable LEDs
	BL PRE_GAME; Wait for player
	
	ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Project:
;;; 	This routine will enable the clock for the Port A-C; RCC_APB2ENR
;;;	Requried:
;;;		R0: Temp address, overwrite
;;; 	R1: Temp data, overwrite
;;;		R2: Temp HEX number, overwrite
;;;
	ALIGN
GPIO_ClockInit PROC
	LDR R0, =RCC_APB2ENR
	LDR R1, [R0]					
	LDR R2, =0x1C; for active port a,b,c: 0001 1100
	ORR R1, R1, R2
	STR R1, [R0]
	
	BX LR
	ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Project: 
;;;		This routine enables the GPIO for the LEDs; GPIOA_CRH
;;;		Port A pins 9-12; The reset value: 0x4444 4444 
;;;	Requried:
;;;		R0: Temp address, overwrite
;;; 	R1: Temp data, overwrite
;;;	Nores:
;;;   CNF:General purpose 00  MODE:ourput 50MHz 11
;;;
	ALIGN
GPIO_init  PROC
	LDR R0, =GPIOA_CRH
	LDR R1, =0x44433334
	STR R1, [R0]

	BX LR
	ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;; END SET_GAME ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
		
		
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; This is an LED pattern, and wait for player to start
;;;	Requried:
;;;		R0: Temp address, overwrite
;;; 	R1: Temp data, overwrite
;;;		R2: Temp HEX number, overwrite
;;;   	R3: Delay time, overwrite
;;;		R4: Count number compare with delay time, overwrite
;;;		R5: Store 4 inputs
;;; Notes:
;;;		123432 123432 
;;;
	ALIGN		
PRE_GAME PROC
	BL TURN_OFF_ALL					; Turn OFF all LEDs before the game begins
	LDR R3, =DT_PRE_GAME			; 30000
	LDR R4, =0x0
	BL PRE_GAME_DELAY				; Have time to react
	
FLASH_LED
	BL RED_ON						; Red LED ON
	LDR R4, =0x0	
	BL PRE_GAME_DELAY				; Wait half second
	BL RED_OFF						; Red LED OFF
;	
	BL BLACK_ON						; Black LED ON
	LDR R4, =0x0	
	BL PRE_GAME_DELAY	
	BL BLACK_OFF					; Black LED OFF
;	
	BL BLUE_ON						; Blue LED ON
	LDR R4, =0x0	
	BL PRE_GAME_DELAY
	BL BLUE_OFF						; Blue LED OFF
;	
	BL GREEN_ON						; Green LED ON
	LDR R4, =0x0	
	BL PRE_GAME_DELAY
	BL GREEN_OFF					; Green LED OFF
;	
	BL BLUE_ON						; Blue LED ON
	LDR R4, =0x0	
	BL PRE_GAME_DELAY	
	BL BLUE_OFF						; Blue LED OFF
;	
	BL BLACK_ON						; Black LED ON
	LDR R4, =0x0	
	BL PRE_GAME_DELAY
	BL BLACK_OFF					; Black LED OFF
;
	B FLASH_LED
	ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Delay loop, wait half second
;;;	Requried:
;;;		R0: Temp address, overwrite
;;; 	R1: Temp data, overwrite
;;;		R2: Temp HEX number, overwrite
;;;   	R3: Delay time, overwrite
;;;		R4: Count number compare with delay time, overwrite
;;;		R5: Store 4 inputs
;;;	Promise:	
;;;		Any of the four buttons been pressed will start the game
;;; Notes:
;;;  	Need to reset R4 before enter this loop
;;;
	ALIGN
PRE_GAME_DELAY PROC	
	PUSH {LR}						; Need to branch back
	BL CHK_INPUT					; Return a number in R5
	POP {LR}
	CMP R5, #0xF
	BNE PLAY_GAME
	
	ADD R4, R4, #0x1
	CMP R3, R4
	BGT PRE_GAME_DELAY
	BX LR							; Return back to FLASH_LED
	ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END PRE_GAME ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; LED will ON when press PB, then just one will ON
;;;	Requried:
;;;		R0: Temp address, overwrite
;;; 	R1: Temp data, overwrite
;;;		R2: Temp HEX number, overwrite by ALPHA, BETA
;;;   	R3: Delay time, overwrite
;;;		R4: Count number compare with delay time
;;;		R5: Store 4 inputs
;;; 	R6: X; Store R5 as first x
;;; 	R7: Random number in two bits
;;; 	R8: LEVEL; Defult 1 -> 15 max
;;;		R9: Delay time for ReactTime
;;;
	ALIGN		
PLAY_GAME PROC
	LDR R8, =0x1					; Level number, defult 1
	LDR R9, =ReactTime				; 450000
	MOV R6, R5						; Seed_number -> PB pressed
	BL RNG
	
	ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Random number generate, wait around half second before LED on
;;;	Requried:
;;; 	R2: ALPHA -> 1664525
;;; 	R2: BETA -> 1013904223
;;;		R3: Delay time, PrelimWait -> 500000
;;;		R4: Count number compare with delay time
;;; 	R6: X; Store R5 as first x
;;; 	R7: Random number in two bits
;;;	Promise:
;;;		After get the random number, branch to one of the four cases
;;; Notes:
;;;		The idea of Random Number Generation is from Karim Naqvi
;;;
	ALIGN
RNG PROC
	LDR R4, =0
	LDR R3, =PrelimWait				; 500000
	BL TURN_OFF_ALL					; Turn off all the LEDs before next step
	
WAIT_LED_ON	
	LDR R2, =ALPHA					; 1664525
	MUL R6, R6, R2					
	LDR R2, =BETA					; 1013904223
	ADD R6, R6, R2
	ADD R4, R4, #1
	CMP R3, R4
	BNE WAIT_LED_ON					; Looping with random number
									; Let player wait before LED on
	LSR R7, R6, #30	
	CMP R7, #0						; CASE_RED
	BEQ CASE_RED
	CMP R7, #1						; CASE_BLACK
	BEQ CASE_BLACK
	CMP R7, #2						; CASE_BLUE
	BEQ CASE_BLUE
	CMP R7, #3						; CASE_GREEN
	BEQ CASE_GREEN					; Can change the order of different cases

	ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Four different cases, have four different loops
;;;	Requried:
;;;		R4: Count number compare with delay time
;;;		R5: Store 4 inputs
;;;		R9: Delay time for ReactTime
;;;	Promise:
;;;		Right input -> LEVEL_UP
;;;		Wrong input or out of time -> GAME_FAIL	
;;;	
	ALIGN
CASE_RED PROC
	BL RED_ON						; Turn on RED LED
	LDR R4, =0x0
RED_DELAY
	ADD R4, R4, #1
	CMP R9, R4						; Times up -> fail
	BEQ GAME_FAIL
	
	BL CHK_INPUT
	CMP R5, #0xF					; No input -> loop; 1111
	BEQ RED_DELAY
	CMP R5, #0x7					; Right input -> next lv; 0111
	BEQ LEVEL_UP
	BL GAME_FAIL					; Wrong input -> fail; 1XXX
	ENDP
	
	ALIGN
CASE_BLACK PROC
	BL BLACK_ON						; Turn on BLACK LED
	LDR R4, =0x0
BLACK_DELAY
	ADD R4, R4, #1
	CMP R9, R4						; Times up -> fail
	BEQ GAME_FAIL	

	BL CHK_INPUT
	CMP R5, #0xF					; No input -> loop; 1111
	BEQ BLACK_DELAY
	CMP R5, #0xB					; Right input -> next lv; 1011
	BEQ LEVEL_UP
	BL GAME_FAIL					; Wrong input -> fail; X1XX
	ENDP
	
	ALIGN
CASE_BLUE PROC
	BL BLUE_ON						; Turn on BLACK LED
	LDR R4, =0x0
BLUE_DELAY
	ADD R4, R4, #1
	CMP R9, R4						; Times up -> fail
	BEQ GAME_FAIL

	BL CHK_INPUT
	CMP R5, #0xF					; No input -> loop; 1111
	BEQ BLUE_DELAY
	CMP R5, #0xD					; Right input -> next lv; 1101
	BEQ LEVEL_UP
	BL GAME_FAIL					; Wrong input -> fail; XX1X
	ENDP

	ALIGN	
CASE_GREEN PROC
	BL GREEN_ON						; Turn on GREEN LED
	LDR R4, =0x0
GREEN_DELAY
	ADD R4, R4, #1
	CMP R9, R4						; Times up -> fail
	BEQ GAME_FAIL

	BL CHK_INPUT
	CMP R5, #0xF					; No input -> loop; 1111
	BEQ GREEN_DELAY
	CMP R5, #0xE					; Right input -> next lv; 1110
	BEQ LEVEL_UP
	BL GAME_FAIL					; Wrong input -> fail; XXX1
	ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
		
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Level up and reduce recation time
;;;	Requried:
;;;		R2: Temp HEX number; Rewrite by NumCycles and #120000
;;; 	R8: LEVEL, compare with NumCycles
;;;		R9: Delay time for ReactTime -> 450000
;;; Promise:
;;; 	If right input, level up and wait time reduced
;;;	Notes:
;;;		15lv max according to NumCycles
;;;
	ALIGN	
LEVEL_UP PROC
	BL TURN_OFF_ALL
	LDR R2, =NumCycles				; 15
	ADD R8, R8, #1
	CMP R8, R2
	BGT GAME_SUCCESS				; If max level -> win
	LDR R2, =LevelUp				; 15000 * 15 = 225000
	SUB R9, R9, R2					; Reduce wait time
	
	BL RNG
	ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END PLAY_GAME ;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Game successed
;;;	Requried:
;;;   	R3: Delay time, Rewrite by DT_END_GAME -> 300000
;;;		R4: Count number compare with delay time
;;;		R5: Store 4 inputs
;;;		R6: Store R5 as first x -> Rewrite by WinningSignalTime
;;;		R7: Random number in two bits -> Rewrite by Count number
;;; Promise:
;;; 	Game ends; Success!!! Flash LED until any input
;;; 	Otherwise LED will flashing about 1 min
;;;		Then program go to RESTART
;;;
	ALIGN
GAME_SUCCESS PROC	
	BL TURN_OFF_ALL					; Turn OFF all LEDs before WinningSignal
	LDR R3, =DT_END_GAME			; 300000
	LDR R4, =0x0	
	
;Delay time before WinningSignal
SUCCESS_DELAY
	ADD R4, R4, #1
	CMP R3, R4
	BNE SUCCESS_DELAY	
	
	;Set delay time and counter for winning signal
	LDR R3, =WinningSignalTime
	LDR R4, =0x0
	LDR R6, =DT_1_MIN				; 600
	LDR R7, =0x0
	
; Flashing winning signal about 1 min
WAIT_RESTART_W
	BL RED_ON						; Red LED ON
	LDR R4, =0x0	
	BL END_GAME_DELAY
	BL RED_OFF						; Red LED OFF
;	
	BL BLACK_ON						; Black LED ON
	LDR R4, =0x0	
	BL END_GAME_DELAY
	BL BLACK_OFF					; Black LED OFF
;	
	BL BLUE_ON						; Blue LED ON
	LDR R4, =0x0	
	BL END_GAME_DELAY
	BL BLUE_OFF						; Blue LED OFF
;	
	BL GREEN_ON						; Green LED ON
	LDR R4, =0x0	
	BL END_GAME_DELAY
	BL GREEN_OFF					; Green LED OFF	
	
	;PB pressed -> restart
	BL CHK_INPUT
	CMP R5, #0xF
	BNE RESTART
	
	; Over 1 min -> resert
	ADD R7, R7, #1
	CMP R6, R7
	BNE WAIT_RESTART_W
	BEQ RESTART
	
	ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;	Game failed
;;;	Requried:
;;;		R2: Temp HEX number -> last bit of level (R8)
;;;   	R3: Delay time, DT_END_GAME -> 300000
;;;		R4: Count number compare with delay time
;;;		R5: Store 4 inputs
;;;		R6: Store R5 as first x -> Rewrite by WinningSignalTime
;;;		R7: Random number in two bits -> Rewrite by Count number
;;; 	R8: LEVEL; Defult 1	
;;; Promise:
;;; 	Game ends; Fail!!! Flash LED until any input
;;; 	Otherwise LED will flashing about 10 sec
;;;		Then program go to RESTART
;;;
	ALIGN
GAME_FAIL PROC
	BL TURN_OFF_ALL					; Turn OFF all LEDs before LosingSignal
	LDR R3, =DT_END_GAME			; 300000
	LDR R4, =0x0	

; Delay time before LosingSignal
FAIL_DELAY
	ADD R4, R4, #1
	CMP R3, R4
	BNE FAIL_DELAY	
	
	;Set delay time and counter for losing signal
	LDR R3, =LosingSignalTime
	LDR R4, =0x0
	LDR R6, =DT_10_SEC				; 100
	LDR R7, =0x0
	
WAIT_RESTART_F						; Flashing losing signal 10 sec
	; Show different level, base on each bit
	PUSH {R8}
	MOV R2, #0x0
	AND R2, R8, #1					; XXXX
	CMP R2, #1						; Check bit0
	BNE CHK_1BIT
	BL GREEN_ON						; If '1', turn on green LED
CHK_1BIT
	LSR R8, R8, #1					; 0XXX
	AND R2, R8, #1
	CMP R2, #1						; Check bit1
	BNE CHK_2BIT	
	BL BLUE_ON						; If '1', turn on blue LED
CHK_2BIT
	LSR R8, R8, #1					; 00XX
	AND R2, R8, #1
	CMP R2, #1						; Check bit2
	BNE CHK_3BIT	
	BL BLACK_ON						; If '1', turn on black LED
CHK_3BIT	
	LSR R8, R8, #1					; 000X
	AND R2, R8, #1
	CMP R2, #1						; Check bit3
	BNE CHK_0BIT
	BL RED_ON						; If '1', turn on red LED
CHK_0BIT
	LDR R4, =0x0	
	BL END_GAME_DELAY

	POP {R8}
	BL TURN_OFF_ALL					; Turn OFF all LEDs before show level
									; Make the level flashing
	LDR R4, =0x0	
	BL END_GAME_DELAY
	
	;PB pressed -> restart
	BL CHK_INPUT
	CMP R5, #0xF
	BNE RESTART
	
	; Over 10 sec -> resert
	ADD R7, R7, #1
	CMP R6, R7
	BNE WAIT_RESTART_F
	BEQ RESTART
	
	ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Restart the game
;;;	Requried:
;;;   	R3: Delay time, DT_RESTART -> 500000
;;;		R4: Count number compare with delay time
;;; Project:
;;; 	Wait for restart, back to PRE_GAME
;;;	
	ALIGN
RESTART PROC
	LDR R3, =DT_RESTART				; 500000
	LDR R4, =0x0
RESTART_DELAY
	ADD R4, R4, #1
	CMP R3, R4
	BNE RESTART_DELAY
	BL PRE_GAME						; After delay time, back to PRE_GAME
	ENDP
		
	ALIGN
GAME_OVER PROC		
END_GAME_DELAY
	ADD R4, R4, #1
	CMP R3, R4
	BNE END_GAME_DELAY
	BX LR
	ENDP
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END PLAY_GAME ;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Turn ON or OFF LEDs
;;;	Requried:
;;;		R0: Temp address, overwrite
;;; 	R1: Temp data, overwrite
;;;		R2: Temp HEX number, overwrite
;;; Notes:
;;; 	PA9 (RED), PA10 (BLACK), PA11 (BLUE), PA12 (GREEN)
;;;		Active LOW
;;;
	ALIGN
LED_CONTROL PROC
RED_ON; Turn on red LED
	LDR R0, =GPIOA_ODR
	LDR R1, [R0]
	LDR R2, =0xFFFFFDFF
	AND R1, R1, R2; 1101 1111 1111
	STR R1, [R0]
	BX LR

RED_OFF; Turn off red LED
	LDR R0, =GPIOA_ODR
	LDR R1, [R0]
	LDR R2, =0x200
	ORR R1, R1, R2; 0010 0000 0000
	STR R1, [R0]
	BX LR

BLACK_ON; Turn on black LED
	LDR R0, =GPIOA_ODR
	LDR R1, [R0]
	LDR R2, =0xFFFFFBFF
	AND R1, R1, R2; 1011 1111 1111
	STR R1, [R0]
	BX LR

BLACK_OFF; Turn off black LED
	LDR R0, =GPIOA_ODR
	LDR R1, [R0]
	LDR R2, =0x400
	ORR R1, R1, R2; 0100 0000 0000
	STR R1, [R0]
	BX LR

BLUE_ON; Turn on blue LED
	LDR R0, =GPIOA_ODR
	LDR R1, [R0]
	LDR R2, =0xFFFFF7FF
	AND R1, R1, R2; 0111 1111 1111
	STR R1, [R0]
	BX LR

BLUE_OFF; Turn off blue LED
	LDR R0, =GPIOA_ODR
	LDR R1, [R0]
	LDR R2, =0x800
	ORR R1, R1, R2; 1000 0000 0000
	STR R1, [R0]
	BX LR

GREEN_ON; Turn on green LED
	LDR R0, =GPIOA_ODR
	LDR R1, [R0]
	LDR R2, =0xFFFFEFFF
	AND R1, R1, R2; 1110 1111 1111 1111
	STR R1, [R0]
	BX LR

GREEN_OFF; Turn off green LED
	LDR R0, =GPIOA_ODR
	LDR R1, [R0]
	LDR R2, =0x1000
	ORR R1, R1, R2; 0001 0000 0000 0000
	STR R1, [R0]
	BX LR

TURN_ON_ALL; Turn on all the LEDs
	LDR R0, =GPIOA_ODR
	LDR R1, [R0]
	LDR R2, =0xFFFFE1FF
	AND R1, R1, R2; 1110 0001 1111 1111
	STR R1, [R0]
	BX LR
	
TURN_OFF_ALL; Turn off all the LEDs
	LDR R0, =GPIOA_ODR
	LDR R1, [R0]
	LDR R2, =0x00001E00
	ORR R1, R1, R2; 0001 1110 0000 0000
	STR R1, [R0]
	BX LR
	
SWITCH_ALL; Switch all the LEDs; on <-> off
	LDR R0, =GPIOA_ODR
	LDR R1, [R0]
	LDR R2, =0x00001E00
	EOR R1, R1, R2; 0001 1110 0000 0000
	STR R1, [R0]
	BX LR
	
	ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Check pushbutton inputs
;;;	Requried:
;;;		R0: Temp address, overwrite
;;; 	R1: Temp data, overwrite
;;;		R5: Store 4 inputs, reset the number everytime
;;; Promise:
;;;		Return a value in R5 (0xF -> no input)
;;; Notes:
;;;		The idea of Check All Inputs is from Trevor Douglas
;;; 	SW2 on PB8  -> R5 bit 3 -> 0111 (7)
;;;		SW3 on PB9  -> R5 bit 2 -> 1011 (B)
;;; 	SW4 on PC12 -> R5 bit 1 -> 1101 (D)
;;;		SW5 on PA5  -> R5 bit 0 -> 1110 (E)
;;;		All active LOW
;;;
	ALIGN
CHK_INPUT PROC
	LDR R5, =0x0; Reset R5
	;RED PB -> bit3
	LDR R0, =GPIOB_IDR
	LDR R1, [R0]
	LSR R1, R1, #8
	AND R1, R1, #1
	ORR R5, R5, R1; 000X
	LSL R5, R5, #1; 00X0
	;BLACK PB -> bit2
	LDR R0, =GPIOB_IDR
	LDR R1, [R0]
	LSR R1, R1, #9
	AND R1, R1, #1
	ORR R5, R5, R1; 00XX
	LSL R5, R5, #1; 0XX0
	;BLUE PB -> bit1
	LDR R0, =GPIOC_IDR
	LDR R1, [R0]
	LSR R1, R1, #12
	AND R1, R1, #1
	ORR R5, R5, R1; 0XXX
	LSL R5, R5, #1; XXX0
	;GREEN PB -> bit0
	LDR R0, =GPIOA_IDR
	LDR R1, [R0]
	LSR R1, R1, #5
	AND R1, R1, #1
	ORR R5, R5, R1; XXXX

	BX LR
	ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
	ALIGN		
	END