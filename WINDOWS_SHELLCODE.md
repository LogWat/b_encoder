# Windows Shellcode 技術文書

本文書は、`b_encoder` プロジェクトの README に記載されていた Windows Shellcode メモを大幅に拡充し、独立した技術資料としてまとめたものである。

> **注意**: 本文書はセキュリティ研究・教育目的の技術資料である。

---

## 目次

1. [Windows アーキテクチャと Shellcode の基礎](#1-windows-アーキテクチャと-shellcode-の基礎)
2. [TEB / PEB 構造体](#2-teb--peb-構造体)
3. [DLL Base Address の解決](#3-dll-base-address-の解決)
4. [PE エクスポートテーブルと関数アドレス解決](#4-pe-エクスポートテーブルと関数アドレス解決)
5. [API ハッシング技法](#5-api-ハッシング技法)
6. [ヌルバイト回避と Position-Independent Code](#6-ヌルバイト回避と-position-independent-code)
7. [x64 呼び出し規約](#7-x64-呼び出し規約)
8. [本プロジェクトのコード解説](#8-本プロジェクトのコード解説)
9. [参考文献](#9-参考文献)

---

## 1. Windows アーキテクチャと Shellcode の基礎

### 1.1 Linux との根本的な違い

Linux では `int 0x80` や `syscall` 命令でカーネルのシステムコールに直接アクセスできる。
一方 Windows では、ユーザモードアプリケーションはシステムコールに直接アクセスできず、
以下の多層構造を経由する:

```
  ユーザモード                     カーネルモード
┌─────────────────┐            ┌──────────────────┐
│   Application   │            │                  │
│        │        │            │   Windows Kernel │
│        ▼        │            │   (ntoskrnl.exe) │
│  WinAPI (Win32) │            │        ▲         │
│  kernel32.dll   │            │        │         │
│  advapi32.dll   │            │   syscall        │
│  user32.dll ... │            │                  │
│        │        │            └──────────────────┘
│        ▼        │
│  NtAPI (Native) │
│  ntdll.dll      │──── syscall ────►
└─────────────────┘
```

| レイヤー | DLL | 説明 |
|:---:|:---|:---|
| **WinAPI** | kernel32.dll, advapi32.dll, gdi32.dll, user32.dll 等 | 文書化されたパブリック API |
| **NtAPI** | ntdll.dll | 未文書化の Native API。最終的に syscall を発行 |

### 1.2 Shellcode における制約

- **kernel32.dll** と **ntdll.dll** はすべてのプロセスに自動的にロードされる
- DLL のベースアドレスは ASLR により起動のたびに変動する
- したがって Shellcode は実行時に動的に DLL のベースアドレスを発見し、
  さらにそこから目的の API 関数のアドレスを解決する必要がある

---

## 2. TEB / PEB 構造体

### 2.1 TEB (Thread Environment Block)

TEB はスレッドごとに存在する構造体で、セグメントレジスタを通じてアクセスする。

| アーキテクチャ | セグメントレジスタ | TEB アクセス | PEB へのオフセット |
|:---:|:---:|:---:|:---:|
| **x86 (32-bit)** | `FS` | `FS:[0x00]` | `FS:[0x30]` → PEB |
| **x64 (64-bit)** | `GS` | `GS:[0x00]` | `GS:[0x60]` → PEB |

### 2.2 PEB (Process Environment Block)

PEB はプロセスごとに 1 つ存在し、プロセス全体の情報を保持する。

| オフセット (x86) | オフセット (x64) | フィールド | 説明 |
|:---:|:---:|:---|:---|
| `0x02` | `0x02` | `BeingDebugged` | デバッガ検出に使用 (BYTE) |
| `0x08` | `0x10` | `ImageBaseAddress` | 実行ファイルのベースアドレス |
| **`0x0C`** | **`0x18`** | **`Ldr`** | **`PEB_LDR_DATA` へのポインタ** |
| `0x10` | `0x20` | `ProcessParameters` | プロセスパラメータ |
| `0x18` | `0x30` | `ProcessHeap` | デフォルトヒープ |

### 2.3 PEB_LDR_DATA

ロードされた DLL 情報を管理する構造体。3 つの双方向リンクリストを持つ。

| オフセット (x86) | オフセット (x64) | フィールド | 説明 |
|:---:|:---:|:---|:---|
| `0x0C` | `0x10` | `InLoadOrderModuleList` | ロード順のモジュールリスト |
| **`0x14`** | **`0x20`** | **`InMemoryOrderModuleList`** | **メモリ配置順のモジュールリスト** |
| `0x1C` | `0x30` | `InInitializationOrderModuleList` | 初期化順のモジュールリスト |

> **なぜ `InMemoryOrderModuleList` を使うのか?**
>
> - `InInitializationOrderModuleList` では、Vista 以降 2 番目のエントリが
>   `kernel32.dll` から `kernelbase.dll` に変更された
> - `InMemoryOrderModuleList` では、全 Windows バージョンを通じて
>   2 番目が `ntdll.dll`、3 番目が `kernel32.dll` という順序が維持されている
> - このためポータビリティの観点から `InMemoryOrderModuleList` が推奨される

### 2.4 LDR_DATA_TABLE_ENTRY

各モジュールリストのノードとなる構造体。

| フィールド | 説明 |
|:---|:---|
| `InLoadOrderLinks` | `LIST_ENTRY` (ロード順リンク) |
| `InMemoryOrderLinks` | `LIST_ENTRY` (メモリ順リンク) |
| `InInitializationOrderLinks` | `LIST_ENTRY` (初期化順リンク) |
| **`DllBase`** | **モジュールのベースアドレス** |
| `EntryPoint` | モジュールのエントリポイント |
| `SizeOfImage` | メモリ上でのモジュールサイズ |
| `FullDllName` | `UNICODE_STRING` (フルパス) |
| `BaseDllName` | `UNICODE_STRING` (ファイル名のみ) |

**重要**: `LIST_ENTRY` は構造体の先頭ではなくメンバーの位置を指すため、
`DllBase` へのオフセットは使用するリストによって異なる。

#### 絶対オフセット (構造体先頭からの)

| フィールド | x86 オフセット | x64 オフセット | 型 |
|:---|:---:|:---:|:---|
| `InLoadOrderLinks` | `0x00` | `0x00` | `LIST_ENTRY` |
| `InMemoryOrderLinks` | `0x08` | `0x10` | `LIST_ENTRY` |
| `InInitializationOrderLinks` | `0x10` | `0x20` | `LIST_ENTRY` |
| **`DllBase`** | **`0x18`** | **`0x30`** | `PVOID` |
| `EntryPoint` | `0x1C` | `0x38` | `PVOID` |
| `SizeOfImage` | `0x20` | `0x40` | `ULONG` |
| `FullDllName` | `0x24` | `0x48` | `UNICODE_STRING` |
| `BaseDllName` | `0x2C` | `0x58` | `UNICODE_STRING` |

#### `InMemoryOrderModuleList` 経由時の相対オフセット

`InMemoryOrderModuleList` の `Flink` が指すのは `InMemoryOrderLinks` フィールド
(絶対オフセット x86: `0x08`, x64: `0x10`) であり、構造体の先頭 (`0x00`) ではない。
したがって各フィールドへのアクセスには以下の相対オフセットを使用する:

| フィールド | 相対オフセット (x86) | 相対オフセット (x64) | 計算式 |
|:---|:---:|:---:|:---|
| `InMemoryOrderLinks` | `+0x00` | `+0x00` | (自身) |
| `InInitializationOrderLinks` | `+0x08` | `+0x10` | `0x10 - 0x08` / `0x20 - 0x10` |
| **`DllBase`** | **`+0x10`** | **`+0x20`** | `0x18 - 0x08` / `0x30 - 0x10` |
| `EntryPoint` | `+0x14` | `+0x28` | `0x1C - 0x08` / `0x38 - 0x10` |
| `SizeOfImage` | `+0x18` | `+0x30` | `0x20 - 0x08` / `0x40 - 0x10` |
| `FullDllName` | `+0x1C` | `+0x38` | `0x24 - 0x08` / `0x48 - 0x10` |
| `BaseDllName` | `+0x24` | `+0x48` | `0x2C - 0x08` / `0x58 - 0x10` |

---

## 3. DLL Base Address の解決

### 3.1 32-bit (x86)

```
fs:0x30  ──►  PEB
               │
               ├─ +0x0C ──►  PEB_LDR_DATA
               │                  │
               │                  ├─ +0x14 ──►  InMemoryOrderModuleList
               │                                    │
               │                                    ├─ [Flink] ──► 1st: 実行ファイル自身
               │                                    │                    │
               │                                    │                    ├─ [Flink] ──► 2nd: ntdll.dll
               │                                    │                                       │
               │                                    │                                       ├─ [Flink] ──► 3rd: kernel32.dll
               │                                    │                                                          │
               │                                    │                                                          └─ +0x10 ──► DllBase
```

**アセンブリ実装:**

```nasm
; 32-bit: kernel32.dll Base Address の取得
xor ebx, ebx
mov ebx, [fs:ebx + 0x30]   ; (1) PEB
mov ebx, [ebx + 0x0C]      ; (2) PEB_LDR_DATA
mov ebx, [ebx + 0x14]      ; (3) InMemoryOrderModuleList (1st entry)
mov ebx, [ebx]              ; (4) 2nd entry (ntdll.dll)
mov ebx, [ebx]              ; (5) 3rd entry (kernel32.dll)
mov ebx, [ebx + 0x10]      ; (6) kernel32.dll DllBase
```

> **`xor ebx, ebx` を使う理由**:
> `mov ebx, [fs:0x30]` は `0x64 0x8B 0x1D 0x30 0x00 0x00 0x00` となり
> ヌルバイトを含む。`fs:ebx + 0x30` とすることで回避できる。

### 3.2 64-bit (x64)

```nasm
; 64-bit: kernel32.dll Base Address の取得
xor rbx, rbx
mov rbx, [gs:rbx + 0x60]   ; (1) PEB
mov rbx, [rbx + 0x18]      ; (2) PEB_LDR_DATA (Ldr)
mov rbx, [rbx + 0x20]      ; (3) InMemoryOrderModuleList (1st entry)
mov rbx, [rbx]              ; (4) 2nd entry (ntdll.dll)
mov rbx, [rbx]              ; (5) 3rd entry (kernel32.dll)
mov rbx, [rbx + 0x20]      ; (6) kernel32.dll DllBase
```

### 3.3 InMemoryOrderModuleList のモジュール順序

| 順番 | モジュール | 備考 |
|:---:|:---|:---|
| 1st | 実行ファイル自身 | |
| 2nd | ntdll.dll | |
| 3rd | kernel32.dll | 全 Windows バージョンで一貫 |

> **Windows バージョン間の違い**:
> - **InInitializationOrderModuleList**: Vista 以前は 2 番目が kernel32.dll だったが、
>   Vista 以降は kernelbase.dll に変更された
> - **InMemoryOrderModuleList**: 全バージョンで順序が安定しているため、
>   こちらの使用が推奨される

---

## 4. PE エクスポートテーブルと関数アドレス解決

kernel32.dll のベースアドレスを取得した後、目的の API 関数のアドレスを
PE (Portable Executable) フォーマットのエクスポートテーブルから解決する。

### 4.1 PE ヘッダの概要

```
Module Base Address
│
├─ DOS Header (IMAGE_DOS_HEADER)
│   └─ +0x3C: e_lfanew ──► PE ヘッダへのオフセット
│
├─ PE Signature ("PE\0\0" = 0x00004550)
│
├─ File Header (IMAGE_FILE_HEADER, 20 bytes)
│
├─ Optional Header (IMAGE_OPTIONAL_HEADER)
│   ├─ +0x00: Magic (0x010B=PE32, 0x020B=PE32+)
│   │         ← Optional Header の先頭 = PE Signature + 0x18
│   └─ DataDirectory[0] (Export Directory)
│       ├─ 32-bit: Optional Header + 0x60 = PE Sig + 0x78
│       └─ 64-bit: Optional Header + 0x70 = PE Sig + 0x88
│
└─ Sections...
```

### 4.2 IMAGE_EXPORT_DIRECTORY 構造体

エクスポートテーブルの構造体は **32-bit / 64-bit 共通のレイアウト** を持つ。

| オフセット | サイズ | フィールド | 説明 |
|:---:|:---:|:---|:---|
| `+0x00` | 4 | `Characteristics` | 予約済み (0) |
| `+0x04` | 4 | `TimeDateStamp` | タイムスタンプ |
| `+0x08` | 2 | `MajorVersion` | メジャーバージョン |
| `+0x0A` | 2 | `MinorVersion` | マイナーバージョン |
| `+0x0C` | 4 | `Name` | DLL 名の RVA |
| `+0x10` | 4 | `Base` | 開始オーディナル番号 |
| **`+0x14`** | 4 | **`NumberOfFunctions`** | **EAT のエントリ数** |
| `+0x18` | 4 | `NumberOfNames` | 名前付きエクスポートの数 |
| **`+0x1C`** | 4 | **`AddressOfFunctions`** | **Export Address Table (EAT) の RVA** |
| **`+0x20`** | 4 | **`AddressOfNames`** | **Name Pointer Table の RVA** |
| **`+0x24`** | 4 | **`AddressOfNameOrdinals`** | **Ordinal Table の RVA** |

### 4.3 RVA (Relative Virtual Address) とは

```
Virtual Address (VA) = Module Base Address + RVA
```

- RVA はモジュールのベースアドレスからの相対オフセット
- ASLR 環境下でも、ベースアドレスさえ判明すれば内部構造にアクセス可能
- Shellcode はメモリ上にロード済みの DLL を操作するため、
  ファイルオフセット ↔ RVA の変換は不要

### 4.4 3 つのテーブルの関係

```
AddressOfNames             AddressOfNameOrdinals        AddressOfFunctions
(DWORD[] RVA→文字列)       (WORD[] インデックス)          (DWORD[] RVA→関数)
┌──────────────────┐       ┌───────────────────┐       ┌──────────────────┐
│ [0]: "CreateFil" │       │ [0]: 5            │──────►│ [5]: RVA_func_A  │
│ [1]: "ExitProce" │       │ [1]: 2            │──┐    │ [2]: RVA_func_B  │
│ [2]: "GetProcAd" │       │ [2]: 8            │  │    │ [8]: RVA_func_C  │
│  ...             │       │  ...              │  │    │  ...             │
│ [i]: "WinExec"   │──┐    │ [i]: ordinal_k    │  │    │ [k]: RVA_WinExec │
└──────────────────┘  │    └───────────────────┘  │    └──────────────────┘
                      │                           │               │
                      └── 名前比較(or ハッシュ比較) │               │
                          でインデックス i を発見    └── ordinal_k ──┘
                                                        を取得          → Base + RVA = VA
```

### 4.5 関数アドレス解決の手順

#### 32-bit

```
Step  命令                                     説明
──── ──────────────────────────────────────── ────────────────────────────
 1.  [Base + 0x3C]                            → e_lfanew (PE Sig の RVA)
 2.  Base + (1)                               → PE Signature のアドレス
 3.  [(2) + 0x78]                             → Export Table の RVA
 4.  Base + (3)                               → Export Table のアドレス
 5.  [(4) + 0x14]                             → エクスポート関数の総数
 6.  [(4) + 0x1C] → Base + RVA               → Address Table のアドレス
 7.  [(4) + 0x20] → Base + RVA               → Name Pointer Table のアドレス
 8.  [(4) + 0x24] → Base + RVA               → Ordinal Table のアドレス
 9.  (7) をループして関数名を比較              → インデックス i を発見
10.  [(8) + i * 2]                            → Ordinal Number
11.  [(6) + (10) * 4]                         → 関数の RVA
12.  Base + (11)                              → 関数の VA (呼び出し可能)
```

#### 64-bit

```
Step  命令                                     説明
──── ──────────────────────────────────────── ────────────────────────────
 1.  [Base + 0x3C]                            → e_lfanew (32-bit DWORD)
 2.  Base + (1)                               → PE Signature のアドレス
 3.  [(2) + 0x88]                             → Export Table の RVA
 4.  Base + (3)                               → Export Table のアドレス
 5～12: 32-bit と同一の手順
     (テーブル内の RVA は 32-bit DWORD のまま)
```

> **32-bit vs 64-bit の主な差異**:
> - Export Table への DataDirectory オフセット: `0x78` (32-bit) vs `0x88` (64-bit)
> - `IMAGE_EXPORT_DIRECTORY` 構造体自体は同一レイアウト
> - テーブル内の RVA は両アーキテクチャとも 32-bit DWORD
> - ただし Base Address の加算結果は 64-bit ポインタになる

#### 32-bit アセンブリ実装例

```nasm
; ebx = kernel32.dll Base Address (前節で取得済み)
funcaddr:
    mov edx, [ebx + 0x3c]          ; e_lfanew → PE Sig RVA
    mov edx, [edx + ebx + 0x78]    ; Export Table RVA
    add edx, ebx                   ; Export Table Address
    mov ecx, [edx + 0x14]          ; NumberOfFunctions (ループカウンタ)
    mov eax, [edx + 0x1C]          ; Address Table RVA
    add eax, ebx                   ; Address Table Address
    push eax                       ; Address Table をスタックに退避
    mov edi, [edx + 0x20]          ; Name Pointer Table RVA
    add edi, ebx                   ; Name Pointer Table Address
    mov edx, [edx + 0x24]          ; Ordinal Table RVA
    add edx, ebx                   ; Ordinal Table Address
    push edx                       ; Ordinal Table をスタックに退避
.tableloop:
    jecxz .notfound                ; ecx == 0 なら関数が見つからなかった
    dec ecx
    mov esi, [edi + ecx * 4]       ; NameTable[ecx] の RVA
    add esi, ebx                   ; NameTable[ecx] の VA
    ; ... (ハッシュ比較、次節参照) ...
.found:
    pop edx                        ; Ordinal Table
    pop eax                        ; Address Table
    mov cx, [edx + ecx * 2]        ; OrdinalTable[ecx] (WORD)
    mov edx, [eax + ecx * 4]       ; AddressTable[ordinal] (RVA)
    add edx, ebx                   ; 関数の VA
```

### 4.6 Forwarded Export について

`AddressOfFunctions` から取得した RVA がエクスポートディレクトリの範囲内にある場合、
それは **Forwarded Export** (転送エクスポート) である。

- RVA が指す先は `"DLLNAME.FunctionName"` 形式の ASCII 文字列
  (例: `"NTDLL.RtlAllocateHeap"`)
- この場合、転送先 DLL をロードし、再帰的に関数を解決する必要がある

---

## 5. API ハッシング技法

### 5.1 なぜハッシュを使うのか

- 関数名の文字列をそのまま Shellcode に埋め込むとサイズが肥大化する
- 文字列はセキュリティソフトに容易に検出される
- **4 バイトのハッシュ値** に圧縮することで、サイズ削減と検出回避を両立する

### 5.2 ROR ハッシングアルゴリズム

本プロジェクトでは `ror edx, 0x11` (17-bit 右ローテーション) を使用している。

**アルゴリズム (擬似コード):**

```
hash = 0
for each char c in function_name:
    hash = ror(hash, 17)   // 32-bit 右ローテーション
    hash = hash + c        // 文字の ASCII 値を加算
return hash
```

**C 言語での実装** (本プロジェクトの `test/ror_test.c` より):

```c
unsigned int ror(unsigned int x, unsigned int n) {
    return (x >> n) | (x << (32 - n));
}

unsigned int compute_hash(const char *s) {
    unsigned int hash = 0;
    while (*s) {
        hash = ror(hash, 0x11);
        hash += *s;
        s++;
    }
    return hash;
}
```

**アセンブリでのハッシュ比較:**

```nasm
; esi = 関数名の先頭アドレス
xor eax, eax               ; lodsb 用にクリア
xor edx, edx               ; ハッシュ値初期化
.nameloop:
    lodsb                   ; al = *esi++
    test al, al             ; ヌル終端チェック
    jz .hashcheck
    ror edx, 0x11           ; 17-bit 右ローテーション
    add edx, eax            ; 文字を加算
    jmp .nameloop
.hashcheck:
    cmp edx, 0x3c3e6889    ; "WinExec" のハッシュ値と比較
    jnz .tableloop          ; 不一致ならば次の関数へ
```

### 5.3 一般的なハッシュアルゴリズムの比較

| アルゴリズム | ローテーション量 | 特徴 |
|:---|:---:|:---|
| **ROR13** | 13-bit | Metasploit で広く使用。最も一般的 |
| **ROR17** | 17-bit | 本プロジェクトで使用。衝突がより少ない |
| **CRC32** | - | 高精度だが計算コストが高い |
| **djb2** | - | シンプルだが Shellcode での使用は稀 |

### 5.4 既知のハッシュ値例 (ROR17)

| 関数名 | ハッシュ値 (ROR17) |
|:---|:---|
| `WinExec` | `0x3C3E6889` |

---

## 6. ヌルバイト回避と Position-Independent Code

### 6.1 ヌルバイト (`0x00`) の問題

多くのエクスプロイトでは `strcpy` 等の文字列関数を介して Shellcode を注入するため、
`0x00` が含まれるとそこで文字列が切断される。

### 6.2 回避テクニック

| 問題のある命令 | バイト列 | 代替手法 | バイト列 |
|:---|:---|:---|:---|
| `mov eax, 0` | `B8 00 00 00 00` | `xor eax, eax` | `31 C0` |
| `mov ebx, 0` | `BB 00 00 00 00` | `xor ebx, ebx` | `31 DB` |
| `push 0` | `6A 00` | `xor eax, eax` → `push eax` | `31 C0 50` |
| 文字列に `\0` を含む | - | スタック上で SUB で生成 | - |

**スタック上での文字列生成例** (本プロジェクトの test32.asm より):

```nasm
; "calc\0" をスタック上に生成 (ヌルバイト回避)
push 0x21212121             ; ダミー値をプッシュ
sub dword [esp], 0x21212121 ; 0x00000000 を生成 (ヌル終端)
push 0x848d8284             ; エンコード済みの値をプッシュ
sub dword [esp], 0x21212121 ; 0x636C6163 ("calc") を復元
```

`0x636C6163` + `0x21212121` = `0x848D8284` という計算に基づく。

### 6.3 Position-Independent Code (PIC)

Shellcode はメモリ上のどこに配置されるか事前に分からないため、
絶対アドレスを使用できない。

**主なテクニック:**

- **call/pop パターン**: `call` 命令がリターンアドレス (= 次の命令のアドレス) を
  スタックに積む性質を利用して EIP/RIP を取得する
- **jmp/call/pop パターン**: jmp → call → pop の組み合わせ
- **x64 RIP 相対アドレッシング**: x64 では `lea rax, [rip + offset]` が使用可能

**本プロジェクトの decode.asm での実装例:**

```nasm
.getencodedshellcode:
    push -0x3d
    call esp              ; call/pop パターンの変形
    pop esi               ; 現在のアドレスを取得
    mov esi, dword [esp - 0x8]
    add esi, 0x59         ; エンコードされた shellcode のアドレスを計算
```

### 6.4 PEB Walk 実装時の落とし穴

#### 落とし穴 1: LIST_ENTRY のオフセット誤り

- **誤り**: `InMemoryOrderModuleList` の `Flink` を `LDR_DATA_TABLE_ENTRY` の先頭
  (`0x00`) と仮定して `DllBase` を `+0x18` (x86) / `+0x30` (x64) で読む
- **結果**: 実際には `InMemoryOrderLinks` (x86: `+0x08`, x64: `+0x10`) を指しているため、
  誤ったメモリを参照する
- **対策**: 上記の相対オフセット表を使用し、x86 では `+0x10`、x64 では `+0x20` で
  `DllBase` にアクセスする

#### 落とし穴 2: モジュール順序のハードコーディング

- **誤り**: kernel32.dll が必ず 3 番目のエントリであると仮定する
- **結果**: Windows 10/11 の並列 DLL ロード、EDR のフック DLL 早期注入、
  AppCompat shim 等の影響で順序が変わることがある
- **対策**: リストを動的に走査し、`BaseDllName` のハッシュ比較でモジュールを特定する

#### 落とし穴 3: UNICODE_STRING の扱い

- **誤り**: `BaseDllName` を ASCII の C 文字列として扱う
- **結果**: UTF-16LE (2 バイト/文字) のためハッシュ計算が狂う
- **対策**:
  - `BaseDllName` は `UNICODE_STRING` 構造体 (`Length`, `MaximumLength`, `Buffer`)
  - `Buffer` は UTF-16LE であり、ヌル終端が保証されない
  - `Length` フィールドでバイト長を取得する
  - 大文字小文字を正規化してからハッシュする

#### 落とし穴 4: 循環リストの終了判定

- **誤り**: `Flink == NULL` をループ終了条件にする
- **結果**: NT の `LIST_ENTRY` は循環双方向リストであり、末尾は `PEB_LDR_DATA` 内の
  リストヘッドに戻る。`NULL` チェックでは無限ループまたはアクセス違反が発生する
- **対策**: 最初のリストヘッドアドレスを保存し、`Flink` がそのアドレスに
  戻ったらループを終了する

#### 落とし穴 5: WOW64 環境

- **誤り**: 64-bit Windows 上の 32-bit プロセスで `gs:[0x60]` を使用、
  またはその逆
- **結果**: 不正なセグメントセレクタによるクラッシュ
- **対策**: 実行モードに応じたセグメントレジスタを使用
  (x86 モード → `FS`、x64 モード → `GS`)
- **注意**: WOW64 プロセスは 32-bit 用と 64-bit 用の
  TEB/PEB を両方持つ

---

## 7. x64 呼び出し規約

x64 Windows では **Microsoft x64 Calling Convention** に従う必要がある。
これに違反するとクラッシュやスタック破壊が発生する。

### 7.1 レジスタによる引数渡し

| 引数番号 | レジスタ |
|:---:|:---:|
| 第 1 引数 | `RCX` |
| 第 2 引数 | `RDX` |
| 第 3 引数 | `R8` |
| 第 4 引数 | `R9` |
| 第 5 引数以降 | スタック |

戻り値は `RAX` に格納される。

### 7.2 Shadow Space (ホーミングスペース)

- 呼び出し側は関数呼び出し前にスタック上に **32 バイト (0x20)** の
  シャドウスペースを確保する義務がある
- この領域は呼び出された関数が引数レジスタ (RCX, RDX, R8, R9) を
  退避するために使用される
- **引数が 4 つ未満、あるいは 0 個であっても確保が必要**

### 7.3 スタックアラインメント

- `call` 命令実行時に **RSP は 16 バイト境界にアラインされている必要がある**
- `call` 命令自体がリターンアドレス (8 バイト) をプッシュするため、
  関数内部では RSP は 8 バイトずれた状態になる
- 典型的な確保量: **0x28 バイト** (32 + 8) または **0x30 バイト** 以上

```nasm
; x64 関数呼び出しの典型パターン
mov rcx, arg1           ; 第 1 引数
mov rdx, arg2           ; 第 2 引数
sub rsp, 0x28           ; shadow space (0x20) + alignment (0x08)
call function_address
add rsp, 0x28           ; スタックの復元
```

### 7.4 Volatile / Non-volatile レジスタ

| 分類 | レジスタ |
|:---|:---|
| **Volatile** (呼び出しで破壊される) | RAX, RCX, RDX, R8, R9, R10, R11 |
| **Non-volatile** (呼び出しで保存される) | RBX, RBP, RDI, RSI, R12, R13, R14, R15 |

### 7.5 実装例 (本プロジェクトの test64.asm より)

```nasm
; WinExec("calc.exe", SW_SHOW) の呼び出し
    xor rdx, rdx
    push rdx                            ; 0x00 (ヌル終端)
    mov rax, 0x6578652E636C6163         ; "calc.exe" (リトルエンディアン)
    push rax
    mov rcx, rsp                        ; 第 1 引数: 文字列ポインタ
    inc rdx                             ; 第 2 引数: 0x01 (SW_SHOW)
    sub rsp, 0x20                       ; shadow space 確保
    call r12                            ; WinExec 呼び出し
```

---

## 8. 本プロジェクトのコード解説

### 8.1 test32.asm — 32-bit WinExec(calc) Shellcode

**処理フロー:**

```
1. pushad/pushfd でレジスタを退避
2. fs:[0x30] → PEB → PEB_LDR_DATA → InMemoryOrderModuleList
   → kernel32.dll Base Address を取得
3. PE ヘッダを辿り Export Table → Name Table → Ordinal Table → Address Table
4. 各関数名を ROR17 ハッシュと比較し WinExec (0x3C3E6889) を検索
5. WinExec のアドレスを取得
6. スタック上に "calc\0" を SUB テクニックで生成
7. WinExec("calc", SW_SHOW) を呼び出し
8. popad/popfd でレジスタを復元し ret
```

### 8.2 test64.asm — 64-bit WinExec(calc.exe) Shellcode

**処理フロー:**

```
1. 使用するレジスタを個別に push で退避 (pushad は x64 に存在しない)
2. gs:[0x60] → PEB → PEB_LDR_DATA → InMemoryOrderModuleList
   → kernel32.dll Base Address を取得
3. PE ヘッダを辿り (+0x88 のオフセットに注意) Export Table を取得
4. ROR17 ハッシュで WinExec を検索
5. x64 呼び出し規約に従い:
   - rcx = "calc.exe" へのポインタ
   - rdx = 1 (SW_SHOW)
   - sub rsp, 0x20 で shadow space を確保
6. WinExec 呼び出し後、レジスタを復元して ret
```

**32-bit との主な違い:**

| 項目 | 32-bit | 64-bit |
|:---|:---|:---|
| PEB アクセス | `fs:[0x30]` | `gs:[0x60]` |
| Ldr オフセット | `+0x0C` | `+0x18` |
| InMemoryOrderModuleList | `+0x14` | `+0x20` |
| DllBase オフセット | `+0x10` | `+0x20` |
| Export Table DataDirectory | `+0x78` | `+0x88` |
| 引数渡し | スタック | RCX, RDX, R8, R9 |
| Shadow space | 不要 | 0x20 バイト必須 |
| pushad/popad | 使用可能 | 存在しない (個別 push/pop) |

### 8.3 decode.asm — ポリモーフィックデコーダ

本プロジェクトの b_encoder でエンコードされた Shellcode を実行時に復元するデコーダ。

**処理フロー:**

```
1. call/pop パターンでエンコード済み shellcode のアドレスを取得
2. ハッシュ検証 (ROR23):
   - エンコード済みデータの末尾に付与されたハッシュ値と比較
   - 不一致なら改竄とみなし exit
3. デコードループ:
   - 2 バイトずつ読み取り (lodsw)
   - 各バイトから 0x61 を減算して元のバイト値を復元
   - 上位ニブルと下位ニブルを再構成 (shl + add)
   - stosb でデコード先に書き込み
4. デコード完了後、復元された shellcode にジャンプ
```

---

## 9. 参考文献

- [Basics of Windows shellcode writing](https://idafchev.github.io/exploit/2017/09/26/writing_windows_shellcode.html) — Iliya Dafchev
- [x86 Opcode Reference](http://ref.x86asm.net/coder32.html)
- [Microsoft PE and COFF Specification](https://learn.microsoft.com/en-us/windows/win32/debug/pe-format)
- [Microsoft x64 Calling Convention](https://learn.microsoft.com/en-us/cpp/build/x64-calling-convention)
- [Windows Internals — PEB/TEB](https://learn.microsoft.com/en-us/windows/win32/api/winternl/ns-winternl-peb)
- [Nirsoft Kernel Struct — PEB_LDR_DATA](https://www.nirsoft.net/kernel_struct/vista/PEB_LDR_DATA.html)
