use std::fs;
use std::io::prelude::*;
use clap::Parser;
use rand::Rng;

mod genasm;

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
}

fn ror32(num: u32, r: u32) -> u32 {
    (num >> r) | (num << (32 - r))
}

// 0x???????? = (1) ^ (2) ^ (3) となるように
// 与えられた0x????????を1, 2, 3に分解する
// 1は0xFFと0x00の組み合わせ, 2, 3はともに0x21~0x7Fの範囲のバイトの組み合わせで表現
// 1, 2, 3返却する
fn split_to_ascii(byte_seq: u32) -> (u32, u32, u32) {
    let bytes: [u8; 4] = byte_seq.to_le_bytes(); // consider little endian
    let mut stand: u32 = 0;
    let mut num1: u32 = 0;
    let mut num2: u32 = 0;
    for (i, b) in bytes.iter().enumerate() {
        let mut tmp = *b as u8;
        if *b >= 0x80 {
            stand |= (0xFF << ((3 - i) * 8)) as u32;
            tmp ^= 0xFF;
        }
        let mut candidates: Vec<(u8, u8)> = Vec::new();
        for j in 0x21..0x7F {
            for k in 0x21..0x7F {
                if j ^ k == tmp {
                    candidates.push((j, k));
                }
            }
        }
        let mut rng = rand::thread_rng();
        let (j, k) = candidates[rng.gen_range(0..candidates.len())]; // TODO: 乱数で決定することは適切か検討する
        num1 |= (j as u32) << ((3 - i) * 8);
        num2 |= (k as u32) << ((3 - i) * 8);
    }

    let for_print: [u8; 4] = byte_seq.to_be_bytes();
    println!("{:02X} {:02X} {:02X} {:02X} => 0x{:08X} = 0x{:08X} ^ 0x{:08X} ^ 0x{:08X}",
    for_print[0], for_print[1], for_print[2], for_print[3], stand ^ num1 ^ num2, stand, num1, num2);

    (stand, num1, num2)
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

    let raw_bytes = input.split("\\x").collect::<Vec<&str>>();
    // TYPE SELECTION (0: ASCII, 1: Polymorphic)
    if etype == 0 {
        let mut bytes: Vec<u8> = Vec::new();
        // find 0xC3 (ret) and replace it with:
        // 0x8B, 0xE1 (mov esp, ecx)
        // 0x61 (popad)
        // 0xC3 (ret)
        for b in raw_bytes {
            if b == "C3" || b == "c3" {
                bytes.push(0x8B);
                bytes.push(0xE1);
                bytes.push(0x61);
                bytes.push(0xC3);
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
    
        let mut ascii_bytes_set: Vec<(u32, u32, u32)> = Vec::new();
        for (i, b) in bytes.iter().enumerate() {
            if (i + 1) % 4 == 0 {
                let mut tmp: u32 = 0;
                tmp |= *b as u32;
                tmp |= (bytes[i - 1] as u32) << 8;
                tmp |= (bytes[i - 2] as u32) << 16;
                tmp |= (bytes[i - 3] as u32) << 24;
                let (stand, num1, num2) = split_to_ascii(tmp);
                ascii_bytes_set.push((stand, num1, num2));
            }
    
            // if the length of bytes is not a multiple of 4, add 0x90 (nop) to the end of bytes
            if (i + 1) == bytes.len() && (i + 1) % 4 != 0 {
                let mut tmp: u32 = 0;
                for j in 0..4 {
                    if j >= 4 - (i + 1) % 4 {
                        tmp |= (bytes[i - j] as u32) << (j * 8);
                    } else {
                        tmp |= 0x90 << (j * 8);
                    }
                }
                let (stand, num1, num2) = split_to_ascii(tmp);
                ascii_bytes_set.push((stand, num1, num2));
            }
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
                eprintln!("Failed to generate asm: {}", e);
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
