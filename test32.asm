; Test Shellcode To Call MsgBox. (32-bit)
section .text

global _start

_start:
    pushad
    pushfd