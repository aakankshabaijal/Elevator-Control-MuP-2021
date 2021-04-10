;If user input is 76 then foreground is 6 which is brown and 7 is background which is white. All characters should blink. Use ‘.’ as the blocking function.
.model tiny
.486
.data
	fname db 'lab1file.txt', 0
	handle dw ?
	color1 db ?
	color2 db ?
	mx1 db 3
	data db 1 dup('$')
	color db ?
	cnt db 25

.code
.startup
	;input without echo
	mov ah, 08h
	int 21h
	
	mov color, 88h
	
	;and to get color
	and al, 0fh
	mov color1, al
	
	;input without echo
	mov ah, 08h
	int 21h
	
	;and to get color
	and al, 0fh
	mov color2, al
	
	mov al, color1
	or color, al
	
	mov cl,4h
	rol color2, cl
	
	mov al, color2
	or color, al
	
	
	;opening a file
	mov ah,3dh
	mov al, 02h
	lea dx, fname
	int 21h
	mov handle, ax
	
	;moving the file pointer 00 times
	mov ah, 42h
	mov al, 00h
	mov bx, handle
	mov cx, 00h
	mov dx, 00
	int 21h
	
	;read from file into data
	mov ah, 3fh
	mov bx, handle
	mov cx, 01h
	lea dx, data
	int 21h
	
	;closing the file
	mov ah, 3eh
	mov bx, handle
	int 21h
	
	;set display mode to text
	mov ah, 00h
	mov al, 03h
	int 10h
	
	lea si, data ;load data for typing
	
	mov cl, 00
	
	mov dh, 00h
	
x3:	mov ah, 02h
	mov dl, 0
	
	mov bh, 00h
	int 10h
	
	;write character
	mov ah, 09h
	mov al,[si]
	mov bh, 00h
	mov bl, color
	mov cx, 80
	int 10h
	
	inc dh
	dec cnt
	jnz x3
	
	
	mov ah, 07h
	x1: int 21h
	cmp al, ')'
	jnz x1
	
.exit
end
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	