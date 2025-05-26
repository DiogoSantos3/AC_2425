/*
 * Use compiler command for Level and Blocked triggered versions> p16as -s .stack=0x2000 ac_tp07.s
 * Use compiler command for Unblocked triggered version> p16as -s .data=0x2000 ac_tp07.s
 */
	.text
	b		program
	b 		.	   
program:
	ldr		sp, addr_stack_top
	b 		main
addr_stack_top:
	.word 	stack_top

/*--------------------------------------------
 * Definição de constantes
 *--------------------------------------------*/
	.equ	INPORT_ADDR , 0xFC00
	.equ	OUTPORT_ADDR, 0xF800
	.equ	EN_MSK, 0x8000
	.equ 	EN_POS, 15
	.equ 	BCD_MSK, 0xF
	.equ 	BCD_POS, 0
	.equ	SEG7_OFF, 0
	.equ 	DOT_IN_MSK, 0x80
	.equ 	DOT_IN_POS, 7
	.equ 	DOT_OUT_MSK, 0x80
	.equ 	DOT_OUT_POS, 7
	.equ 	SEG7_OUT_MSK, 0x07F
	.equ 	SEG7_OUT_POS, 0
	
	; Programa principal com código aplicacional
/*
	// Versão a nível.
	seg7_off();
	while (true) {
		uint16_t val = inport_read();
		if (en_get(val) != 0)
			seg7_display(bcd_get(val));
	}
*/
/*
main:
	bl		seg7_off
main_loop:
	bl 		inport_read
	push	r0
	bl		en_get
	and		r0, r0, r0
	pop		r0
	beq		main_loop
	bl		bcd_get
	bl		seg7_display
	b 		main_loop
*/
/*
	// Versão edge-triggered bloqueante.
	seg7_off();
	while (true) {
		en_rising_edge_blocked();
		seg7_display(bcd_get(inport_read()));
	}
*/
/*
main:
	bl 		seg7_off
main_loop:
	bl		en_rising_edge_blocked
	bl 		inport_read
	bl 		bcd_get
	bl 		seg7_display
	b 		main_loop
*/
/*
	// Versão edge-triggered bloqueante (mesma amostra EN e BCD).
	seg7_off();
	while (true) {
		seg7_display(bcd_get(en_rising_edge_blocked()));
));
	}
*/
/*
main:
	bl 		seg7_off
main_loop:
	bl		en_rising_edge_blocked
	bl 		bcd_get
	bl 		seg7_display
	b 		main_loop
*/
/*
	// Versão edge-triggered não bloqueante.
	seg7_off();
	while (true) {
		uint16_t val = inport_read();
		dot_write(dot_get(val));
		if (en_rising_edge_unblocked(val) != 0)
			seg7_display(bcd_get(val));
	}
*/

main:
	bl 		seg7_off
main_loop:
	bl 		inport_read
	mov 	r4, r0
	bl 		dot_get
	bl		dot_write
	mov		r0, r4
	bl		en_rising_edge_unblocked
	and 	r0, r0, r0
	bzs		main_loop
	mov 	r0, r4
	bl 		bcd_get
	bl 		seg7_display
	b 		main_loop

/*--------------------------------------------
 * LIB : Implementação da API para os 
 * periféricos do sistema:
 * uint8_t en_get(uint16_t inport_value);
 * uint16_t en_rising_edge_blocked();
 * uint8_t en_rising_edge_unblocked(uint16_t inport_value);
 * uint8_t bcd_get(uint16_t inport_value);
 * void seg7_display(uint8_t bcd);
 * void seg7_off();
 * uint8_t dot_get(uint16_t inport_value);
 * void dot_write(uint8_t dp);
 *--------------------------------------------*/
/*
uint8_t en_get(uint16_t inport_value);
Retorna o valor do bit EN, 0 ou 1.
IN: R0 = valor lido do porto de entrada
*/
en_get:
	mov		r1, #EN_MSK & 0xFF
	movt	r1, #EN_MSK >> 8
	and 	r0, r0, r1
	lsr		r0, r0, #EN_POS
	mov		pc, lr

/*
Retorna após deteção de transição de 0 para 1 na entrada EN.
void en_rising_edge_blocked() {
	uint8_t val;
	while ((inport_read() & EN_MSK) != 0)
		;
	while (((val = inport_read()) & EN_MSK) == 0)
		;
	return val;
}
*/
en_rising_edge_blocked:
	push	lr
	push	r4
	mov		r4, #EN_MSK & 0xFF
	movt	r4, #EN_MSK >> 8
