; ISR when fine sensor is encountered
fs_isr: 
    push ax
    push bx
    mov al, 01100100b ; ocw 2 specific EOI for IR4
    out intloc1, al
    mov al, liftMove
    mov ah, currentFloor
    mov bl, destFloor
    mov bh, direction
    cmp al, 01h
    jnz not_moving
    cmp bh, 00h
    jnz dir_up
    dec ah
    mov currentFloor, ah

dir_up:
    inc ah
    mov currentFloor, ah
    call liftstar

    cmp ah, bl
    jnz not_on_dest_floor
    call decel20
    call led_disp
    mov liftMove, 00h
    mov doorClose, 00h
    pop bx
    pop ax
    iret

not_moving:
    mov currentFloor, 00h
    pop bx
    pop ax
    iret

not_on_dest_floor: 
    pop bx
    pop ax
    iret
