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

; not writing the debounce logic assuming that the button press is genuine

.data

table_k db 0eeh, 0edh, 0ebh, 0e7h, 0deh, 0ddh, 0dbh, 0d7h, 0beh, 0bdh, 0bbh, 0b7h, 7eh, 7dh

btn_press db ?

.code 
.startup
    mov al, 10011000b
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
    or al, bl
    mov cx, 0dh ; setting cx = 0014d so that we can loop through all 14 elements of table_k
    mov di, 00h
    ;find out which element of table_k match with al
x3: cmp al, table_k[di]
    jz x2
    inc di
    loop x3

x2: mov btn_press, al




    

    