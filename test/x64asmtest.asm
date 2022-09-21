; x64 assembly behavior test

section .text

global _start

_start:
    int 3
next:
    push 0x21222324
    pop rax
    sub rax, 0x21222325
    push 0x22334455
    pop rcx
    xor al, 0x2f
    push rax
    pop rsi
    push 0x66778899
    xor [rsp + rsi + 0x34], ecx
    pop rdx
