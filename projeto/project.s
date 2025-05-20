.text
.global _start

b_start

ldr pc, isr_addr

.text
rand_seed_addr:
    .word rand_seed

.text
seg7_table:  ;nao est confirmado se hexa está correto
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


_start:

    mov r0, #IE_ENA
    msr cpsr, r0

loop:



isr:

    push r0
    push r1
    push r2
    push r3
    push r4




    pop r4
    pop r3
    pop r2
    pop r1
    pop r0

    movs pc, lr

; void delay_1s()
delay_1s:
    ; Aguarda interrupção do FED para gerar delay de 1 segundo
    bx lr

; void delay_10s()
delay_10s:
    ; Aguarda 10 interrupções do FED
    bx lr

; uint8_t read_sides()
read_sides:
    
    mov r1, #0x80
    movt r1, #0xFF

    ; lê o bit do DIP-switch
    ldrb r0, [r1]  ; r0= valor lido

    ;Isola os bits 2 e 3
    and r0, r0, #0x0C ; r0 = r0 & 0x0C

    ;faz shift para a direita para obter o valor entre 0 e 3
    lsr r0, r0, #2 ; r0 = r0 >> 2

    ;retorna em r0 (0 = 4 lados, 1 = 6 lados, 2 = 8 lados, 3 = 12lados)
    bx lr

; void show_number(uint8_t n)
show_number:
   
   ;por completar

     ; escreve no porto de saída (endereço 0xFFC0)
    mov r1, #0xC0
    movt r1, #0xFF
    strb r2, [r1]       ; escreve só o byte menos significativo

    bx lr

; uint8_t generate_random(uint8_t sides)
generate_random:
    push r1
    push r2
    push r3

    ldr r2, rand_seed_addr

    ldr r1, [r2]       ; r1 = seed[0..15]
    add r1, r1, #3     ; incrementa
    str r1, [r2]       ; atualiza a seed

    ; r0 = número de faces
modulo_loop:
    cmp r1, r0
    blo modulo_done
    sub r1, r1, r0
    b modulo_loop

modulo_done:
    add r0, r1, #1

    pop r3
    pop r2
    pop r1
    bx lr


; =============================================================================
; Dados e variáveis globais
; =============================================================================
    .data

roll_flag:     .word 0       ; Flag de controlo de ROLL
rand_seed:     .word 1       ; Semente do gerador pseudo-aleatório


