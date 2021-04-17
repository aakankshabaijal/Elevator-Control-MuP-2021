up0 proc near
    push ax
    push bx
    mov al, currentFloor
    mov ah, liftMove
    mov bl, doorState
    cmp al,00
    jnz y2
    cmp ah,00
    jnz y2
    
y1:    
    mov doorState, 00h
    pop bx
    pop ax
    ret

y2:
    cmp ah,00
    jnz y2
    cmp al,00
    jz y1
    mov destFloor,00
    mov direction,00
    mov doorState,01
    mov liftMove,01
    call liftstar
    pop bx
    pop ax
    ret
up0 endp


down1 proc near
    push ax
    push bx
    push cx
    mov al, currentFloor
    mov ah, liftMove
    mov bl, doorState
    mov bh,direction
    cmp al,01
    jnz y3
    cmp ah,01
    jnz y4

y5: cmp ah,01
    jz y5

y11:
    mov destFloor,01
    mov doorState,01
    mov liftMove,01
    cmp ah,00
    jnz y12
    mov direction,01
    call liftstar
    pop cx
    pop bx
    pop ax
    ret

y12:
    mov direction,00
    call liftstar
    pop cx
    pop bx
    pop ax
    ret

y4:
    mov doorState,00
    pop cx
    pop bx
    pop ax
    ret
    
y3: 
    cmp ah,01
    jnz y6
    cmp bh,0
    jnz y7
    cmp al,2
    jnz y8

y9:
    mov cl,destFloor
    mov secdest,cl
    mov destFloor,1

y8:
    mov cl,destFloor
    cmp cl,02
    jnz y9

y10:
    cmp ah,00
    jnz y10
    mov destFloor,01
    mov doorState,01
    mov direction,00
    mov liftMove,01
    call liftstar
    pop cx
    pop bx
    pop ax
    ret

y7:
    cmp ah,00
    jnz y7
    jmp y6

y6:
    cmp al,01
    jnz y11
    mov doorState,00
    pop cx
    pop bx
    pop ax
    ret
down1 endp


up2 proc near
    push ax
    push bx
    push cx
    mov al, currentFloor
    mov ah, liftMove
    mov bl, doorState
    mov bh,direction
    cmp al,02
    jnz up2y3
    cmp ah,01
    jnz up2y4

up2y5: cmp ah,01
    jz up2y5

up2y11:
    mov destFloor,02
    mov doorState,01
    mov liftMove,01
    cmp ah,03
    jnz up2y12
    mov direction,00
    call liftstar
    pop cx
    pop bx
    pop ax
    ret

up2y12:
    mov direction,01
    call liftstar
    pop cx
    pop bx
    pop ax
    ret

up2y4:
    mov doorState,00
    pop cx
    pop bx
    pop ax
    ret
    
up2y3: 
    cmp ah,01
    jnz up2y6
    cmp bh,1
    jnz up2y7
    cmp al,1
    jnz up2y8

up2y9:
    mov cl,destFloor
    mov secdest,cl
    mov destFloor,2

up2y8:
    mov cl,destFloor
    cmp cl,01
    jnz up2y9

up2y10:
    cmp ah,00
    jnz up2y10
    mov destFloor,02
    mov doorState,01
    mov direction,01
    mov liftMove,01
    call liftstar
    pop cx
    pop bx
    pop ax
    ret

up2y7:
    cmp ah,00
    jnz up2y7
    jmp up2y6

up2y6:
    cmp al,02
    jnz up2y11
    mov doorState,00
    pop cx
    pop bx
    pop ax
    ret
up2 endp


up1 proc near
    push ax
    push bx
    push cx
    mov al, currentFloor
    mov ah, liftMove
    mov bl, doorState
    mov bh,direction
    cmp al,01
    jnz up1y3
    cmp ah,01
    jnz up1y4

up1y5: cmp ah,01
    jz up1y5

up1y11:
    mov destFloor,01
    mov doorState,01
    mov liftMove,01
    cmp ah,00
    jnz up1y12
    mov direction,01
    call liftstar
    pop cx
    pop bx
    pop ax
    ret

up1y12:
    mov direction,00
    call liftstar
    pop cx
    pop bx
    pop ax
    ret

up1y4:
    mov doorState,00
    pop cx
    pop bx
    pop ax
    ret
    
up1y3: 
    cmp ah,01
    jnz up1y6
    cmp bh,1
    jnz up1y7

up1y9:
    mov cl,destFloor
    mov secdest,cl
    mov destFloor,1
    pop cx
    pop bx
    pop ax
    ret

up1y7:
    cmp ah,00
    jnz up1y7
    jmp up1y6

up1y6:
    cmp al,01
    jnz up1y11
    mov doorState,00
    pop cx
    pop bx
    pop ax
    ret
up1 endp


down3 proc near
    push ax
    push bx
    mov al, currentFloor
    mov ah, liftMove
    mov bl, doorState
    cmp al,03
    jnz dn3y2
    cmp ah,00
    jnz dn3y2

dn3y1:    
    mov doorState, 00h
    pop bx
    pop ax
    ret

dn3y2:
    cmp ah,00
    jnz dn3y2
    cmp al,03
    jz dn3y1
    mov destFloor,00
    mov direction,00
    mov doorState,01
    mov liftMove,01
    call liftstar
    pop bx
    pop ax
    ret
down3 endp

down2 proc near
    push ax
    push bx
    push cx
    mov al, currentFloor
    mov ah, liftMove
    mov bl, doorState
    mov bh,direction
    cmp al,02
    jnz dn2y3
    cmp ah,01
    jnz dn2y4

dn2y5: cmp ah,01
    jz dn2y5

dn2y11:
    mov destFloor,01
    mov doorState,01
    mov liftMove,01
    cmp ah,03
    jnz dn2y12
    mov direction,00
    call liftstar
    pop cx
    pop bx
    pop ax
    ret

dn2y12:
    mov direction,01
    call liftstar
    pop cx
    pop bx
    pop ax
    ret

dn2y4:
    mov doorState,00
    pop cx
    pop bx
    pop ax
    ret
    
dn2y3: 
    cmp ah,01
    jnz dn2y6
    cmp bh,1
    jnz dn2y7

dn2y9:
    mov cl,destFloor
    mov secdest,cl
    mov destFloor,1
    pop cx
    pop bx
    pop ax
    ret

dn2y7:
    cmp ah,00
    jnz dn2y7
    jmp dn2y6

dn2y6:
    cmp al,02
    jnz dn2y11
    mov doorState,00
    pop cx
    pop bx
    pop ax
    ret
down2 endp

