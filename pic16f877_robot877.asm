     list p=16f877                 
    __CONFIG _CP_OFF & _WDT_OFF & _BODEN_OFF & _PWRTE_ON & _HS_OSC & _WRT_ENABLE_ON & _LVP_ON & _DEBUG_OFF & _CPD_OFF
     

#DEFINE   MOTOR_L  PORTC,2
#DEFINE   MOTOR_R  PORTC,1
#DEFINE   SPK	   PORTD,1
#DEFINE   T_F      Flag,0      
#DEFINE   SW_FL    PORTA,4	
#DEFINE   SW_FR    PORTE,0	
#DEFINE   SW_BL    PORTE,1	
#DEFINE   SW_BR    PORTA,5	
#DEFINE   LFT      PORTB,0
#DEFINE   MID	   PORTB,1
#DEFINE   RGT      PORTB,2
#DEFINE   RS	   PORTD,3
#DEFINE   E	   PORTD,2
     
DT0       EQU       0X20	
DT1       EQU       0x21
DT2       EQU       0x22
DL_PWM    EQU	    0x23 
BUF	  EQU	    0x24
Flag      EQU       0x25
COMP_BUF  EQU       0x26 
COUNT     EQU       0x27
TRACK_BUF EQU       0x28
DAT	  EQU	    0x29
COM	  EQU	    0x30
SHT_DEL	  EQU	    0x31
SPK_COUNT EQU	    0x32
DY0	  EQU	    0x33
DY1	  EQU	    0x34
LAST_STATUS EQU	    0x35


	   ORG       0x0000

	   CLRF	     STATUS
           BSF       STATUS,RP0        
	   MOVLW     0x04	
	   MOVWF     ADCON1 
           MOVLW     0xFF
	   MOVWF     TRISA		; input
	   MOVWF     TRISB		; input
           CLRF      TRISC      	; output
           CLRF      TRISD		; output
	   MOVLW     0x07
	   MOVWF     TRISE

           BCF       STATUS,RP0         ; bank 0
	
	   BCF       PORTC,1		 
	   BCF	     PORTC,2

	   CALL	     BEEP		; beeping
	   CALL	     DELAY		; delay 
	   CALL	     BEEP		; beeping
	   CALL	     INIT_LCD		; initial value LCD
	   CALL	     DSP_LCD		; display massage to LCD
	   GOTO	     WAIT_ST		; wait until button pressed

; init lcd	   
INIT_LCD   CALL      DELAY
	   CALL	     DELAY	    
          
           MOVLW     B'00110011'     
           CALL      WR_INS
           MOVLW     B'00110010'
           CALL      WR_INS
           MOVLW     B'00101000'     
           CALL      WR_INS
           MOVLW     B'00001100'    
           CALL      WR_INS
           MOVLW     B'00000110'    
           CALL      WR_INS
           MOVLW     B'00000001'    
           CALL      WR_INS
	   RETURN

DSP_LCD	   CLRF	     COUNT	
DSP1	   MOVF	     COUNT,W		
	   CALL	     TAB1		
	   ADDLW     0x0		 
	   BTFSC     STATUS,Z		
	   GOTO	     DSP_L2		
	   CALL	     WR_DATA		
	   INCF	     COUNT,F		
	   GOTO	     DSP1		

DSP_L2     CLRF	     COUNT		
	   MOVLW     0xC0		
	   CALL      WR_INS		
DSP2	   MOVF	     COUNT,W		
	   CALL	     TAB2		
	   ADDLW     0x0		 
	   BTFSC     STATUS,Z		
	   RETURN			
	     
	   CALL	     WR_DATA		
	   INCF	     COUNT,F		
	   GOTO	     DSP2		

WR_INS    BCF       RS      	  
 	  BSF	    E		  
          MOVWF     COM       	  
          ANDLW     0xF0      	   
	  IORLW	    B'00000100'        
          MOVWF     PORTD     	  
          BCF       E          	   
          CALL      SHOT_DEL  	        
          BSF       E          	  
          SWAPF     COM,W
          ANDLW     0xF0      	  
	  IORLW	    B'00000100'	  
          MOVWF     PORTD     	  
          BCF       E            
          CALL      SHOT_DEL          
          BSF       E           
          CALL      SHOT_DEL	
          RETURN

WR_DATA   BSF       RS		  	
	  BSF	    E 	 	  	
          MOVWF     DAT		  	
          ANDLW     0xF0	  	         
	  IORLW	    B'00001100'	  	
          MOVWF     PORTD	  	
          BCF       E             	
          CALL      SHOT_DEL        	
          BSF       E             	
          SWAPF     DAT,W	  	
          ANDLW     0xF0	  	
	  IORLW	    B'00001100'	  	
          MOVWF     PORTD	  	
          BCF       E             	 
          CALL      SHOT_DEL        	
          BSF       E             	
	  CALL	    SHOT_DEL	  	
          RETURN

