;Display the second character of the file compre2.txt on two rows at the top of the screen.
.model tiny
.486
.data
	fname db 'lab1file.txt', 0
	handle dw ?
	mx1 db 3
	data db 2 dup('$')
	cnt db 25
	color1 db ?
	color2 db ?
	char db ?
	
	char2 db ?

.code
.startup
	;input without echo
	mov ah, 08h
	int 21h
	and al, 0fh
	mov color1, al
	
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
	mov dx, 00
	int 21h
	
	;read from file into data
	mov ah, 3fh
	mov bx, handle
	mov cx, 02h
	lea dx, data
	int 21h
	
	;closing the file
	mov ah, 3eh
	mov bx, handle
	int 21h
	
	;set display mode to text
	mov ah, 00h
	mov al, 02h
	int 10h
	
	
	lea si, data
	
	mov al, [si]
	and al, 0fh
	mov color2, al
	
	inc si
	mov al, [si]
	mov char, al
	
	lea si, char
	
	mov dh, 00
	;set cursor position
	mov ah, 02h
	mov dl, 00h
	mov bh, 00h
	int 10h
	
	
	;write character
	mov ah, 09h
	mov al,[si]
	mov bh, 00h
	mov bl, color1
	mov cx, 80
	int 10h
	
	inc dh
	
	;set cursor position
	mov ah, 02h
	mov dl, 00h
	mov bh, 00h
	int 10h
	
	
	;write character
	mov ah, 09h
	mov al,[si]
	mov bh, 00h
	mov bl, color2
	mov cx, 80
	int 10h
	
	
	
	
	mov ah, 07h
	x1: int 21h
	cmp al, ','
	jnz x1
	
.exit
end
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	