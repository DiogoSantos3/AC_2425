.text
	b		program
	b 		.	   
program:
	ldr		sp, addr_stack_top
	b 		main
addr_stack_top:
	.word 	stack_top

    ;constants
         .equ	INPORT_ADDRESS, 0xFF80
	     .equ	OUTPORT_ADDRESS, 0xC0FF



main:



rand_seed_addr:
    .word rand_seed


; uint8_t read_sides()
read_sides:
    
    bl _Inport_Read ; Lê o valor do inport

    ;Isola os bits 2 e 3
    mov r1, #0x0C     ; coloca 0x0C em r1
    and r0, r0, r1        ; r0 = r0 & r1 (ou seja, & 0x0C)


    ;faz shift para a direita para obter o valor entre 0 e 3
    lsr r0, r0, #2 ; r0 = r0 >> 2

    ;retorna em r0 (0 = 4 lados, 1 = 6 lados, 2 = 8 lados, 3 = 12lados)
    mov pc, lr


 _Inport_Read:
mov r1, #INPORT_ADDRESS & 0xFF
movt r1, #(INPORT_ADDRESS >> 8) & 0xFF
ldrb r0, [ r1, #0]
mov pc, lr


    .data

roll_flag:     .word 0       ; Flag de controlo de ROLL
rand_seed:     .word 1       ; Semente do gerador pseudo-aleatório
stack_top:  
