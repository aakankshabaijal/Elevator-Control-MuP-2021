#make_bin#

#LOAD_SEGMENT=FFFFh#
#LOAD_OFFSET=0000h#

#CS=0000h#
#IP=0000h#

#DS=0000h#
#ES=0000h#

#SS=0000h#
#SP=FFFEh#

#AX=0000h#
#BX=0000h#
#CX=0000h#
#DX=0000h#
#SI=0000h#
#DI=0000h#
#BP=0000h#

    jmp st1
    nop
    db 28 dup(0)

    ; int 08h for 1 shot timer 
    dw os_isr
    dw 0

    ; int 09h for keyboard  
    dw key_isr
    dw 0

    ; int 10h for Coarse Sensor 2
    dw cs2_isr
    dw 0

    ; int 11h for Coarse Sensor 1
    dw cs1_isr 
    dw 0

    ; int 12h for Fine Sensor
    dw fs_isr
    dw 0

    ; int 13h to int 255h not used
    db 972 dup(0)

st1: cli
    ;rom1 : 00000 - 00fff
    ;ram1 : 01000 - 01fff
    ;rom2 : ff000 - fffff 

    ; intialize ds, es, ss to start of RAM
    mov ax,0100h
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov sp,01ffeH

    porta equ 0b0h
    portb equ 0b2h
    portc equ 0b4h
    portcreg equ 0b6h

    conv25 equ 80h
    conv10 equ 82h
    pwm equ 84h
    convcreg equ 86h

    ostimer0 equ 90h
    ostimer1 equ 92h
    oscreg equ 96h

    intloc1 equ 0A0h
    intloc2 equ 0A2h

    bsrcreg equ 0c6h

    ; initializing timers
    ; first timer (chip 1) mode 3; write 16 bit value 61a8h; converts 2.5MHz into 100Hz
    mov al, 00110110b
    out convcreg, al
    mov al, 0a8h
    out conv25, al
    mov al, 61h
    out conv25, al

    ; second timer (chip 1) mode 3; write 8 bit value 0ah; converts 100Hz to 10Hz
    mov al, 01010110b
    out convcreg, al
    mov al, 0ah
    out conv10, al

    ; third timer (chip 1) mode 1; used for PWM
    mov al, 10010010b
    out convcreg, al
    mov al, 0ah ; put a value of 10 so that motor is not running at the start
    out pwm, al

    ; first timer (chip 2) mode 1; write 8 bits value 01h
    mov al, 00001000b
    out oscreg, al
    mov al, 01h
    out ostimer0, al

    ; second timer (chip 2) mode 1; write 8 bits value 20
    mov al, 00001000b
    out oscreg, al
    mov al, 20
    out ostimer1, al
    
    ; initializing 8255
    ; port A output from 8255; for showing current floor value in LED
    ; port B output from 8255; for showing destination floor value in LED
    ; port C upper input; for keyboard columns
    ; port C lower output; for keyboard rows
    mov al, 10001000b
    out portcreg, al
    mov al, 00h
    out portb, al ; display zero on the LED, at the start
    out porta, al ; display zero on the LED, at the start
    out portc, al ; give zero on keyboard column at the start

    ; initialising 8255
    ; port C output from 8255; for giving input signals to motor, lift door and one shot timer
    mov al, 00000000b ; PC0 = 0 initially
    out bsrcreg, al
    mov al, 00000010b ; PC1 = 0 initially
    out bsrcreg, al
    mov al, 00000100b ; PC2 = 0 initially
    out bsrcreg, al
    mov al, 00000110b ; PC3 = 0 initially
    

    ; initializing 8259
    ; IR0 = for generating 100 ms one shot timer
    ; IR1 = for keyboard interrupt
    ; IR2 = for Coarse Sensor 1 (CS1)
    ; IR3 = for Coarse Sensor 2 (CS2)
    ; IR4 = for Fine Sensor (FS)
    mov al, 00010011b ; icw 1
    out intloc1, al
    mov al, 00001000b ; icw 2
    out intloc2, al
    mov al, 00000001b ; icw 4
    out intloc2,al
    mov al, 11100000b ; ocw 1
    out intloc2, al

    sti
    
infiloop: jmp infiloop

;-------------------------------------------------------------------------------------------

