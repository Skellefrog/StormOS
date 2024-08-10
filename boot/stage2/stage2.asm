bits 16
org 0x7e00

global _start

_start:
	xor ah, ah
	mov al, ah
	mov bh, ah
	mov bl, ah

	mov bx, msg1

	call print

	jmp finish
print:
	mov si, 0
print_loop:
	mov ah, 0x0e
	mov al, [bx + si]
	int 0x10
	add si, 1
	cmp byte [bx + si], 0
	jne print_loop
	ret

finish:
	jmp $

msg1:
	db "Second stage loaded.", 0
