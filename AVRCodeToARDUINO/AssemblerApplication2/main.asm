.include "m328pdef.inc"
.include "delay_Macro.inc"
.include "UART_Macros.inc"
.include "div_Macro.inc"
.dseg
.org SRAM_START
threshold:	.byte	1

.def A = r16
.def AH = r17
.cseg
.org 0x0000
Serial_begin
; I/O Pins Configuration
SBI DDRB,5 ; Set PB5 pin for Output to LED
CBI PORTB,5 ; LED OFF
; ADC Configuration
LDI A,0b11000111 ; [ADEN ADSC ADATE ADIF ADIE ADIE ADPS2 ADPS1 ADPS0]
STS ADCSRA,A
LDI A,0b01100000 ; [REFS1 REFS0 ADLAR – MUX3 MUX2 MUX1 MUX0]
STS ADMUX,A ; Select ADC0 (PC0) pin
SBI PORTC,PC0 ; Enable Pull-up Resistor
	LDI r18  ,200;

loop:
	 Serial_read
    CPI r16, 0       ; Check if data received
    BREQ skip_update ; If no data received, skip updating threshold
    Mov r18, r16 ; Store the value in register r16 at the address 0x20 in data space
	Mov r21 , r16
    skip_update:
	 LDI r18 , 200
	 mov r21 , r18 
LDS A,ADCSRA ; Start Analog to Digital Conversion
ORI A,(1<<ADSC)
STS ADCSRA,A
wait:
LDS A,ADCSRA ; wait for conversion to complete
sbrc A,ADSC
rjmp wait
LDS A,ADCL ; Must Read ADCL before ADCH
LDS AH,ADCH
delay 100 ; delay 100ms
Serial_writeReg AH
CP AH, r18; Compare AH (LDR value) with the threshold
    BRLO LED_OFF     ; Jump if AH < threshold

    ; LED ON condition
    SBI PORTB, 5    ; Set PB5 (LED) ON
    RJMP loop       ; Continue looping

LED_OFF:
    ; LED OFF condition
    CBI PORTB, 5    ; Set PB5 (LED) OFF
    RJMP loop       ; Continue looping