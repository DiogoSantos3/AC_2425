.text
	b		program
	b 		.	   

;======== Endereço do topo da stack ========
program:
	ldr		sp, addr_stack_top
	b 		main
addr_stack_top:
	.word 	stack_top
    /*
seg7_ptr:
    .word seg7_values
*/


;======== Constantes ========
	.equ	INPORT_ADDRESS,  0xFF80
	.equ	OUTPORT_ADDRESS, 0xC0FF
	.equ 	BCD_MSK,         0xF
	.equ 	BCD_POS,         0

;======== Tabela dos segmentos para BCD 0-9 ========


; Tabela de valores BCD para o display
seg7_values:
    .word 0x06    ; 1
    .word 0x5B    ; 2
    .word 0x4F    ; 3
    .word 0x66    ; 4
    .word 0x6D    ; 5
    .word 0x7D    ; 6
    .word 0x07    ; 7
    .word 0x7F    ; 8
    .word 0x6F    ; 9
    .word 0x77    ; 10 (A)
    .word 0x7C    ; 11 (b)
    .word 0x39    ; 12 (C)



;======== Código principal ========
main:
	bl 	bcd_get
	; ou bl read_sides (se precisares de testar os bits do SIDES)
	; bl seg7_display

;======== Funções auxiliares ========

; uint8_t read_sides()
read_sides:
	bl _Inport_Read
	mov r1, #0x0C
	and r0, r0, r1
	lsr r0, r0, #2
	mov pc, lr

; uint16_t inport_read()
_Inport_Read:
	mov r1, #INPORT_ADDRESS & 0xFF
	movt r1, #(INPORT_ADDRESS >> 8) & 0xFF
	ldrb r0, [r1, #0]
	mov pc, lr

; void seg7_display(uint8_t bcd)
/*
seg7_display:
	push	lr
	mov 	r1, #9
	cmp		r1, r0
	blo		seg7_display_ret
	    ldr  r1, seg7_ptr

	ldrb	r0, [r1, r0]
	bl		outport_write
    
seg7_display_ret:
	pop		pc
    */

; uint8_t bcd_get(uint16_t val)
bcd_get:
	mov 	r1, #BCD_MSK & 0xF
	movt	r1, #BCD_MSK >> 8
	and 	r0, r0, r1
	lsr 	r0, r0, #BCD_POS
	mov		pc, lr

; void outport_write(uint8_t val)
outport_write:
	ldr		r1, outport_addr
	strb	r0, [r1, #1]
	ldr		r1, outport_img_addr
	strb	r0, [r1]
	mov		pc, lr	

outport_addr:
	.word OUTPORT_ADDRESS

outport_img_addr:
	.word outport_img

;======== Dados (.data) ========
.data
outport_img:
	.space 1

	.align 1
roll_flag:     .word 0       ; Flag de controlo de ROLL

	.align 1
rand_seed:     .word 1       ; Semente do gerador pseudo-aleatório

;======== Stack (.stack) ========
.stack
	.space 64
stack_top:

