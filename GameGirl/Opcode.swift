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
    case incB = 0x04
    case decB = 0x05
    case ldBFromImmediate = 0x06
    case rlca = 0x07
    case ldImmediateIndirectFromSP = 0x08
    case addBCToHL = 0x09
    case ldAFromBCIndirect = 0x0A
    case decBC = 0x0B
    case incC = 0x0C
    case decC = 0x0D
    case ldCFromImmediate = 0x0E
    case rrca = 0x0F
    case ldDEFromImmediate = 0x11
    case ldDEIndirectFromA = 0x12
    case incDE = 0x13
    case incD = 0x14
    case decD = 0x15
    case ldDFromImmediate = 0x16
    case rla = 0x17
    case jrImmediate = 0x18
    case addDEToHL = 0x19
    case ldAFromDEIndirect = 0x1A
    case decDE = 0x1B
    case incE = 0x1C
    case decE = 0x1D
    case ldEFromImmediate = 0x1E
    case rra = 0x1F
    case jrImmediateIfZeroReset = 0x20
    case ldHLFromImmediate = 0x21
    case ldHLIndirectFromAAndIncrement = 0x22
    case incHL = 0x23
    case incH = 0x24
    case decH = 0x25
    case ldHFromImmediate = 0x26
    case daa = 0x27
    case jrImmediateIfZeroSet = 0x28
    case addHLToHL = 0x29
    case ldAFromHLIndirectAndIncrement = 0x2A
    case decHL = 0x2B
    case incL = 0x2C
    case decL = 0x2D
    case ldLFromImmediate = 0x2E
    case cpl = 0x2F
    case jrImmediateIfCarryReset = 0x30
    case ldSPFromImmediate = 0x31
    case ldHLIndirectFromAAndDecrement = 0x32
    case incSP = 0x33
    case incHLIndirect = 0x34
    case decHLIndirect = 0x35
    case ldHLIndirectFromImmediate = 0x36
    case scf = 0x37
    case jrImmediateIfCarrySet = 0x38
    case addSPToHL = 0x39
    case ldAFromHLIndirectAndDecrement = 0x3A
    case decSP = 0x3B
    case incA = 0x3C
    case decA = 0x3D
    case ldAFromImmediate = 0x3E
    case ccf = 0x3F
    case ldBFromB = 0x40
    case ldBFromC = 0x41
    case ldBFromD = 0x42
    case ldBFromE = 0x43
    case ldBFromH = 0x44
    case ldBFromL = 0x45
    case ldBFromHLIndirect = 0x46
    case ldCFromB = 0x48
    case ldCFromC = 0x49
    case ldCFromD = 0x4A
    case ldCFromE = 0x4B
    case ldCFromH = 0x4C
    case ldCFromL = 0x4D
    case ldCFromHLIndirect = 0x4E
    case ldDFromB = 0x50
    case ldDFromC = 0x51
    case ldDFromD = 0x52
    case ldDFromE = 0x53
    case ldDFromH = 0x54
    case ldDFromL = 0x55
    case ldDFromHLIndirect = 0x56
    case ldEFromB = 0x58
    case ldEFromC = 0x59
    case ldEFromD = 0x5A
    case ldEFromE = 0x5B
    case ldEFromH = 0x5C
    case ldEFromL = 0x5D
    case ldEFromHLIndirect = 0x5E
    case ldHFromB = 0x60
    case ldHFromC = 0x61
    case ldHFromD = 0x62
    case ldHFromE = 0x63
    case ldHFromH = 0x64
    case ldHFromL = 0x65
    case ldHFromHLIndirect = 0x66
    case ldLFromB = 0x68
    case ldLFromC = 0x69
    case ldLFromD = 0x6A
    case ldLFromE = 0x6B
    case ldLFromH = 0x6C
    case ldLFromL = 0x6D
    case ldLFromHLIndirect = 0x6E
    case ldHLIndirectFromB = 0x70
    case ldHLIndirectFromC = 0x71
    case ldHLIndirectFromD = 0x72
    case ldHLIndirectFromE = 0x73
    case ldHLIndirectFromH = 0x74
    case ldHLIndirectFromL = 0x75
    case addBToA = 0x80
    case addCToA = 0x81
    case addDToA = 0x82
    case addEToA = 0x83
    case addHToA = 0x84
    case addLToA = 0x85
    case addHLIndirectToA = 0x86
    case addAToA = 0x87
    case adcBToA = 0x88
    case adcCToA = 0x89
    case adcDToA = 0x8A
    case adcEToA = 0x8B
    case adcHToA = 0x8C
    case adcLToA = 0x8D
    case adcHLIndirectToA = 0x8E
    case adcAToA = 0x8F
    case subBFromA = 0x90
    case subCFromA = 0x91
    case subDFromA = 0x92
    case subEFromA = 0x93
    case subHFromA = 0x94
    case subLFromA = 0x95
    case subHLIndirectFromA = 0x96
    case subAFromA = 0x97
    case sbcBFromA = 0x98
    case sbcCFromA = 0x99
    case sbcDFromA = 0x9A
    case sbcEFromA = 0x9B
    case sbcHFromA = 0x9C
    case sbcLFromA = 0x9D
    case sbcHLIndirectFromA = 0x9E
    case sbcAFromA = 0x9F
    case andAWithB = 0xA0
    case andAWithC = 0xA1
    case andAWithD = 0xA2
    case andAWithE = 0xA3
    case andAWithH = 0xA4
    case andAWithL = 0xA5
    case andAWithHLIndirect = 0xA6
    case andAWithA = 0xA7
    case xorAWithB = 0xA8
    case xorAWithC = 0xA9
    case xorAWithD = 0xAA
    case xorAWithE = 0xAB
    case xorAWithH = 0xAC
    case xorAWithL = 0xAD
    case xorAWithHLIndirect = 0xAE
    case xorAWithA = 0xAF
    case orAWithB = 0xB0
    case orAWithC = 0xB1
    case orAWithD = 0xB2
    case orAWithE = 0xB3
    case orAWithH = 0xB4
    case orAWithL = 0xB5
    case orAWithHLIndirect = 0xB6
    case orAWithA = 0xB7
    case cpAWithB = 0xB8
    case cpAWithC = 0xB9
    case cpAWithD = 0xBA
    case cpAWithE = 0xBB
    case cpAWithH = 0xBC
    case cpAWithL = 0xBD
    case cpAWithHLIndirect = 0xBE
    case cpAWithA = 0xBF
    case addImmediateToA = 0xC6
    case adcImmediateToA = 0xCE
    case subImmediateFromA = 0xD6
    case sbcImmediateFromA = 0xDE
    case andImmediateWithA = 0xE6
    case xorImmediateWithA = 0xEE
    case orImmediateWithA = 0xF6
    case cpImmediateWithA = 0xFE
}

