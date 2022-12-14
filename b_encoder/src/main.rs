use std::fs;
use std::io::prelude::*;
use clap::Parser;

mod genasm;
mod logic;
mod asm_helper;

use logic::StackSize;

#[derive(Parser)]
#[clap(author, version, about, long_about = None)]
struct Opts {
    #[clap(short = 'i', long = "input", default_value = "input", help = "Input file name")]
    input: String,
    #[clap(short = 'o', long = "output", default_value = "output", help = "Output file name")]
    output: String,
    #[clap(short = 'f', long = "format", default_value = "binary", help = "Output file format")]
    format: String,
    #[clap(short = 'n', long = "num", default_value = "0x21", help = "Number to encode")]
    num: String,
    #[clap(short = 'e', long = "encode", default_value = "a", help = "Type of encoding (a: ASCII, p: Polymorphic)")]
    encode: String,
    #[clap(short = 'a', long = "arch", default_value = "x86", help = "Architecture (x86, x64)")]
    arch: String,
}

fn ror32(num: u32, r: u32) -> u32 {
    (num >> r) | (num << (32 - r))
}

fn main() -> std::io::Result<()> {
    let opts = Opts::parse();
    let input = match fs::read_to_string(opts.input) {
        Ok(input) => input,
        Err(e) => {
            eprintln!("Failed to read input file: {}", e);
            return Ok(());
        }
    };
    let mut output = match fs::File::create(opts.output) {
        Ok(output) => {
            output
        },
        Err(e) => {
            eprintln!("Failed to create output file: {}", e);
            return Ok(());
        }
    };
    let etype = match opts.encode.as_str() {
        "a" => 0,
        "p" => 1,
        _ => {
            eprintln!("Invalid encoding type: {}", opts.encode);
            return Ok(());
        }
    };
    let arch = match opts.arch.as_str() {
        "x86" => 0,
        "x64" => 1,
        _ => {
            eprintln!("Invalid architecture: {}", opts.arch);
            return Ok(());
        }
    };

    let raw_bytes = input.split("\\x").collect::<Vec<&str>>();
    // TYPE SELECTION (0: ASCII, 1: Polymorphic)
    if etype == 0 {
        let mut bytes: Vec<u8> = Vec::new();
        // find 0xC3 (ret) and replace it with:
        // 32bit (x86)
        // 0x8B, 0xE3 (mov esp, ebx)
        // 0x61 (popad) <= this is for pushad in encoder shellcode
        // 0xC3 (ret)
        // ----
        // 64bit (x64)
        // 0x48, 0x8B, 0xE3 (mov rsp, rbx)
        // 0x5f, 0x5e, 0x5b, 0x5a, 0x59, 0x58 (pop rdi, pop rsi, pop rbx, pop rdx, pop rcx, pop rax)
        // 0xC3 (ret)
        for b in raw_bytes {
            if b == "C3" || b == "c3" {
                if arch == 0 {
                    bytes.push(0x8B);
                    bytes.push(0xE3);
                    bytes.push(0x61);
                    bytes.push(0xC3);
                } else {
                    bytes.push(0x48);
                    bytes.push(0x8B);
                    bytes.push(0xE3);
                    bytes.push(0x5F);
                    bytes.push(0x5E);
                    bytes.push(0x5B);
                    bytes.push(0x5A);
                    bytes.push(0x59);
                    bytes.push(0x58);
                    bytes.push(0xC3);
                }
            } else if b == "" {
                continue;
            } else {
                match u8::from_str_radix(b, 16) {
                    Ok(b) => bytes.push(b),
                    Err(e) => {
                        eprintln!("Failed to parse input file: {}", e);
                        return Ok(());
                    }
                }
            }
        }
    
        let mut ascii_bytes_set: Vec<(StackSize, StackSize, StackSize)> = Vec::new();
        let stack_bytes = match logic::change_bytes_to_stack_size(&bytes, arch) {
            Ok(stack_bytes) => stack_bytes,
            Err(e) => {
                eprintln!("Failed to change bytes to stack size: {}", e);
                return Ok(());
            }
        };
        for stack_byte in stack_bytes {
            let (stand, num1, num2) = logic::split_bytes_to_ascii(stack_byte);
            ascii_bytes_set.push((stand, num1, num2));
        }
    
        let mut asm_outputfile = match fs::File::create("asm_output.asm") {
            Ok(output) => {
                output
            },
            Err(e) => {
                eprintln!("Failed to create asm_output.asm: {}", e);
                return Ok(());
            }
        };

        match genasm::generate_asm(&ascii_bytes_set, &mut asm_outputfile) {
            Ok(_) => {},
            Err(e) => {
                eprintln!("Failed to assemble: {}", e);
                return Ok(());
            }
        }

    } else {
        let mut bytes: Vec<u8> = Vec::new();
        for b in raw_bytes {
            if b == "" {
                continue;
            } else {
                match u8::from_str_radix(b, 16) {
                    Ok(b) => bytes.push(b),
                    Err(e) => {
                        eprintln!("Failed to parse input file: {}", e);
                        return Ok(());
                    }
                }
            }
        }

        // encode
        let shift: u8 = match u8::from_str_radix(&opts.num[2..], 16) {
            Ok(shift) => {
                if shift < 0x21 || shift > 0x6F {
                    eprintln!("Valid shift is between 0x21 and 0x6F");
                    return Ok(());
                }
                shift
            }
            Err(e) => {
                println!("Fail to parse number {}: {}", opts.num, e);
                return Ok(());
            }
        };
        match opts.format.as_ref() {
            "binary" => {
                output.write(&[0x0a])?; // insert lf for formatting
            }
            "hex" => {
                output.write(b"\\x0a")?;
            }
            _ => {
                println!("Invalid format. Must be binary or hex");
                return Ok(());
            }
        }

        let mut encoded_hash: u32 = 0;
        let mut lf_cnt: u32 = 0;
        for b in bytes {
            let mut b0 = b % 0x10;
            let mut b1 = b / 0x10;
            b0 += shift;
            b1 += shift;

            // cal hash
            encoded_hash = ror32(encoded_hash, 0x17);
            encoded_hash += b1 as u32;
            encoded_hash = ror32(encoded_hash, 0x17);
            encoded_hash += b0 as u32;

            if opts.format == "binary" {
                output.write(&[b1, b0])?;
            } else {
                output.write(&format!("\\x{:x}\\x{:x}", b1, b0).as_bytes())?;
            }

            // insert LF at 21st char
            lf_cnt += 1;
            if lf_cnt == 20 {
                if opts.format == "binary" {
                    output.write(&[0x0a])?;
                } else {
                    output.write(&format!("\\x0a").as_bytes())?;
                }
                lf_cnt = 0;
            }
        }

        println!("Hash: {:x}", encoded_hash);
        // shellcode end with \x20(space) and hash
        if opts.format == "binary" {
            output.write(&[0x20])?;
            // consider endianness
            output.write(&encoded_hash.to_le_bytes())?;
        } else {
            output.write("\\x20".as_bytes())?;
            // consider endianness
            output.write(&format!("\\x{:x}\\x{:x}\\x{:x}\\x{:x}", (encoded_hash << 24 >> 24) as u8, (encoded_hash << 16 >> 24) as u8, (encoded_hash << 8 >> 24) as u8, (encoded_hash >> 24) as u8).as_bytes())?;
        }
    }

    Ok(())
}
