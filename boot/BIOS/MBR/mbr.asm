org 0x7c00

global _start

_start:
	; Disable interrupts
	cli
	; Save "drive number" value
	mov [drive_number], dl
	; Set up stack 512 bytes after MBR ends
	mov sp, 0x07c00
	; Initialize registers to 0
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	; Relocate MBR to 0x500
	mov cx, 0x0100 ; 256 words in MBR
	mov si, 0x7c00 ; Where the MBR is located at first
	mov di, 0x0500 ; Where we want to move the MBR
	rep movsw      ; Move the MBR
	jmp 0:new_start; Jump to new address

new_start:
	mov si, relocated_msg
	call print
	
print:
	mov ah, 0x0e
	mov al, [si]
	int 0x10
	add si, 0x01
	cmp byte [si], 0
	jne print
	ret

done:
	nop
	

relocated_msg:
	db "Successfully relocated MBR.", 0

drive_number:
	db 0

times (0x1b4 - ($ - $$)) nop

UID times 10 db 0
PT1 times 16 db 0
PT2 times 16 db 0
PT3 times 16 db 0
PT4 times 16 db 0

dw 0xAA55
