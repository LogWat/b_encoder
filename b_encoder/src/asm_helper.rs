#[derive(Clone, Copy)]
#[allow(dead_code)]
pub enum Reg8 {
    AL,
    CL,
    DL,
    BL,
    AH,
    CH,
    DH,
    BH,
    SIL,
    DIL,
    BPL,
    SPL,
    R8B,
    R9B,
    R10B,
    R11B,
    R12B,
    R13B,
    R14B,
    R15B,
}

#[derive(Clone, Copy)]
pub enum Reg16 {
    AX,
    BX,
    CX,
    DX,
    SI,
    DI,
    BP,
    SP,
    R8W,
    R9W,
    R10W,
    R11W,
    R12W,
    R13W,
    R14W,
    R15W,
}

#[derive(Clone, Copy)]
pub enum Reg32 {
    EAX,
    EBX,
    ECX,
    EDX,
    ESI,
    EDI,
    EBP,
    ESP,
    R8D,
    R9D,
    R10D,
    R11D,
    R12D,
    R13D,
    R14D,
    R15D,
}

#[derive(Clone, Copy)]
#[allow(dead_code)]
pub enum Reg64 {
    RAX,
    RBX,
    RCX,
    RDX,
    RSI,
    RDI,
    RBP,
    RSP,
    R8,
    R9,
    R10,
    R11,
    R12,
    R13,
    R14,
    R15,
}

#[derive(Clone, Copy)]
pub enum Register {
    Reg8(Reg8),
    Reg16(Reg16),
    Reg32(Reg32),
    Reg64(Reg64),
}

pub fn reg_to_string(reg: Register) -> String {
    let reg_str = match reg {
        Register::Reg8(reg) => match reg {
            Reg8::AL => "al".to_string(),
            Reg8::CL => "cl".to_string(),
            Reg8::DL => "dl".to_string(),
            Reg8::BL => "bl".to_string(),
            Reg8::AH => "ah".to_string(),
            Reg8::CH => "ch".to_string(),
            Reg8::DH => "dh".to_string(),
            Reg8::BH => "bh".to_string(),
            Reg8::SIL => "sil".to_string(),
            Reg8::DIL => "dil".to_string(),
            Reg8::BPL => "bpl".to_string(),
            Reg8::SPL => "spl".to_string(),
            Reg8::R8B => "r8b".to_string(),
            Reg8::R9B => "r9b".to_string(),
            Reg8::R10B => "r10b".to_string(),
            Reg8::R11B => "r11b".to_string(),
            Reg8::R12B => "r12b".to_string(),
            Reg8::R13B => "r13b".to_string(),
            Reg8::R14B => "r14b".to_string(),
            Reg8::R15B => "r15b".to_string(),
        },
        Register::Reg16(reg) => match reg {
            Reg16::AX => "ax".to_string(),
            Reg16::BX => "bx".to_string(),
            Reg16::CX => "cx".to_string(),
            Reg16::DX => "dx".to_string(),
            Reg16::SI => "si".to_string(),
            Reg16::DI => "di".to_string(),
            Reg16::BP => "bp".to_string(),
            Reg16::SP => "sp".to_string(),
            Reg16::R8W => "r8w".to_string(),
            Reg16::R9W => "r9w".to_string(),
            Reg16::R10W => "r10w".to_string(),
            Reg16::R11W => "r11w".to_string(),
            Reg16::R12W => "r12w".to_string(),
            Reg16::R13W => "r13w".to_string(),
            Reg16::R14W => "r14w".to_string(),
            Reg16::R15W => "r15w".to_string(),
        },
        Register::Reg32(reg) => match reg {
            Reg32::EAX => "eax".to_string(),
            Reg32::EBX => "ebx".to_string(),
            Reg32::ECX => "ecx".to_string(),
            Reg32::EDX => "edx".to_string(),
            Reg32::ESI => "esi".to_string(),
            Reg32::EDI => "edi".to_string(),
            Reg32::EBP => "ebp".to_string(),
            Reg32::ESP => "esp".to_string(),
            Reg32::R8D => "r8d".to_string(),
            Reg32::R9D => "r9d".to_string(),
            Reg32::R10D => "r10d".to_string(),
            Reg32::R11D => "r11d".to_string(),
            Reg32::R12D => "r12d".to_string(),
            Reg32::R13D => "r13d".to_string(),
            Reg32::R14D => "r14d".to_string(),
            Reg32::R15D => "r15d".to_string(),
        },
        Register::Reg64(reg) => match reg {
            Reg64::RAX => "rax".to_string(),
            Reg64::RBX => "rbx".to_string(),
            Reg64::RCX => "rcx".to_string(),
            Reg64::RDX => "rdx".to_string(),
            Reg64::RSI => "rsi".to_string(),
            Reg64::RDI => "rdi".to_string(),
            Reg64::RBP => "rbp".to_string(),
            Reg64::RSP => "rsp".to_string(),
            Reg64::R8 => "r8".to_string(),
            Reg64::R9 => "r9".to_string(),
            Reg64::R10 => "r10".to_string(),
            Reg64::R11 => "r11".to_string(),
            Reg64::R12 => "r12".to_string(),
            Reg64::R13 => "r13".to_string(),
            Reg64::R14 => "r14".to_string(),
            Reg64::R15 => "r15".to_string(),
        },
    };
    
    reg_str
}

