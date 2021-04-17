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
    nop
    db 28 dup(0)

    ; int 08h for 1 shot timer 
    dw os_isr
    dw 0

    ; int 09h for keyboard  
    dw key_isr
    dw 0

    ; int 10h for Coarse Sensor 2
    dw cs2_isr
    dw 0

    ; int 11h for Coarse Sensor 1
    dw cs1_isr 
    dw 0

    ; int 12h for Fine Sensor
    dw fs_isr
    dw 0

    ; int 13h to int 255h not used
    db 972 dup(0)

st1: cli
    ;rom1 : 00000 - 00fff
    ;ram1 : 01000 - 01fff
    ;rom2 : ff000 - fffff 

    ; intialize ds, es, ss to start of RAM
    mov ax,0100h
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov sp,01ffeH

    porta equ 0b0h
    portb equ 0b2h
    portc equ 0b4h
    portcreg equ 0b6h

    conv25 equ 80h
    conv10 equ 82h
    pwm equ 84h
    convcreg equ 86h

    ostimer equ 90h
    oscreg equ 96h

    intloc1 equ 0A0h
    intloc2 equ 0A2h

		bsrportc equ 0c4h
    bsrcreg equ 0c6h

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

    ; first timer (chip 2) mode 1; write 8 bits value 01h
    mov AL,00001000b
    out oscreg,AL
    mov AL,01h
    out ostimer,AL
    
    ; initializing 8255
    ; port A output from 8255; for showing current floor value in LED
    ; port B output from 8255; for showing destination floor value in LED
    ; port C upper output; for keyboard columns
    ; port C lower input; for keyboard rows
    mov AL,10000001b
    out portcreg,AL
    mov AL,00h
    out portb,AL ; display zero on the LED, at the start
    out porta,AL ; display zero on the LED, at the start

    ; initialising 8255
    ; port C output from 8255; for giving input signals to motor, lift door and one shot timer
    mov AL,10010010b
    out bsrcreg, AL

    ; initializing 8259
    ; IR0 = for generating 100 ms one shot timer
    ; IR1 = for keyboard interrupt
    ; IR2 = for Coarse Sensor 1 (CS1)
    ; IR3 = for Coarse Sensor 2 (CS2)
    ; IR4 = for Fine Sensor (FS)
    mov AL,00010011b ; icw 1
    out intloc1,AL
    mov AL,00001000b ; icw 2
    out intloc2,AL
    mov AL,00000001b ; icw 4
    out intloc2,AL
    mov AL,11111100b ; ocw 1
    out intloc2,AL
    
infiloop: jmp infiloop
    
    ; asli kaam
    key_isr:
    		
    	


		
  











