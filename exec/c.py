# バイト列をバイナリ文字列として保存する
with open('in', 'r') as f, open('out.st', 'wb') as g:
    l = f.read().replace('\n', '').split('\\x')
    x = []
    for i in l:
        if i:
            x.append(int(i, 16))
    g.write(bytes(x))