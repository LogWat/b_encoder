# b_encorder
バイナリエンコーダー
- 入力されたshellcodeバイト列(ファイル名指定)に対してASCII化エンコードを行い，出力するプログラム
    - 変換後のACSII文字は，0x21(!) ~ 0x7E(~) である(DELなどの特殊文字は含まない)
    - バイナリ命令列のバイト範囲を0x0 ~ 0xFFとすると(正確にはこの中でも限られるはずであるが)
    ASCIIの文字範囲を超えてしまう -> 2byte((0x7E-0x21+0x1)^2)使用することで解決
    - 与えられたバイト列を4bit*2に分割，そのそれぞれについてASCIIに変換
        - 0x00 ~ 0xFの16種類のASCII文字だけが必要となる
        - 0x61('a') ~ 0x7e('~')への変換が行える
        - オプションにより変換後のASCII文字範囲を変更することができる
            - 与える値は，0x00をどれほどシフトするかという値となる
            - 0x22を与えた場合，変換後のshellcodeは0x22('"') ~ 0x31('1')となる
    - 変換後のshellcodeの終端には，0x20(space)及びencode後のshellcode全体のハッシュ値が付与される
        - decode時には，まずencodeされたshellcodeからハッシュ値を導き，終端に付与された値と比較する
        - もし付与されているハッシュ値と一致しない場合には実行を終了
- 生成されたShellcodeを実行するためには，デコーダを先頭に付与する必要がある(decode.asm)

- nasm -f elf32 a.asm ; ld -melf_i386 -o a a.o
- objdump -d ./*** |grep '[0-9a-f]:'|grep -v 'file'|cut -f2 -d:|cut -f1-7 -d' '|tr -s ' '|tr '\t' ' '|sed 's/ $//g'|sed 's/ /\\ x/g'|paste -d '' -s |sed 's/^/"/'|sed 's/$/"/g' | grep "\\x00"

- **逆アセンブルされればすぐに分かる小細工程度のプログラム(遊戯用)**
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
