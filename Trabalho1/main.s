
; constants
    .equ STACK_SIZE, 64
    .equ N, 5
    .equ RAND_MAX, 0xff

; ---------------------------------------------
; startup
    .section startup
    b _start
    b .

_start:
    ldr sp, sp_addr
    mov r0, pc
    add lr, r0, #4
    ldr pc, main_addr
    b .

sp_addr:
    .word top_of_stack

main_addr:
    .word main

; ---------------------------------------------
; code
    .text

    ;r0;r1 temps
    ;r4 :i
    ;r5 = error
    ;r6 = rand number
    ;5423 = 0x152F
main:
    push lr
    push r4
    push r5
    push r6
    mov r4, #0
    mov r5, #0
    mov r0, #0x2f
    movt r0, #0x15
    mov r1, #0
    bl srand
main_for_loop:
    mov r0, #0 
    cmp r5, r0
    bzc main_return
    mov r0, #N
    cmp r4, r0
    bhs main_return
    bl rand
    mov r6, r0
main_if:
    ldr r0, result_addr
    ldr r0, [r0, r4]
    cmp r6,r0
    beq for_inc
    mov r5, #1
    b main_return
for_inc:
    add r4, r4, #1
    b main_for_loop
main_return:
    mov r0, #0
    pop r4
    pop pc

    result_addr:
        .word result



;r0:r1:r2:r3 m[r0:r1] e p[0..63]
;r8:r9 M[0..31]
;r3 temp
;r4 i
;r6 p_1
umull32:
    push r4
    push r5
    push r6
    push r7
    push r8
    push r9
    mov r2, #0 ; p[32..47] = 0
    mov r3, #0 ; p[48..63] = 0
    mov r6, #0 ; p_1 = 0
    mov r4, #0 ; i = 0
umull32_for_loop:
umull32_if:
    mov r5, #0x1
    and r5, r0, r5 ; p & 0x1
    bzc umull32_else_if
    mov r5, #1
    cmp r5, r6
    bzc umull32_else_if
    add r2, r2, r8
    adc r3, r3, r9
umull32_else_if:
    mov r5, #0x1
    and r5, r0, r5 ; p & 0x1 =1
    beq umull32_else
    mov r5, #0
    cmp r5, r6
    bzc umull32_else
    sub r2, r2, r8
    sbc r3, r3, r9
umull32_else:
    mov r5, #0x1
    and r5, r0, r5
    mov r6, r5
   ; asr r0, r0, #1
    ;asr r1, r1, #1
    ;asr r2, r2, #1
    asr r3, r3, #1
    rrx r2, r2
    rrx r1, r1
    rrx r0, r0
    add r4, r4, #1
    mov r5, #32
    cmp r4, r5
    blo umull32_for_loop
umull32_for_end:
    pop r9
    pop r8
    pop r7
    pop r6
    pop r5
    pop r4
    movs pc, lr


; void srand (uint32_t nseed)
; nseed = r1:r0
; r2 = &seed
srand:
    ldr r2, seed_addr   ; r2 = &seed
    str r0, [r2, #0]    ; seed[0..15] = r0
    str r1, [r2, #2]    ; seed[16..31] = r1
    movs pc, lr





rand:
    push lr
    push r4

    ;argumentos para  umull32 ( seed , 214013 )
    ldr r0, seed_addr   ; r2 = &seed
    str r2, [r0, #0]    ; seed[0..15] = r0
    str r3, [r0, #2]    ; seed[16..31] = r1

    ; 214013 = 0x343FD = r1:r0
     mov r0, #0xfd     ; r0 = 0xfd
     movt  r0, #0x43   ; r0 = 0x43fd -> escreve um valor de 16 bits na parte alta
     mov r1, #0x03     ; r1 = 0x03
     movt r1, #0x00    ; r1 = 0x0003 ->  escreve um valor de 16 bits na parte alta de r1
    ; r1:r0 = 0x343FD = 214013 = umull32(seed, 214013)

    bl umull32
    ; add (retorno de umull32) + 2531011
    ; 2531011 = 0x269EC3
    mov r4, #0xc3    
    movt r4, #0x9e
    add r0, r0, r4
    mov r4, #0x26
    movt r4, #0x00

    
    ldr r2, seed_addr
    ; seed = ... % RAND_MAX
    str r0, [r2, #0]
    str r1, [r2, #2]
    ; return seed >> 16
    mov r0, r1 ; seed >> 16
    mov r1, #0
    pop r4
    pop lr
    pop pc


      .data
result:
    .word 17747, 2055, 3664, 15611, 9819
seed:
    .word 0x0001
    .word 0x0000

seed_addr:
    .word seed

; ---------------------------------------------
; stack
    .section .stack
    .space STACK_SIZE
top_of_stack:
    b .
