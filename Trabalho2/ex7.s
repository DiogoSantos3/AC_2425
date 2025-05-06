
;constants
         .equ	INPORT_ADDRESS, 0x7000
	     .equ	OUTPORT_ADDRESS, 0x7FFF


; startup
    .section startup
    b _Main
    b .

_Main:
    bl _Inport_Read
    and r1,r0 ,#0x7
    mov r2, #1
    lsl r2,r2,r1
    mvn r2,r2
    bl _Outport_Write
    b _Main



_Inport_Read:
mov r1, #INPORT_ADDRESS & 0xFF
movt r1, #(INPORT_ADDRESS >> 8) & 0xFF
ldrb r0, [ r1, #0]
mov pc, lr

_Outport_Write:
mov r3, #OUTPORT_ADDRESS & 0xFF
movt r3, #(OUTPORT_ADDRESS >> 8) & 0xFF
strb r2, [r3, #0]
mov pc, lr


   