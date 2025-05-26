; -----------------------------------------------------------------------------
; Ficheiro:  ac_tp06.S
; Descricao: Codigo de suporte a realizacao da 6a aula teorico-pratica de AC.
; Autor:     Tiago M Dias (tiago.dias@isel.pt)
; Data:      28-03-2024
; -----------------------------------------------------------------------------
; Notas:     O ficheiro deve ser traduzido para codigo maquina usando o comando
;            p16as -s .text=0x6100 -s .data=0x4020 ac_tp06.S
; -----------------------------------------------------------------------------

	; Valores iniciais a considerar para os registos do processador:
	; R5=8020, R7=1234, R8=5678, SP=4000 e PC=6100

	.equ	var2_addr, 32

	.text
	push	pc
	ldr	r0, var1_addr
	ldrb	r1, [r0, #0]
	ldrb	r2, [r0, #1]

	mov	r3, #var2_addr
	ldr	r4, [r3, #0]

	ldr	r6, [r5, #0]
	strb	r7, [r5, #0]
	strb	r8, [r5, #1]

	ldr	r9, [r3, #0]

	pop	r10
	b	.

var1_addr:
	.word	var1

	.data
var1:
	.word	0xABCD
