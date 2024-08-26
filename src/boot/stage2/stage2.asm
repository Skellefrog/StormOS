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
	jmp load_gdt

gdt_desc:
	dw gdt_end - gdt - 1	; For limit storage
     	dd gdt			; For base storage

CODE_SEG equ gdt_kernel_code - gdt
DATA_SEG equ gdt_kernel_data - gdt
	
load_gdt:
	cli
	xor ax, ax		; eax is 0
	mov ds, ax
	lgdt [gdt_desc]		; load gdt data into gdt register

	jmp gdt_loaded

gdt_loaded:
	mov bx, gdt_loaded_msg
	call print
	mov ah, 0
	int 0x10
	jmp protected_mode

protected_mode:
	mov eax, cr0
	or eax, 1
	mov cr0, eax
	jmp CODE_SEG:reload_segments

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

msg1:
	db "Second stage loaded.", 0

enable_a20_start_msg:
	db "Enabling A20 Line...", 0
a20_disabled_msg:
	db "A20 Line disabled.", 0
a20_enabled_msg:
	db "A20 Line enabled.", 0
protected_mode_entered_msg:
	db "Entered protected mode.", 0
gdt_loaded_msg:
	db "GDT loaded.", 0


gdt:
gdt_null:
	times 0x08 db 0		; Null Descriptor
gdt_kernel_code:
	db 0xFF, 0xFF		; Limit lower 16 bits (0-15)
	db 0x00, 0x00		; Base lower 16 bits (15-31)
	db 0x00			; Base middle 8 bits (32-39)
	db 0x9A			; Access Byte, 0b10011010 (40-47)
	db 0xCF			; Flag bits and limit higher 4 bits (48-55)
	db 0x00			; Base higher 8 bits (56-63)
gdt_kernel_data:
	db 0xFF, 0xFF		; Limit lower 16 bits (0-15)
	db 0x00, 0x00		; Base lower 16 bits (15-31)
	db 0x00			; Base middle 8 bits (32-39)
	db 0x92			; Access Byte, 0b10010010 (40-47)
	db 0xCF			; Flag bits and limit higher 4 bits (48-55)
	db 0x00			; Base higher 8 bits (56-63)
gdt_user_code:
	db 0xFF, 0xFF		; Limit lower 16 bits (0-15)
	db 0x00, 0x00		; Base lower 16 bits (15-31)
	db 0x00			; Base middle 8 bits (32-39)
	db 0xFA			; Access Byte, 0b11111010 (40-47)
	db 0xCF			; Flag bits and limit higher 4 bits (48-55)
	db 0x00			; Base higher 8 bits (56-63)
gdt_user_data:
	db 0xFF, 0xFF		; Limit lower 16 bits (0-15)
	db 0x00, 0x00		; Base lower 16 bits (15-31)
	db 0x00			; Base middle 8 bits (32-39)
	db 0xF2			; Access Byte, 0b11110010 (40-47)
	db 0xCF			; Flag bits and limit higher 4 bits (48-55)
	db 0x00			; Base higher 8 bits (56-63)
gdt_task_segment:
	db 0x00, 0x6E		; Limit lower 16 bits (0-15)
	db 0xFE, 0x00		; Base lower 16 bits (15-31)
	db 0x00			; Base middle 8 bits (32-39)
	db 0x89			; Access Byte, 0b11110010 (40-47)
	db 0x00			; Flag bits and limit higher 4 bits (48-55)
	db 0x00			; Base higher 8 bits (56-63)
gdt_end:

[bits 32]
reload_segments:
	jmp 0x08:.reload	; 0x08 is the kernel code segment
.reload:
	mov al, 'S'
	mov ah, 0x1f
	mov [0xb8000], ax
	mov al, 'T'
	mov ah, 0x1f
	mov [0xb8002], ax
	mov al, 'O'
	mov ah, 0x1f
	mov [0xb8004], ax
	mov al, 'R'
	mov ah, 0x1f
	mov [0xb8006], ax
	mov al, 'M'
	mov ah, 0x1f
	mov [0xb8008], ax
	mov al, 'O'
	mov ah, 0x1f
	mov [0xb800a], ax
	mov al, 'S'
	mov ah, 0x1f
	mov [0xb800c], ax
	mov al, ' '
	mov ah, 0x1f
	mov [0xb800e], ax
	mov al, 'B'
	mov ah, 0x1f
	mov [0xb8010], ax
	mov al, 'O'
	mov ah, 0x1f
	mov [0xb8012], ax
	mov al, 'O'
	mov ah, 0x1f
	mov [0xb8014], ax
	mov al, 'T'
	mov ah, 0x1f
	mov [0xb8016], ax
	mov al, 'E'
	mov ah, 0x1f
	mov [0xb8018], ax
	mov al, 'D'
	mov ah, 0x1f
	mov [0xb801a], ax
	jmp finish

finish:
	jmp $
