; x86 test shellcode
; open a message box with a message and title
section .text

global _start

%include "find_func.asm"

_start:
    pushad
    pushfd
find_kernel32:
    xor ebx, ebx
    mov ebx, [fs:ebx + 0x30]; Get PEB
    mov ebx, [ebx + 0x0c]   ; Get Ldr
    mov ebx, [ebx + 0x14]   ; Get InMemoryOrderModuleList
    mov ebx, [ebx]          ; Get first entry (ntdll.dll)
    mov ebx, [ebx]          ; Get second entry (kernel32.dll)
    mov ebx, [ebx + 0x10]   ; Get kernel32.dll base address
    mov ebp, ebx            ; Save kernel32 base in EBP for later use
resolve_loadlibrary:
    push 0xC40C8266         ; Push LoadLibraryA hash onto stack
    call find_function      ; EAX = LoadLibraryA address
    mov edi, eax            ; Save LoadLibraryA address in EDI
load_user32:
    ; "user32.dll\0" = 75 73 65 72 33 32 2E 64 6C 6C 00
    ; Stack pushes in reverse (4 bytes at a time, little-endian):
    ;   "ll\0\0" = 0x00006C6C  -- contains null bytes, use SUB technique
    ;   "32.d"   = 0x642E3233
    ;   "user"   = 0x72657375
    xor eax, eax            ; EAX = 0
    mov ax, 0x6c6c         ; EAX = 0x00006c6c ("ll\0\0")
    push eax                ; [esp] = "ll\0\0"
    push 0x642e3233         ; [esp] = "32.d"
    push 0x72657375         ; [esp] = "user"
    push esp                ; [esp] = pointer to "user32.dll\0"
    call edi                ; Call LoadLibraryA("user32.dll")
    mov ebx, eax            ; Save user32.dll base in EBX for later use
find_messagebox:
    push 0x1A8890E5         ; Push MessageBoxA hash onto stack
    call find_function      ; EAX = MessageBoxA address
    mov esi, eax            ; Save MessageBoxA address in ESI
call_messagebox:
    ; 1. lpCaption (title): "Notice\0" (8 bytes / 2 DWORDs)
    xor eax, eax
    mov ax, 0x6563          ; EAX = 0x00006563 ("ce\0\0")
    push eax                ; [esp] = "ce\0\0"
    push 0x69746f4e         ; [esp] = "Noti"
    mov ecx, esp            ; ECX = pointer to "Notice\0"
    ; 2. lpText (message): "Hello from Shellcode!\0" (24 bytes / 6 DWORDs)
    xor eax, eax
    mov al, 0x21                   ; eax = 0x00000021 ("!\0\0\0")
    push eax                       ; [esp] = "!\0\0\0"
    push 0x65646f63                ; "code"
    push 0x6c6c6568                ; "hell"
    push 0x53206d6f                ; "om S"
    push 0x7266206f                ; "o fr"
    push 0x6c6c6548                ; "Hell"
    mov edx, esp                   ; edx = "Hello from Shellcode!\0" へのポインタ
    ; MessageBoxA(NULL, lpText, lpCaption, MB_OK)
    xor eax, eax                   ; EAX = 0 (MB_OK)
    push eax                       ; MB_OK
    push ecx                       ; lpCaption
    push edx                       ; lpText
    push eax                       ; hWnd = NULL
    call esi                       ; Call MessageBoxA(NULL, lpText, lpCaption, MB_OK)
call_exitprocess:
    push 0xEA8A9494                ; Push ExitProcess hash onto stack
    call find_function             ; EAX = ExitProcess address
    mov edi, eax                   ; Save ExitProcess address in EDI
    xor eax, eax                   ; EAX = 0 (exit code)
    push eax                       ; Push exit code 0
    call edi                       ; Call ExitProcess(0)