pub fn reg16_to_reg8(reg: Reg16) -> Reg8 {
    match reg {
        Reg16::AX => Reg8::AL,
        Reg16::BX => Reg8::BL,
        Reg16::CX => Reg8::CL,
        Reg16::DX => Reg8::DL,
        Reg16::SI => Reg8::SIL,
        Reg16::DI => Reg8::DIL,
        Reg16::BP => Reg8::BPL,
        Reg16::SP => Reg8::SPL,
        Reg16::R8W => Reg8::R8B,
        Reg16::R9W => Reg8::R9B,
        Reg16::R10W => Reg8::R10B,
        Reg16::R11W => Reg8::R11B,
        Reg16::R12W => Reg8::R12B,
        Reg16::R13W => Reg8::R13B,
        Reg16::R14W => Reg8::R14B,
        Reg16::R15W => Reg8::R15B,
    }
}

#[allow(dead_code)]
pub fn reg64_to_reg32(reg: Reg64) -> Reg32 {
    match reg {
        Reg64::RAX => Reg32::EAX,
        Reg64::RBX => Reg32::EBX,
        Reg64::RCX => Reg32::ECX,
        Reg64::RDX => Reg32::EDX,
        Reg64::RSI => Reg32::ESI,
        Reg64::RDI => Reg32::EDI,
        Reg64::RBP => Reg32::EBP,
        Reg64::RSP => Reg32::ESP,
        Reg64::R8 => Reg32::R8D,
        Reg64::R9 => Reg32::R9D,
        Reg64::R10 => Reg32::R10D,
        Reg64::R11 => Reg32::R11D,
        Reg64::R12 => Reg32::R12D,
        Reg64::R13 => Reg32::R13D,
        Reg64::R14 => Reg32::R14D,
        Reg64::R15 => Reg32::R15D,
    }
}

#[allow(dead_code)]
pub fn reg32_to_reg16(reg: Reg32) -> Reg16 {
    match reg {
        Reg32::EAX => Reg16::AX,
        Reg32::EBX => Reg16::BX,
        Reg32::ECX => Reg16::CX,
        Reg32::EDX => Reg16::DX,
        Reg32::ESI => Reg16::SI,
        Reg32::EDI => Reg16::DI,
        Reg32::EBP => Reg16::BP,
        Reg32::ESP => Reg16::SP,
        Reg32::R8D => Reg16::R8W,
        Reg32::R9D => Reg16::R9W,
        Reg32::R10D => Reg16::R10W,
        Reg32::R11D => Reg16::R11W,
        Reg32::R12D => Reg16::R12W,
        Reg32::R13D => Reg16::R13W,
        Reg32::R14D => Reg16::R14W,
        Reg32::R15D => Reg16::R15W,
    }
}