TAB1       addwf     PCL,F            
          
           DT    "  ET-ROBOT 877",0

TAB2	   addwf     PCL,F            
          
           DT    " (CPU PIC16F877)",0


; main    
WAIT_ST    BTFSC     PORTA,2		 
	   GOTO	     $-1
	   BTFSS     PORTA,2
	   GOTO	     $-1

MAIN       CALL	     TRACK		 
	   CALL	     SCAN_BUMP		
	   BTFSC     PORTA,2		 
	   GOTO	     MAIN		
	 
	   BTFSS     PORTA,2		
	   GOTO	     $-1
	   CALL	     BEEP	
	   GOTO	     WAIT_ST

SCAN_BUMP  BTFSS     SW_FL		
	   GOTO	     FL_BUMP		 
	   BTFSS     SW_FR
	   GOTO	     FR_BUMP		
	   BTFSS     SW_BL
	   GOTO	     BL_BUMP		
	   BTFSS     SW_BR
	   GOTO	     BR_BUMP		
	   RETURN

FL_BUMP	   CALL	     EVADE_L		
	   RETURN

FR_BUMP	   CALL	     EVADE_R		
	   RETURN
	   
BL_BUMP	   CALL	     FOR_W		
	   CALL	     TURN_R		
	   RETURN

BR_BUMP	   CALL	     FOR_W		
	   CALL	     TURN_L		
	   RETURN
 
; tracker sensor
TRACK      MOVLW  B'00000111'
	   MOVWF  COMP_BUF	
	   CALL   COMP			
	   BTFSS  Flag,0                
	   GOTO   NEXT			
	   MOVF	     COMP_BUF,W		
	   MOVWF     LAST_STATUS	
	   CALL   M_RIGHT		
	   RETURN

NEXT	   MOVLW  B'00000110'		
	   MOVWF  COMP_BUF		
	   CALL   COMP			
	   BTFSS  Flag,0			   
	   GOTO   NEXT0	   	   	
	   MOVF	     COMP_BUF,W		
	   MOVWF     LAST_STATUS	
	   CALL   NORMAL_R		
	   RETURN

NEXT0      MOVLW  B'00000011'		
	   MOVWF  COMP_BUF
	   CALL   COMP		
	   BTFSS  Flag,0			   
	   GOTO   NEXT1				
	   MOVF	     COMP_BUF,W	
	   MOVWF     LAST_STATUS	
	   CALL	  NORMAL_L	
	   RETURN 

NEXT1      MOVLW     B'00000001'
	   MOVWF     COMP_BUF		
	   CALL      COMP 		
 	   BTFSS     Flag,0			
	   GOTO      NEXT2		
	   MOVF	     COMP_BUF,W	
	   MOVWF     LAST_STATUS	
	   CALL      M_LEFT		
	   RETURN

NEXT2      MOVLW     B'00000100'		
	   MOVWF     COMP_BUF		
	   CALL      COMP 		
 	   BTFSS     Flag,0		
	   GOTO      NEXT3		
	   MOVF	     COMP_BUF,W	
	   MOVWF     LAST_STATUS	
	   CALL      M_RIGHT		
	   RETURN

NEXT3      MOVLW     B'00000010'		
	   MOVWF     COMP_BUF		
	   CALL      COMP 		
 	   BTFSS     Flag,0		
	   GOTO      NEXT4		
	   MOVF	     COMP_BUF,W		
	   MOVWF     LAST_STATUS	
	   CALL      FORWARD		
	   RETURN

NEXT4      CLRF      COMP_BUF		
	   CALL	     COMP		
	   BTFSS     Flag,0		
	   GOTO	     NEXT5		
	   BTFSC     LAST_STATUS,0	
	   GOTO	     LFT_ON	
	   BTFSS     LAST_STATUS,2	 
	   GOTO	     NEXT5		
    	   CALL	     NORMAL_R		
	   BTFSS     MID		
	   GOTO	     $-2		
	   GOTO	     NEXT5	   
 	  
LFT_ON	   CALL	     NORMAL_L		
	   BTFSS     MID		
	   GOTO	     $-2		
	  	   
NEXT5	   CALL      FORWARD		
	   RETURN
    	   
; cmp stuff
COMP	   MOVF      PORTB,W			
	   ANDLW     B'00000111'	; 3 bits LSB
           XORWF     COMP_BUF,W   	
	   BTFSC     STATUS,Z		; zero?
	   GOTO      EQUAL		
	   BCF	     Flag,0		
	   RETURN				

