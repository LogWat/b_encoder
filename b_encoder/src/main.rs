use std::fs;
use std::io::prelude::*;
use clap::Parser;
use rand::Rng;

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
}

fn ror32(num: u32, r: u32) -> u32 {
    (num >> r) | (num << (32 - r))
}

// 0x???????? = (1) ^ (2) ^ (3) となるように
// 与えられた0x????????を1と2に分解する (2, 3はともに0x21~0x7Fの範囲のバイトの組み合わせ)
// 1は0xFFと0x00の組み合わせで表現する
// 1, 2, 3返却する関数
fn split_to_ascii(byte_seq: u32) -> (u32, u32, u32) {
    let bytes: [u8; 4] = byte_seq.to_be_bytes();
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
                    candidates.push((j, k)); // 乱数使ってばらばらにする？
                }
            }
        }
        let mut rng = rand::thread_rng();
        let (j, k) = candidates[rng.gen_range(0..candidates.len())];
        num1 |= (j as u32) << ((3 - i) * 8);
        num2 |= (k as u32) << ((3 - i) * 8);
    }

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
        Ok(output) => output,
        Err(e) => {
            eprintln!("Failed to create output file: {}", e);
            return Ok(());
        }
    };

    let mut bytes = Vec::new();
    let mut for_push_bytes: Vec<u32> = Vec::new();
    let mut counter = 0;
    for c in input.split("\\x") {
        // convert hex to byte
        match u8::from_str_radix(&c, 16) {
            Ok(b) => {
                bytes.push(b);
                counter += 1;
                if counter == 4 {
                    for_push_bytes.push(
                        ((bytes[counter-1] as u32) << 24) |
                        ((bytes[counter-2] as u32) << 16) |
                        ((bytes[counter-3] as u32) << 8) |
                        (bytes[counter-4] as u32)
                    );

                    let (stand, num1, num2) = split_to_ascii(for_push_bytes[for_push_bytes.len()-1]);
        
                    println!("{:02X} {:02X} {:02X} {:02X} => 0x{:08X} = 0x{:08X} ^ 0x{:08X} ^ 0x{:08X}",
                        bytes[counter-4], bytes[counter-3], bytes[counter-2], bytes[counter-1],
                        for_push_bytes[for_push_bytes.len()-1],
                        stand, num1, num2
                    );

                    bytes.clear();
                    counter = 0;
                }
            },
            Err(e) => {
                // space is ignored
                if c.len() > 0 {
                    println!("Fail to convert hex to byte: {}", e);
                    return Ok(());
                }
            }
        }
    }

    // fill the last bytes
    if bytes.len() != 0 {
        for _ in counter..4 {
            bytes.push(0x90);
        }
        for_push_bytes.push(
            ((bytes[3] as u32) << 24) |
            ((bytes[2] as u32) << 16) |
            ((bytes[1] as u32) << 8) |
            (bytes[0] as u32)
        );
        println!("{:02X} {:02X} {:02X} {:02X} => 0x{:08X}",
            bytes[0], bytes[1], bytes[2], bytes[3],
            for_push_bytes[for_push_bytes.len()-1]
        );
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

    Ok(())
}
