BITS 32
  
                org     0x08048000
  
ehdr:                                                   ; Elf32_Ehdr
                db      0x7F, "ELF", 1, 1, 1, 0         ;   e_ident
        times 8 db      0
                dw      2                               ;   e_type
                dw      3                               ;   e_machine
                dd      1                               ;   e_version
                dd      _start                          ;   e_entry
                dd      phdr - $$                       ;   e_phoff
                dd      0                               ;   e_shoff
                dd      0                               ;   e_flags
                dw      ehdrsize                        ;   e_ehsize
                dw      phdrsize                        ;   e_phentsize
                dw      1                               ;   e_phnum
                dw      0                               ;   e_shentsize
                dw      0                               ;   e_shnum
                dw      0                               ;   e_shstrndx
  
ehdrsize equ $ - ehdr
  
phdr:                                                   ; Elf32_Phdr
                dd      1                               ;   p_type
                dd      0                               ;   p_offset
                dd      $$                              ;   p_vaddr
                dd      $$                              ;   p_paddr
                dd      filesize                        ;   p_filesz
                dd      filesize                        ;   p_memsz
                dd      5                               ;   p_flags
                dd      0x1000                          ;   p_align
  
phdrsize      equ     $ - phdr

; Constants --------------------------------------------------------------------

sys_exit                equ     1
sys_write               equ     4
sys_nanosleep           equ     162

exit_success            equ     0
stdout                  equ     1

; Structures -------------------------------------------------------------------

struc   timespec
    sec:     resd    1
    nsec:    resd    1
endstruc

; Data -------------------------------------------------------------------------

ping:
    db 'Ping...'
ping_end:

pong:
    db ' pong.', 10
pong_end:

sleep_delay:
    istruc timespec
        at sec, dd 1
        at nsec, dd 100000000 ; 100 ms
    iend


; Main -------------------------------------------------------------------------

_start:

write_again:
    ; Write ping.
    mov eax, sys_write
    mov ebx, stdout
    mov ecx, ping
    mov edx, ping_end-ping
    int 0x80
    
    ; Sleep for a while.
    mov eax, sys_nanosleep
    mov ebx, sleep_delay
    mov ecx, 0                  ; Abandon remaining time on interrupts.
    int 0x80
    
    ; Write pong.
    mov eax, sys_write
    mov ebx, stdout
    mov ecx, pong
    mov edx, pong_end-pong
    int 0x80
    
    ; Sleep for a while.
    mov eax, sys_nanosleep
    mov ebx, sleep_delay
    mov ecx, 0                  ; Abandon remaining time on interrupts.
    int 0x80
    
    jmp write_again

filesize      equ     $ - $$
