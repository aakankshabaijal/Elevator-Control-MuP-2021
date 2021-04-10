;The character entered by user is compared against the 20th character (counting from 0) in file compre1.txt.
.model tiny
.486
.data
	fname db 'lab1file.txt', 0
	handle dw ?
	color db ?
	mx1 db 3
	data db 1 dup('$')
	cnt db 25
	color db 00001010b

.code
.startup
	;input without echo
	mov ah, 08h
	int 21h
	
	
	
	;opening a file
	mov ah,3dh
	mov al, 02h
	lea dx, fname
	int 21h
	mov handle, ax
	
	;moving the file pointer 20 times
	mov ah, 42h
	mov al, 00h
	mov bx, handle
	mov cx, 00h
	mov dx, 20
	int 21h
	
	;read from file into data
	mov ah, 3fh
	mov bx, handle
	mov cx, 03h
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
	
	mov dh, 00
	
x2:	;set cursor position
	mov ah, 02h
	mov dl, 00h
	mov bh, 00h
	int 10h
	
	;write character
	mov ah, 09h
	mov al,[si]
	mov bh, 00h
	mov bl, color
	mov cx, 80h
	int 10h
	
	inc dh
	dec cnt
	jnz x2
	
	
	mov ah, 07h
	x1: int 21h
	cmp al, ','
	jnz x1
	
.exit
end
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	