;all isrs used in the program

    ; ISR for one shot timer
    os_isr:
        mov al, 01100000b ; ocw 2 specific EOI for IR0
        out intloc1, al

        mov CL, 01h
        iret
    
    ; ISR for keyboard
    key_isr:
        mov al, 01100001b ; ocw 2 specific EOI for IR1
        out intloc1, al

        ; check for key press
        mov al, 00h
        out portc, al

    x1: in al, portc
        and al, 0f0h
        cmp al, 0f0h
        jz x1

        ; check for key press in column 1
        mov al, 0eh
        mov bl, al

        out portc, al
        in al, portc

        and al, 0f0h
        cmp al, 0f0h
        jnz check_key

        ; check for key press in column 2
        mov al, 0dh
        mov bl, al

        out portc, al
        in al, portc

        and al, 0f0h
        cmp al, 0f0h
        jnz check_key

        ; check for key press in column 3
        mov al, 0bh
        mov bl, al

        out portc, al
        in al, portc

        and al, 0f0h
        cmp al, 0f0h
        jnz check_key

        ; check for key press in column 4
        mov al, 0bh
        mov bl, al

        out portc, al
        in al, portc

        and al, 0f0h
        cmp al, 0f0h
        jnz check_key

        ; find out which key was pressed from hex keypad
        ; key00 => EEh == CLOSE DOOR
        ; key04 => DEh == UP0
        ; key05 => DDh == DOWN1
        ; key06 => DBh == UP1
        ; key07 => D7h == DOWN2 
        ; key08 => BEh == UP2
        ; key09 => BDh == DOWN3
        ; key10 => BBh == LIFT0
        ; key11 => B7h == LIFT1
        ; key12 => 7Eh == LIFT2
        ; key13 => 7Dh == LIFT3

    check_key: 
        or al, bl ; which key is pressed
        cmp al, 0eeh
        jnz x5

        mov al, 00
        out portc, al

        call drClose
        jmp check_key

    x5: cmp al, 0deh
        jnz x6   

        mov al, 00
        out portc, al     

        call up0
        jmp check_key

    x6: cmp al, 0ddh 
        jnz x7

        mov al, 00
        out portc, al

        call down1
        jmp check_key

    x7: cmp al, 0dbh
        jnz x8

        mov al, 00
        out portc, al

        call up1
        jmp check_key

    x8: cmp al, 0d7h
        jnz x9

        mov al, 00
        out portc, al

        call down2
        jmp check_key

    x9:cmp al, 0beh
        jnz x10

        mov al, 00
        out portc, al

        call up2
        jmp check_key

    x10:cmp al, 0bdh
        jnz x11

        mov al, 00
        out portc, al

        call down3
        jmp check_key

    x11:cmp al, 0bbh
        jnz x12

        mov al, 00
        out portc, al

        call lift0
        jmp check_key

    x12:cmp al, 0b7h
        jnz x13

        mov al, 00
        out portc, al

        call lift1
        jmp check_key

    x13:cmp al, 07eh
        jnz x14

        mov al, 00
        out portc, al

        call lift2
        jmp check_key

    x14:cmp al, 07dh
        jnz check_key

        mov al, 00
        out portc, al

        call lift3
        jmp check_key

        iret


    ; ISR for coarse sensor 2
    cs2_isr:
        push ax
        push bx

        mov al, 01100011b ; ocw 2 specific EOI for IR3
        out intloc1, al

        mov al, dir
        mov ah, current
        mov bl, dest

        cmp al, 00h
        jnz dir_down

        call accel50

        pop bx
        pop ax
        iret


    dir_down:
        dec ah
        cmp ah, bl
        jnz dir_down

        call decel20

        pop bx
        pop ax
        iret

    ; SR for coarse sensor 1
    cs1_isr:
        push ax
        push bx

        mov al, 01100010b ; ocw 2 specific EOI for IR2
        out intloc1, al

        mov al, dir
        mov ah, current
        mov bl, dest

        cmp dir, 01
        jnz dir_up

        call accel50
        pop bx
        pop ax
        iret


    dir_up:
        inc ah
        cmp ah, bl
        jnz dir_up

        call decel20

        pop bx
        pop ax
        iret

    ; SR for fine sensor
    fs_isr: 
        push ax
        push bx

        mov al, 01100100b ; ocw 2 specific EOI for IR4
        out intloc1, al

        mov al, liftMove
        mov ah, current
        mov bl, dest
        mov bh, dir

        cmp al, 01h
        jnz f2

        cmp bh, 00h
        jnz f4

        dec ah
        mov current, ah
        cmp ah, bl
        jnz f1

        call decel20
        call ledDisp

        mov drState, 00h
        mov AL, 04h
        out bsrcreg, AL

        mov liftMove, 00h

        pop bx
        pop ax
        iret


    f4:
        inc ah
        mov current, ah
        cmp ah, bl
        jnz f1

        call decel20
        call ledDisp

        mov drState, 00h
        mov AL, 04h
        out bsrcreg, AL

        mov liftMove, 00h

        pop bx
        pop ax
        iret


    f2:
        pop bx
        pop ax
        iret


    f1: 
        cmp bh, 00h
        jnz f3

        dec ah
        mov current, ah

        pop bx
        pop ax
        iret


    f3:
        inc ah
        mov current, ah

        pop bx
        pop ax
        iret


