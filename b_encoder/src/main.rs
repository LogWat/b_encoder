use std::fs::File;
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

    let mut input_file = match File::open(input) {
        Ok(file) => file,
        Err(_) => {
            println!("Could not open input file");
            return Ok(());
        }
    };
    let mut buf: Vec<u8> = Vec::new();
    input_file.read_to_end(&mut buf)?;

    let mut output_file = File::create(output)?;

    // encode
    let mut encoded: Vec<u8> = Vec::new();
    for b in buf {
        let mut b0 = b % 0x10;
        let mut b1 = b / 0x10;
        b0 += 0x61;
        b1 += 0x61;
        encoded.push(b0);
        encoded.push(b1);
    }

    output_file.write_all(&encoded)?;

    Ok(())
}
