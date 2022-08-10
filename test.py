# 与えられたバイト列から，目的のASCII範囲への変換を行うための
# 変換式を求めるプログラム

for i in range(0x1, 0xFF + 1):
    # convert 0x1 ~ 0xFF to ASCII(0x21 ~ 0x7E)
    a = i & 0x7F + (i & 0x80 >> 8)
    if a > 0x7E or a < 0x21:
        print('[!] {}: {}'.format(hex(i), hex(a)))
    else:
        print('[*] {}: {}'.format(hex(i), chr(a)))