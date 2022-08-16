# b_encorder
バイナリエンコーダー
- 入力されたasm命令(ファイル名指定)に対してASCII化エンコードを行い，出力するプログラム
    - 変換後のACSII文字は，0x21(!) ~ 0x7E(~) である(DELなどの特殊文字は含まない)
    - バイナリ命令列のバイト範囲を0x0 ~ 0xFFとすると(正確にはこの中でも限られるはずであるが)
    ASCIIの文字範囲を超えてしまう -> 2byte((0x7E-0x21+0x1)^2)使用することで解決
    - 与えられたバイト列を4bit*2に分割，そのそれぞれについてASCIIに変換
        - 0x00 ~ 0xFの16種類のASCII文字だけが必要となる
        - 当プログラムでは，0x61('a') ~ 0x70('p')へ変換が行える
- 生成されたShellcodeを実行するためには，デコーダを先頭に付与する必要がある(decode.asm)

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
    3. [(2) + 0x10] -> InMemoryOrderModuleList
    ([... + 0x14] -> InInitializationOrderModuleList)
    4. [ (3) ] -> ntdll.dll entry
    5. [ (4) ] -> kernel32.dll entry
    6. [(5) + 0x10] -> kernel32.dll baseaddr!!!


- API Functionの見つけ方
    - **まずPEの勉強をしてください(自分へ)**
    - アドレスが変動するため RVA (Relative Virtual Address: 相対仮想アドレス)
    をもとに辿っていく必要がある
        1. [base + 0x3C] -> RVA of PE signature
        2. [base + (1)]  -> Address of PE signature
        3. [(2) + 0x78]  -> RVA of Export Table
        4. [base + (3)]  -> Address of Export Table
        5. [(4) + 0x14]  -> the number of exported functions
        6. [(4) + 0x1C]  -> RVA of Address Table
        7. [base + (6)]  -> Address of Address Table
        8. [(4) + 0x20]  -> RVA of Name Pointer Table
        9. [base + (8)]  -> Address of Name Pointer Table
        10. [(4) + 0x24] -> RVA of Ordinal Table
        11. [base + (10)] -> Address of Ordinal Table
        12. (9)のNamePointerTableから，関数の名前をもとにループで探索 場所を記憶(12)
        13. [(11) + (12) * 2] -> 目的関数のOrdinal Number
        14. [(7) + (13) * 4] -> RVA of 目的関数
        15. [base + (14)] -> Address of 目的関数!!!
