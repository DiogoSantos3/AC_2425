	.text
	b		program
	b 		.	   
program:
	ldr		sp, addr_stack_top
	b 		main
addr_stack_top:
	.word 	stack_top


main:



rand_seed_addr:
    .word rand_seed


; uint8_t read_sides()
read_sides:
    
    mov r1, #0x80
    movt r1, #0xFF

    ; lê o bit do DIP-switch
    ldrb r0, [r1]  ; r0= valor lido

    ;Isola os bits 2 e 3
    mov r1, #0x0C     ; coloca 0x0C em r1
    and r0, r1        ; r0 = r0 & r1 (ou seja, & 0x0C)


    ;faz shift para a direita para obter o valor entre 0 e 3
    lsr r0, r0, #2 ; r0 = r0 >> 2

    ;retorna em r0 (0 = 4 lados, 1 = 6 lados, 2 = 8 lados, 3 = 12lados)
    bx lr

; =============================================================================
; Dados e variáveis globais
; =============================================================================
    .data

roll_flag:     .word 0       ; Flag de controlo de ROLL
rand_seed:     .word 1       ; Semente do gerador pseudo-aleatório


