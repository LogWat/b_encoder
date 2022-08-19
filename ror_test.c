#include <stdio.h>

void print_bin(int n) {
    for (int i = 0; i < 32; i++) printf("%d", (n >> i) & 1);
}

unsigned int ror(unsigned int x, unsigned int n)
{
    print_bin(x);
    unsigned int a = (x >> n) | (x << (32 - n));
    printf(" => ");
    print_bin(a);
    printf("\n");
    return a;
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Usage: %s <number>\n", argv[0]);
        return 1;
    }
    char *s = argv[1];
    unsigned int hash = 0;
    while (*s) {
        printf("%c: ", *s);
        hash = ror(hash, 0xd);
        hash += *s;
        s++;
    }
    printf("%s = 0x%08x\n", argv[1], hash);
    return 0;
}