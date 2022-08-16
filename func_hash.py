# Function name encode program
# When searching for a function to be called in Name Pointer Table
# by name, the function name as comparison target is hashed and
# compared accordingly.
# This program peforms the hashing.

# ROR function (Rotate val right by r_bits)
def ror(val, r_bits):
    val_str = bin(val)[2:]
    print("{} => ".format(val_str), end='')
    for _ in range(0, r_bits):
        val_str = val_str[-1] + val_str[:-1]
    print("{}".format(val_str))
    val = int(val_str, 2)
    return val
    

func_name = input("Enter function name: ")

hash_num = 0
for c in func_name:
    hash_num = ror(hash_num, 0xd)
    hash_num += ord(c)

hash_num -= 1

print("Hash value: 0x{:02X}".format(hash_num))