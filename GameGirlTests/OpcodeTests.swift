//
//  OpcodeTests.swift
//  GameGirl
//
//  Created by Danielle Kefford on 12/23/25.
//

import Testing
@testable import GameGirl

extension CPU {
    mutating func setProgram(program: [UInt8]) {
        self.program = program
    }
}

enum RegisterChange {
    case unchanged
    case newValue(UInt8)

    public func getValue(oldValue: UInt8) -> UInt8 {
        switch self {
        case .unchanged: return oldValue
        case .newValue(let newValue): return newValue
        }
    }
}

enum RegisterPairChange {
    case unchanged
    case newValue(UInt16)

    public func getValue(oldValue: UInt16) -> UInt16 {
        switch self {
        case .unchanged: return oldValue
        case .newValue(let newValue): return newValue
        }
    }
}

struct OpcodeTests {
    var cpu = CPU()

    @Test mutating func nop() async throws {
        try await self.testProgram(program: [0x00],
                                   extraCycles: 1,
                                   newPC: 0x0001)
    }

    @Test mutating func ldBCFromImmediate() async throws {
        try await self.testProgram(program: [0x01, 0x34, 0x12],
                                   extraCycles: 3,
                                   newPC: 0x0003,
                                   newB: .newValue(0x12),
                                   newC: .newValue(0x34))
    }

    @Test mutating func ldDEFromImmediate() async throws {
        try await self.testProgram(program: [0x11, 0x34, 0x12],
                                   extraCycles: 3,
                                   newPC: 0x0003,
                                   newD: .newValue(0x12),
                                   newE: .newValue(0x34))
    }

    @Test mutating func ldHLFromImmediate() async throws {
        try await self.testProgram(program: [0x21, 0x34, 0x12],
                                   extraCycles: 3,
                                   newPC: 0x0003,
                                   newH: .newValue(0x12),
                                   newL: .newValue(0x34))
    }

    @Test mutating func ldSPFromImmediate() async throws {
        try await self.testProgram(program: [0x31, 0x34, 0x12],
                                   extraCycles: 3,
                                   newPC: 0x0003,
                                   newSP: .newValue(0x1234))
    }

    @Test mutating func ldBFromImmediate() async throws {
        try await self.testProgram(program: [0x06, 0x42],
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newB: .newValue(0x42))
    }

    @Test mutating func ldCFromImmediate() async throws {
        try await self.testProgram(program: [0x0E, 0x42],
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newC: .newValue(0x42))
    }

    @Test mutating func ldDFromImmediate() async throws {
        try await self.testProgram(program: [0x16, 0x42],
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newD: .newValue(0x42))
    }

    @Test mutating func ldEFromImmediate() async throws {
        try await self.testProgram(program: [0x1E, 0x42],
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newE: .newValue(0x42))
    }

    @Test mutating func ldHFromImmediate() async throws {
        try await self.testProgram(program: [0x26, 0x42],
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newH: .newValue(0x42))
    }

    @Test mutating func ldLFromImmediate() async throws {
        try await self.testProgram(program: [0x2E, 0x42],
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newL: .newValue(0x42))
    }

    @Test mutating func ldHLIndirectFromImmediate() async throws {
        try await self.testProgram(program: [0x36, 0x42, 0x00],
                                   h: 0x00,
                                   l: 0x02,
                                   extraCycles: 3,
                                   newPC: 0x0002,
                                   memoryChanges: [0x0002 : 0x42])
    }

    @Test mutating func ldAFromImmediate() async throws {
        try await self.testProgram(program: [0x3E, 0x42],
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newA: .newValue(0x42))
    }

    @Test mutating func ldBCIndirectFromA() async throws {
        try await self.testProgram(program: [0x02, 0x00, 0x00, 0x00],
                                   a: 0x42,
                                   b: 0x00,
                                   c: 0x03,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   memoryChanges: [0x0003 : 0x42])
    }

