# バイト列をバイナリ文字列として保存する
from glob import escape


with open('in', 'r') as f, open('out.st', 'wb') as g:
    l = f.read().replace('\n', '').split('\\x')
    e = []
    for i in l:
        if i:
            if chr(int(i, 16)) == '"' or chr(int(i, 16)) == '\\':
                e.append(ord('\\'))
            e.append(int(i, 16))
    x = []
    first = True
    counter = 0
    for i in e:
        if i:
            if first:
                x.append(ord('"'))
                first = False

            x.append(i)
            counter += 1
            if counter == 67:
                x.append(ord('"'))
                x.append(ord('\n'))
                x.append(ord('"'))
                counter = 0
    g.write(bytes(x))