bits 16
org 0x7e00
cli

global _start

_start:
	xor ah, ah
	mov al, ah
	mov bh, ah
	mov bl, ah

	mov bx, msg1

	call print

	mov bx, enable_a20_start_msg
	call print

	call check_a20
	cmp ax, 0
	je a20_check_failed

	jmp enable_a20

a20_check_failed:
	mov bx, a20_disabled_msg
	call print
	jmp enable_a20

check_a20:
	pushf
	push ds
	push es
	push di
	push si

	xor ax, ax
	not ax		; ax = FFFF
	mov ds, ax
	mov si, 0x7DfE	; end of bootsector with magic bytes

	mov eax, 0xAA55	; magic number at end of bootsector
	cmp eax, [ds:si]
	je a20_disabled
	jmp a20_enabled
a20_disabled:
	mov ax, 0
	jmp check_a20_exit
a20_enabled:
	mov ax, 1
	jmp check_a20_exit
check_a20_exit:
	pop si
	pop di
	pop es
	pop ds
	popf

	ret


enable_a20:
	in al, 0x92
	or al, 2
	out 0x92, al

	call check_a20
	
	cmp ax, 0
	jne a20_check_passed
	jmp finish
a20_check_passed:
	mov bx, a20_enabled_msg
	call print
	jmp finish


reload_segments:
	jmp 08h:.reload	; 0x08 is the kernel code segment
.reload:
	mov bx, msg1
	call print

	mov ax, 0x10		; 0x10 is the kernel data segment
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	ret

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

finish:
	jmp $

msg1:
	db "Second stage loaded.", 0

enable_a20_start_msg:
	db "Enabling A20 Line...", 0
a20_disabled_msg:
	db "A20 Line disabled.", 0
a20_enabled_msg:
	db "A20 Line enabled.", 0
