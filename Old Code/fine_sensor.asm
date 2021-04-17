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
    jnz f2
    cmp bh, 00h
    jnz f4
    dec ah
    mov currentFloor, ah
    cmp ah, bl
    jnz f1
    call decel20
    call led_disp
    mov liftMove, 00h
    mov doorClose, 00h
    pop bx
    pop ax
    iret

f4:
    inc ah
    mov currentFloor, ah

    cmp ah, bl
    jnz f1
    call decel20
    call led_disp
    mov liftMove, 00h
    mov doorClose, 00h
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
    mov currentFloor, ah
    pop bx
    pop ax
    iret
f3:
    inc ah
    mov currentFloor, ah
    pop bx
    pop ax
    iret
