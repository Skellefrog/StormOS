bits 16
org 0x7c00
cli

global _start

_start:
	mov bx, msg
	call print
	jmp load_gdt

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

gdt_desc:
	db gdt_end - gdt	; For limit storage
     	dw gdt			; For base storage
	
load_gdt:
	xor ax, ax		; eax is 0
	mov ds, ax
	lgdt [gdt_desc]		; load gdt data into gdt register

	jmp gdt_loaded

gdt_loaded:
	mov bx, gdt_loaded_msg
	call print
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

gdt_loaded_msg:
	db "GDT loaded.", 0x0a, 0xd, 0

num_sectors:
	db 0x0040
start_sector:
	db 0x0002

gdt:
	times 0x08 db 0		; Null Descriptor
; GDT KERNEL CODE SEGMENT
	dw 0xFFFF		; Limit lower 16 bits (0-15)
	dw 0x0000		; Base lower 16 bits (15-31)
	db 0x00			; Base middle 8 bits (32-39)
	db 0x9A			; Access Byte, 0b10011010 (40-47)
	db 0xCF			; Flag bits and limit higher 4 bits (48-55)
	db 0x00			; Base higher 8 bits (56-63)
; GDT KERNEL DATA SEGMENT
	dw 0xFFFF		; Limit lower 16 bits (0-15)
	dw 0x0000		; Base lower 16 bits (15-31)
	db 0x00			; Base middle 8 bits (32-39)
	db 0x92			; Access Byte, 0b10010010 (40-47)
	db 0xCF			; Flag bits and limit higher 4 bits (48-55)
	db 0x00			; Base higher 8 bits (56-63)
; GDT USER CODE SEGMENT
	dw 0xFFFF		; Limit lower 16 bits (0-15)
	dw 0x0000		; Base lower 16 bits (15-31)
	db 0x00			; Base middle 8 bits (32-39)
	db 0xFA			; Access Byte, 0b11111010 (40-47)
	db 0xCF			; Flag bits and limit higher 4 bits (48-55)
	db 0x00			; Base higher 8 bits (56-63)
; GDT USER DATA SEGMENT
	dw 0xFFFF		; Limit lower 16 bits (0-15)
	dw 0x0000		; Base lower 16 bits (15-31)
	db 0x00			; Base middle 8 bits (32-39)
	db 0xF2			; Access Byte, 0b11110010 (40-47)
	db 0xCF			; Flag bits and limit higher 4 bits (48-55)
	db 0x00			; Base higher 8 bits (56-63)
; GDT TASK STATE SEGMENT
	dw 0x006E		; Limit lower 16 bits (0-15)
	dw 0xFE00		; Base lower 16 bits (15-31)
	db 0x00			; Base middle 8 bits (32-39)
	db 0x89			; Access Byte, 0b11110010 (40-47)
	db 0x00			; Flag bits and limit higher 4 bits (48-55)
	db 0x00			; Base higher 8 bits (56-63)
gdt_end:

times 510 - ($ - $$) db 0

dw 0xAA55
