BITS 32
  
org     0x08048200

    mov eax, 11                 ; execve
    mov ebx, binsh
    mov ecx, 0
    mov edx, 0
    int 0x80
    
binsh:
    db '/bin/sh', 0
