# Shellcode テクニック総合文書

本文書は、OS やアーキテクチャを問わない汎用的な Shellcode 技術を体系的にまとめた技術資料である。
Windows 固有の内容については [WINDOWS_SHELLCODE.md](./WINDOWS_SHELLCODE.md) を参照。

> **注意**: 本文書はセキュリティ研究・教育目的の技術資料である。

---

## 目次

1. [Shellcode の基本概念](#1-shellcode-の基本概念)
2. [OS 別システムコール](#2-os-別システムコール)
3. [Position-Independent Code (PIC)](#3-position-independent-code-pic)
4. [ヌルバイト回避と Bad Character 対策](#4-ヌルバイト回避と-bad-character-対策)
5. [Shellcode エンコーディング](#5-shellcode-エンコーディング)
6. [ASCII / Alphanumeric Shellcode](#6-ascii--alphanumeric-shellcode)
7. [ポリモーフィック・メタモーフィック技法](#7-ポリモーフィックメタモーフィック技法)
8. [NOP スレッドと代替技法](#8-nop-スレッドと代替技法)
9. [Egg Hunter とステージング](#9-egg-hunter-とステージング)
10. [メモリ保護機構と回避](#10-メモリ保護機構と回避)
11. [アーキテクチャ間の差異](#11-アーキテクチャ間の差異)
12. [本プロジェクト (b_encoder) の設計](#12-本プロジェクト-b_encoder-の設計)
13. [ツールチェインとデバッグ](#13-ツールチェインとデバッグ)
14. [参考文献](#14-参考文献)

---

## 1. Shellcode の基本概念

### 1.1 定義

Shellcode とは、エクスプロイトのペイロードとして注入・実行される小さな機械語コード断片である。
名前の由来はシェル (/bin/sh) を起動する目的だったが、現在はあらゆる動作を行うコードを含む。

### 1.2 Shellcode の制約

| 制約 | 理由 |
|:---|:---|
| **Position-Independent** | メモリ上のどのアドレスにロードされるか不明 |
| **ヌルバイト禁止** | `strcpy` 等の文字列関数で切断される |
| **サイズ制限** | バッファオーバーフローの利用可能領域に依存 |
| **Bad Character 回避** | フィルタリングされる文字を含められない |
| **自己完結型** | 外部ライブラリや絶対アドレスに依存できない |

### 1.3 Shellcode のライフサイクル

```
 ┌─────────────┐     ┌──────────────┐     ┌──────────────────┐
 │  生バイト列   │ ──► │  エンコード   │ ──► │  注入 (Inject)    │
 │  (payload)   │     │  (encode)    │     │  バッファ等に配置  │
 └─────────────┘     └──────────────┘     └──────────────────┘
                                                   │
                                                   ▼
 ┌─────────────┐     ┌──────────────┐     ┌──────────────────┐
 │  目的の動作   │ ◄── │  デコード     │ ◄── │  実行フロー奪取   │
 │  を実行       │     │  (decode stub)│     │  EIP/RIP制御     │
 └─────────────┘     └──────────────┘     └──────────────────┘
```

---

## 2. OS 別システムコール

### 2.1 Linux x86 (32-bit)

`int 0x80` ソフトウェア割り込みでカーネルモードに遷移する。

| 要素 | レジスタ |
|:---:|:---:|
| システムコール番号 | `EAX` |
| 引数 1 | `EBX` |
| 引数 2 | `ECX` |
| 引数 3 | `EDX` |
| 引数 4 | `ESI` |
| 引数 5 | `EDI` |
| 引数 6 | `EBP` |
| 発行命令 | `int 0x80` |

**例: `exit(0)`**

```nasm
xor eax, eax        ; eax = 0
xor ebx, ebx        ; ebx = 0 (status code)
mov al, 1            ; sys_exit = 1
int 0x80
```

> **システムコール番号の参照**:
> `/usr/include/asm/unistd_32.h` または
> カーネルソース `arch/x86/entry/syscalls/syscall_32.tbl`

### 2.2 Linux x64 (64-bit)

`syscall` 命令を使用する。`int 0x80` より高速。

| 要素 | レジスタ |
|:---:|:---:|
| システムコール番号 | `RAX` |
| 引数 1 | `RDI` |
| 引数 2 | `RSI` |
| 引数 3 | `RDX` |
| 引数 4 | `R10` |
| 引数 5 | `R8` |
| 引数 6 | `R9` |
| 発行命令 | `syscall` |
| 破壊されるレジスタ | `RCX`, `R11` |

**例: `exit(0)`**

```nasm
xor rdi, rdi         ; rdi = 0 (status code)
mov al, 60           ; sys_exit = 60
syscall
```

> **注意**: `syscall` 命令は `RCX` にリターンアドレス、`R11` に RFLAGS を保存するため、
> これらのレジスタは破壊される。

### 2.3 Linux x86 vs x64 主要システムコール番号比較

| システムコール | x86 番号 | x64 番号 |
|:---|:---:|:---:|
| `read` | 3 | 0 |
| `write` | 4 | 1 |
| `open` | 5 | 2 |
| `close` | 6 | 3 |
| `execve` | 11 | 59 |
| `exit` | 1 | 60 |
| `socket` | 359 | 41 |
| `connect` | 362 | 42 |
| `dup2` | 63 | 33 |
| `mprotect` | 125 | 10 |

### 2.4 macOS x64 (Intel)

macOS はシステムコールに `syscall` 命令を使用するが、
番号体系が Linux と大きく異なる。BSD 互換レイヤーのシステムコールには
`0x2000000` のオフセットが加算される。

| 要素 | レジスタ |
|:---:|:---:|
| システムコール番号 | `RAX` |
| 引数 1 | `RDI` |
| 引数 2 | `RSI` |
| 引数 3 | `RDX` |
| 発行命令 | `syscall` |

**例: `exit(0)` on macOS x64**

```nasm
xor rdi, rdi
mov rax, 0x2000001   ; sys_exit = 1 + 0x2000000
syscall
```

### 2.5 macOS ARM64 (Apple Silicon)

| 要素 | レジスタ |
|:---:|:---:|
| システムコール番号 | `X16` |
| 引数 1〜6 | `X0`〜`X5` |
| 発行命令 | `svc #0x80` |

**例: `exit(0)` on macOS ARM64**

```asm
mov x0, #0           ; status code
movz x16, #1         ; sys_exit
movk x16, #0x200, lsl #16  ; 0x2000001
svc #0x80
```

> **Linux ARM64 との違い**: Linux では `X8` にシステムコール番号を格納し `svc #0` を使用する。
> macOS では `X16` を使用し `svc #0x80` を使用する。

### 2.6 Windows

Windows ではシステムコールに直接アクセスできない。
詳細は [WINDOWS_SHELLCODE.md](./WINDOWS_SHELLCODE.md) を参照。

### 2.7 システムコール比較一覧

| | Linux x86 | Linux x64 | macOS x64 | macOS ARM64 | Windows |
|:---|:---:|:---:|:---:|:---:|:---:|
| **発行命令** | `int 0x80` | `syscall` | `syscall` | `svc #0x80` | N/A (WinAPI) |
| **番号レジスタ** | EAX | RAX | RAX | X16 | N/A |
| **引数 1** | EBX | RDI | RDI | X0 | RCX |
| **引数 2** | ECX | RSI | RSI | X1 | RDX |
| **引数 3** | EDX | RDX | RDX | X2 | R8 |
| **引数 4** | ESI | R10 | R10 | X3 | R9 |
| **番号体系** | 小さい整数 | 小さい整数 | `0x2000000`+ | `0x2000000`+ | N/A |

---

## 3. Position-Independent Code (PIC)

Shellcode はメモリ上のどこにロードされるか不明であるため、
絶対アドレスを使用できない。以下の技法で現在のアドレスを取得する。

### 3.1 call/pop パターン (x86)

`call` 命令は次の命令のアドレスをスタックに積む性質を利用する。

```nasm
    jmp short get_addr
shellcode:
    pop esi              ; esi = shellcode データのアドレス
    ; ... esi を使って相対アドレスでデータにアクセス ...

get_addr:
    call shellcode       ; リターンアドレスが push される
    ; ここにデータを配置 ...
    db "/bin/sh", 0
```

### 3.2 call $+5 パターン (x86)

```nasm
    call $+5             ; 次の命令のアドレスを push
    pop eax              ; eax = 現在の EIP
```

> **注意**: `call $+5` はバイト列 `E8 00 00 00 00` を生成しヌルバイトを含む。
> 回避策として `call $+N` (N ≠ 5) を使い、pop 後に調整する。

### 3.3 fnstenv / fstenv パターン (x86)

FPU 命令を利用して EIP を取得する方法。

```nasm
    fldz                 ; FPU 命令を実行 (EIP が FPU 環境に記録される)
    fnstenv [esp - 0x0C] ; FPU 環境をスタックに保存
    pop eax              ; eax = 最後の FPU 命令が実行されたアドレス
```

### 3.4 RIP 相対アドレッシング (x64)

x64 では `lea` 命令で RIP 相対アドレスを直接取得できる。

```nasm
    lea rax, [rip]       ; rax = 現在の RIP (次の命令のアドレス)
    lea rsi, [rel data]  ; rsi = data ラベルのアドレス
```

### 3.5 ADR / ADRP (ARM64)

ARM64 では PC 相対アドレスを直接取得できる。

```asm
    adr x0, data         ; x0 = data のアドレス (±1MB 範囲)
    adrp x0, data        ; x0 = data のページアドレス (±4GB 範囲)
```

---

## 4. ヌルバイト回避と Bad Character 対策

### 4.1 ヌルバイトの問題

`0x00` が含まれると `strcpy`, `gets`, `scanf("%s")` 等の文字列関数で
ペイロードが切断される。

### 4.2 共通的な回避テクニック

| 問題 | 回避策 | 例 |
|:---|:---|:---|
| `mov reg, 0` | `xor reg, reg` | `xor eax, eax` → `31 C0` |
| `mov reg, small_imm` | `xor` + `mov al` | `xor eax, eax; mov al, 1` |
| `push 0` | `xor` + `push` | `xor eax, eax; push eax` |
| 文字列中の `\0` | スタック上で構築 | `push` で逆順に積む |
| 小さい即値 | `push byte` + `pop` | `push byte 0x0B; pop eax` |
| 0x00 を含む即値 | `SUB` / `NOT` で生成 | 下記参照 |

### 4.3 SUB テクニックによる値の生成

目的の値 `V` を直接即値として使えない場合、`V = A - B` となる
Bad Character を含まない `A`, `B` を見つける。

```nasm
; 0x00000000 を生成 (ヌル終端用)
push 0x21212121
sub dword [esp], 0x21212121   ; [esp] = 0x00000000
```

本プロジェクトではこの手法を発展させ、任意のバイト列を ASCII 範囲内の
XOR 演算で生成している（詳細は [12 章](#12-本プロジェクト-b_encoder-の設計) 参照）。

### 4.4 NOT / NEG テクニック

```nasm
; 0x00 を含む値を生成
mov eax, 0xFFFFFF80      ; ~0x7F
not eax                  ; eax = 0x0000007F
```

### 4.5 Bad Character の特定方法

1. すべてのバイト値 `0x00`〜`0xFF` を含むテストペイロードを送信
2. 受信側で欠落・変化したバイトを特定
3. エンコーダでそれらのバイトを回避する

---

## 5. Shellcode エンコーディング

### 5.1 XOR エンコーディング

最も基本的なエンコーディング手法。`A ^ K ^ K = A` という XOR の可逆性を利用する。

**エンコーダ (疑似コード):**

```
for each byte b in shellcode:
    encoded[i] = b ^ key
```

**デコーダスタブ (x86):**

```nasm
decoder:
    jmp short get_encoded
decode:
    pop esi                 ; esi = エンコード済みデータのアドレス
    xor ecx, ecx
    mov cl, SHELLCODE_LEN   ; ループカウンタ
decode_loop:
    xor byte [esi], KEY     ; 1 バイトずつ XOR デコード
    inc esi
    loop decode_loop
    jmp short decoded       ; デコード済みコードへジャンプ
get_encoded:
    call decode
decoded:
    ; エンコード済みデータがここに続く
```

### 5.2 マルチバイトキー XOR

単一バイトキーではキーがペイロード中の Bad Character と一致する場合に
`0x00` が生じる問題がある。マルチバイトキーでこれを緩和する。

```
key = [K0, K1, K2, K3]
encoded[i] = shellcode[i] ^ key[i % 4]
```

### 5.3 ニブル分割エンコーディング

本プロジェクトのポリモーフィック方式で使用。各バイトを上位・下位ニブル (4-bit) に分割し、
それぞれにオフセットを加えて ASCII 範囲に収める。

```
元のバイト: 0xAB
上位ニブル: 0x0A + 0x61 = 0x6B ('k')
下位ニブル: 0x0B + 0x61 = 0x6C ('l')
エンコード結果: "kl"
```

デコード時は逆にオフセットを引いてニブルを再結合する。

### 5.4 ADD/SUB エンコーディング

XOR の代わりに加算・減算を使用する。キーの選択肢が広がる。

```
encoded[i] = (shellcode[i] + key) % 256
decoded[i] = (encoded[i] - key) % 256
```

### 5.5 エンコーディング比較

| 手法 | サイズ膨張 | デコーダサイズ | Bad Char 回避力 | 検出耐性 |
|:---|:---:|:---:|:---:|:---:|
| **単一バイト XOR** | 1x | ~15 bytes | 低 | 低 |
| **マルチバイト XOR** | 1x | ~20 bytes | 中 | 中 |
| **ニブル分割** | 2x | ~30 bytes | 高 | 中 |
| **ADD/SUB** | 1x | ~15 bytes | 中 | 低 |
| **Alphanumeric** | 3〜5x | ~50 bytes | 最高 | 中 |

---

## 6. ASCII / Alphanumeric Shellcode

### 6.1 定義

| 分類 | バイト範囲 | 使用可能文字 |
|:---|:---:|:---|
| **Printable ASCII** | `0x21`〜`0x7E` | `!` 〜 `~` (スペースを含まない) |
| **Alphanumeric** | `0x30`〜`0x39`, `0x41`〜`0x5A`, `0x61`〜`0x7A` | `0-9`, `A-Z`, `a-z` |

本プロジェクトでは `0x21`〜`0x7E` (Printable ASCII) を使用する。

### 6.2 Printable ASCII 範囲で利用可能な主要 x86 命令

| オペコード | ASCII | ニーモニック | オペランド |
|:---:|:---:|:---|:---|
| `0x21` | `!` | `AND` | `r/m32, r32` |
| `0x24` | `$` | `AND` | `AL, imm8` |
| `0x25` | `%` | `AND` | `EAX, imm32` |
| `0x28` | `(` | `SUB` | `r/m8, r8` |
| `0x29` | `)` | `SUB` | `r/m32, r32` |
| `0x2C` | `,` | `SUB` | `AL, imm8` |
| `0x2D` | `-` | `SUB` | `EAX, imm32` |
| `0x30` | `0` | `XOR` | `r/m8, r8` |
| `0x31` | `1` | `XOR` | `r/m32, r32` |
| `0x34` | `4` | `XOR` | `AL, imm8` |
| `0x35` | `5` | `XOR` | `EAX, imm32` |
| `0x40`〜`0x47` | `@`〜`G` | `INC` | `EAX`〜`EDI` |
| `0x48`〜`0x4F` | `H`〜`O` | `DEC` | `EAX`〜`EDI` |
| `0x50`〜`0x57` | `P`〜`W` | `PUSH` | `EAX`〜`EDI` |
| `0x58`〜`0x5F` | `X`〜`_` | `POP` | `EAX`〜`EDI` |
| `0x6A` | `j` | `PUSH` | `imm8` |
| `0x68` | `h` | `PUSH` | `imm32` |

> **x64 での注意**: `0x40`〜`0x4F` は x64 では REX プレフィックスとなるため、
> `INC`/`DEC` としては使用できない。

### 6.3 AND-SUB テクニック

任意の 32-bit 値を ASCII 命令だけで EAX に生成する古典的技法。

```
手順:
1. AND EAX, 0x21212121    ; EAX をクリアに近い値にする
2. AND EAX, 0x21216121    ; 2回の AND で EAX = 0 にする
3. SUB EAX, val1          ; val1, val2, val3 は ASCII 範囲内
4. SUB EAX, val2          ; 3回の SUB で目的の値を生成
5. SUB EAX, val3          ; (オーバーフローを利用)
6. PUSH EAX               ; スタックに積む
```

### 6.4 NOP の代替 (ASCII 範囲)

IDS/IPS は `0x90` (NOP) の連続パターンを検知する。
ASCII 範囲内で NOP 等価な命令ペアを使用する:

```nasm
; 状態を変更しない命令ペア
inc eax     ; 0x40
dec eax     ; 0x48

push eax    ; 0x50
pop eax     ; 0x58
```

### 6.5 ゼロ生成 (ASCII 範囲)

本プロジェクト README で言及されている手法:

```nasm
; 0x00000000 を EAX に生成
push byte 0x??    ; 0x6A, 0x?? (ASCII 範囲内の任意値)
pop eax           ; 0x58
xor al, 0x??      ; 0x34, 0x?? (同じ値)
; 結果: EAX = 0x00000000
; バイト列: "j?X4?" (すべて ASCII)
```

---

## 7. ポリモーフィック・メタモーフィック技法

### 7.1 ポリモーフィック Shellcode

ペイロード本体は暗号化し、毎回異なるキー・デコーダスタブで包む。

```
┌────────────────────────────────────────┐
│  デコーダスタブ (毎回異なる)              │
│  ┌──────────────────────────────────┐  │
│  │  暗号化されたペイロード (毎回同一)  │  │
│  └──────────────────────────────────┘  │
└────────────────────────────────────────┘
```

**変異手法:**

- 暗号化キーの変更
- デッドコード挿入 (無意味な命令の追加)
- レジスタ入れ替え
- 命令の等価置換 (例: `mov eax, 0` → `xor eax, eax` → `sub eax, eax`)

### 7.2 メタモーフィック Shellcode

デコーダだけでなくペイロード本体のコード構造自体を書き換える。

| 手法 | 説明 |
|:---|:---|
| **命令置換** | `add eax, 1` → `inc eax` → `sub eax, -1` |
| **コード転置** | 独立した命令ブロックの順序入れ替え |
| **レジスタ再割り当て** | `eax` での操作を `ebx` に変更 |
| **ジャンク挿入** | 無意味な命令を挿入 |
| **サブルーチン化** | インライン処理を call/ret に分割 |

### 7.3 ポリモーフィック vs メタモーフィック

| 特性 | ポリモーフィック | メタモーフィック |
|:---|:---|:---|
| **変化する部分** | デコーダスタブ | コード全体 |
| **復号後のペイロード** | 毎回同一 | 毎回異なる構造 |
| **実装の複雑さ** | 中程度 | 非常に高い |
| **エミュレーション耐性** | 低い (復号すれば同一) | 高い |
| **静的解析耐性** | 高い | 非常に高い |

---

## 8. NOP スレッドと代替技法

### 8.1 NOP スレッド (NOP Sled)

バッファオーバーフロイトで正確な Shellcode アドレスを特定する必要性を緩和するため、
Shellcode の前に大量の NOP (`0x90`) を配置する。

```
[NOP NOP NOP ... NOP] [Shellcode]
         ↑
  この範囲のどこにジャンプしても
  最終的に Shellcode に到達する
```

### 8.2 NOP 等価命令 (Soft NOP)

IDS/IPS は `0x90` の連続パターンで NOP スレッドを検出する。
レジスタ状態を変更しない命令ペアを代替として使用:

| 命令ペア | バイト列 | 効果 |
|:---|:---|:---|
| `inc eax; dec eax` | `40 48` | EAX 不変 |
| `push eax; pop eax` | `50 58` | EAX 不変、スタック不変 |
| `push ebx; pop ebx` | `53 5B` | EBX 不変 |
| `xchg eax, eax` | `90` | 通常の NOP |
| `lahf; sahf` | `9F 9E` | フラグ不変 |
| `cmc; cmc` | `F5 F5` | キャリーフラグ不変 |

### 8.3 ランダム化 NOP スレッド

複数の NOP 等価命令をランダムに混在させることで、
パターンマッチングベースの検出を困難にする。

---

## 9. Egg Hunter とステージング

### 9.1 Egg Hunter

利用可能なバッファが小さくて完全な Shellcode を収容できない場合に使用する。

**仕組み:**

```
小さいバッファ:  [Egg Hunter (30〜50 bytes)]

メモリ上の別の場所:  [EGG_TAG][EGG_TAG][Main Shellcode ...]
```

1. 小さな Egg Hunter コードがまず実行される
2. プロセスのメモリ空間全体を走査し、特定のマーカー (Egg Tag) を検索する
3. マーカーを発見したら、その直後にある本体 Shellcode にジャンプする

**Egg Tag**: 通常 4 バイトの値を 2 回繰り返す (例: `w00tw00t`)。
2 回繰り返すのは、Hunter 自身のコード中に含まれるマーカーと区別するため。

**Linux x86 Egg Hunter 例:**

```nasm
egg_hunter:
    xor ecx, ecx
    mul ecx              ; eax = edx = 0
next_page:
    or dx, 0xFFF         ; ページ境界にアラインメント
next_addr:
    inc edx
    lea ebx, [edx + 4]
    push byte 0x21       ; sys_access = 33 (0x21)
    pop eax
    int 0x80             ; access(edx+4, 0) でアドレスの有効性を確認
    cmp al, 0xF2         ; EFAULT? (-14 = 0xF2)
    je next_page         ; ページが無効なら次のページへ
    mov eax, 0x50905090  ; Egg Tag
    mov edi, edx
    scasd                ; [edi] == eax ? then edi += 4
    jnz next_addr
    scasd                ; 2回目の比較
    jnz next_addr
    jmp edi              ; Egg 発見 → 本体 Shellcode へジャンプ
```

### 9.2 ステージド Shellcode (Staged Shellcode)

Shellcode を複数段階に分割する。

```
Stage 0 (Stager):     小さなコード。ネットワーク接続を確立し Stage 1 を受信
                      ↓
Stage 1 (Stage):      完全なペイロード。メモリ上に展開して実行
```

**利点:**

- Stage 0 のサイズを極小化できる
- Stage 1 を動的に変更可能
- Stage 1 は暗号化して転送可能

---

## 10. メモリ保護機構と回避

### 10.1 主要な保護機構

| 保護機構 | 説明 | OS |
|:---|:---|:---|
| **DEP / NX bit** | メモリページを「書き込み可能」or「実行可能」に分離 (W^X) | 全 OS |
| **ASLR** | スタック・ヒープ・ライブラリのアドレスをランダム化 | 全 OS |
| **Stack Canary** | スタックバッファの直後に監視値を配置 | 全 OS |
| **RELRO** | GOT を読み取り専用化 | Linux |
| **PIE** | 実行ファイル自体のアドレスもランダム化 | Linux |
| **CFG** | 間接呼び出しの飛び先を検証 | Windows |
| **CET** | Shadow Stack によるリターンアドレス保護 | Windows/Linux |

### 10.2 DEP/NX の回避: Return-Oriented Programming (ROP)

DEP/NX によりスタック・ヒープ上のコードが実行不能になるため、
既存のコード断片 (ガジェット) を再利用する。

**ガジェット**: `ret` 命令で終わる短い命令列。

```
例: mprotect() を呼び出して Shellcode が配置されたメモリを実行可能にする

スタック上の ROP チェーン:
[gadget1_addr] → pop rdi; ret      (rdi = shellcode_addr)
[shellcode_addr]
[gadget2_addr] → pop rsi; ret      (rsi = size)
[0x1000]
[gadget3_addr] → pop rdx; ret      (rdx = PROT_READ|PROT_WRITE|PROT_EXEC = 7)
[0x7]
[mprotect_addr]                     mprotect(addr, size, 7)
[shellcode_addr]                    mprotect 完了後 shellcode へジャンプ
```

**権限変更 API:**

| OS | API | 説明 |
|:---|:---|:---|
| Linux | `mprotect(addr, len, prot)` | メモリ保護属性の変更 |
| Windows | `VirtualProtect(addr, size, prot, &old)` | メモリ保護属性の変更 |

### 10.3 ASLR の回避

| 手法 | 説明 |
|:---|:---|
| **情報リーク** | フォーマット文字列脆弱性等でアドレスをリーク |
| **ブルートフォース** | 32-bit ではエントロピーが低く (8-16 bit) 実用的 |
| **部分上書き** | アドレスの下位バイトのみ上書き (ページ内オフセットは固定) |
| **ret2plt** | PLT/GOT エントリは PIE がなければ固定アドレス |

### 10.4 自己書き換えコード (Self-Modifying Code)

メモリ上で自身の命令を動的に変更する。
DEP/NX 環境下では `mprotect` / `VirtualProtect` で
メモリ属性を変更する必要がある。

---

## 11. アーキテクチャ間の差異

### 11.1 x86 vs x64 の主要差異

| 項目 | x86 (32-bit) | x64 (64-bit) |
|:---|:---|:---|
| 汎用レジスタ数 | 8 | 16 |
| レジスタ幅 | 32-bit | 64-bit |
| アドレス空間 | 4GB | 256TB (48-bit) |
| syscall 命令 | `int 0x80` | `syscall` |
| `pushad`/`popad` | 使用可能 | **存在しない** |
| `inc r32`/`dec r32` (1バイト) | `0x40`-`0x4F` | **REX プレフィックスに使用** |
| RIP 相対アドレッシング | 不可 | 標準 |
| 関数呼出規約 (Linux) | スタック渡し | RDI, RSI, RDX, RCX, R8, R9 |
| 関数呼出規約 (Windows) | スタック渡し | RCX, RDX, R8, R9 + Shadow Space |

### 11.2 x86/x64 vs ARM64 の主要差異

| 項目 | x86/x64 | ARM64 (AArch64) |
|:---|:---|:---|
| 命令長 | 可変長 (1〜15 bytes) | 固定長 (4 bytes) |
| アーキテクチャ | CISC | RISC |
| 汎用レジスタ数 | 8/16 | 31 (X0-X30) + SP + ZR |
| 条件実行 | フラグ + 条件ジャンプ | 条件付き命令あり |
| 即値制約 | ほぼ任意 | 12-bit / 16-bit + シフト |
| PIC | call/pop テクニック必要 | `adr`/`adrp` 命令でネイティブ対応 |
| ヌルバイト回避 | 比較的容易 | 固定長命令のため困難な場合あり |

### 11.3 ARM64 固有の課題

- **固定長命令**: 4 バイト命令のため、1 バイトでもヌルバイトを含むと回避が難しい
- **即値制約**: 即値の範囲が限定されており、大きな定数の構築に複数命令が必要
  (`movz` + `movk` の組み合わせ)
- **キャッシュコヒーレンシ**: 自己書き換えコードでは命令キャッシュとデータキャッシュの
  同期が必要 (`dc cvau` + `ic ivau` + `isb` 命令)

---

## 12. 本プロジェクト (b_encoder) の設計

### 12.1 概要

b_encoder は Shellcode を ASCII 印字可能文字範囲 (`0x21`〜`0x7E`) に変換する
バイナリエンコーダである。2 つのエンコード方式を提供する。

### 12.2 スタック展開方式 (`-e a`)

入力 Shellcode をスタック上に復元する命令列を生成する。
生成される命令列自体が ASCII 範囲内に収まる。

**エンコードアルゴリズム:**

```
入力バイト列を 4 バイト (x86) / 8 バイト (x64) 単位に分割

各ブロックについて:
  1. バイトが 0x80 以上のものを特定 → stand マスク (0xFF 位置)
  2. 0x80 以上のバイトは 0xFF で XOR して反転
  3. 反転後の値を num1 ^ num2 = target となる ASCII 範囲内の
     ペア (num1, num2) に分解 (ランダム選択)
  4. アセンブリ命令を生成:
     - push num1 → pop eax → xor eax, num2 → push eax
     - 0xFF 位置は [esp + offset] に対して xor cx/cl で復元
```

**stand (0xFF マスク) の最適化:**

| 0xFF の個数 | 処理 |
|:---:|:---|
| 0 | XOR 不要。`push num1; pop eax; xor eax, num2; push eax` |
| 1 | `xor [esp + offset], cl` (byte 単位) |
| 2 (連続) | `xor [esp + offset], cx` (word 単位) |
| 3〜4 | まず `0xFFFFFFFF` を push してから XOR |

### 12.3 ポリモーフィック方式 (`-e p`)

入力 Shellcode をニブル分割でエンコードし、デコーダスタブ付きで出力する。

**エンコード処理:**

```
for each byte b in shellcode:
    上位ニブル = b / 16 + shift    (shift: 0x21〜0x6F)
    下位ニブル = b % 16 + shift
    出力: [上位ニブル, 下位ニブル]
```

**整合性検証 (ハッシュ):**

- エンコード済みデータの末尾にスペース (`0x20`) と 4 バイトのハッシュを付与
- ハッシュは ROR23 (`ror edx, 0x17`) + 加算の累積ハッシュ
- デコーダ (`decode.asm`) はまずハッシュを検証し、不一致なら実行を中止

**デコード処理 (`decode.asm`):**

```
1. call/pop パターンでエンコード済みデータのアドレスを取得
2. ROR23 ハッシュを計算し、末尾のハッシュ値と比較
3. 一致した場合:
   a. 2 バイトずつ読み取り (lodsw)
   b. 各バイトから shift 値を減算
   c. 上位ニブルを 4 bit 左シフトし、下位ニブルと加算
   d. 復元したバイトを書き込み (stosb)
4. デコード完了後、復元済み Shellcode にジャンプ
```

### 12.4 x86 / x64 対応

| 項目 | x86 | x64 |
|:---|:---|:---|
| スタック単位 | 4 バイト (DWORD) | 8 バイト (QWORD) |
| レジスタ退避 | `pushad` | 個別 push (rax, rcx, rdx, rbx, rsi, rdi) |
| レジスタ復元 | `popad` | 個別 pop |
| ret の置換 | `mov esp, ebx; popad; ret` | `mov rsp, rbx; pop rdi..rax; ret` |
| 0xFFFFFFFF 生成 | `push 0x21; pop eax; xor al, 0x21; dec eax` | `push 0x31323334; pop rax; sub rax, 0x31323335` |

### 12.5 x64 での 0xFFFFFFFF_FFFFFFFF 生成

x64 では 64-bit の `0xFFFFFFFF_FFFFFFFF` を生成するために、
即値のオーバーフローを利用する：

```nasm
push 0x31323334       ; rax = 0x31323334 (符号拡張で 0x00000000_31323334)
pop rax
sub rax, 0x31323335   ; rax = 0xFFFFFFFF_FFFFFFFF (-1)
```

さらに上位 32-bit と下位 32-bit を独立して操作するため、
以下のマスク値を用意する:

```nasm
; rcx = 0xFFFFFFFF_FFFFFFFF (前述)
push rcx
xor [rsp + rsi + 0x30], ecx   ; 下位 32-bit を XOR
pop rdx                        ; rdx = 0xFFFFFFFF_00000000

push rcx
xor [rsp + rsi + 0x34], ecx   ; 上位 32-bit を XOR
pop rdi                        ; rdi = 0x00000000_FFFFFFFF
```

---

## 13. ツールチェインとデバッグ

### 13.1 アセンブルとリンク

```bash
# x86 (32-bit) ELF
nasm -f elf32 shellcode.asm -o shellcode.o
ld -melf_i386 -o shellcode shellcode.o

# x64 (64-bit) ELF
nasm -f elf64 shellcode.asm -o shellcode.o
ld -o shellcode shellcode.o

# Windows (32-bit)
nasm -f win32 shellcode.asm -o shellcode.obj
link /entry:_start /subsystem:console shellcode.obj

# macOS ARM64
as -arch arm64 shellcode.s -o shellcode.o
ld -arch arm64 -e _main -o shellcode shellcode.o -lSystem \
   -syslibroot $(xcrun -sdk macosx --show-sdk-path)
```

### 13.2 バイト列の抽出

```bash
# objdump からバイト列を "\x" 形式で抽出
objdump -d ./shellcode | \
  grep '[0-9a-f]:' | \
  grep -v 'file' | \
  cut -f2 -d: | \
  cut -f1-7 -d' ' | \
  tr -s ' ' | \
  tr '\t' ' ' | \
  sed 's/ $//g' | \
  sed 's/ /\\x/g' | \
  paste -d '' -s | \
  sed 's/^/"/' | \
  sed 's/$/"/g'
```

### 13.3 ヌルバイトの確認

```bash
# ヌルバイトを含む行をハイライト
objdump -d ./shellcode | grep '\\x00'

# xxd でバイナリ確認
xxd shellcode | grep ' 00'
```

### 13.4 デバッグツール

| ツール | 用途 | OS |
|:---|:---|:---|
| `gdb` | 汎用デバッガ | Linux |
| `gdb` + `peda` / `gef` / `pwndbg` | セキュリティ研究向け拡張 | Linux |
| `lldb` | Apple 環境デバッガ | macOS |
| `x64dbg` / `x32dbg` | GUI デバッガ | Windows |
| `WinDbg` | カーネルデバッグも可能 | Windows |
| `cdb.exe` | コマンドラインデバッガ | Windows |
| `radare2` / `rizin` | リバースエンジニアリングフレームワーク | 全 OS |
| `strace` / `ltrace` | システムコール/ライブラリ呼び出しトレース | Linux |

### 13.5 Shellcode テスト用 C ラッパー

```c
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>

unsigned char shellcode[] = "\x31\xc0\x50\x68...";

int main() {
    void *exec = mmap(NULL, sizeof(shellcode),
                      PROT_READ | PROT_WRITE | PROT_EXEC,
                      MAP_ANON | MAP_PRIVATE, -1, 0);
    memcpy(exec, shellcode, sizeof(shellcode));
    ((void(*)())exec)();
    return 0;
}
```

```bash
gcc -z execstack -o test test.c
./test
```

---

## 14. 参考文献

### x86/x64 命令セット
- [Intel® 64 and IA-32 Architectures Software Developer's Manuals](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html)
- [x86 Opcode Reference (coder32)](http://ref.x86asm.net/coder32.html)
- [x86-64 Opcode Reference (coder64)](http://ref.x86asm.net/coder64.html)
- [Felix Cloutier's x86 Reference](https://www.felixcloutier.com/x86/)

### Linux システムコール
- [Linux Syscall Table (x86)](https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md#x86-32_bit)
- [Linux Syscall Table (x64)](https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md#x86_64-64_bit)

### Windows Shellcode
- [WINDOWS_SHELLCODE.md](./WINDOWS_SHELLCODE.md) — 本プロジェクトの Windows 専用文書
- [Basics of Windows shellcode writing](https://idafchev.github.io/exploit/2017/09/26/writing_windows_shellcode.html)

### エンコーディング・難読化
- [ALPHA3 Alphanumeric Encoder](https://github.com/SkyLined/alpha3)
- [Phrack: Writing ia32 alphanumeric shellcodes](http://phrack.org/issues/57/15.html)

### セキュリティ機構
- [Microsoft DEP Documentation](https://learn.microsoft.com/en-us/windows/win32/memory/data-execution-prevention)
- [Return-Oriented Programming (Shacham, 2007)](https://hovav.net/ucsd/dist/rop.pdf)
