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
    case incBC = 0x03
    case ldImmediateIndirectFromSP = 0x08
    case addBCToHL = 0x09
    case ldAFromBCIndirect = 0x0A
    case decBC = 0x0B
    case ldDEFromImmediate = 0x11
    case ldDEIndirectFromA = 0x12
    case incDE = 0x13
    case addDEToHL = 0x19
    case ldAFromDEIndirect = 0x1A
    case decDE = 0x1B
    case ldHLFromImmediate = 0x21
    case ldHLIndirectFromAAndIncrement = 0x22
    case incHL = 0x23
    case addHLToHL = 0x29
    case ldAFromHLIndirectAndIncrement = 0x2A
    case decHL = 0x2B
    case ldSPFromImmediate = 0x31
    case ldHLIndirectFromAAndDecrement = 0x32
    case incSP = 0x33
    case addSPToHL = 0x39
    case ldAFromHLIndirectAndDecrement = 0x3A
    case decSP = 0x3B
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
        case .incBC, .incDE, .incHL, .incSP: 1
        case .ldImmediateIndirectFromSP: 3
        case .addBCToHL, .addDEToHL, .addHLToHL, .addSPToHL: 1
        case .ldAFromBCIndirect, .ldAFromDEIndirect, .ldAFromHLIndirectAndIncrement, .ldAFromHLIndirectAndDecrement: 1
        case .decBC, .decDE, .decHL, .decSP: 1
        }
    }
}

extension Opcode {
    var cycles: Int {
        switch self {
        case .nop: 1
        case .ldBCFromImmediate, .ldDEFromImmediate, .ldHLFromImmediate, .ldSPFromImmediate: 3
        case .ldBCIndirectFromA, .ldDEIndirectFromA, .ldHLIndirectFromAAndIncrement, .ldHLIndirectFromAAndDecrement: 2
        case .incBC, .incDE, .incHL, .incSP: 2
        case .ldImmediateIndirectFromSP: 5
        case .addBCToHL, .addDEToHL, .addHLToHL, .addSPToHL: 2
        case .ldAFromBCIndirect, .ldAFromDEIndirect, .ldAFromHLIndirectAndIncrement, .ldAFromHLIndirectAndDecrement: 2
        case .decBC, .decDE, .decHL, .decSP: 2
        }
    }
}
