
/*
uint16_t rand ( void ) {
seed = ( umull32 ( seed , 214013 ) + 2531011 ) % RAND_MAX ;
return ( seed >> 16 ) ;
}
*/


/*
3a -> A constante RAND_MAX pode ser implementada de 2 formas:
 - criando uma variável global (RAND_MAX) na secção ".data", tendo que ser implementada com um valor
inicial, e irá ser alocada em memória

 - Se fosse uma constante (.equ), o compilador iria procurar no ficheiro de código as suas ocorrências 
 e substituí-las pelo seu valor, o que seria o caso mais adequado de utilizar visto que não estamos
 a desperdiçar memória, uma vez que o valor é sempre o mesmo;
*/


.equ RAND_MAX, 0xff


rand:
    push lr
    push r4

    ;argumentos para  umull32 ( seed , 214013 )
    ldr r0, seed_addr   ; r2 = &seed
    str r2, [r0, #0]    ; seed[0..15] = r0
    str r3, [r0, #2]    ; seed[16..31] = r1

    ; 214013 = 0x343FD = r1:r0
     mov r0, 0xfd     ; r0 = 0xfd
     movt  r0, 0x43   ; r0 = 0x43fd -> escreve um valor de 16 bits na parte alta
     mov r1, 0x03     ; r1 = 0x03
     movt r1, 0x00    ; r1 = 0x0003 ->  escreve um valor de 16 bits na parte alta de r1
    ; r1:r0 = 0x343FD = 214013 = umull32(seed, 214013)

    bl umull32
    ; add (retorno de umull32) + 2531011
    ; 2531011 = 0x269EC3
    mov r4, 0xc3    
    movt r4, 0x9e
    add r0, r0, r4
    mov r4, 0x26
    movt r4, 0x00

    
    ldr r2, seed_addr
    ; seed = ... % RAND_MAX
    str r0, [r2, #0]
    str r1, [r2, #2]
    ; return seed >> 16
    mov r0, r1 ; seed >> 16
    mov r1, #0
    pop r4
    pop pc









