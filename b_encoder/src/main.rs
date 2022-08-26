use std::fs;
use std::io::prelude::*;
use clap::Parser;

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
    for c in input.split("\\x") {
        // convert hex to byte
        match u8::from_str_radix(&c, 16) {
            Ok(b) => bytes.push(b),
            Err(e) => {
                // space is ignored
                if c.len() > 0 {
                    println!("Fail to convert hex to byte: {}", e);
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

    Ok(())
}
