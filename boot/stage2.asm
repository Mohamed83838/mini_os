
%include "layout.inc"


[BITS 16]
[ORG 0x8000]

start:

    xor ax, ax
    mov ds, ax
    ;clear the DF which control if to meve +1 in si or -1 in si
    cld


    mov es, ax
    mov bx, 0x9000

    ; BIOS disk read: INT 13h, function 02h
    mov ah, 0x02       ; Read sectors
    mov al, KERNEL_SECTORS ; Read one sector
    mov ch, 0          ; Cylinder 0 
    mov cl, KERNEL_LBA          ; the start of kernel sector
    mov dh, 0          ; Head 0
    mov dl, [BOOT_DRIVE_ADDR]

    int 0x13           ; Read sector 2 into ES:BX

    ; Check whether the read failed
    jc disk_error

    ; activate protected mode
    CODE_SEG equ 0x08
    DATA_SEG equ 0x10

enter_protected_mode:

    cli                 ; Disable interrupts during transition

    ; Enable A20
    in al, 0x92
    or al, 00000010b
    and al, 11111110b
    out 0x92, al

    ; Load the Global Descriptor Table
    lgdt [gdt_descriptor]

    ; Set bit 0 of CR0: enable protected mode
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; Far jump: reload CS using our code selector
    jmp CODE_SEG:protected_mode_entry


; GDT: three descriptors

gdt_start:

    ; Entry 0: null descriptor
    dq 0

    ; Entry 1: 32-bit code segment
    ; Base = 0, Limit = 4 GiB
    dq 0x00CF9A000000FFFF

    ; Entry 2: 32-bit data segment
    ; Base = 0, Limit = 4 GiB
    dq 0x00CF92000000FFFF

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start


; We are now in 32-bit protected mode.

[BITS 32]

protected_mode_entry:

    ; Load data segment selectors
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Set up a 32-bit stack
    mov esp, 0x90000

    ; Jump to the kernel
    mov eax, 0x9000
    jmp eax

disk_error:
    mov si, error_message
print_error:
    lodsb
    cmp al , 0 
    je halt
    mov ah, 0x0E
    int 0x10
    jmp print_error

halt:
    cli
stop:
    hlt
    jmp stop

;blocks used to reference to certain operation it point to the memory of the first byte of the block and db tell the compiler to put the bytes of the message and end it with 0
error_message:
    db 'error with loading kernel',0



    
