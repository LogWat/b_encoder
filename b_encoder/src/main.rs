use std::fs;
use std::io::prelude::*;
use std::env;

fn main() -> std::io::Result<()> {
    let args: Vec<String> = env::args().collect();
    let mut input = "input";
    let mut output = "output";
    match args.len() {
        1 => {}
        2 => {
            input = &args[1];
        }
        3 => {
            input = &args[1];
            output = &args[2];
        }
        _ => {}
    }

    let content = match fs::read_to_string(input) {
        Ok(c) => c,
        Err(e) => {
            println!("Fail to read file: {}", e);
            return Ok(());
        }
    };

    let mut bytes = Vec::new();
    for c in content.split("\\x") {
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


    let mut output_file = fs::File::create(output)?;

    // encode
    let mut encoded: Vec<u8> = Vec::new();
    for b in bytes {
        let mut b0 = b % 0x10;
        let mut b1 = b / 0x10;
        b0 += 0x61;
        b1 += 0x61;
        encoded.push(b0);
        encoded.push(b1);
    }

    for b in encoded {
        println!("\\x{:x}", b);
        output_file.write(&format!("\\x{:x}", b).as_bytes())?;
    }

    Ok(())
}
