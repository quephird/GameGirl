//
//  Opcode.swift
//  GameGirl
//
//  Created by Danielle Kefford on 12/22/25.
//

enum Opcode: UInt8 {
    case nop = 0x00
    case ldBc = 0x01
    case ldBcMem = 0x02
    case ldDe = 0x11
    case ldDeMem = 0x12
    case ldHl = 0x21
    case ldHlMemI = 0x22
    case ldSp = 0x31
    case ldHlMemD = 0x32

}

extension Opcode {
    enum Register16Target: UInt8 {
        case bc = 0b00
        case de = 0b01
        case hl = 0b10
        case sp = 0b11

        init?(opcode: Opcode) {
            let rawValue = (opcode.rawValue & 0b0011_0000) >> 4
            self.init(rawValue: rawValue)
        }
    }

    enum IndirectMemoryTarget: UInt8 {
        case bc = 0b00
        case de = 0b01
        case hli = 0b10
        case hld = 0b11

        init?(opcode: Opcode) {
            let rawValue = (opcode.rawValue & 0b0011_0000) >> 4
            self.init(rawValue: rawValue)
        }
    }

}

extension Opcode {
    var bytes: Int {
        switch self {
        case .nop: 1
        case .ldBc, .ldDe, .ldHl, .ldSp: 3
        case .ldBcMem, .ldDeMem, .ldHlMemI, .ldHlMemD: 1
        }
    }
}

extension Opcode {
    var cycles: Int {
        switch self {
        case .nop: 1
        case .ldBc, .ldDe, .ldHl, .ldSp: 3
        case .ldBcMem, .ldDeMem, .ldHlMemI, .ldHlMemD: 2
        }
    }
}
