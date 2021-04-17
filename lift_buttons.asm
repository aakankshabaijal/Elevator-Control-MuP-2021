; subroutine when lift0 is pressed
lift0 proc near
    push ax
    cmp currentFloor, 0
    jz a1
    mov destFloor, 0
    mov direction, 0
    mov liftMove, 1
    call liftstar
    mov doorState, 1

    ; check if lift is moving or not
a2: cmp liftMove, 1
    jz a2

    ; secdest = 0 OR secdest = dest
a1: mov ah, 0
    mov al, secDest
    cmp secDest, 0
    jz a3
    inc ah
    cmp al, destFloor
    jz a3
    inc ah
    cmp ah, 0
    jge a4

    ; secdest > dest
a4: mov al, secDest
    cmp al, destFloor
    jg a5
    mov destFloor, al
    mov direction, 0
    mov liftMove, 1
    call liftstar
    mov doorState, 1
    jmp a6

a5: mov destFloor, al
    mov direction, 1
    mov liftMove, 1
    call liftstar
    mov doorState, 1

a6: cmp, liftMove, 1
    jz a6

a3: mov destFloor, 0
    mov direction, 0
    mov liftMove, 1
    call liftstar
    mov doorState, 1
    pop ax
    ret
lift0 endp


; subroutine when lift1 is pressed
lift1 proc near
    push ax
    cmp currentFloor, 1
    jz b1

    ; check if current floor = 0
    cmp currentFloor, 0
    jz b2
    mov destFloor, 1
    mov direction, 0
    mov liftMove, 1
    call liftstar
    mov doorState, 1
    jmp b3

b2: mov destFloor, 1
    mov direction, 1
    mov liftMove, 1
    call liftstar
    mov doorState, 1

    ; check if lift is moving or not
b3: cmp liftMove, 1
    jz b3

    ; secdest = 0 OR secdest = dest
b1: mov ah, 0
    mov al, secDest
    cmp secDest, 0
    jz b4
    inc ah
    cmp al, destFloor
    jz b4
    inc ah
    cmp ah, 0
    jge b5

    ; secdest > dest
b5: mov al, secDest
    cmp al, destFloor
    jg b6
    mov destFloor, al
    mov direction, 0
    mov liftMove, 1
    call liftstar
    mov doorState, 1
    jmp b7

b6: mov destFloor, al
    mov direction, 1
    mov liftMove, 1
    call liftstar
    mov doorState, 1

b7: cmp, liftMove, 1
    jz b7

b4: mov destFloor, 0
    mov direction, 0
    mov liftMove, 1
    call liftstar
    mov doorState, 1
    pop ax
    ret
lift1 endp


; subroutine when lift2 is pressed
lift2 proc near
    push ax
    cmp currentFloor, 2
    jz c1

    ; check if current floor = 3
    cmp currentFloor, 3
    jz c2
    mov destFloor, 2
    mov direction, 1
    mov liftMove, 1
    call liftstar
    mov doorState, 1
    jmp c3

c2: mov destFloor, 2
    mov direction, 0
    mov liftMove, 1
    call liftstar
    mov doorState, 1

    ; check if lift is moving or not
c3: cmp liftMove, 1
    jz c3

    ; secdest = 0 OR secdest = dest
c1: mov ah, 0
    mov al, secDest
    cmp secDest, 0
    jz c4
    inc ah
    cmp al, destFloor
    jz c4
    inc ah
    cmp ah, 0
    jge c5

    ; secdest > dest
c5: mov al, secDest
    cmp al, destFloor
    jg c6
    mov destFloor, al
    mov direction, 0
    mov liftMove, 1
    call liftstar
    mov doorState, 1
    jmp c7

c6: mov destFloor, al
    mov direction, 1
    mov liftMove, 1
    call liftstar
    mov doorState, 1

c7: cmp, liftMove, 1
    jz c7

c4: mov destFloor, 0
    mov direction, 0
    mov liftMove, 1
    call liftstar
    mov doorState, 1
    pop ax
    ret
lift2 endp


; subroutine when lift3 is pressed
lift3 proc near
    push ax
    cmp currentFloor, 3
    jz d1
    mov destFloor, 3
    mov direction, 1
    mov liftMove, 1
    call liftstar
    mov doorState, 1

    ; check if lift is moving or not
d2: cmp liftMove, 1
    jz d2

    ; secdest = 0 OR secdest = dest
d1: mov ah, 0
    mov al, secDest
    cmp secDest, 0
    jz d3
    inc ah
    cmp al, destFloor
    jz d3
    inc ah
    cmp ah, 0
    jge d4

    ; secdest > dest
d4: mov al, secDest
    cmp al, destFloor
    jg d5
    mov destFloor, al
    mov direction, 0
    mov liftMove, 1
    call liftstar
    mov doorState, 1
    jmp d6

d5: mov destFloor, al
    mov direction, 1
    mov liftMove, 1
    call liftstar
    mov doorState, 1

d6: cmp, liftMove, 1
    jz d6

d3: mov destFloor, 0
    mov direction, 0
    mov liftMove, 1
    call liftstar
    mov doorState, 1
    pop ax
    ret
lift3 endp


; subroutine when doorClose is called
doorClose proc near
    mov doorState, 1
doorClose endp