; -------------------------------------------------------------------------------------

; all subroutines used in ISR
up0 proc near
    push ax
    push bx
    push cx

    mov al, current
    mov ah, liftMove
    mov bl, drState

    cmp al,00
    jnz y2

    cmp ah,00
    jnz y2
    

y1:    
    mov drState, 00h
    mov AL, 04h
    out bsrcreg, AL

    pop cx
    pop bx
    pop ax
    ret


y2:
    cmp ah, 00
    jnz y2

    cmp al, 00
    jz y1

    mov dest, 00
    mov dir, 00
    mov AL, 02h
    out bsrcreg,al
    
    mov drState, 01h
    mov AL, 05h
    out bsrcreg, AL

    mov cl, 0
q1: cmp cl, 1
    jne q1

    mov liftMove, 01
    call liftstar

    pop cx
    pop bx
    pop ax
    ret
up0 endp


down1 proc near
    push ax
    push bx
    push cx

    mov al, current
    mov ah, liftMove
    mov bl, drState
    mov bh, dir

    cmp al, 01
    jnz y3

    cmp ah, 01
    jnz y4


y5: cmp ah, 01
    jz y5


y11:
    mov dest, 01
    mov dir, 00
    mov al, 02h
    out bsrcreg, al

    mov drState, 01h
    mov AL, 05h
    out bsrcreg, AL

    mov cl, 0
q8: cmp cl, 1
    jne q8

    mov liftMove, 01
    call liftstar

    cmp ah, 00
    jnz y12

    mov dir, 01
    mov al,03H
    out bsrcreg,al

    mov cl, 0
q2: cmp cl, 1
    jne q2

    mov liftMove, 1
    call liftstar

    pop cx
    pop bx
    pop ax
    ret


y12:
    mov drState, 00h
    mov AL, 04h
    out bsrcreg, AL

    mov dir, 00
    mov AL, 02h
    out bsrcreg,al

    mov cl, 0
q3: cmp cl, 1
    jne q3

    mov liftMove, 01
    call liftstar

    pop cx
    pop bx
    pop ax
    ret


y4:
    mov drState, 00h
    mov AL, 04h
    out bsrcreg, AL

    pop cx
    pop bx
    pop ax
    ret
    
y3: 
    cmp ah, 01
    jnz y6

    cmp bh, 0
    jnz y7

    cmp al, 2
    jnz y8


y9:
    mov cl, dest
    mov secdest, cl
    mov dest,1


y8:
    mov cl, dest
    cmp cl, 02
    jnz y9


y10:
    cmp ah, 00
    jnz y10

    mov dest, 01
    mov drState, 01h
    mov AL, 05h
    out bsrcreg, AL

    mov dir, 00
    mov AL, 02h
    out bsrcreg,al

    mov cl, 0
q4: cmp cl, 1
    jne q4

    mov liftMove, 01
    call liftstar

    pop cx
    pop bx
    pop ax
    ret


y7:
    cmp ah, 00
    jnz y7
    jmp y6


y6:
    cmp al, 01
    jnz y11

    mov dir, 00
    mov al, 02h
    out bsrcreg, al

    mov drState, 00h
    mov AL, 04h
    out bsrcreg, AL

    mov cl, 0
q9: cmp cl, 1
    jne q9

    mov liftMove, 01
    call liftstar

    pop cx
    pop bx
    pop ax
    ret
down1 endp


