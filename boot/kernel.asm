[BITS 32]
[ORG 0x9000]

start:
    ; Initialize data segment
    mov ax, 0x10
    mov ds, ax

    cld
    ;clear screen
    mov edi ,0xB8000
    mov ecx, 80 * 25
    mov ax, 0x0720


    
clear_screen:
    mov word [edi], ax
    add edi, 2
    loop clear_screen


    mov edi ,0xB8000
    mov esi, message
    ;calculate the center
    mov eax , 12*80*2 + 25*2
    add edi, eax
    

print:
    lodsb

    cmp al, 0
    je halt

    ; Write character
    mov [edi], al

    ; Write color attribute
    mov byte [edi + 1], 0x04

    ; Move to next VGA cell (2 bytes)
    add edi, 2

    jmp print

halt:
    cli

stop:
    hlt
    jmp stop

message:
    db 'Kernel is loaded successfully ', 0
