# 実験用

l = []

print("[!] Encode")
c = 0
for i in range(0x0, 0xFF + 1):
    b0 = i % 0x10   # 下位4bit
    b1 = i // 0x10  # 上位4bit
    b0 += 0x61      # 0x1 ~ 0xF -> 0x61 ~ 0x70
    b1 += 0x61      # 0x1 ~ 0xF -> 0x61 ~ 0x70
    print("0x{:02X} => {}{} | ".format(i, chr(b1), chr(b0)), end='')
    c += 1
    if c % 0x10 == 0:
        print("")
    l.append(chr(b1) + chr(b0))

print("[!] Decode")
c = 0
for i in l:
    r = ((ord(i[0]) - 0x61) << 4) + ord(i[1]) - 0x61
    print("{} => 0x{:02X} | ".format(i, r), end='')
    c += 1
    if c % 0x10 == 0:
        print("")