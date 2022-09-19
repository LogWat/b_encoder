use rand::Rng;

pub enum StackSize {
    X86(u32),
    X64(u64),
}

pub fn change_bytes_to_stack_size(bytes: &Vec<u8>, arch: usize) -> Result<Vec<StackSize>, String> {
    let mut stack_bytes: Vec<StackSize> = Vec::new();
    for (i, b) in bytes.iter().enumerate() {

        if arch == 0 {
            if (i + 1) % 4 == 0 {
                let mut tmp: u32 = 0;
                tmp |= *b as u32;
                tmp |= (bytes[i - 1] as u32) << 8;
                tmp |= (bytes[i - 2] as u32) << 16;
                tmp |= (bytes[i - 3] as u32) << 24;
                stack_bytes.push(StackSize::X86(tmp));
            }
            if (i + 1) == bytes.len() && (i + 1) % 4 != 0 {
                let mut tmp: u32 = 0;
                for j in 0..4 {
                    if j < (i + 1) % 4 {
                        tmp |= (bytes[i - j] as u32) << (j * 8);
                    } else {
                        tmp |= (0x90 as u32) << (j * 8);
                    }
                }
                stack_bytes.push(StackSize::X86(tmp));
            }
        } else {
            if (i + 1) % 8 == 0 {
                let mut tmp: u64 = 0;
                for j in 0..8 {
                    tmp |= (*b as u64) << (j * 8);
                }
                stack_bytes.push(StackSize::X64(tmp));
            }

            if (i + 1) == bytes.len() && (i + 1) % 8 != 0 {
                let mut tmp: u64 = 0;
                for j in 0..8 {
                    if j < (i + 1) % 8 {
                        tmp |= (bytes[i - j] as u64) << (j * 8);
                    } else {
                        tmp |= (0x90 as u64) << (j * 8);
                    }
                }
                stack_bytes.push(StackSize::X64(tmp));
            }
        }
    }

    Ok(stack_bytes)
}



pub fn split_bytes_to_ascii(bytes_seq: StackSize) -> (StackSize, StackSize, StackSize) {
    let bytes: Vec<u8> = match bytes_seq {
        StackSize::X86(num) => num.to_le_bytes().to_vec(),
        StackSize::X64(num) => num.to_le_bytes().to_vec(),
    };
    let mut stand: StackSize = match bytes_seq {
        StackSize::X86(_) => StackSize::X86(0),
        StackSize::X64(_) => StackSize::X64(0),
    };
    let mut num1: StackSize = match bytes_seq {
        StackSize::X86(_) => StackSize::X86(0),
        StackSize::X64(_) => StackSize::X64(0),
    };
    let mut num2: StackSize = match bytes_seq {
        StackSize::X86(_) => StackSize::X86(0),
        StackSize::X64(_) => StackSize::X64(0),
    };

    for (i, b) in bytes.iter().enumerate() {
        let mut tmp = *b as u8;
        if *b >= 0x80 {
            match &mut stand {
                StackSize::X86(num) => *num |= (0xFF << ((3 - i) * 8)) as u32,
                StackSize::X64(num) => *num |= (0xFF << ((7 - i) * 8)) as u64,
            }
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
        match &mut num1 {
            StackSize::X86(num) => *num |= (j as u32) << ((3 - i) * 8),
            StackSize::X64(num) => *num |= (j as u64) << ((7 - i) * 8),
        }
        match &mut num2 {
            StackSize::X86(num) => *num |= (k as u32) << ((3 - i) * 8),
            StackSize::X64(num) => *num |= (k as u64) << ((7 - i) * 8),
        }
    }

    let for_print: Vec<u8> = match bytes_seq {
        StackSize::X86(num) => num.to_be_bytes().to_vec(),
        StackSize::X64(num) => num.to_be_bytes().to_vec(),
    };
    match bytes_seq {
        StackSize::X86(num) => {
            let fnum1: u32 = match num1 {
                StackSize::X86(num) => num,
                _ => {
                    println!("Error: num1 is not u32");
                    0
                }
            };
            let fnum2: u32 = match num2 {
                StackSize::X86(num) => num,
                _ => {
                    println!("Error: num2 is not u32");
                    0
                }
            };
            println!("{:02X} {:02X} {:02X} {:02X} -> 0x{:08X} = 0x{:08X} ^ 0x{:08X}",
            for_print[0], for_print[1], for_print[2], for_print[3], num, fnum1, fnum2);
        },
        StackSize::X64(num) => {
            let fnum1: u64 = match num1 {
                StackSize::X64(num) => num,
                _ => {
                    println!("Error: num1 is not u64");
                    0
                }
            };
            let fnum2: u64 = match num2 {
                StackSize::X64(num) => num,
                _ => {
                    println!("Error: num2 is not u64");
                    0
                }
            };
            println!("{:02X} {:02X} {:02X} {:02X} {:02X} {:02X} {:02X} {:02X} -> 0x{:016X} = 0x{:016X} ^ 0x{:016X}",
            for_print[0], for_print[1], for_print[2], for_print[3], for_print[4], for_print[5], for_print[6], for_print[7], num, fnum1, fnum2);
        },
    };

    (stand, num1, num2)
}
