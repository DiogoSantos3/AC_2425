;2a -> A variável seed é uma variável global inicializada com o valor 1,
; como o seu tipo é de 32 bit, definimos 2 palavras (.word), a parte baixa tem o valor 1,
; e a alta fica a 0. Se por acaso a variável não fosse inicializada, era na secção ".bss".

seed:
    .word 0x0001 ; seed[16..31]
    .word 0x0000 ; seed[0..15] (cada 0 representa 4 bits)

seed_addr:
    .word seed

; void srand (uint32_t nseed)
; nseed = r1:r0
; r2 = &seed
srand:
    ldr r2, seed_addr   ; r2 = &seed
    str r0, [r2, #0]    ; seed[0..15] = r0
    str r1, [r2, #2]    ; seed[16..31] = r1
    mov pc, lr


;porque é que temos que dar load e stores para a seed? Não podiamos fazer simplesmente mov r2, seed_addr?


/*
void srand (unit32_t nseed) {
    seed = nseed;
}
*/

