//
//  Opcode.swift
//  GameGirl
//
//  Created by Danielle Kefford on 12/22/25.
//

enum Opcode: UInt8 {
    case nop = 0x00
    case ldBCFromImmediate = 0x01
    case ldBCIndirectFromA = 0x02
    case ldImmediateIndirectFromSP = 0x08
    case ldAFromBCIndirect = 0x0A
    case ldDEFromImmediate = 0x11
    case ldDEIndirectFromA = 0x12
    case ldAFromDEIndirect = 0x1A
    case ldHLFromImmediate = 0x21
    case ldHLIndirectFromAAndIncrement = 0x22
    case ldAFromHLIndirectAndIncrement = 0x2A
    case ldSPFromImmediate = 0x31
    case ldHLIndirectFromAAndDecrement = 0x32
    case ldAFromHLIndirectAndDecrement = 0x3A
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
        case .ldBCFromImmediate, .ldDEFromImmediate, .ldHLFromImmediate, .ldSPFromImmediate: 3
        case .ldBCIndirectFromA, .ldDEIndirectFromA, .ldHLIndirectFromAAndIncrement, .ldHLIndirectFromAAndDecrement: 1
        case .ldImmediateIndirectFromSP: 3
        case .ldAFromBCIndirect, .ldAFromDEIndirect, .ldAFromHLIndirectAndIncrement, .ldAFromHLIndirectAndDecrement: 1
        }
    }
}

extension Opcode {
    var cycles: Int {
        switch self {
        case .nop: 1
        case .ldBCFromImmediate, .ldDEFromImmediate, .ldHLFromImmediate, .ldSPFromImmediate: 3
        case .ldBCIndirectFromA, .ldDEIndirectFromA, .ldHLIndirectFromAAndIncrement, .ldHLIndirectFromAAndDecrement: 2
        case .ldImmediateIndirectFromSP: 5
        case .ldAFromBCIndirect, .ldAFromDEIndirect, .ldAFromHLIndirectAndIncrement, .ldAFromHLIndirectAndDecrement: 2
        }
    }
}