EQUAL      BSF       Flag,0
	   RETURN

; servo motors
FORWARD	   CALL   SER_L2ms		; pulse 2ms
	   CALL   SER_R1ms		; pulse 1ms
	   CALL   DEL_18ms		 
	   RETURN

FOR_W      MOVLW  .30			; loop 30
	   MOVWF  DL_PWM	  
FOR_W1	   CALL   SER_L2ms		
	   CALL   SER_R1ms		
	   CALL   DEL_18ms		
	   DECFSZ DL_PWM,F		
	   GOTO   FOR_W1		
	   RETURN

EVADE_L    CALL   BACK_W		
	   CALL   TURN_R		
	   GOTO   MAIN			

EVADE_R    CALL   BACK_W		
	   CALL   TURN_L		
	   GOTO   MAIN			

BACK_W     MOVLW  .40			
	   MOVWF  COUNT
BACK	   CALL   SER_L1ms		
	   CALL   SER_R2ms		
	   CALL   DEL_18ms		
	   CALL	  SCAN_BUMP		
	   DECFSZ COUNT,F
	   GOTO   BACK			
	   RETURN

TURN_L     MOVLW  .20		
	   MOVWF  DL_PWM
TURN_L1	   CALL   SER_L1ms		
	   CALL   SER_R1ms		
	   CALL   DEL_18ms		
	   DECFSZ DL_PWM,F
	   GOTO   TURN_L1		
	   RETURN

TURN_R     MOVLW  .20			
	   MOVWF  DL_PWM
TURN_R1	   CALL   SER_L2ms	
	   CALL   SER_R2ms	
	   CALL   DEL_18ms	
	   DECFSZ DL_PWM,F
	   GOTO   TURN_R1
	   RETURN
	   	    	       
M_LEFT     CALL   SER_L1ms	
	   CALL   SER_R1ms	
	   CALL   DEL_18ms
	   RETURN

M_RIGHT    CALL   SER_L2ms
	   CALL   SER_R2ms
	   CALL   DEL_18ms
	   RETURN

NORMAL_L   BCF	  MOTOR_L	
	   CALL   SER_R1ms
	   CALL   DEL_18ms
	   RETURN

NORMAL_R   BCF	  MOTOR_R
	   CALL   SER_L2ms
	   CALL   DEL_18ms
	   RETURN

SER_L1ms   BSF	  MOTOR_L
	   CALL   DEL_1ms
	   BCF	  MOTOR_L
	   RETURN

SER_L2ms   BSF	  MOTOR_L
	   CALL   DEL_2ms
	   BCF	  MOTOR_L
	   RETURN

SER_R1ms   BSF	  MOTOR_R
	   CALL   DEL_1ms
	   BCF	  MOTOR_R
	   RETURN

SER_R2ms   BSF	  MOTOR_R
	   CALL   DEL_2ms
	   BCF	  MOTOR_R
	   RETURN

; speaker beep
BEEP	   CLRF      SPK_COUNT		
BEE_P	   BSF       SPK		
	   CALL	     SHOT_DEL		
	   BCF	     SPK		
	   CALL	     SHOT_DEL	       	
	   DECFSZ    SPK_COUNT,F	 
	   GOTO      BEE_P		
	   RETURN   

; delay pwm 1ms
DEL_1ms    MOVLW     .4
	   MOVWF     DT0
DEL0	   MOVLW     .207
	   MOVWF     DT1
DEL1       DECFSZ    DT1,F
           GOTO      DEL1
           DECFSZ    DT0,F
           GOTO      DEL0
	   RETURN 

; delay pwm 2ms
DEL_2ms    MOVLW     .8
	   MOVWF     DT0
DELY0	   MOVLW     .207
	   MOVWF     DT1
DELY1      DECFSZ    DT1,F
           GOTO      DELY1
           DECFSZ    DT0,F
           GOTO      DELY0
	   RETURN 

; delay - 18ms

DEL_18ms   MOVLW     .72
	   MOVWF     DT1	
DL1        MOVLW     .207
	   MOVWF     DT2
DL2        DECFSZ    DT2,F
           GOTO      DL2
           DECFSZ    DT1,F
           GOTO      DL1
	   RETURN

; delay
DELAY      CLRF      DY0	
DLY1       CLRF      DY1
           DECFSZ    DY1,F
           GOTO      $-1
           DECFSZ    DY0,F
           GOTO      DLY1
	   RETURN

SHOT_DEL   CLRF      SHT_DEL		 
	   DECFSZ    SHT_DEL,F
	   GOTO	     $-1
	   RETURN


	 END    