up2 proc near
    push ax
    push bx
    push cx

    mov al, current
    mov ah, liftMove
    mov bl, drState
    mov bh, dir

    cmp al, 02
    jnz up2y3

    cmp ah, 01
    jnz up2y4


up2y5: cmp ah, 01
    jz up2y5 


up2y11:
    mov dest, 02
    mov drState, 01h
    mov AL, 05h
    out bsrcreg, AL

    cmp al, 03
    jnz up2y12

    mov dir, 00
    mov AL, 02h
    out bsrcreg,al
    
    mov cl, 0
q5: cmp cl, 1
    jne q5

    mov liftMove, 01
    call liftstar

    pop cx
    pop bx
    pop ax
    ret


up2y12:
    mov dir, 01
    mov al,03H
    out bsrcreg,al

    mov cl, 0
q6: cmp cl, 1
    jne q6

    mov liftMove, 01
    call liftstar
     
    pop cx
    pop bx
    pop ax
    ret


up2y4:
    mov drState, 00h
    mov AL, 04h
    out bsrcreg, AL

    pop cx
    pop bx
    pop ax
    ret
    

up2y3: 
    cmp ah, 01
    jnz up2y6

    cmp bh, 1
    jnz up2y7

    cmp al, 1
    jnz up2y8


up2y9:
    mov cl, dest
    mov secdest, cl
    mov dest, 2


up2y8:
    mov cl, dest
    cmp cl, 01
    jnz up2y9


up2y10:
    cmp ah, 01
    jz up2y10

    mov dest, 02
    mov drState, 01h
    mov AL, 05h
    out bsrcreg, AL

    mov dir, 01
    mov al,03H
    out bsrcreg,al

    mov cl, 0
q7: cmp cl, 1
    jne q7

    mov liftMove, 01
    call liftstar

    pop cx
    pop bx
    pop ax
    ret


up2y7:
    cmp ah, 01
    jz up2y7

    jmp up2y6


up2y6:
    cmp al, 02
    jnz up2y11

    mov drState, 00h
    mov AL, 04h
    out bsrcreg, AL

    pop cx
    pop bx
    pop ax
    ret
up2 endp


up1 proc near
    push ax
    push bx
    push cx

    mov al, current
    mov ah, liftMove
    mov bl, drState
    mov bh, dir

    cmp al, 01
    jnz up1y3

    cmp ah, 01
    jnz up1y4


up1y5: cmp ah, 01
    jz up1y5


up1y11:
    mov dest, 01
    mov drState, 01h
    mov AL, 05h
    out bsrcreg, AL

    cmp ah, 00
    jnz up1y12

    mov dir, 01
    mov al,03H
    out bsrcreg,al

    mov cl, 0
q10:cmp cl, 1
    jne q10

    mov liftMove, 01
    call liftstar

    pop cx
    pop bx
    pop ax
    ret


up1y12:
    mov dir, 00
    mov AL, 02h
    out bsrcreg,al

    mov cl, 0
q11:cmp cl, 1
    jne q11

    mov liftMove, 01
    call liftstar

    pop cx
    pop bx
    pop ax
    ret


up1y4:
    mov drState, 00h
    mov AL, 04h
    out bsrcreg, AL

    pop cx
    pop bx
    pop ax
    ret
    

up1y3: 
    cmp ah, 01
    jnz up1y6

    cmp bh, 1
    jnz up1y7


up1y9:
    mov cl, dest
    mov secdest, cl
    mov dest, 1

    pop cx
    pop bx
    pop ax
    ret


up1y7:
    cmp ah, 00
    jnz up1y7
    jmp up1y6


up1y6:
    cmp al, 01
    jnz up1y11

    mov drState, 00h
    mov AL, 04h
    out bsrcreg, AL

    pop cx
    pop bx
    pop ax
    ret
up1 endp


down3 proc near
    push ax
    push bx
    push cx

    mov al, current
    mov ah, liftMove
    mov bl, drState

    cmp al, 03
    jnz dn3y2

    cmp ah, 00
    jnz dn3y2


dn3y1:    
    mov drState, 00h
    mov AL, 04h
    out bsrcreg, AL

    pop cx
    pop bx
    pop ax
    ret


dn3y2:
    cmp ah, 00
    jnz dn3y2

    cmp al, 03
    jz dn3y1

    mov dest, 00
    mov dir, 00
    mov AL, 02h
    out bsrcreg,al

    mov drState, 01h
    mov AL, 05h
    out bsrcreg, AL

    mov cl, 0
