; key00 => EEh == CLOSE DOOR
; key01 => EDh == COARSE SENSOR 1
; key02 => EBh == FINE SENSOR
; key03 => E7h == COARSE SENSOR 2
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

; PC0 to PC3 act as inputs of hex keypad (D0 of 8255 is 0)
; PC4 to PC7 act as outputs of hex keypad (D3 of 8255 is 1)
; PB0 to PB3 of first 8255 act as inputs to 7447 for LED display outside the lift
; PC0 to PC3 of second 8255 act as inputs to 7447 for LED display inside the lift

; base address of 8255 used is 00h

; base address of 8253 used is 80h

; not writing the debounce logic assuming that the button press is genuine

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

; table db 0eeh, 0edh, 0ebh, 0e7h, 0deh, 0ddh, 0dbh, 0d7h, 0beh, 0bdh, 0bbh, 0b7h, 7eh, 7dh

liftMove db 0
floorNum db 0
direction db 0
doorState db 0

st1: 
    cli
    mov al, 10011000b ;writing into 8255 control word
    out 06h, al

    ; check for key press
    mov al, 00h
    out 04h, al
x1: in al, 04h
    and al, 0f0h
    cmp al, 0f0h
    jz x1

    ; check for key press in column 1
    mov al, 0eh
    mov bl, al
    out 04h, al
    in al, 04h
    and al, 0f0h
    cmp al, 0f0h
    jnz check_key

    ; check for key press in column 2
    mov al, 0dh
    mov bl, al
    out 04h, al
    in al, 04h
    and al, 0f0h
    cmp al, 0f0h
    jnz check_key

    ; check for key press in column 3
    mov al, 0bh
    mov bl, al
    out 04h, al
    in al, 04h
    and al, 0f0h
    cmp al, 0f0h
    jnz check_key

    ; check for key press in column 4
    mov al, 0bh
    mov bl, al
    out 04h, al
    in al, 04h
    and al, 0f0h
    cmp al, 0f0h
    jnz check_key

    ; find out which key was pressed from hex keypad
check_key: 
    or al, bl ; which key is pressed
    cmp al, 0eeh
    jnz x3
    call doorClose
    jmp check_key

x3: cmp al, 0edh
    jnz x4
    call coarseSensor
    jmp check_key

x4: cmp al, 0ebh
    jnz x5
    call fineSensor
    jmp check_key

x5: cmp al, 0e7h
    jnz x6
    call coarseSensor
    jmp check_key

x6: cmp al, 0deh
    jnz x7
    call up0
    jmp check_key

x7: cmp al, 0ddh
    jnz x8
    call down1
    jmp check_key

x8: cmp al, 0dbh
    jnz x9
    call up1
    jmp check_key

x9: cmp al, 0d7h
    jnz x10
    call down2
    jmp check_key

x10:cmp al, 0beh
    jnz x11
    call up2
    jmp check_key

x11:cmp al, 0bdh
    jnz x12
    call down3
    jmp check_key

x12:cmp al, 0bbh
    jnz x13
    call lift0
    jmp check_key

x13:cmp al, 0b7h
    jnz x14
    call lift1
    jmp check_key

x14:cmp al, 07eh
    jnz x15
    call lift2
    jmp check_key

x15:cmp al, 07dh
    jnz check_key
    call lift3
    jmp check_key


    
    
;     mov cx, 14 ; setting cx = 0014d so that we can loop through all 14 elements of table
;     mov di, 00h
;     ;find out which element of table match with al
; x3: cmp al, table[di]
;     jz x2
;     inc di
;     loop x3

; x2: cmp al, 0eeh
;     jz doorClose
;     cmp al, 0edh
;     jz 









;  D7  D6  D5  D4  D3  D2  D1  D0
;                               


    

    