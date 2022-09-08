use std::fs;
use std::io::prelude::*;

pub fn generate_asm(bytes: &Vec<(u32, u32, u32)>, output: &mut fs::File) -> std::io::Result<()> {
    let mut asm = String::new();
    asm.push_str("section .text\n\n");
    asm.push_str("global _start\n");

    asm.push_str("_start:\n");
    asm.push_str("    pushad\n");
    asm.push_str("    pushfd\n");


    asm.push_str("register:\n");
    asm.push_str("    push 0x21\n");
    asm.push_str("    pop eax\n");
    asm.push_str("    xor al , 0x21\n"); // eax = 0x00
    asm.push_str("    push eax\n");
    asm.push_str("    pop ebx\n");       // ebx = 0x00
    asm.push_str("    dec ebx\n");       // ebx = 0xFFFFFFFF
    asm.push_str("    push esp\n");
    asm.push_str("    pop ecx\n");       // ecx = original esp + all registers

    asm.push_str("encode:\n");
    for (i, (stand, num1, num2)) in bytes.iter().rev().enumerate() {
        asm.push_str(&format!("; push 0x{:08x}\n", stand ^ num1 ^ num2)); // comment
        asm.push_str(&format!("    push 0x{:08x}\n", num1));
        asm.push_str("    pop eax\n");
        asm.push_str(&format!("    xor eax, 0x{:08x}\n", num2));
        if *stand != 0x00000000 as u32 {
            asm.push_str("    push esp\n");
            asm.push_str("    pop edx\n");
            for j in 0..4 {
                if stand & (0xFF << (j * 8)) != 0x00000000 as u32 {
                    asm.push_str("    inc edx\n");
                    asm.push_str("    xor byte [edx], dl\n"); // ^ 0xFF
                }
            }
        }
    }

    asm.push_str("retpre:\n");
    asm.push_str("    push ecx\n"); // ecx = original esp + all registers
    asm.push_str("    pop esp\n");  // esp = original esp + all registers
    asm.push_str("    popfd\n");
    asm.push_str("    popad\n");    // esp = original esp
    asm.push_str("    ret\n");

    output.write_all(asm.as_bytes())
}