q12:cmp cl, 1
    jne q12

    mov liftMove, 01
    call liftstar

    pop cx
    pop bx
    pop ax
    ret
down3 endp

down2 proc near
    push ax
    push bx
    push cx

    mov al, current
    mov ah, liftMove
    mov bl, drState
    mov bh, dir

    cmp al, 02
    jnz dn2y3

    cmp ah, 01
    jnz dn2y4


dn2y5: cmp ah, 01
    jz dn2y5


dn2y11:
    mov dest, 01
    mov drState, 01h
    mov AL, 05h
    out bsrcreg, AL

    mov cl, 0
q13:cmp cl, 1
    jne q13

    mov liftMove, 01
    call liftstar

    cmp ah, 03
    jnz dn2y12

    mov dir, 00
    mov AL, 02h
    out bsrcreg,al

    mov cl, 0
q14:cmp cl, 1
    jne q14

    mov liftMove, 01
    call liftstar

    pop cx
    pop bx
    pop ax
    ret


dn2y12:
    mov dir, 01
    mov al,03H
    out bsrcreg,al

    mov cl, 0
q15:cmp cl, 1
    jne q15

    mov liftMove, 01
    call liftstar

    pop cx
    pop bx
    pop ax
    ret


dn2y4:
    mov drState, 00h
    mov AL, 04h
    out bsrcreg, AL

    pop cx
    pop bx
    pop ax
    ret
    

dn2y3: 
    cmp ah, 01
    jnz dn2y6
    cmp bh, 1
    jnz dn2y7


dn2y9:
    mov cl, dest
    mov secdest, cl
    mov dest, 1

    pop cx
    pop bx
    pop ax
    ret


dn2y7:
    cmp ah, 00
    jnz dn2y7
    jmp dn2y6


dn2y6:
    cmp al, 02
    jnz dn2y11

    mov drState, 00h
    mov AL, 04h
    out bsrcreg, AL

    pop cx
    pop bx
    pop ax
    ret
down2 endp


; subroutine when lift0 is pressed
lift0 proc near
    push ax
    push cx

    cmp current, 0
    jz a1

    mov dest, 0
    mov dir, 0
    mov al, 02h
    out bsrcreg, al

    mov drState, 01h
    mov AL, 05h
    out bsrcreg, AL

    mov cl, 0
q16:cmp cl, 1
    jne q16

    mov liftMove, 1
    call liftstar
    

    ; check if lift is moving or not
a2: cmp liftMove, 1
    jz a2


    ; secdest = 0 OR secdest = dest
a1: mov ah, 0
    mov al, secDest
    cmp secDest, 0
    jz a3

    inc ah
    cmp al, dest
    jz a3

    inc ah
    cmp ah, 0
    jge a4


    ; secdest > dest
a4: mov al, secDest
    cmp al, dest
    jg a5

    mov dest, al
    mov dir, 0
    mov al, 02h
    out bsrcreg, al

    mov drState, 01h
    mov AL, 05h
    out bsrcreg, AL

    mov cl, 0
q17:cmp cl, 1
    jne q17

    mov liftMove, 1
    call liftstar
    jmp a6


a5: mov dest, al
    mov dir, 01h
    mov AL, 03h
    out bsrcreg, AL

    mov drState, 01h
    mov AL, 05h
    out bsrcreg, AL

    mov cl, 0
q18:cmp cl, 1
    jne q18

    mov liftMove, 1
    call liftstar
    

a6: cmp liftMove, 1
    jz a6


a3: mov dest, 0
    mov dir, 0
    mov al, 02h
    out bsrcreg, al

    mov drState, 01h
    mov AL, 05h
    out bsrcreg, AL

    mov cl, 0
q19:cmp cl, 1
    jne q19

    mov liftMove, 01
    call liftstar
    
    pop cx
    pop ax
    ret
lift0 endp


; subroutine when lift1 is pressed
lift1 proc near
    push ax
    cmp current, 1
    jz b1

    ; check if current floor = 0
    cmp current, 0
    jz b2

    mov dest, 1
    mov dir, 0
    mov al, 02h
    out bsrcreg, al

    mov drState, 01h
    mov AL, 05h
    out bsrcreg, AL

    mov cl, 0
