; 8255 chip base address is 70h
; first 8253 chip base address is 80h; converts 2.5MHz to 100Hz and 10Hz, and also for PWM
; second 8253 chip base address is 90h; used as one shot timer
; first 8259 chip base address is A0h

porta equ 70h
portb equ 72h
portc equ 74h
portcreg equ 76h

conv25 equ 80h
conv10 equ 82h
pwm equ 84h
convcreg equ 86h

ostimer equ 90h
oscreg equ 96h

intloc1 equ 0A0h
intloc2 equ 0A2h

; initializing timers
; first timer (chip 1) mode 3; write 16 bit value 61a8h; converts 2.5MHz into 100Hz
mov AL,00110110b
out convcreg,AL
mov AL,0a8h
out conv25,AL
mov AL,61h
out conv25,AL

; second timer (chip 1) mode 3; write 8 bit value 0ah; converts 100Hz to 10Hz
mov AL,01010110b
out convcreg,AL
mov AL,0ah
out conv10,AL

; third timer (chip 1) mode 1; used for PWM
mov AL,10010010b
out convcreg,AL
mov AL,0ah ; put a value of 10 so that motor is not running at the start
out pwm,AL

; first timer (chip 2) mode 1; used as one shot timer for delays
; the clock for first timer is 10Hz, so that with a count of 1, we get a delay of 100ms
mov AL,00010010b
out oscreg,AL
mov AL,01h
out ostimer,AL


; initializing 8255
; port A output from 8255; for triggering one shot timer
; port B output from 8255; for LED Display
; port C upper output; for keyboard columns
; port C lower input; for keyboard rows
mov AL,10000001b
out portcreg,AL
mov AL,00h
out portb,AL ; display zero on the LED, at the start


; initializing 8259
; IR0 = for generating 100 ms one shot timer
; IR1 = for keyboard interrupt
; IR2 = for Coarse Sensor 1 (CS1)
; IR3 = for Coarse Sensor 2 (CS2)
; IR4 = for Fine Sensor (FS)
mov AL,00010011b ; icw 1
out intloc1,AL
mov AL,00000000b ; icw 2; Pending decision on first 5 bits of vector number
out intloc2,AL
mov AL,00000001b ; icw 4
out intloc2,AL
mov AL,11111100b ; ocw 1
out intloc2,AL

; ISR for one shot timer
os_isr:
    mov AL,01100000b ; ocw 2 specific EOI for IR0
    out intloc1,AL
    mov CL,01h
    iret

; start and accelaration routine 20% to 40%
liftstar proc near
    mov AL,08h ; for 20% duty cycle
    out pwm,AL
    mov AL,00h ; first give a low on port A
    out porta,AL
    mov AL,01h ; then give a high on port A to trigger one shot timer
    out porta,AL
    mov CL,00h
il1:cmp CL,01h ; infinite loop, waiting for ISR to set CL to 1
    jne il1
    mov AL,07h ; 30% duty cycle
    out pwm,AL
    mov AL,00h
    out porta,AL
    mov AL,01h
    out porta,AL
    mov CL,00h
il2:cmp CL,01h ; infinite loop, waiting for ISR to set CL to 1
    jne il2
    mov AL,06h ; 40% duty cycle
    out pwn,AL
    ret
liftstar endp


accel50 proc near ; accelaration to 50%
    mov AL,05h ; 50% duty cycle
    out pwn,AL
    ret
accel50 endp

decel20 proc near ; decelaration routine from 50% to 20%
    mov AL,06h ; 40%
    out pwm,AL
    mov AL,00h
    out porta,AL
    mov AL,01h
    out porta,AL
    mov CL,00h
il3:cmp CL,01h
    jne il3
    mov AL,07h ; 30%
    out pwm,AL
    mov AL,00h
    out porta,AL
    mov AL,01h
    out porta,AL
    mov CL,00h
il4:cmp CL,01h
    jne il4
    mov AL,08h ; 20%
    out pwm,AL
    ret 
decel endp

; finally stop from 20% to 0
liftstop proc near
    mov AL,0ah
    out pwm,AL
liftstop endp