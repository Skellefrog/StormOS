bits 16
org 0x7e00

global _start

_start:
	xor ah, ah
	mov al, ah
	mov bh, ah
	mov bl, ah
	mov si, 0
	jmp print


print:
	mov ah, 0x0e
	mov al, [msg + si]
	int 0x10
	add si, 1
	cmp byte [msg + si], 0
	jne print

jmp $

msg:
	db "Second stage loaded.", 0