q20:cmp cl, 1
    jne q20

    mov liftMove, 01
    call liftstar
    
    jmp b3


b2: mov dest, 1
    mov dir, 01h
    mov AL, 03h
    out bsrcreg, AL

    mov drState, 01h
    mov AL, 05h
    out bsrcreg, AL

    mov cl, 0
q21:cmp cl, 1
    jne q21

    mov liftMove, 01
    call liftstar
    

    ; check if lift is moving or not
b3: cmp liftMove, 1
    jz b3


    ; secdest = 0 OR secdest = dest
b1: mov ah, 0
    mov al, secDest
    cmp secDest, 0
    jz b4

    inc ah
    cmp al, dest
    jz b4

    inc ah
    cmp ah, 0
    jge b5


    ; secdest > dest
b5: mov al, secDest
    cmp al, dest
    jg b6

    mov dest, al
    mov dir, 0
    mov al, 02h
    out bsrcreg, al

    mov drState, 01h
    mov AL, 05h
    out bsrcreg, AL

    mov cl, 0
q22:cmp cl, 1
    jne q22

    mov liftMove, 01
    call liftstar
    
    jmp b7


b6: mov dest, al
    mov dir, 01h
    mov AL, 03h
    out bsrcreg, AL

    mov drState, 01h
    mov AL, 05h
    out bsrcreg, AL

    mov cl, 0
q23:cmp cl, 1
    jne q23

    mov liftMove, 01
    call liftstar
    

b7: cmp liftMove, 1
    jz b7


b4: mov dest, 0
    mov dir, 0
    mov al, 02h
    out bsrcreg, al

    mov drState, 01h
    mov AL, 05h
    out bsrcreg, AL

    mov cl, 0
q24:cmp cl, 1
    jne q24

    mov liftMove, 01
    call liftstar
    
    pop cx
    pop ax
    ret
lift1 endp


; subroutine when lift2 is pressed
lift2 proc near
    push ax
    push cx 

    cmp current, 2
    jz c1

    ; check if current floor = 3
    cmp current, 3
    jz c2

    mov dest, 2
    mov dir, 01h
    mov AL, 03h
    out bsrcreg, AL

    mov drState, 01h
    mov AL, 05h
    out bsrcreg, AL

    mov cl, 0
q25:cmp cl, 1
    jne q25

    mov liftMove, 01
    call liftstar
    
    jmp c3


c2: mov dest, 2
    mov dir, 0
    mov al, 02h
    out bsrcreg, al

    mov drState, 01h
    mov AL, 05h
    out bsrcreg, AL

    mov cl, 0
q26:cmp cl, 1
    jne q26

    mov liftMove, 01
    call liftstar
    

    ; check if lift is moving or not
c3: cmp liftMove, 1
    jz c3


    ; secdest = 0 OR secdest = dest
c1: mov ah, 0
    mov al, secDest
    cmp secDest, 0
    jz c4

    inc ah
    cmp al, dest
    jz c4

    inc ah
    cmp ah, 0
    jge c5


    ; secdest > dest
c5: mov al, secDest
    cmp al, dest
    jg c6

    mov dest, al
    mov dir, 0
    mov al, 02h
    out bsrcreg, al

    mov drState, 01h
    mov AL, 05h
    out bsrcreg, AL

    mov cl, 0
q27:cmp cl, 1
    jne q27

    mov liftMove, 01
    call liftstar
    
    jmp c7


c6: mov dest, al
    mov dir, 01h
    mov AL, 03h
    out bsrcreg, AL

    mov drState, 01h
    mov AL, 05h
    out bsrcreg, AL

    mov cl, 0
q28:cmp cl, 1
    jne q28

    mov liftMove, 01
    call liftstar
    

c7: cmp liftMove, 1
    jz c7


c4: mov dest, 0
    mov dir, 0
    mov al, 02h
    out bsrcreg, al

    mov drState, 01h
    mov AL, 05h
    out bsrcreg, AL

    mov cl, 0
q29:cmp cl, 1
    jne q29

    mov liftMove, 01
    call liftstar
    
    pop cx
    pop ax
    ret
lift2 endp


; subroutine when lift3 is pressed
lift3 proc near
    push ax
    push cx

    cmp current, 3
    jz d1

    mov dest, 3
    mov dir, 01h
    mov AL, 03h
    out bsrcreg, AL

    mov drState, 01h
    mov AL, 05h
    out bsrcreg, AL

    mov cl, 0
