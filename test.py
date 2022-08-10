# 与えられたバイト列から，目的のASCII範囲への変換を行うための
# 変換式を求めるプログラム

l = []

print("[!] Encode")
for i in range(0x0, 0xFF + 1):
    b0 = i % 0x10   # 下位4bit
    b1 = i // 0x10  # 上位4bit
    b0 += 0x61      # 0x1 ~ 0xF -> 0x61 ~ 0x70
    b1 += 0x61      # 0x1 ~ 0xF -> 0x61 ~ 0x70
    print("0x{:02X} => {}{}".format(i, chr(b1), chr(b0)))
    l.append(chr(b1) + chr(b0))

print("[!] Decode")
for i in l:
    r = (ord(i[0]) - 0x61 << 4) + (ord(i[1]) - 0x61)
    print("{} => 0x{:02X}".format(i, r))