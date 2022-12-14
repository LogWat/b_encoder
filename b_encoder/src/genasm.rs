use std::fs;
use std::io::prelude::*;

use crate::logic::StackSize;
use crate::asm_helper;
use crate::asm_helper::{Reg16, Reg32, Reg64, Register};


pub fn generate_asm(bytes: &Vec<(StackSize, StackSize, StackSize)>, output: &mut fs::File) -> std::io::Result<()> {
    let mut asm = String::new();
    let mut arch = 0;
    for (i, values) in bytes.iter().rev().enumerate() {
        if i == 0 {  // init
            match values {
                (StackSize::X86(_), StackSize::X86(_), StackSize::X86(_)) => asm.push_str("; x86 encoded shellcode"),
                (StackSize::X64(_), StackSize::X64(_), StackSize::X64(_)) => asm.push_str("; x64 encoded shellcode"),
                _ => panic!("Invalid stack size"),
            }

            asm.push_str("section .text\n\n");
            asm.push_str("global _start\n");
            asm.push_str("_start:\n");

            match values {
                (StackSize::X86(_), StackSize::X86(_), StackSize::X86(_)) => {
                    arch = 0;
                    asm.push_str("    pushad\n");
                    
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
                },
                (StackSize::X64(_), StackSize::X64(_), StackSize::X64(_)) => {
                    arch = 1;
                    asm.push_str("    push rax\n");
                    asm.push_str("    push rcx\n");
                    asm.push_str("    push rdx\n");
                    asm.push_str("    push rbx\n");
                    asm.push_str("    push rsi\n");
                    asm.push_str("    push rdi\n");

                    asm.push_str("register:\n");
                    asm.push_str("    push 0x31323334\n");
                    asm.push_str("    pop rax\n");
                    asm.push_str("    sub rax, 0x31323335\n"); // rax = 0xFFFFFFFF_FFFFFFFF
                    asm.push_str("    push rax\n");
                    asm.push_str("    xor al, 0x2f\n");  // rax ^= 0x2f = 0xFFFFFFFF_FFFFFFD0 (-48)
                    asm.push_str("    push rax\n");
                    asm.push_str("    pop rsi\n");       // rsi = 0xFFFFFFFF_FFFFFFD0 (-48)
                    asm.push_str("    pop rcx\n");       // rcx = 0xFFFFFFFF_FFFFFFFF
                    asm.push_str("    push rcx\n");
                    asm.push_str("    xor [rsp + rsi + 0x30], ecx\n");
                    asm.push_str("    pop rdx\n");       // rdx = 0xFFFFFFFF_00000000
                    asm.push_str("    push rcx\n");
                    asm.push_str("    xor [rsp + rsi + 0x34], ecx\n");
                    asm.push_str("    pop rdi\n");       // rdi = 0x00000000_FFFFFFFF
                    asm.push_str("    push rsp\n");
                    asm.push_str("    pop rbx\n");       // rbx = original rsp + some registers
                },
                _ => panic!("Invalid stack size"),
            }

            asm.push_str("encode:\n");
        }

        match values {
            (StackSize::X86(stand), StackSize::X86(num1), StackSize::X86(num2)) => {
                let fcnt = stand.count_ones() / 8;
                asm.push_str(&format!("; push 0x{:08X}\n", stand ^ num1 ^ num2)); // comment
                // if the num of 0xFF in stand is over 2, push 0xFFFFFFFF first
                if fcnt > 2 {
                    asm.push_str("    push ecx\n");
                    asm.push_str("    pop eax\n");
                    asm.push_str(&format!("    xor eax, 0x{:08x}\n", num1));
                    asm.push_str(&format!("    xor eax, 0x{:08x}\n", num2));
                    asm.push_str("    push eax\n");
                    asm.push_str(
                        xor_ff(*stand, false, Register::Reg32(Reg32::ESI), Reg16::CX, 0x30 as u8).as_str()
                    );
                } else {
                    // ??????: stand = 0xFF0000FF
                    // 0xFFFFFFFF???xor??????????????????0x0000????????????xor?????????1??????xor?????????
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
                        asm.push_str(
                            xor_ff(*stand, true, Register::Reg32(Reg32::ESI), Reg16::CX, 0x30 as u8).as_str()
                        );
                    }
                }
            },
            (StackSize::X64(stand), StackSize::X64(num1), StackSize::X64(num2)) => {
                // lower 32 bits
                let lstand: u32 = (stand % 0x100000000 as u64) as u32;
                let lnum1: u32  = (num1 % 0x100000000 as u64) as u32;
                let lnum2: u32  = (num2 % 0x100000000 as u64) as u32;
                let lfcnt = lstand.count_ones() / 8;
                print!("lower: {:08X} {:08X} {:08X} {}, ", lstand, lnum1, lnum2, lfcnt);
                // upper 32 bits
                let ustand: u32 = (stand / 0x100000000 as u64) as u32;
                let unum1: u32  = (num1 / 0x100000000 as u64) as u32;
                let unum2: u32  = (num2 / 0x100000000 as u64) as u32;
                let ufcnt = ustand.count_ones() / 8;
                println!("upper: {:08X} {:08X} {:08X} {}", ustand, unum1, unum2, ufcnt);

                asm.push_str(&format!("; push 0x{:016X}\n", stand ^ num1 ^ num2)); // comment

                // TODO: xor???????????? <<<<<<<<<<<<<<<<<<<<<
                if lfcnt > 2 && ufcnt > 2 {
                    asm.push_str("    push rcx\n");
                    
                    // lower 4 bytes
                    asm.push_str("    pop rax\n");
                    asm.push_str(&format!("    xor rax, 0x{:08x}\n", lnum1));
                    asm.push_str(&format!("    xor rax, 0x{:08x}\n", lnum2));
                    asm.push_str("    push rax\n");
                    asm.push_str(
                        xor_ff(lstand, false, Register::Reg64(Reg64::RSI), Reg16::CX, 0x30 as u8).as_str()
                    );

                    // upper 4 bytes
                    asm.push_str(&format!("    push 0x{:08x}\n", unum1));
                    asm.push_str("    pop rax\n");
                    asm.push_str(&format!("    xor rax, 0x{:08x}\n", unum2));
                    asm.push_str("    xor [rsp + rsi + 0x34], eax\n");
                    asm.push_str(
                        xor_ff(ustand, false, Register::Reg64(Reg64::RSI), Reg16::CX, 0x34 as u8).as_str()
                    );
                } else if lfcnt > 2 && ufcnt <= 2 {
                    // rdi = 0x00000000_FFFFFFFF
                    asm.push_str("    push rdi\n");

                    // lower 4 bytes
                    asm.push_str("    pop rax\n");
                    asm.push_str(&format!("    xor rax, 0x{:08x}\n", lnum1));
                    asm.push_str(&format!("    xor rax, 0x{:08x}\n", lnum2));
                    asm.push_str("    push rax\n");
                    asm.push_str(
                        xor_ff(lstand, false, Register::Reg64(Reg64::RSI), Reg16::CX, 0x30 as u8).as_str()
                    );

                    // upper 4 bytes
                    asm.push_str(&format!("    push 0x{:08x}\n", unum1));
                    asm.push_str("    pop rax\n");
                    asm.push_str(&format!("    xor rax, 0x{:08x}\n", unum2));
                    asm.push_str("    xor [rsp + rsi + 0x34], eax\n");
                    asm.push_str(
                        xor_ff(ustand, true, Register::Reg64(Reg64::RSI), Reg16::CX, 0x34 as u8).as_str()
                    );
                } else if lfcnt <= 2 && ufcnt > 2 {
                    // rdx = 0xFFFFFFFF_00000000
                    asm.push_str("    push rdx\n");

                    // lower 4 bytes
                    asm.push_str("    pop rax\n");
                    asm.push_str(&format!("    xor rax, 0x{:08x}\n", lnum1));
                    asm.push_str(&format!("    xor rax, 0x{:08x}\n", lnum2));
                    asm.push_str("    push rax\n");
                    asm.push_str(
                        xor_ff(lstand, true, Register::Reg64(Reg64::RSI), Reg16::CX, 0x30 as u8).as_str()
                    );

                    // upper 4 bytes
                    asm.push_str(&format!("    push 0x{:08x}\n", unum1));
                    asm.push_str("    pop rax\n");
                    asm.push_str(&format!("    xor rax, 0x{:08x}\n", unum2));
                    asm.push_str("    xor [rsp + rsi + 0x34], eax\n");
                    asm.push_str(
                        xor_ff(ustand, false, Register::Reg64(Reg64::RSI), Reg16::CX, 0x34 as u8).as_str()
                    );
                } else {
                    // lower 4 bytes
                    asm.push_str(&format!("    push 0x{:08x}\n", lnum1));
                    asm.push_str("    pop rax\n");
                    asm.push_str(&format!("    xor rax, 0x{:08x}\n", lnum2));
                    asm.push_str("    push rax\n");
                    asm.push_str(
                        xor_ff(lstand, true, Register::Reg64(Reg64::RSI), Reg16::CX, 0x30 as u8).as_str()
                    );

                    // upper 4 bytes
                    asm.push_str(&format!("    push 0x{:08x}\n", unum1));
                    asm.push_str("    pop rax\n");
                    asm.push_str(&format!("    xor rax, 0x{:08x}\n", unum2));
                    asm.push_str("    xor [rsp + rsi + 0x34], eax\n");
                    asm.push_str(
                        xor_ff(ustand, true, Register::Reg64(Reg64::RSI), Reg16::CX, 0x34 as u8).as_str()
                    );
                }
                // TODO: ??????: 0xFF0000FF_????????, 0x????????_FF0000FF, 0xFF0000FF_FF0000FF
            },
            _ => panic!("Invalid stack size"),
        }
    }

    asm.push_str("; jmp to shellcode\n");
    asm.push_str("to_shellcode:\n");
    if arch == 0 {
        asm.push_str("    jmp esp\n");
    } else {
        asm.push_str("    jmp rsp\n");
    }

    output.write_all(asm.as_bytes())
}

