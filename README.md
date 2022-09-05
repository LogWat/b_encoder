# b_encorder
バイナリエンコーダー

- alphanumeric shellcodeとは異なり，このプログラムではASCII文字 0x21(!) ~ 0x7E(~)への変換を行う
    - 与えられた命令列からスタックに変換した命令列を積んでいく
    - その際の命令列がASCII文字範囲となるようにする
    - 最終的にjmp esp によって与えられたshellcodeを実行するようにする
    - 使える命令列は http://ref.x86asm.net/coder32.html を参考にした

- nasm -f elf32 a.asm ; ld -melf_i386 -o a a.o
- objdump -d ./*** |grep '[0-9a-f]:'|grep -v 'file'|cut -f2 -d:|cut -f1-7 -d' '|tr -s ' '|tr '\t' ' '|sed 's/ $//g'|sed 's/ /\\ x/g'|paste -d '' -s |sed 's/^/"/'|sed 's/$/"/g' | grep "\\x00"

- **逆アセンブルされればすぐに分かる小細工程度のプログラム(遊戯用)**

使えそうなやつら
|po|nemonic|op|
|:---:|:---:|:---:|
|0x24|and|al, imm8|
|0x25|and|eax, imm32|
|0x67|and|r/m16/32/r16/32|r16/32/r/m16/32|

---
## Windows Shellcode memo
当プログラムには直接関係ないただのメモ

(参考)https://idafchev.github.io/exploit/2017/09/26/writing_windows_shellcode.html
- WindowsはLinuxなどと異なり直接システムコール関数にアクセスできない
- (外部) WinAPI <-> NtAPI <-> syscall (内部)
- WinAPI (kernel32.dll, advapi32.dll, gdi32.dll...)
- NtAPI (ntdll.dll)
- kernel32.dll＆ntdll.dllはどのプロセスにもimportされる
- WinAPIを利用するために，ロードされてるDLLのBaseAddressを知る必要がある 

- Windowsの実行可能ファイル形式はPE format(Portable Executable)
    - プロセス生成時には，メモリ割り当てとインポートした関数解決が行われる


### 32-bit
- DLLBase Addr の見つけ方
    1. fs:0x30 -> PEB (Process Env Block)
    2. [(1) + 0x0C] -> PEB_LDR_DATA
    3. [(2) + 0x14] -> InMemoryOrderModuleList
    ([... + 0x14] -> InInitializationOrderModuleList)
    4. [ (3) ] -> ntdll.dll entry
    5. [ (4) ] -> kernel32.dll entry
    6. [(5) + 0x10] -> kernel32.dll baseaddr!!!


- API Functionの見つけ方
    - **まずPEの勉強をしてください(自分へ)**
    - アドレスが変動するため RVA (Relative Virtual Address: 相対仮想アドレス)
    をもとに辿っていく必要がある
        1. [base + 0x3C] -> RVA of PE signature
        2. base + (1)    -> Address of PE signature
        3. [(2) + 0x78]  -> RVA of Export Table
        4. base + (3)  -> Address of Export Table
        5. [(4) + 0x14]  -> the number of exported functions
        6. [(4) + 0x1C]  -> RVA of Address Table
        7. base + (6)  -> Address of Address Table
        8. [(4) + 0x20]  -> RVA of Name Pointer Table
        9. base + (8)  -> Address of Name Pointer Table
        10. [(4) + 0x24] -> RVA of Ordinal Table
        11. base + (10) -> Address of Ordinal Table
        12. (9)のNamePointerTableから，関数の名前をもとにループで探索 場所を記憶(12)
        13. [(11) + (12) * 2] -> 目的関数のOrdinal Number
        14. [(7) + (13) * 4] -> RVA of 目的関数
        15. base + (14) -> Address of 目的関数!!!

---
## ネタ帳
- encodeした結果の末尾に，shellcode全体のハッシュ値を署名として付与してもおもしろそう
    - decodeの際にまずそのハッシュ値を確認させる

## ASCII-Shellcode-Tech
- ASCII-Shellcodeとは，Shellcodeをバイナリ文字列にしたときに，すべてASCII文字(0x30 ~ 0x7A)の範囲で表せるようなもの

- NOP
    - IPSなどは，単純な繰り返し文字からNOPスレッドを感知できる場合がある
    - INC&DEC, PUSH&POP reg で対策

- Gen 0x00 (byte, dword...)
    - ` push byte 0x?? -> pop eax -> xor al, 0x?? ` -> `j?X4?`
    - ` push 0x???????? -> pop eax -> xor al, 0x???????? ` -> `j?X4?`
    - ??の部分がASCIIなら別になんでもいい