en_rising_edge_blocked_high:
	bl		inport_read
	and 	r0, r0, r4
	bzc		en_rising_edge_blocked_high
en_rising_edge_blocked_low:
	bl		inport_read
	and		r1, r0, r4
	bzs		en_rising_edge_blocked_low
	pop		r4
	pop		pc

/*
Retorna se deteta transição de 0 para 1 na entrada EN, versão não bloqueante.
uint16_t en_last = 0;
uint16_t en_rising_edge_unblocked(uint16_t value) {
	uint16_t val = en_last == 0 && (value & EN_MSK) != 0;
	en_last = value & EN_MSK;
	return val;
}
*/
en_rising_edge_unblocked:
	mov		r1, #EN_MSK & 0xFF
	movt	r1, #EN_MSK >> 8
	and 	r1, r0, r1
	ldr		r2, en_last_addr
	ldr		r3, [r2]
	str 	r1, [r2]
	mov		r0, #0
	and 	r3, r3, r3
	bzc 	en_trg_unblocked_ret
	and 	r1, r1, r1
	bzs 	en_trg_unblocked_ret
	mov 	r0, #1
en_trg_unblocked_ret:
	mov 	pc, lr

en_last_addr:
	.word 	en_last
/*
uint8_t bcd_get(uint16_t inport_value);
Retorna o valor BCD, entre 0 e 9.
IN: R0 = valor lido do porto de entrada
*/
bcd_get:
	mov 	r1, #BCD_MSK & 0xF
	movt	r1, #BCD_MSK >> 8
	and 	r0, r0, r1
	lsr 	r0, r0, #BCD_POS
	mov		pc, lr

/*
void seg7_display(uint8_t bcd);
Afixa no display 7 segmentos o número 
correspondente ao valor BCD.
IN: R0 = valor BCD
*/
seg7_display:
	push	lr
	mov 	r1, #9
	cmp		r1, r0
	blo		seg7_display_ret
	ldr		r1, seg7_values_addr
	ldrb	r0, [r1, r0]
	lsl 	r1, r0, #SEG7_OUT_POS
	mov		r0, #SEG7_OUT_MSK
	bl		outport_write_bits
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
void seg7_off();
Coloca todos os segmentos do display apagados.
*/
seg7_off:
	push	lr
	mov		r0, #SEG7_OFF
	bl 		outport_write
	pop		pc

/*
uint8_t dot_get(uint16_t inport_value);
Retorna o valor do bit DP, 0 ou 1.
IN: R0 = valor lido do porto de entrada
*/
dot_get:
	mov 	r1, #DOT_IN_MSK & 0xFF
	movt 	r1, #DOT_IN_MSK >> 8
	and 	r0, r0, r1
	lsr 	r0, r0, #DOT_IN_POS
	mov 	pc, lr
	
/*
void dot_write(uint8_t dp);
Atualiza DP do display 7 segmentos com o valor DP, 0 ou 1.
IN: R0 = valor do DP, 0 ou 1
*/
dot_write:
	push 	lr
	lsl 	r1, r0, #DOT_OUT_POS
	mov 	r0, #DOT_OUT_MSK
	bl 		outport_write_bits
	pop 	pc
	
/*--------------------------------------------
 * HAL: Implementação da API para portos paralelos:
 * uint16_t inport_read();
 * void outport_write(uint8_t value);
 * void outport_write_bits ( uint8_t pins_mask , uint8_t value );
 *--------------------------------------------*/
/*
Devolve o valor atual do estado dos bits do porto de entrada.
uint16_t inport_read ( );
*/
inport_read:
	ldr		r0, inport_addr
	ldr		r0, [r0]
	mov		pc, lr

inport_addr:
	.word	INPORT_ADDR

/* 
Faz a iniciação do porto, atribuindo o valor value aos seus bits.
void outport_write ( uint8_t value );
*/
outport_write:
	ldr		r1, outport_addr
	strb	r0, [r1, #1]
	; save value to image port
	ldr		r1, outport_img_addr
	strb	r0, [r1]
	mov		pc, lr	

outport_addr:
	.word	OUTPORT_ADDR

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

	.data
	; secção com dados globais iniciados e não iniciados
en_last:
	.word	0
outport_img:
	.space	1

	.equ 	STACK_SIZE, 64
	.stack
	; secção stack para armazenamento de dados temporários
	.space	STACK_SIZE
stack_top:
