use std::env;

fn calc_ror_hash(s: &str, shift: u32, verbose: bool) -> u32 {
    let mut hash: u32 = 0;
    for byte in s.bytes() {
        if verbose {
            print!("{}: {:032b}", byte as char, hash);
        }
        // Rust標準の u32::rotate_right メソッドを利用
        hash = hash.rotate_right(shift);
        if verbose {
            println!(" => {:032b}", hash);
        }
        hash = hash.wrapping_add(byte as u32);
    }
    hash
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        eprintln!("Usage: {} <string> [shift_hex_or_dec] [-v|--verbose]", args[0]);
        eprintln!("Default shift is 0x11 (17 bits)");
        std::process::exit(1);
    }

    let target_str = &args[1];
    let mut shift: u32 = 0x11;
    let mut verbose = false;

    for arg in &args[2..] {
        if arg == "-v" || arg == "--verbose" {
            verbose = true;
        } else if arg.starts_with("0x") || arg.starts_with("0X") {
            if let Ok(val) = u32::from_str_radix(&arg[2..], 16) {
                shift = val;
            }
        } else if let Ok(val) = arg.parse::<u32>() {
            shift = val;
        }
    }

    let hash = calc_ror_hash(target_str, shift, verbose);
    println!("{} (shift: 0x{:X}) = 0x{:08X}", target_str, shift, hash);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_ror17_winexec() {
        assert_eq!(calc_ror_hash("WinExec", 0x11, false), 0x3C3E6889);
    }

    #[test]
    fn test_ror17_exitprocess() {
        assert_eq!(calc_ror_hash("ExitProcess", 0x11, false), 0xEA8A9494);
    }

    #[test]
    fn test_ror17_messageboxa() {
        assert_eq!(calc_ror_hash("MessageBoxA", 0x11, false), 0x1A8890E5);
    }
}