extension Opcode {
    enum Register8Target: UInt8 {
        case b = 0b000
        case c = 0b001
        case d = 0b010
        case e = 0b011
        case h = 0b100
        case l = 0b101
        case hlIndirect = 0b110
        case a = 0b111

        init?(atBit3Of opcode: Opcode) {
            let rawValue = (opcode.rawValue & 0b0011_1000) >> 3
            self.init(rawValue: rawValue)
        }

        init?(atBit0Of opcode: Opcode) {
            let rawValue = opcode.rawValue & 0b0000_0111
            self.init(rawValue: rawValue)
        }
    }

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

    enum JumpCondition: UInt8 {
        case zeroReset = 0b00
        case zeroSet = 0b01
        case carryReset = 0b10
        case carrySet = 0b11

        init?(opcode: Opcode) {
            let rawValue = (opcode.rawValue & 0b0001_1000) >> 3
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
        case .incB, .incC, .incD, .incE, .incH, .incL, .incHLIndirect, .incA: 1
        case .decB, .decC, .decD, .decE, .decH, .decL, .decHLIndirect, .decA: 1
        case .ldBFromImmediate, .ldCFromImmediate, .ldDFromImmediate, .ldEFromImmediate, .ldHFromImmediate, .ldLFromImmediate, .ldHLIndirectFromImmediate, .ldAFromImmediate: 2
        case .rlca, .rrca, .rla, .rra, .daa, .cpl, .scf, .ccf: 1
        case .jrImmediate: 2
        case .jrImmediateIfZeroReset, .jrImmediateIfZeroSet, .jrImmediateIfCarryReset, .jrImmediateIfCarrySet: 3
        case .ldImmediateIndirectFromSP: 3
        case .addBCToHL, .addDEToHL, .addHLToHL, .addSPToHL: 1
        case .ldAFromBCIndirect, .ldAFromDEIndirect, .ldAFromHLIndirectAndIncrement, .ldAFromHLIndirectAndDecrement: 1
        case .decBC, .decDE, .decHL, .decSP: 1
        case .ldBFromB, .ldBFromC, .ldBFromD, .ldBFromE, .ldBFromH, .ldBFromL, .ldBFromHLIndirect,
                .ldCFromB, .ldCFromC, .ldCFromD, .ldCFromE, .ldCFromH, .ldCFromL, .ldCFromHLIndirect,
                .ldDFromB, .ldDFromC, .ldDFromD, .ldDFromE, .ldDFromH, .ldDFromL, .ldDFromHLIndirect,
                .ldEFromB, .ldEFromC, .ldEFromD, .ldEFromE, .ldEFromH, .ldEFromL, .ldEFromHLIndirect,
                .ldHFromB, .ldHFromC, .ldHFromD, .ldHFromE, .ldHFromH, .ldHFromL, .ldHFromHLIndirect,
                .ldLFromB, .ldLFromC, .ldLFromD, .ldLFromE, .ldLFromH, .ldLFromL, .ldLFromHLIndirect,
                .ldHLIndirectFromB, .ldHLIndirectFromC, .ldHLIndirectFromD,
                .ldHLIndirectFromE, .ldHLIndirectFromH, .ldHLIndirectFromL: 1
        case .addBToA, .addCToA, .addDToA, .addEToA, .addHToA, .addLToA, .addHLIndirectToA, .addAToA: 1
        case .adcBToA, .adcCToA, .adcDToA, .adcEToA, .adcHToA, .adcLToA, .adcHLIndirectToA, .adcAToA: 1
        case .subBFromA, .subCFromA, .subDFromA, .subEFromA, .subHFromA, .subLFromA, .subHLIndirectFromA, .subAFromA: 1
        case .sbcBFromA, .sbcCFromA, .sbcDFromA, .sbcEFromA, .sbcHFromA, .sbcLFromA, .sbcHLIndirectFromA, .sbcAFromA: 1
        case .andAWithB, .andAWithC, .andAWithD, .andAWithE, .andAWithH, .andAWithL, .andAWithHLIndirect, .andAWithA: 1
        case .xorAWithB, .xorAWithC, .xorAWithD, .xorAWithE, .xorAWithH, .xorAWithL, .xorAWithHLIndirect, .xorAWithA: 1
        case .orAWithB, .orAWithC, .orAWithD, .orAWithE, .orAWithH, .orAWithL, .orAWithHLIndirect, .orAWithA: 1
        case .cpAWithB, .cpAWithC, .cpAWithD, .cpAWithE, .cpAWithH, .cpAWithL, .cpAWithHLIndirect, .cpAWithA: 1
        case .addImmediateToA, .adcImmediateToA, .subImmediateFromA, .sbcImmediateFromA, .andImmediateWithA, .xorImmediateWithA, .orImmediateWithA, .cpImmediateWithA: 2
        }
    }
}

