BITS 32
  
org     0x08048200

write_again:
    ; Write boom.
    mov eax, sys_write
    mov ebx, stdout
    mov ecx, boom
    mov edx, boom_end-boom
    int 0x80
    
    ; Sleep for a while.
    mov eax, sys_nanosleep
    mov ebx, sleep_delay
    mov ecx, 0                  ; Abandon remaining time on interrupts.
    int 0x80
    
    jmp write_again

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

boom:
    db 'BOOM!!! '
boom_end:

sleep_delay:
    istruc timespec
        at sec, dd 1
        at nsec, dd 0
    iend
