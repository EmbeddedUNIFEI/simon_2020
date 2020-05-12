	include <p16f887.inc>
	list p=16f887
	__config _CONFIG1, 0x2FF4
	__config _CONFIG2, 0x3FFF
	
	#define LED_RED B'00000001'; bit 0
	#define LED_YELLOW 0X02; bit 1
	#define LED_GREEN 0x04 ; bit2
	#define LED_BLUE 0x08; bit3
	#define MOVE_VETOR_SIZE .32

	cblock 0x20
		led_cnt
		aux
		level ;level = 0(facil), 1(dificil)
		valor_sorteado
	endc

	cblock 0x40
		move_vetor: MOVE_VETOR_SIZE
		move_index
		move
		exibe_index
	endc

	org 0x00		;vetor de reset
	goto Setup

	org 0x04		;vetor de interrupção
	retfie

Setup:
	bsf STATUS, RP0 ; bank1
	movlw b'11110000'
	movwf TRISA 	; ra0-ra3 como saida 
	bsf   TRISB, TRISB4 ; botão de start (entrada)
	bsf   TRISB, TRISB5 ; seleção de nível (entrda)
	bsf STATUS, RP1 ; bank3
	clrf ANSEL		; AN0-AN7 como IO digital
	clrf ANSELH		; AN8-AN13 como IO digital
	bcf STATUS, RP1
	bcf STATUS, RP0 ; bank0 
	clrf move_index
Loop:
	;call RotinaInicializacao

	call SorteiaMovimento
	movwf move
	call ArmazenaMovimento
	
	call ExibeSequencia
	goto Loop

;	btfss PORTB, RB4 ;testa botão start
	;goto Loop

	btfss PORTB, RB5 ; testa seleção de dificuldade
	goto SetLevelEasy
	bsf level, 0 	; level = 1 (dificil)
	goto ExitTestLevel
SetLevelEasy
	bcf level, 0  ; level = 0 (facil)

ExitTestLevel

	;SorteioMovimento
	;ArmezenaMovimento
	;ExibeMovimento
	;ExibeSequencia	

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


;----Função SorteiaMovimento---------
SorteiaMovimento:
	addlw .8
	movwf valor_sorteado
	movlw B'00000011' ;mascara
	andwf valor_sorteado, F ;filtro
	
TesteValor0
	movlw .0
	subwf valor_sorteado, W
	btfss STATUS, Z
	goto TesteValor1
	retlw LED_RED

TesteValor1
	movlw .1
	subwf valor_sorteado, W
	btfss STATUS, Z
	goto TesteValor2
	retlw LED_YELLOW

TesteValor2
	movlw .2
	subwf valor_sorteado, W
	btfss STATUS, Z
	goto TesteValor3
	retlw LED_GREEN

TesteValor3
	retlw LED_BLUE

;---------------------------------

;-----Funçao ArmazenaMovimento----
;Argumentos: move
ArmazenaMovimento:
	bcf STATUS, IRP ;banco 0 ou 1
	movlw move_vetor
	movwf FSR
	movf move_index, W
	addwf FSR, F
	movf move, W
	movwf INDF
	incf move_index, F
	return
;---------------------------------


;---Função ExibeMovimento---------
;Argumento: move
ExibeMovimento:
	movf move, W
	movwf PORTA
	;emite som (depois)
	call Delay_500ms ;fake
	clrf PORTA
	return
;---------------------------------

;------Delay 500ms ---------------
;Temporaria
Delay_500ms:
	return

;---------------------------------	
	
;------Função ExibeSequencia------
ExibeSequencia:
	movlw move_vetor
	movwf FSR
	bcf STATUS, IRP
	clrf exibe_index
LoopExibe:
	movf INDF, W
	movwf move
	call ExibeMovimento
	incf FSR, F
	incf exibe_index, F
	movf move_index, W
	subwf exibe_index, W
	btfss STATUS, Z
	goto LoopExibe
	return

;---------------------------------

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