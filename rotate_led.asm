;    File Version: 1                                                         *
;    This code lights up an LED bar wired to the PIC 18F4685.                *
;    The lit LED rotates left and right	                                     * 
;******************************************************************************
;                                                                            *
;    Files required: P18F4685.INC                                            *
;                                                                            *
;******************************************************************************

    LIST P=18F4685, F=INHX32    ;directive to define processor
    #include <P18F4685.INC> ;processor specific variable definitions

;******************************************************************************
; Configuration bits
; Microchip has changed the format for defining the configuration bits, please 
; see the .inc file for futher details on notation.  Below are a few examples.



;   Oscillator Selection:
    CONFIG  OSC = HS              ; HS for 20 MHz
    CONFIG  WDT = OFF             ; Watchdog Timer Enable bit (WDT disabled)
    CONFIG  BOREN = OFF           ; Brown-out Reset Enable bits (Brown-out Reset disabled in hardware and software)
;*******************************************************************************
    
; Variable definitions
; These variables are only needed if low priority interrupts are used. 
; More variables may be needed to store other special function registers used
; in the interrupt routines.

        UDATA

WREG_TEMP   RES 1   ;variable in RAM for context saving 
STATUS_TEMP RES 1   ;variable in RAM for context saving
BSR_TEMP    RES 1   ;variable in RAM for context saving

        UDATA_ACS

DCounter1   RES 1   ; DCounter1 variable
DCounter2   RES 1   ; DCounter2 variable
DCounter3  RES 1    ; DCounter3 variable

;******************************************************************************
; EEPROM data
; Data to be programmed into the Data EEPROM is defined here


DATA_EEPROM CODE    0xf00000

        DE  "Test Data",0,1,2,3,4,5

;******************************************************************************
; Reset vector
; This code will start executing when a reset occurs.

RESET_VECTOR    CODE    0x0000

        goto    Main        ;go to start of main code

;******************************************************************************
; High priority interrupt vector
; This code will start executing when a high priority interrupt occurs or
; when any interrupt occurs if interrupt priorities are not enabled.

HI_INT_VECTOR   CODE    0x0008

        bra HighInt     ;go to high priority interrupt routine

;******************************************************************************
; Low priority interrupt vector and routine
; This code will start executing when a low priority interrupt occurs.
; This code can be removed if low priority interrupts are not used.

LOW_INT_VECTOR  CODE    0x0018

        bra LowInt      ;go to low priority interrupt routine

;******************************************************************************
; High priority interrupt routine
; The high priority interrupt code is placed here to avoid conflicting with
; the low priority interrupt vector.


        CODE

HighInt:

;   *** high priority interrupt code goes here ***


        retfie  FAST

;******************************************************************************
; Low priority interrupt routine
; The low priority interrupt code is placed here.
; This code can be removed if low priority interrupts are not used.

LowInt:
        movff   STATUS,STATUS_TEMP  ;save STATUS register
        movff   WREG,WREG_TEMP      ;save working register
        movff   BSR,BSR_TEMP        ;save BSR register

;   *** low priority interrupt code goes here ***


        movff   BSR_TEMP,BSR        ;restore BSR register
        movff   WREG_TEMP,WREG      ;restore working register
        movff   STATUS_TEMP,STATUS  ;restore STATUS register
        retfie

;******************************************************************************
; Start of main program
; The main program code is placed here.

Main:

;   *** main code goes here ***
    
	CLRF	WREG	        ; clears the W register
	CLRF	TRISC	       
	CLRF	PORTC
	CLRF	LATC	        ; setting Lat C to an output 
	
DELAY			        ; reserving space for delay loop variables
	MOVLW 0Xac
	MOVWF DCounter1
	MOVLW 0X13
	MOVWF DCounter2
	MOVLW 0X06
	MOVWF DCounter3
    	
	MOVLW	B'00000001'     ; placing a mask in port C
	MOVWF	LATC	        ; mask is moved to Lat C
	
LOOPLEFT 
	CALL	DELAYLOOP       ; calling the delay so we can see an individual LED lit up
	RLNCF	LATC            ; rotate f left (no carry)
	BTFSS	PORTC, 7        ; testing to see if port C bit 7 is lit
	
	GOTO	LOOPLEFT        ; go to the top of the loop if not
	GOTO	LOOPRIGHT       ; go to the loop right loop if bit 7 is lit
	
LOOPRIGHT		    
	CALL	DELAYLOOP
	RRNCF	LATC	        ; rotate f right (no carry)
	BTFSS	PORTC, 0        ; testing to see if port C bit 0 is lit
	
	GOTO	LOOPRIGHT       ; go to the top of the loop if not
	GOTO	LOOPLEFT        ; go to the loop left loop if bit 0 is lit
	
DELAYLOOP		        ; delay loop of approximately 60 ms
			        ; delay loop assistance: http://www.onlinepiccompiler.com/delayGeneratorENG.php
	DECFSZ DCounter1, 1
	GOTO DELAYLOOP
	DECFSZ DCounter2, 1
	GOTO DELAYLOOP
	NOP
	NOP

	RETURN
	
	END
    
