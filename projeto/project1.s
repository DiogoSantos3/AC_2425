.text
	b		program
	b 		.	   
program:
	ldr		sp, addr_stack_top
	b 		main
addr_stack_top:
	.word 	stack_top

;======== Constantes ========
	.equ	INPORT_ADDRESS,  0xFF80
	.equ	OUTPORT_ADDRESS, 0xFFC0 ; Endereço do porto de saída (ns se esta certo)
	.equ 	BCD_MSK,         0xF
	.equ 	BCD_POS,         0



;======== Código principal ========

main:
	bl read_sides 		 ; r0 = número de lados do dado (0-3)
	bl select_roll       ; r0 = número de lados do dado (6, 8 ou 12)
    ;bl _Inport_Read     ; r0 = valor do INPORT
    ;bl bcd_get          ; r0 = valor BCD (0-9 extraído) bits 0-3
    ;bl 	seg7_display
    b main



;======== Funções ========

select_roll:
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
    b generate

set_max_6:              ;n faces = 6
    mov     r2, #6
    b       generate

set_max_8:              ;n faces = 8
    mov     r2, #8
    b       generate

set_max_9:              ;n faces = 12
    mov     r2, #9             
    b       generate


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
	.byte	0b00111111 // 0
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

.data

outport_img:
	.space	1

    .align 1
roll_flag:     .word 0

    .align 1
rand_seed:     .word 1
    .align 1
rand_seed_addr:
    .word rand_seed
stack_top:  