// 0xFF???xor??????asm??????????????????
// stand: 0xFF???xor????????????????????? (ex. 0x0000FFFF)
// flag: 0xFF???xor???????????????0xFF???0x00???????????? (ex. 0x000000FF???0xFF????????????xor??????????????????true)
// reg1: [esp(rsp) + reg1 + xxx], reg2
// reg2: [esp(rsp) + reg1 + xxx], reg2
// idx_base: ASCII????????????????????? [esp(rsp) + register + xxx] ??? xxx ?????????
fn xor_ff(stand: u32, flag: bool, register1: Register, register2: Reg16, idx_base: u8) -> String {
    let mut asm = String::new();
    let stack_ptr = match register1 {
        Register::Reg64(_) => "rsp",
        Register::Reg32(_) => "esp",
        _ => panic!("Invalid register"),
    };
    let reg1: String = asm_helper::reg_to_string(register1);
    let reg2: String = asm_helper::reg_to_string(Register::Reg16(register2));
    let reg2_8: String = asm_helper::reg_to_string(Register::Reg8(asm_helper::reg16_to_reg8(register2)));

    if flag {
        if stand != 0x00000000 {
            for j in 0..4 {
                if j != 3 && stand & (0xFFFF << (j * 8)) == 0xFFFF << (j * 8) {
                    let idx: u8 = idx_base + (j as u8);
                    asm.push_str(&format!("    xor [{} + {} + 0x{:02x}], {}\n", stack_ptr, reg1, idx, reg2));
                    break; // there should be no more than 2 0xFF
                } else if stand & (0xFF << (j * 8)) == 0xFF << (j * 8) {
                    let idx: u8 = idx_base + (j as u8);
                    asm.push_str(&format!("    xor [{} + {} + 0x{:02x}], {}\n", stack_ptr, reg1, idx, reg2_8));
                }
            }
        }
    } else {
        if stand != 0xFFFFFFFF {
            for j in 0..4 {
                if j != 3 && stand & (0xFFFF << (j * 8)) == 0x00000000 {
                    let idx: u8 = idx_base + (j as u8);
                    asm.push_str(&format!("    xor [{} + {} + 0x{:02x}], {}\n", stack_ptr, reg1, idx, reg2));
                    break; // there should be no more than 2 0xFF
                } else if stand & (0xFF << (j * 8)) == 0x00000000 {
                    let idx: u8 = idx_base + (j as u8);
                    asm.push_str(&format!("    xor [{} + {} + 0x{:02x}], {}\n", stack_ptr, reg1, idx, reg2_8));
                }
            }
        }
    }

    asm
}
