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
destFloor db 0
secdest db 0
direction db 0
doorState db 0
currentFloor db 0

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
    jnz x2
    call doorClose
    jmp check_key

x2: cmp al, 0edh
    jnz x3
    call coarseSensor
    jmp check_key

x3: cmp al, 0ebh
    jnz x4
    call fineSensor;  change the fine sensor sub routine to manage if lift is stopped it should be on gnd floor
    jmp check_key

x4: cmp al, 0e7h
    jnz x5
    call coarseSensor
    jmp check_key

x5: cmp al, 0deh
    jnz x6
    call up0
    jmp check_key

x6: cmp al, 0ddh
    jnz x7
    call down1
    jmp check_key

x7: cmp al, 0dbh
    jnz x8
    call up1
    jmp check_key

x8: cmp al, 0d7h
    jnz x9
    call down2
    jmp check_key

x9:cmp al, 0beh
    jnz x10
    call up2
    jmp check_key

x10:cmp al, 0bdh
    jnz x11
    call down3
    jmp check_key

x11:cmp al, 0bbh
    jnz x12
    call lift0
    jmp check_key

x12:cmp al, 0b7h
    jnz x13
    call lift1
    jmp check_key

x13:cmp al, 07eh
    jnz x14
    call lift2
    jmp check_key

x14:cmp al, 07dh
    jnz check_key
    call lift3
    jmp check_key


; subroutine for up0
up0 proc near; corrected

    push ax
    push bx
    mov al, currentFloor
    mov ah, liftMove
    mov bl, doorState
    cmp al, 00h
    jnz lift_not_on_gnd_floor0
    cmp ah,00
    jnz lift_not_on_gnd_floor0
    mov doorState, 00h
    pop bx
    pop ax
    ret

lift_not_on_gnd_floor0:
    cmp ah, 01h
    jnz lift_not_moving
    cmp al,00
    jnz change_dest_to_0
    
    jmp lift_not_on_gnd_floor0

lift_not_moving0:
    cmp al,00
    jnz x25
    mov doorState, 00h
    pop bx
    pop ax
    ret
 x25:
    mov doorState, 01
    
door_closed0:
    mov destFloor, 00h
    mov direction, 00h 
    mov liftMove, 01h

    pop bx
    pop ax
    ret
up0 endp

; subroutine for down1 
down1 proc near 
    push ax
    push bx
    mov al, currentFloor
    mov ah, direction
    mov bl, liftMove
    cmp al, 01h
    jnz lift_not_on_first_floor_and_direction_down
    cmp ah, 00h
    jnz lift_not_on_first_floor_and_direction_down
    
x17:cmp bl, 00h
    jnz x17
    mov doorState, 00h
    pop bx
    pop ax
    ret

lift_not_on_first_floor_and_direction_down:
    cmp al, 03h
    jnz lift_not_on_third_floor1
    mov destFloor, 01h
    mov liftMove, 01h
    mov direction, 00h
    pop bx
    pop ax
    ret

lift_not_on_third_floor1:
    cmp al, 02h
    jnz lift_not_on_second_floor_and_direction_down1
    mov destFloor, 01h
    mov liftMove, 01h
    pop bx
    pop ax
    ret

lift_not_on_second_floor_and_direction_down1:
    mov currentFloor, 01h
    mov destFloor, 01h
    ; Save floor number 1 in memory, complete the ongoing journey and return to third floor

    pop bx
    pop ax
    ret
down1 endp

; subroutine for up1
up1 proc near
    push ax
    push bx
    mov al, currentFloor
    mov ah, direction
    mov bl, liftMove
    cmp al, 01h
    jnz lift_not_on_first_floor_and_direction_up1
    cmp ah, 01h
    jnz lift_not_on_first_floor_and_direction_up1

x18:cmp bl, 00h
    jnz x18
    mov doorState, 00h
    pop bx
    pop ax
    ret

lift_not_on_first_floor_and_direction_up1:
    cmp al, 00h
    jnz lift_not_on_gnd_floor1
    mov destFloor, 01h
    mov direction, 01h
    mov liftMove, 01h
    pop bx
    pop ax
    ret

lift_not_on_gnd_floor1:
    mov currentFloor, 01h
    mov destFloor, 01h
    ; Save floor number 1 in memory, complete the ongoing journey and return to ground floor

    pop bx
    pop ax
    ret
up1 endp

; subroutine for down2
down2 proc near
    push ax
    push bx
    mov al, currentFloor
    mov ah, direction
    mov bl, liftMove
    cmp al, 02h
    jnz lift_not_on_second_floor_and_direction_down2
    cmp ah, 01h
    jnz lift_not_on_second_floor_and_direction_down2

x19:cmp bl, 00h
    jnz x19
    mov doorState, 00h
    pop bx
    pop ax
    ret

 lift_not_on_second_floor_and_direction_down2:
    cmp al, 03h
    jnz lift_not_on_third_floor2
    mov destFloor, 02h
    mov direction, 00h
    mov liftMove, 01h
    pop bx
    pop ax
    ret

