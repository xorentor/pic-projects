     list p=16f877                 
     #include <p16f877.inc>        

 __CONFIG _CP_OFF & _WDT_OFF & _BODEN_ON & _PWRTE_ON & _HS_OSC & _WRT_ENABLE_ON & _LVP_ON & _DEBUG_OFF & _CPD_OFF 


offset    EQU       0x20
temp      EQU       0x21
          ORG       0x0000

; init
init      bsf       STATUS,RP0     
          clrf      TRISD
          movlw     0x40           ; baud rate 9600
          movwf     SPBRG
          clrf      TXSTA           
          bcf       STATUS,RP0     ; bank 0

          bsf       RCSTA,SPEN     ; async enable
          bsf       RCSTA,CREN     ; continuous receive

          bsf       STATUS,RP0     ; bank 1
          bsf       TXSTA,TXEN     ; Transmit enable
	  bsf       TXSTA,BRGH     ; hi speed
          bcf       STATUS,RP0     ; bank 0

; send 
          clrf      offset        
start     movf      offset,w       
          call      TAB
          addlw     0              
          btfsc     STATUS,Z       
          goto      wait2          
          movwf     TXREG           
wait1     movlw     TXSTA           
          movwf     FSR           
          btfss     INDF,1         
          goto      wait1          
          incf      offset,f       
          goto      start          ; again

; receive         
wait2     btfss     PIR1,RCIF      
          goto      wait2          
          movf      RCREG,w        
          movwf     TXREG

          goto      wait2

TAB       addwf     PCL,F             
          
	  DT        0X0C,"PROGRAM TEST RS232 PORT ON CPU PIC16F877 RUN FREQ 10MHz",0X0A,0X0D,0X0



          END
