%include "layout.inc"

[BITS 16]
[ORG 0x7C00]

start:
    ; Initialize segment registers and stack
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Save the BIOS boot drive (provided in DL)
   mov [BOOT_DRIVE_ADDR], dl

    ; Configure destination: 0000:8000
    xor ax, ax
    mov es, ax
    mov bx, 0x8000

    ; BIOS disk read: INT 13h, function 02h
    mov ah, 0x02       ; Read sectors
    mov al, STAGE2_SECTORS          ; Read one sector
    mov ch, 0          ; Cylinder 0
    mov cl, STAGE2_LBA          ; Sector 2
    mov dh, 0          ; Head 0
    mov dl, [BOOT_DRIVE_ADDR]
    

    int 0x13           ; Read sector 2 into ES:BX

    ; Check whether the read failed
    jc disk_error

    ; Jump to Stage 2
    jmp 0x0000:0x8000

disk_error:
    mov si, error_message

print_error:
    lodsb
    cmp al, 0
    je halt

    mov ah, 0x0E
    int 0x10
    jmp print_error

halt:
    cli

stop:
    hlt
    jmp stop

boot_drive:   db 0
error_message: db 'Disk read error!', 0

; Fill the boot sector to exactly 512 bytes
times 510 - ($ - $$) db 0
dw 0xAA55