lift_not_on_third_floor2:
    mov currentFloor, 02h
    mov destFloor, 02h
    ; Save floor number 2 in memory, complete the ongoing journey and return to third floor

    pop bx
    pop ax
    ret
down2 endp

; subroutine for up2
up2 proc near
    push ax
    push bx
    mov al, currentFloor
    mov ah, direction
    mov bl, liftMove
    cmp al, 02h
    jnz lift_not_on_second_floor_and_direction_up
    cmp ah, 01h
    jnz lift_not_on_second_floor_and_direction_up

x20:cmp bl, 00h
    jnz x20
    mov doorState, 00h
    pop bx
    pop ax
    ret

lift_not_on_second_floor_and_direction_up:
    cmp al, 01h
    jnz lift_not_on_first_floor_and_direction_up2
    mov destFloor, 02h
    mov liftMove, 01h
    pop bx
    pop ax
    ret

lift_not_on_first_floor_and_direction_up2:
    cmp al, 00h
    jnz lift_not_on_gnd_floor2
    mov destFloor, 02h
    mov liftMove, 01h
    mov direction, 01h
    pop bx
    pop ax
    ret

lift_not_on_gnd_floor2:
    mov destFloor, 02h
    mov currentFloor, 02h
    ; Save floor number 2 in memory, complete the ongoing journey and return to ground floor

    pop bx
    pop ax
    ret
up endp

; subroutine for down3
down3 proc near
    push ax
    push bx
    mov al, currentFloor
    mov ah, liftMove
    mov bl, doorState
    cmp al, 03h
    jnz lift_not_on_third_floor3

    mov doorState, 00h
    mov direction, 00h
    mov liftMove, 01h
    pop bx
    pop ax
    ret

lift_not_on_third_floor3:
    cmp ah, 01h
    jnz lift_not_moving3
    jmp lift_not_third_floor3

lift_not_moving3:
    cmp bl, 01h
    jz door_closed3
    jmp lift_not_movin

door_closed3:
    mov destFloor, 03h
    mov direction, 01h 
    mov liftMove, 01h

    pop bx
    pop ax
    ret
down3 endp

;subroutine for 0 pressed inside lift
lift0 proc near
    push ax
    push bx

    mov al,currentFloor
    mov ah, liftMove
    mov bl, doorState
    cmp al,00h
    jnz not_on_0
    mov ah,00
    mov bl,00
    pop bx
    pop ax
    ret
not_on_0:
    cmp ah,00
    jnz not_on_0
    cmp bl,01
    jnz not_on_0
    mov destFloor,0
    mov direction,0
    mov doorState,1
    mov liftMove,01
    pop bx
    pop ax
    ret
lift0 endp

;subroutine for 1 pressed inside lift
lift1 proc near
    push bx 
    push ax
    mov al,currentFloor
    mov ah, liftMove
    mov bl, doorState
    cmp al,01
    jnz floor_0
    mov liftMove,00
    mov doorState,00
    pop bx
    pop ax
    ret

floor_0:

    cmp al,00
    jnz floor_either_2_or_3
    cmp ah,00
    jnz floor_0
    cmp bl,01
    jnz floor_0
    mov destfloor,1
    mov direction,1
    mov doorState,1
    mov liftMove,1
    pop bx
    pop ax
    ret

floor_either_2_or_3:
    cmp ah,00
    jnz floor_either_2_or_3
    cmp bl,01
    jnz floor_either_2_or_3
    mov destfloor,1
    mov direction,0
    mov doorState,1
    mov liftMove,1
    pop bx
    pop ax
    ret
lift1 endp

;subroutine for 2 pressed inside lift
lift2 proc near
    push bx 
    push ax
    mov al,currentFloor
    mov ah, liftMove
    mov bl, doorState
    cmp al,02
    jnz floor_3
    mov liftMove,00
    mov doorState,00
    pop bx
    pop ax
    ret

floor_3:
    cmp al,03
    jnz floor_either_0_or_1
    cmp ah,00
    jnz floor_3
    cmp bl,01
    jnz floor_3
    mov destfloor,2
    mov direction,0
    mov doorState,1
    mov liftMove,1
    pop bx
    pop ax
    ret

floor_either_0_or_1:
    cmp ah,00
    jnz floor_either_0_or_1
    cmp bl,01
    jnz floor_either_0_or_1
    mov destfloor,2
    mov direction,1
    mov doorState,1
    mov liftMove,1
    pop bx
    pop ax
    ret
lift2 endp

;subroutine for 3 pressed inside lift 
lift3 proc near
    push bx 
    push ax
    mov al,currentFloor
    mov ah, liftMove
    mov bl, doorState
    cmp al,03h
    jnz not_on_0
    mov ah,00
    mov bl,00
    pop bx
    pop ax
    ret
not_on_3:
    cmp ah,00
    jnz not_on_3
    cmp bl,01
    jnz not_on_3
    mov destFloor,3
    mov direction,1
    mov doorState,1
    mov liftMove,01

    pop bx
    pop ax
    ret
lift3 endp






















    






    

    