# b_encorder
バイナリエンコーダー

- alphanumeric shellcodeとは異なり，このプログラムではASCII文字 0x21(!) ~ 0x7E(~)への変換を行う
    - 与えられたshellcodeをスタックに展開する方式(Option: -e a)と与えられたshellcodeが
    スタック上に展開されることを前提に直接それを書き換えていく方式(Option: -e p)が利用できる

- スタック展開式
    - 与えられた命令列からスタックに変換した命令列を積んでいく
    - その際の命令列がASCII文字範囲となるようにする
    - 最終的にjmp esp によって与えられたshellcodeを実行するようにする
    - 使える命令列は http://ref.x86asm.net/coder32.html を参考にした

- ポリモーフィック式
    - 与えられた命令列をASCII文字範囲内になるようにencodeし，デコーダ(decode.asm)の直下に付与したものを出力
        - この方式では，出力形式をバイト列 or 文字列で選択可能
    - 実行時には，デコーダによってencodeされたshellcodeを復元し，その後与えられたshellcodeが実行される

- nasm -f elf32 a.asm ; ld -melf_i386 -o a a.o
- objdump -d ./*** |grep '[0-9a-f]:'|grep -v 'file'|cut -f2 -d:|cut -f1-7 -d' '|tr -s ' '|tr '\t' ' '|sed 's/ $//g'|sed 's/ /\\ x/g'|paste -d '' -s |sed 's/^/"/'|sed 's/$/"/g' | grep "\\x00"

- **逆アセンブルされればすぐに分かる小細工程度のプログラム(遊戯用)**

使える命令郡(順次追加)
|po|nemonic|op|
|:---:|:---:|:---:|
|0x24|and|al, imm8|
|0x25|and|eax, imm32|
|0x67|and|r/m16/32/r16/32|r16/32/r/m16/32|

---
- shellcodeをstackにpushする方式の場合の問題点
    - stackにpushしていくために実行されるshellcodeをS1とする
    - stack上に展開されたshellcodeをS2とする
        - S2内でretが呼び出されてもespはS2の先頭を指しているはずなので正常に戻れない
        - S1でpushad, pushfdを呼び出した場合，S2でその分のpopad, popfdを行わなければならない
- 解決策
    - S1内でpushad, pushfdを実行したあとのespの値を汎用レジスタのどれかに保存しておく
    - S2を生成する際に，ret命令を見つけ出し，move esp, (選択した汎用レジスタ)の命令列に置き換える
    - S2内でpopad, popfdを行うようにバイト列を追加する
    - retを追加する
    - このretではS1に戻るのではなく直接S1の呼び出し元に戻ることが可能
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