    @Test mutating func ldDEIndirectFromA() async throws {
        try await self.testProgram(program: [0x12, 0x00, 0x00, 0x00],
                                   a: 0x42,
                                   d: 0x00,
                                   e: 0x03,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   memoryChanges: [0x0003 : 0x42])
    }


    @Test mutating func ldHLIndirectFromAAndIncrement() async throws {
        try await self.testProgram(program: [0x22, 0x00, 0x00, 0x00],
                                   a: 0x42,
                                   h: 0x00,
                                   l: 0x03,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newH: .unchanged,
                                   newL: .newValue(0x04),
                                   memoryChanges: [0x0003 : 0x42])
    }

    @Test mutating func ldHLIndirectFromAAndDecrement() async throws {
        try await self.testProgram(program: [0x32, 0x00, 0x00, 0x00],
                                   a: 0x42,
                                   h: 0x00,
                                   l: 0x03,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newH: .unchanged,
                                   newL: .newValue(0x02),
                                   memoryChanges: [0x0003 : 0x42])
    }

    @Test mutating func ldAFromBCIndirect() async throws {
        try await self.testProgram(program: [0x0A, 0x00, 0x00, 0x42],
                                   b: 0x00,
                                   c: 0x03,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newA: .newValue(0x42))
    }

    @Test mutating func ldAFromDEIndirect() async throws {
        try await self.testProgram(program: [0x1A, 0x00, 0x00, 0x42],
                                   d: 0x00,
                                   e: 0x03,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newA: .newValue(0x42))
    }

    @Test mutating func ldAFromHLIndirectAndIncrement() async throws {
        try await self.testProgram(program: [0x2A, 0x00, 0x00, 0x42],
                                   h: 0x00,
                                   l: 0x03,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newA: .newValue(0x42),
                                   newH: .unchanged,
                                   newL: .newValue(0x04))
    }

    @Test mutating func ldAFromHLIndirectAndDecrement() async throws {
        try await self.testProgram(program: [0x3A, 0x00, 0x00, 0x42],
                                   h: 0x00,
                                   l: 0x03,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newA: .newValue(0x42),
                                   newH: .unchanged,
                                   newL: .newValue(0x02))
    }

    @Test mutating func ldImmediateIndirectFromSP() async throws {
        try await self.testProgram(program: [0x08, 0x03, 0x00, 0x00, 0x00],
                                   sp: 0x1234,
                                   extraCycles: 5,
                                   newPC: 0x0003,
                                   memoryChanges: [
                                       0x0003 : 0x34,
                                       0x0004 : 0x12])
    }

