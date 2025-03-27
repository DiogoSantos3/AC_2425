
;r0:r1:r4:r5 m[r0:r1] e p[0..63]
;r8:r9 M[0..31]
;r3 temp
;r2 i
;r6 p_1


mov r4, #0 ; p[32..47] = 0
mov r5, #0 ; p[48..63] = 0
mov r6, #0 ; p_1 = 0
for:
    mov r2, #0 ; i = 0
for_loop:
if:
    mov r3, #0x1
    and r3, r0, r3 ; p & 0x1
    bzc else_if
    mov r3, #1
    cmp r3, r6
    bzc else_if
    add r4, r4, r8
    adc r5, r5, r9
else_if:
    mov r3, #0x1
    and r3, r0, r3 ; p & 0x1 =1
    beq else
    mov r3, #0
    cmp r3, r6
    bzc else
    sub r4, r4, r8
    sbc r5, r5, r9
else:
    mov r3, #0x1
    and r3, r0, r3
    mov r6, r3
    asr r0, r0, #1
    asr r1, r1, #1
    asr r4, r4, #1
    asr r5, r5, #1
    rrx r1, r0
    rrx r4, r1
    rrx r5, r4
    add r2, r2, #1
    mov r3, #32
    cmp r2, r3
    blo for_loop
for_end:
    mov pc, lr              ; Retorna da função