q30:cmp cl, 1
    jne q30

    mov liftMove, 01
    call liftstar
    

    ; check if lift is moving or not
d2: cmp liftMove, 1
    jz d2


    ; secdest = 0 OR secdest = dest
d1: mov ah, 0
    mov al, secDest
    cmp secDest, 0
    jz d3

    inc ah
    cmp al, dest
    jz d3

    inc ah
    cmp ah, 0
    jge d4


    ; secdest > dest
d4: mov al, secDest
    cmp al, dest
    jg d5

    mov dest, al
    mov dir, 0
    mov al, 02h
    out bsrcreg, al

    mov drState, 01h
    mov AL, 05h
    out bsrcreg, AL

    mov cl, 0
q31:cmp cl, 1
    jne q31

    mov liftMove, 01
    call liftstar
    
    jmp d6


d5: mov dest, al
    mov dir, 01h
    mov AL, 03h
    out bsrcreg, AL

    mov drState, 01h
    mov AL, 05h
    out bsrcreg, AL

    mov cl, 0
q32:cmp cl, 1
    jne q32

    mov liftMove, 01
    call liftstar
    

d6: cmp liftMove, 1
    jz d6


d3: mov dest, 0
    mov dir, 0
    mov al, 02h
    out bsrcreg, al

    mov drState, 01h
    mov AL, 05h
    out bsrcreg, AL

    mov cl, 0
q33:cmp cl, 1
    jne q33

    mov liftMove, 01
    call liftstar
    
    pop cx
    pop ax
    ret
lift3 endp


; subroutine when drClose is called
drClose proc near
    push ax

    mov drState, 01h
    mov AL, 05h
    out bsrcreg, AL

    pop ax
    ret
drClose endp


; LED display logic
ledDisp proc near
    push ax

    mov al, current
    out porta, al

    cmp liftMove, 01
    jnz e1

    out portb, al
    

e1: cmp dir, 00
    jnz e2

    dec al
    out portb, al


e2: inc al
    out portb, al

    pop ax
    ret
ledDisp endp


; start and accelaration routine 0% to 40%
liftstar proc near
    push ax
    push cx

    mov AL,08h ; for 20% duty cycle
    out pwm,AL

    mov AL,00h ; first give a low on port PC0 (bsr) (0000 000 0b)
    out bsrcreg,AL

    mov AL,01h ; then give a high on port PC0 (bsr) to trigger one shot timer (0000 000 1b)
    out bsrcreg,AL

    mov CL,00h
il1:cmp CL,01h ; infinite loop, waiting for ISR to set CL to 1
    jne il1

    mov AL,07h ; 30% duty cycle
    out pwm,AL

    mov AL,00h
    out bsrcreg,AL

    mov AL,01h
    out bsrcreg,AL

    mov CL,00h
il2:cmp CL,01h ; infinite loop, waiting for ISR to set CL to 1
    jne il2

    mov AL,06h ; 40% duty cycle
    out pwm, AL

    pop cx
    pop ax
    ret
liftstar endp


; accelaration to 50%
accel50 proc near 
    push ax

    mov AL,05h ; 50% duty cycle
    out pwm, AL

    pop ax
    ret
accel50 endp


; decelaration routine from 50% to 20%
decel20 proc near 
    push ax
    push cx

    mov AL,06h ; 40%
    out pwm,AL

    mov AL,00h
    out bsrcreg,AL

    mov AL,01h
    out bsrcreg,AL

    mov CL,00h
il3:cmp CL,01h
    jne il3

    mov AL,07h ; 30%
    out pwm,AL

    mov AL,00h
    out bsrcreg,AL

    mov AL,01h
    out bsrcreg,AL

    mov CL,00h
il4:cmp CL,01h
    jne il4

    mov AL,08h ; 20%
    out pwm,AL

    pop cx
    pop ax
    ret 
decel20 endp

; finally stop from 20% to 0
liftstop proc near
    push ax

    mov AL,0ah
    out pwm,AL

    pop ax
    ret
liftstop endp


    ; storing variables in RAM
    db 1000 dup(0) ; randomly skipping 1000 memory locations so that variables are stored in RAM
    ; variables used
    liftMove db 0
    dest db 0
    secdest db 0
    dir db 0
    drState db 0
    current db 0
    

    
    		
    	


		
  











