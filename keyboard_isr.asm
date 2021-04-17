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

    