    @Test mutating func rlcaWithCarryAndZero() async throws {
        try await self.testProgram(program: [0x07],
                                   a: 0x80,
                                   f: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x00),
                                   newF: .newValue(RegisterBit.zero.value | RegisterBit.carry.value))
    }

    @Test mutating func rlcaWithCarryButNotZero() async throws {
        try await self.testProgram(program: [0x07],
                                   a: 0xFF,
                                   f: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0xFE),
                                   newF: .newValue(RegisterBit.carry.value))
    }

    @Test mutating func rlcaWithZeroButNotCarry() async throws {
        try await self.testProgram(program: [0x07],
                                   a: 0x00,
                                   f: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x00),
                                   newF: .newValue(RegisterBit.zero.value))
    }

    @Test mutating func rlcaWithNoFlagsSet() async throws {
        try await self.testProgram(program: [0x07],
                                   a: 0x01,
                                   f: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x02),
                                   newF: .unchanged)
    }

    @Test mutating func rrcaWithCarryAndZero() async throws {
        try await self.testProgram(program: [0x0F],
                                   a: 0x01,
                                   f: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x00),
                                   newF: .newValue(RegisterBit.zero.value | RegisterBit.carry.value))
    }

    @Test mutating func rrcaWithCarryButNotZero() async throws {
        try await self.testProgram(program: [0x0F],
                                   a: 0xFF,
                                   f: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x7F),
                                   newF: .newValue(RegisterBit.carry.value))
    }

    @Test mutating func rrcaWithZeroButNotCarry() async throws {
        try await self.testProgram(program: [0x0F],
                                   a: 0x00,
                                   f: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x00),
                                   newF: .newValue(RegisterBit.zero.value))
    }

    @Test mutating func rrcaWithNoFlagsSet() async throws {
        try await self.testProgram(program: [0x0F],
                                   a: 0x80,
                                   f: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x40),
                                   newF: .unchanged)
    }

    @Test mutating func rlaWithCarryAndZero() async throws {
        try await self.testProgram(program: [0x17],
                                   a: 0x80,
                                   f: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x00),
                                   newF: .newValue(RegisterBit.zero.value | RegisterBit.carry.value))
    }

    @Test mutating func rlaWithCarryButNotZero() async throws {
        try await self.testProgram(program: [0x17],
                                   a: 0xFF,
                                   f: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0xFE),
                                   newF: .newValue(RegisterBit.carry.value))
    }

    @Test mutating func rlaWithZeroButNotCarry() async throws {
        try await self.testProgram(program: [0x17],
                                   a: 0x00,
                                   f: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x00),
                                   newF: .newValue(RegisterBit.zero.value))
    }

    @Test mutating func rlaWithNoFlagsSet() async throws {
        try await self.testProgram(program: [0x17],
                                   a: 0x01,
                                   f: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x02),
                                   newF: .unchanged)
    }

    @Test mutating func rlaWithOldCarryRotatedIn() async throws {
        try await self.testProgram(program: [0x17],
                                   a: 0x00,
                                   f: 0x10,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x01),
                                   newF: .newValue(0x00))
    }

    @Test mutating func rraWithCarryAndZero() async throws {
        try await self.testProgram(program: [0x1F],
                                   a: 0x01,
                                   f: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x00),
                                   newF: .newValue(RegisterBit.zero.value | RegisterBit.carry.value))
    }

    @Test mutating func rraWithCarryButNotZero() async throws {
        try await self.testProgram(program: [0x1F],
                                   a: 0xFF,
                                   f: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x7F),
                                   newF: .newValue(RegisterBit.carry.value))
    }

    @Test mutating func rraWithZeroButNotCarry() async throws {
        try await self.testProgram(program: [0x1F],
                                   a: 0x00,
                                   f: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .unchanged,
                                   newF: .newValue(RegisterBit.zero.value))
    }

    @Test mutating func rraWithNoFlagsSet() async throws {
        try await self.testProgram(program: [0x1F],
                                   a: 0x80,
                                   f: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x40),
                                   newF: .unchanged)
    }

    @Test mutating func rraWithOldCarryRotatedIn() async throws {
        try await self.testProgram(program: [0x1F],
                                   a: 0x00,
                                   f: 0x10,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x80),
                                   newF: .newValue(0x00))
    }

    @Test mutating func daaAfterAdditionNoCorrectionNeeded() async throws {
        try await self.testProgram(program: [0x27],
                                   a: 0x01,
                                   f: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .unchanged,
                                   newF: .unchanged)
    }

    @Test mutating func daaAfterAdditionZeroResult() async throws {
        try await self.testProgram(program: [0x27],
                                   a: 0x00,
                                   f: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .unchanged,
                                   newF: .newValue(RegisterBit.zero.value))
    }

    @Test mutating func daaAfterAdditionOnesDigitCorrected() async throws {
        try await self.testProgram(program: [0x27],
                                   a: 0x0F,
                                   f: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x15),
                                   newF: .unchanged)
    }

    @Test mutating func daaAfterAdditionTensDigitCorrected() async throws {
        try await self.testProgram(program: [0x27],
                                   a: 0xF0,
                                   f: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x50),
                                   newF: .newValue(RegisterBit.carry.value))
    }

    @Test mutating func daaAfterAdditionBothDigitsCorrected() async throws {
        try await self.testProgram(program: [0x27],
                                   a: 0x9C,
                                   f: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x02),
                                   newF: .newValue(RegisterBit.carry.value))
    }

    @Test mutating func daaAfterSubtractionNoCorrectionNeeded() async throws {
        try await self.testProgram(program: [0x27],
                                   a: 0x09,
                                   f: 0x40,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .unchanged,
                                   newF: .unchanged)
    }

    @Test mutating func daaAfterSubtractionOnesDigitCorrected() async throws {
        try await self.testProgram(program: [0x27],
                                   a: 0x0D,
                                   f: 0x60,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x07),
                                   newF: .newValue(RegisterBit.subtraction.value))
    }

    @Test mutating func daaAfterSubtractionTensDigitCorrected() async throws {
        try await self.testProgram(program: [0x27],
                                   a: 0xE4,
                                   f: 0x50,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x84),
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.carry.value))
    }

    @Test mutating func cpl() async throws {
        try await self.testProgram(program: [0x2F],
                                   a: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0xFF),
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value))
    }

    @Test mutating func scf() async throws {
        try await self.testProgram(program: [0x37],
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newF: .newValue(RegisterBit.carry.value))
    }

    @Test mutating func ccfSetCarry() async throws {
        try await self.testProgram(program: [0x3F],
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newF: .newValue(RegisterBit.carry.value))
    }

    @Test mutating func ccfResetCarry() async throws {
        try await self.testProgram(program: [0x3F],
                                   f: 0x10,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newF: .newValue(0x00))
    }

    @Test mutating func incBC() async throws {
        try await self.testProgram(program: [0x03],
                                   b: 0x12,
                                   c: 0x34,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newB: .unchanged,
                                   newC: .newValue(0x35))
    }

    @Test mutating func incDE() async throws {
        try await self.testProgram(program: [0x13],
                                   d: 0x12,
                                   e: 0x34,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newD: .unchanged,
                                   newE: .newValue(0x35))
    }

    @Test mutating func incHL() async throws {
        try await self.testProgram(program: [0x23],
                                   h: 0xFF,
                                   l: 0xFF,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newH: .newValue(0x00),
                                   newL: .newValue(0x00))
    }

    @Test mutating func incSP() async throws {
        try await self.testProgram(program: [0x33],
                                   sp: 0x1234,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newSP: .newValue(0x1235))
    }

    @Test mutating func incB() async throws {
        try await self.testProgram(program: [0x04],
                                   b: 0x0F,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newF: .newValue(RegisterBit.halfCarry.value),
                                   newB: .newValue(0x10))
    }

    @Test mutating func incC() async throws {
        try await self.testProgram(program: [0x0C],
                                   c: 0xFF,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newF: .newValue(RegisterBit.zero.value | RegisterBit.carry.value | RegisterBit.halfCarry.value),
                                   newC: .newValue(0x00))
    }

    @Test mutating func incD() async throws {
        try await self.testProgram(program: [0x14],
                                   d: 0x41,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newF: .unchanged,
                                   newD: .newValue(0x42))
    }

    @Test mutating func incE() async throws {
        try await self.testProgram(program: [0x1C],
                                   e: 0x41,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newF: .unchanged,
                                   newE: .newValue(0x42))
    }

    @Test mutating func incH() async throws {
        try await self.testProgram(program: [0x24],
                                   h: 0x41,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newF: .unchanged,
                                   newH: .newValue(0x42))
    }

    @Test mutating func incL() async throws {
        try await self.testProgram(program: [0x2C],
                                   l: 0x41,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newF: .unchanged,
                                   newL: .newValue(0x42))
    }

    @Test mutating func incHLIndirect() async throws {
        try await self.testProgram(program: [0x34, 0xFF],
                                   h: 0x00,
                                   l: 0x01,
                                   extraCycles: 3,
                                   newPC: 0x0001,
                                   newF: .newValue(RegisterBit.zero.value | RegisterBit.carry.value | RegisterBit.halfCarry.value),
                                   memoryChanges: [0x0001: 0x00])
    }

    @Test mutating func incA() async throws {
        try await self.testProgram(program: [0x3C],
                                   a: 0x41,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x42),
                                   newF: .unchanged)
    }

    @Test mutating func decBC() async throws {
        try await self.testProgram(program: [0x0B],
                                   b: 0x12,
                                   c: 0x34,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newB: .unchanged,
                                   newC: .newValue(0x33))
    }

    @Test mutating func decDE() async throws {
        try await self.testProgram(program: [0x1B],
                                   d: 0x12,
                                   e: 0x34,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newD: .unchanged,
                                   newE: .newValue(0x33))
    }

    @Test mutating func decHL() async throws {
        try await self.testProgram(program: [0x2B],
                                   h: 0x00,
                                   l: 0x00,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newH: .newValue(0xFF),
                                   newL: .newValue(0xFF))
    }

    @Test mutating func decSP() async throws {
        try await self.testProgram(program: [0x3B],
                                   sp: 0x1234,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newSP: .newValue(0x1233))
    }

    @Test mutating func decB() async throws {
        try await self.testProgram(program: [0x05],
                                   b: 0x0F,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value),
                                   newB: .newValue(0x0E))
    }

    @Test mutating func decC() async throws {
        try await self.testProgram(program: [0x0D],
                                   c: 0x10,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newF: .newValue(RegisterBit.subtraction.value),
                                   newC: .newValue(0x0F))
    }

    @Test mutating func decD() async throws {
        try await self.testProgram(program: [0x15],
                                   d: 0x01,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value | RegisterBit.zero.value),
                                   newD: .newValue(0x00))
    }

    @Test mutating func decE() async throws {
        try await self.testProgram(program: [0x1D],
                                   e: 0x43,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value),
                                   newE: .newValue(0x42))
    }

    @Test mutating func decH() async throws {
        try await self.testProgram(program: [0x25],
                                   h: 0x43,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value),
                                   newH: .newValue(0x42))
    }

    @Test mutating func decL() async throws {
        try await self.testProgram(program: [0x2D],
                                   l: 0x43,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value),
                                   newL: .newValue(0x42))
    }

    @Test mutating func decHLIndirect() async throws {
        try await self.testProgram(program: [0x35, 0x43],
                                   h: 0x00,
                                   l: 0x01,
                                   extraCycles: 3,
                                   newPC: 0x0001,
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value),
                                   memoryChanges: [0x0001: 0x42])
    }

    @Test mutating func decA() async throws {
        try await self.testProgram(program: [0x3D],
                                   a: 0x43,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x42),
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value))
    }

    @Test mutating func addBCToHL() async throws {
        try await self.testProgram(program: [0x09],
                                   b: 0x01,
                                   c: 0x02,
                                   h: 0x03,
                                   l: 0x04,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newB: .unchanged,
                                   newC: .unchanged,
                                   newH: .newValue(0x04),
                                   newL: .newValue(0x06))
    }

    @Test mutating func addDEToHL() async throws {
        try await self.testProgram(program: [0x19],
                                   d: 0x0F,
                                   e: 0x01,
                                   h: 0x01,
                                   l: 0x02,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newF: .newValue(RegisterBit.halfCarry.value),
                                   newD: .unchanged,
                                   newE: .unchanged,
                                   newH: .newValue(0x10),
                                   newL: .newValue(0x03))
    }

    @Test mutating func addHLToHL() async throws {
        try await self.testProgram(program: [0x29],
                                   h: 0x7F,
                                   l: 0xFF,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newF: .newValue(RegisterBit.halfCarry.value),
                                   newH: .newValue(0xFF),
                                   newL: .newValue(0xFE))
    }

    @Test mutating func addSPToHL() async throws {
        try await self.testProgram(program: [0x39],
                                   sp: 0x0001,
                                   h: 0xFF,
                                   l: 0xFF,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newSP: .unchanged,
                                   newF: .newValue(RegisterBit.halfCarry.value | RegisterBit.carry.value),
                                   newH: .newValue(0x00),
                                   newL: .newValue(0x00))
    }

    mutating func testProgram(program: [UInt8],
                              pc: UInt16 = 0x0000,
                              sp: UInt16 = 0x0000,
                              a: UInt8 = 0x00,
                              f: UInt8 = 0x00,
                              b: UInt8 = 0x00,
                              c: UInt8 = 0x00,
                              d: UInt8 = 0x00,
                              e: UInt8 = 0x00,
                              h: UInt8 = 0x00,
                              l: UInt8 = 0x00,
                              extraCycles: Int,
                              newPC: UInt16,
                              newSP: RegisterPairChange = .unchanged,
                              newA: RegisterChange = .unchanged,
                              newF: RegisterChange = .unchanged,
                              newB: RegisterChange = .unchanged,
                              newC: RegisterChange = .unchanged,
                              newD: RegisterChange = .unchanged,
                              newE: RegisterChange = .unchanged,
                              newH: RegisterChange = .unchanged,
                              newL: RegisterChange = .unchanged,
                              memoryChanges: [UInt16 : UInt8] = [:]) async throws {
        self.cpu.program = program
        self.cpu.pc = pc
        self.cpu.sp = sp
        self.cpu.a = a
        self.cpu.f = f
        self.cpu.b = b
        self.cpu.c = c
        self.cpu.d = d
        self.cpu.e = e
        self.cpu.h = h
        self.cpu.l = l

        let oldCPU = self.cpu
        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: extraCycles,
                 pc: newPC,
                 sp: newSP,
                 a: newA,
                 f: newF,
                 b: newB,
                 c: newC,
                 d: newD,
                 e: newE,
                 h: newH,
                 l: newL,
                 memoryChanges: memoryChanges)
    }

    func checkCPU(
        _ oldCPU: CPU,
        extraCycles: Int,
        pc: UInt16,
        sp: RegisterPairChange = .unchanged,
        a: RegisterChange = .unchanged,
        f: RegisterChange = .unchanged,
        b: RegisterChange = .unchanged,
        c: RegisterChange = .unchanged,
        d: RegisterChange = .unchanged,
        e: RegisterChange = .unchanged,
        h: RegisterChange = .unchanged,
        l: RegisterChange = .unchanged,
        memoryChanges: [UInt16 : UInt8] = [:]
    ) {
        #expect(self.cpu.cycles == oldCPU.cycles + extraCycles)
        #expect(self.cpu.pc == pc)
        #expect(self.cpu.sp == sp.getValue(oldValue: oldCPU.sp))
        #expect(self.cpu.a == a.getValue(oldValue: oldCPU.a))
        #expect(self.cpu.f == f.getValue(oldValue: oldCPU.f))
        #expect(self.cpu.b == b.getValue(oldValue: oldCPU.b))
        #expect(self.cpu.c == c.getValue(oldValue: oldCPU.c))
        #expect(self.cpu.d == d.getValue(oldValue: oldCPU.d))
        #expect(self.cpu.e == e.getValue(oldValue: oldCPU.e))
        #expect(self.cpu.h == h.getValue(oldValue: oldCPU.h))
        #expect(self.cpu.l == l.getValue(oldValue: oldCPU.l))

        for address in self.cpu.program.indices {
            if let newValue = memoryChanges[UInt16(address)] {
                #expect(self.cpu.program[address] == newValue)
            } else {
                #expect(self.cpu.program[address] == oldCPU.program[address])
            }
        }
    }
}
