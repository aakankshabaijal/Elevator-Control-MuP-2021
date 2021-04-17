; isr when coarse sensor 2 is encountered
coarse_sensor2:
    push ax
    push bx
    mov al, 01100011b ; ocw 2 specific EOI for IR3
    out intloc1, al
    mov al, direction
    mov ah, currentFloor
    mov bl, destFloor
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

