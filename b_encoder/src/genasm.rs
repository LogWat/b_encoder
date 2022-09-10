use std::fs;
use std::io::prelude::*;

pub fn generate_asm(bytes: &Vec<(u32, u32, u32)>, output: &mut fs::File) -> std::io::Result<()> {
    let mut asm = String::new();
    asm.push_str("section .text\n\n");
    asm.push_str("global _start\n");

    asm.push_str("_start:\n");
    asm.push_str("    pushad\n");

    // eax = any
    // ecx = 0xFFFFFFFF : for xor
    // ebx = original esp
    // esi = -0x30(-48) ~ -0x36(-54) : for index ([esp + esi + xxx])
    asm.push_str("register:\n");
    asm.push_str("    push 0x21\n");
    asm.push_str("    pop eax\n");
    asm.push_str("    xor al , 0x21\n"); // eax = 0x00
    asm.push_str("    dec eax\n");       // eax = 0xFFFFFFFF
    asm.push_str("    push eax\n");
    asm.push_str("    xor al, 0x2f\n"); // <============================ random ?
    asm.push_str("    push eax\n");
    asm.push_str("    pop esi\n");       // esi = 0xFFFFFFFF ^ 0x2f = 0xFFFFFFD0 (-48)
    asm.push_str("    pop ecx\n");       // ecx = 0xFFFFFFFF
    asm.push_str("    push esp\n");
    asm.push_str("    pop ebx\n");       // ebx = original esp + all registers

    asm.push_str("encode:\n");
    for (stand, num1, num2) in bytes.iter().rev() {
        asm.push_str(&format!("; push 0x{:08x}\n", stand ^ num1 ^ num2)); // comment
        // count bits of stand
        let fcnt = stand.count_ones() / 8;
        // if the num of 0xFF in stand is over 2, push 0xFFFFFFFF first
        if fcnt > 2 {
            asm.push_str("    push ecx\n");
            asm.push_str("    pop eax\n");
            asm.push_str(&format!("    xor eax, 0x{:08x}\n", num1));
            asm.push_str(&format!("    xor eax, 0x{:08x}\n", num2));
            asm.push_str("    push eax\n");
            if *stand != 0xFFFFFFFF as u32 {
                for j in 0..4 {
                    if stand & (0xFF << (j * 8)) == 0x00000000 as u32 {
                        let idx: u8 = 0x30 + (j as u8);
                        asm.push_str(&format!("    xor [esp + esi + 0x{:02x}], ch\n", idx));
                    }
                }
            }
        } else {
            asm.push_str(&format!("    push 0x{:08x}\n", num1));
            asm.push_str("    pop eax\n");
            asm.push_str(&format!("    xor eax, 0x{:08x}\n", num2));
            asm.push_str("    push eax\n");
            // 特例: stand = 0x0000FFFF
            // esp直接参照xor式 = 8 bytes, edx inc式 = 7 bytes
            if *stand == 0x0000FFFF as u32 {
                asm.push_str("    push esp\n");
                asm.push_str("    pop edx\n");
                asm.push_str("    xor [edx], ch\n");
                asm.push_str("    inc edx\n");
                asm.push_str("    xor [edx], ch\n");
            } else if *stand != 0x00000000 as u32 {
                for j in 0..4 {
                    if stand & (0xFF << (j * 8)) != 0x00000000 as u32 {
                        let idx: u8 = 0x30 + (j as u8);
                        asm.push_str(&format!("    xor [esp + esi + 0x{:02x}], ch\n", idx));
                    }
                }
            }
        }
    }

    asm.push_str("; jmp to shellcode\n");
    asm.push_str("to_shellcode:\n");
    asm.push_str("    jmp esp\n"); // this isn't ASCII!!! NOO

    output.write_all(asm.as_bytes())
}