// NOTA BENE: This extension is commented out until I figure out how
// to best compute the cycle count for instructions for which that figure
// is dependent on some other state of the CPU, such as the various JR
// opcodes.
//
//extension Opcode {
//    var cycles: Int {
//        switch self {
//        case .nop: 1
//        case .ldBCFromImmediate, .ldDEFromImmediate, .ldHLFromImmediate, .ldSPFromImmediate: 3
//        case .ldBCIndirectFromA, .ldDEIndirectFromA, .ldHLIndirectFromAAndIncrement, .ldHLIndirectFromAAndDecrement: 2
//        case .incBC, .incDE, .incHL, .incSP: 2
//        case .incB, .incC, .incD, .incE, .incH, .incL, .incA: 1
//        case .decB, .decC, .decD, .decE, .decH, .decL, .decA: 1
//        case .ldBFromImmediate, .ldCFromImmediate, .ldDFromImmediate, .ldEFromImmediate, .ldHFromImmediate, .ldLFromImmediate, .ldAFromImmediate: 2
//        case .rlca, .rrca, .rla, .rra, .daa, .cpl, .scf, .ccf: 1
//        case .jrImmediate: 3
//        case .ldHLIndirectFromImmediate: 3
//        case .incHLIndirect: 3
//        case .decHLIndirect: 3
//        case .ldImmediateIndirectFromSP: 5
//        case .addBCToHL, .addDEToHL, .addHLToHL, .addSPToHL: 2
//        case .ldAFromBCIndirect, .ldAFromDEIndirect, .ldAFromHLIndirectAndIncrement, .ldAFromHLIndirectAndDecrement: 2
//        case .decBC, .decDE, .decHL, .decSP: 2
//        case .ldBFromB, .ldBFromC, .ldBFromD, .ldBFromE, .ldBFromH, .ldBFromL,
//                .ldCFromB, .ldCFromC, .ldCFromD, .ldCFromE, .ldCFromH, .ldCFromL,
//                .ldDFromB, .ldDFromC, .ldDFromD, .ldDFromE, .ldDFromH, .ldDFromL,
//                .ldEFromB, .ldEFromC, .ldEFromD, .ldEFromE, .ldEFromH, .ldEFromL,
//                .ldHFromB, .ldHFromC, .ldHFromD, .ldHFromE, .ldHFromH, .ldHFromL,
//                .ldLFromB, .ldLFromC, .ldLFromD, .ldLFromE, .ldLFromH, .ldLFromL: 1
//        case .ldBFromHLIndirect, .ldCFromHLIndirect, .ldDFromHLIndirect,
//                .ldEFromHLIndirect, .ldHFromHLIndirect, .ldLFromHLIndirect: 2
//        case .ldHLIndirectFromB, .ldHLIndirectFromC, .ldHLIndirectFromD,
//                .ldHLIndirectFromE, .ldHLIndirectFromH, .ldHLIndirectFromL: 2
//        case .addBToA, .addCToA, .addDToA, .addEToA, .addHToA, .addLToA, .addAToA: 1
//        case .addHLIndirectToA: 2
//        case .adcBToA, .adcCToA, .adcDToA, .adcEToA, .adcHToA, .adcLToA, .adcAToA: 1
//        case .adcHLIndirectToA: 2
//        case .subBFromA, .subCFromA, .subDFromA, .subEFromA, .subHFromA, .subLFromA, .subAFromA: 1
//        case .subHLIndirectFromA: 2
//        case .sbcBFromA, .sbcCFromA, .sbcDFromA, .sbcEFromA, .sbcHFromA, .sbcLFromA, .sbcAFromA: 1
//        case .sbcHLIndirectFromA: 2
//        case .andAWithB, .andAWithC, .andAWithD, .andAWithE, .andAWithH, .andAWithL, .andAWithA: 1
//        case .andAWithHLIndirect: 2
//        case .xorAWithB, .xorAWithC, .xorAWithD, .xorAWithE, .xorAWithH, .xorAWithL, .xorAWithA: 1
//        case .xorAWithHLIndirect: 2
//        case .orAWithB, .orAWithC, .orAWithD, .orAWithE, .orAWithH, .orAWithL, .orAWithA: 1
//        case .orAWithHLIndirect: 2
//        case .cpAWithB, .cpAWithC, .cpAWithD, .cpAWithE, .cpAWithH, .cpAWithL, .cpAWithA: 1
//        case .cpAWithHLIndirect: 2
//        case .addImmediateToA, .adcImmediateToA, .subImmediateFromA, .sbcImmediateFromA, .andImmediateWithA, .xorImmediateWithA, .orImmediateWithA, .cpImmediateWithA: 2
//        }
//    }
//}
