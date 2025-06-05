.text
    b program           ; endereço 0 (reset vector)
    b isr   ; endereço 2 (interrupt vector)

isr_addr:
    .word isr

program:
	ldr		sp, addr_stack_top
	b 		main_init
addr_stack_top:
	.word 	stack_top

;======== Constantes ========
	.equ	INPORT_ADDRESS,  0xFF80
	.equ	OUTPORT_ADDRESS, 0xFFC0 ; Endereço do porto de saída (ns se esta certo)
	.equ 	BCD_MSK,         0xF
	.equ 	BCD_POS,         0
	.equ	VAR_INIT_VAL, 0 ; Valor inicial de var
	.equ	FED_ADDRESS, 0xFF40 



;======== Código principal ========

main_init:
	bl sides_init
	
main:
	mov	r0, #VAR_INIT_VAL
	ldr	r1, var_addr_main
	strb	r0, [r1, #0]             ; inicializa contador/variável

	
	bl _check_roll_flag
	bl read_sides 		 ; r0 = número de lados do dado (0-3)
	;bl select_roll       ; r0 = número de lados do dado (6, 8 ou 12)
    ;bl _Inport_Read     ; r0 = valor do INPORT
    ;bl bcd_get          ; r0 = valor BCD (0-9 extraído) bits 0-3
    ;bl 	seg7_display
    b main



;======== Funções ========


sides_init:
    push lr
    mov r0,  #0x3F         ; índice do número 0 no vetor seg7_values

    bl outport_write
    pop pc


select_Dice:
  	mov     r1, r0             ; guarda o valor de SIDES em r1
	 
	; switch SIDES
    mov r2, #1              ; coloca o valor 6 num registo temporário
    cmp r1, r2              ; compara registos r1 e r2
    beq     set_max_6
    mov r2, #2
    cmp r1, r2
    beq     set_max_8
    mov r2, #3
    cmp r1, r2
    beq     set_max_9
    b set_max_4             ; se não for nenhum dos anteriores, assume 4 lados


set_max_4:              ;n faces = 4
    mov r2, #4
    b launch_dice

set_max_6:              ;n faces = 6
    mov     r2, #6
    b       launch_dice

set_max_8:              ;n faces = 8
    mov     r2, #8
    b       launch_dice

set_max_9:              ;n faces = 12
    mov     r2, #9             
    b       launch_dice


generate:
   ; bl      generate_random    ; r0 ← valor entre 1 e r2
   ; bl      seg7_display       ; mostra no display
    b       main               ; loop infinito



seg7_display:
	push	lr
	mov 	r1, #9
	cmp		r1, r0
	blo		seg7_display_ret
	ldr		r1, seg7_values_addr
	ldrb	r0, [r1, r0]
	bl		outport_write
seg7_display_ret:
	pop		pc  

seg7_values_addr:
	.word	seg7_values
seg7_values:
//           dpgfedcba
	;.byte	0b00111111 // 0
    .byte 	0b00000110 // 1
	.byte 	0b01011011 // 2
	.byte 	0b01001111 // 3
	.byte 	0b01100110 // 4
	.byte 	0b01101101 // 5
	.byte 	0b01111101 // 6
	.byte 	0b00000111 // 7
	.byte 	0b01111111 // 8
	.byte	0b01101111 // 9
	.align	1


launch_dice:
    push lr

	bl read_sides
	bl select_Dice ; r2 = número de lados do dado (6, 8 ou 12)

	mov r4, #4

roll_efect:
	bl generate_random ; gera um número aleatório entre 1 e r2
	bl seg7_display ; mostra o número no display

wait_250:
	ldr r0 var_addr_isr
	ldrb r1, [r0]
	mov r3, #25
	cmp r1,r3
	blo wait_250:
	mov r2, #0
	strb r2, [r0] ; reseta o contador

	sub r4, r4, #1
	bne roll_efect

	bl generate_random ; gera o número final entre 1 e r2
	bl seg7_display ; mostra o número final no display

	wait_10s:
    ldr r0, var_addr_isr
    ldrb r1, [r0]
    mov r3, #1000
    cmp r1, r3
    blo wait_10s
    mov r2, #0
    strb r2, [r0]

    pop pc




/* 
Faz a iniciação do porto, atribuindo o valor value aos seus bits.
void outport_write ( uint8_t value );
*/
outport_write:
	ldr		r1, outport_addr
	strb	r0, [r1]
	; save value to image port
	ldr		r1, outport_img_addr
	strb	r0, [r1]
	mov		pc, lr	

outport_addr:
	.word	OUTPORT_ADDRESS

/*
Atualiza no porto de saída os bits identificados por pins_mask com o valor value.
void outport_write_bits ( uint8_t pins_mask , uint8_t value );
*/
outport_write_bits:
	push	lr
	and		r1, r1, r0 ; filtra os bits em value de acordo com pins_mask
	ldr		r2, outport_img_addr
	ldrb	r2, [r2]
	mvn		r0, r0
	and		r0, r0, r2
	orr		r0, r0, r1
	bl		outport_write
	pop		pc

outport_img_addr:
	.word	outport_img

; uint8_t read_sides()
read_sides:
   push lr
    
    bl _Inport_Read ; Lê o valor do inport

    ;Isola os bits 2 e 3
    mov r1, #0x0C     	; coloca 0x0C em r1
    and r0, r0, r1        ; r0 = r0 & r1 (ou seja, & 0x0C)


    ;faz shift para a direita para obter o valor entre 0 e 3
    lsr r0, r0, #2 ; r0 = r0 >> 2

    ;retorna em r0 (0 = 4 lados, 1 = 6 lados, 2 = 8 lados, 3 = 12lados)
    pop pc


_Inport_Read:
    mov r1, #INPORT_ADDRESS & 0xFF
    movt r1, #(INPORT_ADDRESS >> 8) & 0xFF
    ldrb r0, [ r1, #0]
    mov pc, lr

bcd_get:
	mov 	r1, #BCD_MSK & 0xF
	movt	r1, #BCD_MSK >> 8
	and 	r0, r0, r1
	lsr 	r0, r0, #BCD_POS
	mov		pc, lr

_check_roll_flag:
	push	lr
	
_check_roll_flag_loop:
	bl _Inport_Read

	mov r1, #0x01
	and r0, r0, r1 ; Isola o bit 0 do inport

	;ldr r2, roll_flag  ;o chat deu me assim mas achei estranho
	;ldrb r3, [r2]

	ldr   r3, roll_flag  ; carrega o endereço de roll_flag para r3
    ldrb  r2, [r3]        ; lê o byte guardado nesse endereço para r2
	strb    r0, [r3] 		;guarda o valor atual como novo valor anterior


	mov r1, #1
	cmp r2, r1
	bne _check_roll_flag_loop 
	and r0, r0, r0
	bne _check_roll_flag_loop
	pop pc

	;bl ;aqui onde fazemos o laçamento do dado porque houve transição descendente, ou entao vai se para a main que chama o generate

isr:
	push	r1
	push	r0
	mov	r0, #FED_ADDRESS & 0xFF
	movt	r0, #(FED_ADDRESS >> 8) & 0xFF
	strb	r2, [r0, #0]
	ldr	r0, var_addr_isr
	ldrb	r1, [r0, #0]
	add	r1, r1, #1
	strb	r1, [r0, #0]
	pop	r0
	pop	r1
	movs	pc, lr

var_addr_isr:
	.word	var

	;sempre que precisamos da variavel var vemos o valor da mesma, depois e so fazer um loop onde se compara 

	;usar 100 hz

generate_random:
    push lr
gen_rand_try:
    bl rand           ; r0 ∈ [0, 65535]
    cmp r2, r0        ; testa se r0 > r2
    bcc gen_rand_try  ; se for maior, tenta de novo
    add r0, r0, #1    ; ajusta para intervalo [1, r2]
    pop pc




rand:
	push	lr
	ldr	r2, seed_addr_rand
	ldr	r0, [r2, #0]
	ldr	r1, [r2, #2]
	mov	r2, #( 0x43FD >> 0 ) & 0xFF
	movt	r2, #( 0x43FD >> 8 ) & 0xFF
	mov	r3, #( 0x0003 >> 0 ) & 0xFF
	movt	r3, #( 0x0003 >> 8 ) & 0xFF
	bl	umull32
	mov	r2, #( 0x9EC3 >> 0 ) & 0xFF
	movt	r2, #( 0x9EC3 >> 8 ) & 0xFF
	mov	r3, #( 0x0026 >> 0 ) & 0xFF
	movt	r3, #( 0x0026 >> 8 ) & 0xFF
	add	r0, r0, r2
	adc	r1, r1, r3
	mov	r2, #0xFF
	movt	r2, #0xFF
	cmp r0, r2
	bne rand_save_seed
	mov	r3, #0xFF
	movt	r3, #0xFF
	cmp r1, r3
	bne rand_save_seed
	mov r0, #0
	mov r1, #0
rand_save_seed:
	ldr	r2, seed_addr_rand
	str	r0, [r2, #0]
	str	r1, [r2, #2]
	mov	r0, r1
	pop	pc


umull32:
	push	r8
	push	r7
	push	r6
	push	r5
	push	r4
	asr	r4, r3, #15
	mov	r5, r4
	mov	r6, #0
	mov	r7, #0
umull32_loop:
	mov	r8, #32
	cmp	r7, r8
	bhs	umull32_ret
	mov	r8, #1
	and	r8, r2, r8
	bzc	umull32_else
	mov	r8, #1
	cmp	r6, r8
	bne	umull32_loop_end
	add	r4, r4, r0
	adc	r5, r5, r1
	b	umull32_loop_end
umull32_else:
	mov	r8, #0
	cmp	r6, r8
	bne	umull32_loop_end
	sub	r4, r4, r0
	sbc	r5, r5, r1
umull32_loop_end:
	mov	r8, #1
	and	r6, r2, r8
	asr	r5, r5, #1
	rrx	r4, r4
	rrx	r3, r3
	rrx	r2, r2
	add	r7, r7, #1
	b	umull32_loop
umull32_ret:
	mov	r0, r2
	mov	r1, r3
	pop	r4
	pop	r5
	pop	r6
	pop	r7
	pop	r8
	mov	pc, lr


.data

seed:
	.word 1, 0

seed_addr_rand:
	.word seed

var:
	.space	1

outport_img:
	.space	1

    .align 1
roll_flag:     .word 0

    .align 1

stack_top: 

