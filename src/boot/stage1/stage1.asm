bits 16
org 0x7c00
cli

global _start

_start:
	mov bx, msg
	call print
	jmp load_stage_2

print:
	pusha
print_loop:
	mov ah, 0xe
	mov al, [bx]
	int 0x10
	inc bx
	cmp byte [bx], 0
	jne print_loop
	jmp finish_print
finish_print:			
	mov ah, 0x0e
	mov al, 0x0a		; newline character
	int 0x10
	mov ah, 0x0e
	mov al, 0xd		; carriage return
	int 0x10
	popa
	ret

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
	db "Booting StormOS...", 0


num_sectors:
	db 0x0040
start_sector:
	db 0x0002


times 510 - ($ - $$) db 0

dw 0xAA55
