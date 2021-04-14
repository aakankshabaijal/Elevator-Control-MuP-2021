; LED display logic
led_disp proc near
    push ax
    push cx
    mov al, currentFloor
    mov ah, destFloor
    mov cl, 04
    ror ah, cl
    or al, ah
    out portb, al
    pop cx
    pop ax
    ret
led_disp endp