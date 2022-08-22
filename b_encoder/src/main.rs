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
    #[clap(short = 'n', long = "num", default_value = "0x61", help = "Number to encode")]
    num: String,
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
            if shift < 0x22 || shift > 0x6F {
                eprintln!("Valid shift is between 0x22 and 0x6F");
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
        "binary" => {}
        "hex" => {}
        _ => {
            println!("Invalid format. Must be binary or hex");
            return Ok(());
        }
    }

    for b in bytes {
        let mut b0 = b % 0x10;
        let mut b1 = b / 0x10;
        b0 += shift;
        b1 += shift;

        if opts.format == "binary" {
            output.write(&[b0, b1])?;
        } else {
            output.write(&format!("\\x{:x}\\x{:x}", b0, b1).as_bytes())?;
        }
    }

    Ok(())
}
