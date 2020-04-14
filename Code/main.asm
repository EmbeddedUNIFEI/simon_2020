	include <p16f887.inc>
	list p=16f887
	__config _CONFIG1, 0x2FF4
	__config _CONFIG2, 0x3FFF
	
	cblock 0x20
		led_cnt
		aux
	endc


	org 0x00		;vetor de reset
	goto Setup

	org 0x04		;vetor de interrupção
	retfie

Setup:
	bsf STATUS, RP0 ; bank1
	movlw b'11110000'
	movwf TRISA 	; ra0-ra3 como saida 
	bsf STATUS, RP1 ; bank3
	clrf ANSEL		; AN0-AN7 como IO digital
	bcf STATUS, RP1
	bcf STATUS, RP0 ; bank0 

Loop:
	;call RotinaInicializacao

	;Delay 1cy
	nop
	;Delay 2cy
	goto $+1
	
	;Delay 4cy
	call Delay4cy
	
	;Delay 8cy
	call Delay8cy

	;Loop de delay
	movlw .0
	movwf aux
	decfsz aux, F
	goto $-1
	
	;1+1+(1+2)*(x-1) + 2
	;3*(x-1) + 4
	;3*x + 1

Delay4cy
	return

Delay8cy
	call Delay4cy
	return


	goto Loop


RotinaInicializacao:
	movlw b'00001111'	; mascara or
	iorwf PORTA, F		; aplica mascara
	call Delay_1s
	clrf led_cnt		;limpa registrador
LedLoop:	
	movlw .0
	subwf led_cnt, W    ;compara led_cnt com 0
	btfsc STATUS, Z
	goto Led_0
	
	movlw .1
	subwf led_cnt, W    ;compara led_cnt com 1
	btfsc STATUS, Z
	goto Led_1

	movlw .2
	subwf led_cnt, W    ;compara led_cnt com 2
	btfsc STATUS, Z
	goto Led_2

	movlw .3
	subwf led_cnt, W    ;compara led_cnt com 3
	btfsc STATUS, Z
	goto Led_3

	movlw .4
	subwf led_cnt, W    ;compara led_cnt com 4
	btfss STATUS, Z
	goto LedLoop
	clrf PORTA
	return

Led_0:
	movlw 0x01
	movwf PORTA
	call Delay_200ms
	incf led_cnt, F
	goto LedLoop

Led_1:
	movlw 0x02
	movwf PORTA
	call Delay_200ms
	incf led_cnt, F
	goto LedLoop

Led_2:
	movlw 0x04
	movwf PORTA
	call Delay_200ms
	incf led_cnt, F
	goto LedLoop

Led_3:
	movlw 0x08
	movwf PORTA
	call Delay_200ms
	incf led_cnt, F
	goto LedLoop
	
	

	
	

Delay_1s
	nop
	return

Delay_200ms
	nop
	return
	
	end