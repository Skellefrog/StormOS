bits 16
org 0x7c00

global _start

_start:
	jmp print_welcome

mov si, 0

print_welcome:
	mov ah, 0x0e
	mov al, [msg + si]
	int 0x10
	add si, 1
	cmp byte [msg + si], 0
	jne print_welcome
	jmp load_stage_2

load_stage_2:
	mov ah, 0x02
	mov al, [num_sectors]
	mov ch, 0 ; cylinder number 0
	mov cl, [start_sector]
	mov dh, 0 ; head number 0
	xor bx, bx
	mov es, bx ; es should be 0
	mov bx, 0x7e00 ; 512 bytes from origin address 0x7c00
	int 0x13
	jmp 0x7e00

msg:
	db "Welcome to StormOS!", 0x0a, 0xd, 0

num_sectors:
	db 0x0040
start_sector:
	db 0x0002

times 510 - ($ - $$) db 0

dw 0xAA55
