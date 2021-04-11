; sub program when coarse_sensor1 is pressed
coarse_sensor1:
    push ax
    push bx
    mov al,direction
    mov ah,currentFloor
    mov bl,destFloor
    cmp dir,01
    jnz direction_up
    call accel50
    pop bx
    pop ax
    iret

direction_up:
    inc ah
    cmp ah,bl
    jnz direction_up
    call decel20
    pop bx
    pop ax
    iret


    
