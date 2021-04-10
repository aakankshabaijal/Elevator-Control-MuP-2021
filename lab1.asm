.model tiny
.486
.data
	fname db 'lab1file.txt', 0
	handle dw ?
	color db ?
	mx1 db 3
	data db 3 dup('$')

.code
.startup
	;input without echo
	mov ah, 01h
	int 21h
	
	;and to get color
	and al, 0fh
	mov color, al
	
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
	
	;set cursor position
	mov ah, 02h
	mov dl, 00h
	mov dh, 11h
	mov bh, 00h
	int 10h
	
	;write character
	mov ah, 09h
	mov al,[si]
	mov bh, 00h
	mov bl, color
	mov cx, 80h
	int 10h
	
	inc si
	
	;set cursor position
	mov ah, 02h
	mov dl, 00h
	mov dh, 11h
	mov bh, 00h
	int 10h
	
	;write character
	mov ah, 09h
	mov al,[si]
	mov bh, 00h
	mov bl, color
	mov cx, 80h
	int 10h
	
	inc si
	
	;set cursor position
	mov ah, 02h
	mov dl, 00h
	mov dh, 11h
	mov bh, 00h
	int 10h
	
	;write character
	mov ah, 09h
	mov al,[si]
	mov bh, 00h
	mov bl, color
	mov cx, 80h
	int 10h
	
	mov ah, 07h
	x1: int 21h
	cmp al, ')'
	jnz x1
	
.exit
end
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	