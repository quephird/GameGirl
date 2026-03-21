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
        self.memory = program
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

enum FlagChange {
    case unchanged
    case newValue(Bool)

    public func getValue(oldValue: Bool) -> Bool {
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

    @Test mutating func jrImmediate() async throws {
        try await self.testProgram(program: [0x18, 0x40],
                                   extraCycles: 3,
                                   newPC: 0x0042,
                                   newF: .unchanged)
    }

    @Test mutating func jrImmediateIfZeroReset() async throws {
        try await self.testProgram(program: [0x20, 0x40],
                                   f: 0x00,
                                   extraCycles: 3,
                                   newPC: 0x0042,
                                   newF: .unchanged)
    }

    @Test mutating func jrImmediateIfZeroResetButZeroActuallySet() async throws {
        try await self.testProgram(program: [0x20, 0x40],
                                   f: 0x80,
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newF: .unchanged)
    }

    @Test mutating func jrImmediateIfZeroSet() async throws {
        try await self.testProgram(program: [0x28, 0x40],
                                   f: 0x80,
                                   extraCycles: 3,
                                   newPC: 0x0042,
                                   newF: .unchanged)
    }

    @Test mutating func jrImmediateIfZeroSetButZeroActuallyReset() async throws {
        try await self.testProgram(program: [0x28, 0x40],
                                   f: 0x00,
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newF: .unchanged)
    }

    @Test mutating func jrImmediateIfCarryReset() async throws {
        try await self.testProgram(program: [0x30, 0x40],
                                   f: 0x00,
                                   extraCycles: 3,
                                   newPC: 0x0042,
                                   newF: .unchanged)
    }

    @Test mutating func jrImmediateIfCarryResetButCarryActuallySet() async throws {
        try await self.testProgram(program: [0x30, 0x40],
                                   f: 0x10,
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newF: .unchanged)
    }

    @Test mutating func jrImmediateIfCarrySet() async throws {
        try await self.testProgram(program: [0x38, 0x40],
                                   f: 0x00,
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newF: .unchanged)
    }

    @Test mutating func jrImmediateIfCarrySetButCarryActuallyReset() async throws {
        try await self.testProgram(program: [0x38, 0x40],
                                   f: 0x10,
                                   extraCycles: 3,
                                   newPC: 0x0042,
                                   newF: .unchanged)
    }

    @Test mutating func jpImmediate() async throws {
        try await self.testProgram(program: [0xC3, 0x34, 0x12],
                                   extraCycles: 4,
                                   newPC: 0x1234,
                                   newF: .unchanged)
    }

    @Test mutating func jpImmediateIfZeroReset() async throws {
        try await self.testProgram(program: [0xC2, 0x34, 0x12],
                                   f: 0x00,
                                   extraCycles: 4,
                                   newPC: 0x1234,
                                   newF: .unchanged)
    }

    @Test mutating func jpImmediateIfZeroResetButZeroActuallySet() async throws {
        try await self.testProgram(program: [0xC2, 0x34, 0x12],
                                   f: 0x80,
                                   extraCycles: 3,
                                   newPC: 0x0003,
                                   newF: .unchanged)
    }

    @Test mutating func jpImmediateIfZeroSet() async throws {
        try await self.testProgram(program: [0xCA, 0x34, 0x12],
                                   f: 0x80,
                                   extraCycles: 4,
                                   newPC: 0x1234,
                                   newF: .unchanged)
    }

    @Test mutating func jpImmediateIfZeroSetButZeroActuallyReset() async throws {
        try await self.testProgram(program: [0xCA, 0x34, 0x12],
                                   f: 0x00,
                                   extraCycles: 3,
                                   newPC: 0x0003,
                                   newF: .unchanged)
    }

    @Test mutating func jpImmediateIfCarryReset() async throws {
        try await self.testProgram(program: [0xD2, 0x34, 0x12],
                                   f: 0x00,
                                   extraCycles: 4,
                                   newPC: 0x1234,
                                   newF: .unchanged)
    }

    @Test mutating func jpImmediateIfCarryResetButCarryActuallySet() async throws {
        try await self.testProgram(program: [0xD2, 0x34, 0x12],
                                   f: 0x10,
                                   extraCycles: 3,
                                   newPC: 0x0003,
                                   newF: .unchanged)
    }

    @Test mutating func jpImmediateIfCarrySet() async throws {
        try await self.testProgram(program: [0xDA, 0x34, 0x12],
                                   f: 0x00,
                                   extraCycles: 3,
                                   newPC: 0x0003,
                                   newF: .unchanged)
    }

    @Test mutating func jpImmediateIfCarrySetButCarryActuallyReset() async throws {
        try await self.testProgram(program: [0xDA, 0x34, 0x12],
                                   f: 0x10,
                                   extraCycles: 4,
                                   newPC: 0x1234,
                                   newF: .unchanged)
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
                                   b: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newF: .newValue(RegisterBit.subtraction.value),
                                   newB: .newValue(0xFF))
    }

    @Test mutating func decC() async throws {
        try await self.testProgram(program: [0x0D],
                                   c: 0x10,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.carry.value),
                                   newC: .newValue(0x0F))
    }

    @Test mutating func decD() async throws {
        try await self.testProgram(program: [0x15],
                                   d: 0x01,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value | RegisterBit.carry.value | RegisterBit.zero.value),
                                   newD: .newValue(0x00))
    }

    @Test mutating func decE() async throws {
        try await self.testProgram(program: [0x1D],
                                   e: 0xF0,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.carry.value),
                                   newE: .newValue(0xEF))
    }

    @Test mutating func decH() async throws {
        try await self.testProgram(program: [0x25],
                                   h: 0x43,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value | RegisterBit.carry.value),
                                   newH: .newValue(0x42))
    }

    @Test mutating func decL() async throws {
        try await self.testProgram(program: [0x2D],
                                   l: 0x43,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value | RegisterBit.carry.value),
                                   newL: .newValue(0x42))
    }

    @Test mutating func decHLIndirect() async throws {
        try await self.testProgram(program: [0x35, 0x43],
                                   h: 0x00,
                                   l: 0x01,
                                   extraCycles: 3,
                                   newPC: 0x0001,
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value | RegisterBit.carry.value),
                                   memoryChanges: [0x0001: 0x42])
    }

    @Test mutating func decA() async throws {
        try await self.testProgram(program: [0x3D],
                                   a: 0x43,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x42),
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value | RegisterBit.carry.value))
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

    @Test mutating func ldBFromB() async throws {
        try await self.testProgram(program: [0x40],
                                   b: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newB: .unchanged)
    }

    @Test mutating func ldBFromC() async throws {
        try await self.testProgram(program: [0x41],
                                   c: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newB: .newValue(0x42),
                                   newC: .unchanged)
    }

    @Test mutating func ldBFromD() async throws {
        try await self.testProgram(program: [0x42],
                                   d: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newB: .newValue(0x42),
                                   newD: .unchanged)
    }

    @Test mutating func ldBFromE() async throws {
        try await self.testProgram(program: [0x43],
                                   e: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newB: .newValue(0x42),
                                   newE: .unchanged)
    }

    @Test mutating func ldBFromH() async throws {
        try await self.testProgram(program: [0x44],
                                   h: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newB: .newValue(0x42),
                                   newH: .unchanged)
    }

    @Test mutating func ldBFromL() async throws {
        try await self.testProgram(program: [0x45],
                                   l: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newB: .newValue(0x42),
                                   newL: .unchanged)
    }

    @Test mutating func ldBFromHLIndirect() async throws {
        try await self.testProgram(program: [0x46, 0x42],
                                   h: 0x00,
                                   l: 0x01,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newB: .newValue(0x42),
                                   newH: .unchanged,
                                   newL: .unchanged)
    }

    @Test mutating func ldCFromB() async throws {
        try await self.testProgram(program: [0x48],
                                   b: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newB: .unchanged,
                                   newC: .newValue(0x42))
    }

    @Test mutating func ldCFromC() async throws {
        try await self.testProgram(program: [0x49],
                                   c: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newC: .unchanged)
    }

    @Test mutating func ldCFromD() async throws {
        try await self.testProgram(program: [0x4A],
                                   d: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newC: .newValue(0x42),
                                   newD: .unchanged)
    }

    @Test mutating func ldCFromE() async throws {
        try await self.testProgram(program: [0x4B],
                                   e: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newC: .newValue(0x42),
                                   newE: .unchanged)
    }

    @Test mutating func ldCFromH() async throws {
        try await self.testProgram(program: [0x4C],
                                   h: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newC: .newValue(0x42),
                                   newH: .unchanged)
    }

    @Test mutating func ldCFromL() async throws {
        try await self.testProgram(program: [0x4D],
                                   l: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newC: .newValue(0x42),
                                   newL: .unchanged)
    }

    @Test mutating func ldCFromHLIndirect() async throws {
        try await self.testProgram(program: [0x4E, 0x42],
                                   h: 0x00,
                                   l: 0x01,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newC: .newValue(0x42),
                                   newH: .unchanged,
                                   newL: .unchanged)
    }

    @Test mutating func ldDFromB() async throws {
        try await self.testProgram(program: [0x50],
                                   b: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newB: .unchanged,
                                   newD: .newValue(0x42))
    }

    @Test mutating func ldDFromC() async throws {
        try await self.testProgram(program: [0x51],
                                   c: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newC: .unchanged,
                                   newD: .newValue(0x42))
    }

    @Test mutating func ldDFromD() async throws {
        try await self.testProgram(program: [0x52],
                                   d: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newD: .unchanged)
    }

    @Test mutating func ldDFromE() async throws {
        try await self.testProgram(program: [0x53],
                                   e: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newD: .newValue(0x42),
                                   newE: .unchanged)
    }

    @Test mutating func ldDFromH() async throws {
        try await self.testProgram(program: [0x54],
                                   h: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newD: .newValue(0x42),
                                   newH: .unchanged)
    }

    @Test mutating func ldDFromL() async throws {
        try await self.testProgram(program: [0x55],
                                   l: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newD: .newValue(0x42),
                                   newL: .unchanged)
    }

    @Test mutating func ldDFromHLIndirect() async throws {
        try await self.testProgram(program: [0x56, 0x42],
                                   h: 0x00,
                                   l: 0x01,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newD: .newValue(0x42),
                                   newH: .unchanged,
                                   newL: .unchanged)
    }

    @Test mutating func ldEFromB() async throws {
        try await self.testProgram(program: [0x58],
                                   b: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newB: .unchanged,
                                   newE: .newValue(0x42))
    }

    @Test mutating func ldEFromC() async throws {
        try await self.testProgram(program: [0x59],
                                   c: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newC: .unchanged,
                                   newE: .newValue(0x42))
    }

    @Test mutating func ldEFromD() async throws {
        try await self.testProgram(program: [0x5A],
                                   d: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newD: .unchanged,
                                   newE: .newValue(0x42))
    }

    @Test mutating func ldEFromE() async throws {
        try await self.testProgram(program: [0x5B],
                                   e: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newE: .unchanged)
    }

    @Test mutating func ldEFromH() async throws {
        try await self.testProgram(program: [0x5C],
                                   h: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newE: .newValue(0x42),
                                   newH: .unchanged)
    }

    @Test mutating func ldEFromL() async throws {
        try await self.testProgram(program: [0x5D],
                                   l: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newE: .newValue(0x42),
                                   newL: .unchanged)
    }

    @Test mutating func ldEFromHLIndirect() async throws {
        try await self.testProgram(program: [0x5E, 0x42],
                                   h: 0x00,
                                   l: 0x01,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newE: .newValue(0x42),
                                   newH: .unchanged,
                                   newL: .unchanged)
    }

    @Test mutating func ldHFromB() async throws {
        try await self.testProgram(program: [0x60],
                                   b: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newB: .unchanged,
                                   newH: .newValue(0x42))
    }

    @Test mutating func ldHFromC() async throws {
        try await self.testProgram(program: [0x61],
                                   c: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newC: .unchanged,
                                   newH: .newValue(0x42))
    }

    @Test mutating func ldHFromD() async throws {
        try await self.testProgram(program: [0x62],
                                   d: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newD: .unchanged,
                                   newH: .newValue(0x42))
    }

    @Test mutating func ldHFromE() async throws {
        try await self.testProgram(program: [0x63],
                                   e: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newE: .unchanged,
                                   newH: .newValue(0x42))
    }

    @Test mutating func ldHFromH() async throws {
        try await self.testProgram(program: [0x64],
                                   h: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newH: .unchanged)
    }

    @Test mutating func ldHFromL() async throws {
        try await self.testProgram(program: [0x65],
                                   l: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newH: .newValue(0x42),
                                   newL: .unchanged)
    }

    @Test mutating func ldHFromHLIndirect() async throws {
        try await self.testProgram(program: [0x66, 0x42],
                                   h: 0x00,
                                   l: 0x01,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newH: .newValue(0x42),
                                   newL: .unchanged)
    }

    @Test mutating func ldLFromB() async throws {
        try await self.testProgram(program: [0x68],
                                   b: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newB: .unchanged,
                                   newL: .newValue(0x42))
    }

    @Test mutating func ldLFromC() async throws {
        try await self.testProgram(program: [0x69],
                                   c: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newC: .unchanged,
                                   newL: .newValue(0x42))
    }

    @Test mutating func ldLFromD() async throws {
        try await self.testProgram(program: [0x6A],
                                   d: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newD: .unchanged,
                                   newL: .newValue(0x42))
    }

    @Test mutating func ldLFromE() async throws {
        try await self.testProgram(program: [0x6B],
                                   e: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newE: .unchanged,
                                   newL: .newValue(0x42))
    }

    @Test mutating func ldLFromH() async throws {
        try await self.testProgram(program: [0x6C],
                                   h: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newH: .unchanged,
                                   newL: .newValue(0x42))
    }

    @Test mutating func ldLFromL() async throws {
        try await self.testProgram(program: [0x6D],
                                   l: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newL: .unchanged)
    }

    @Test mutating func ldLFromHLIndirect() async throws {
        try await self.testProgram(program: [0x6E, 0x42],
                                   h: 0x00,
                                   l: 0x01,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newH: .unchanged,
                                   newL: .newValue(0x42))
    }

    @Test mutating func ldHLIndirectFromB() async throws {
        try await self.testProgram(program: [0x70, 0x00],
                                   b: 0x42,
                                   h: 0x00,
                                   l: 0x01,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newB: .unchanged,
                                   newH: .unchanged,
                                   newL: .unchanged,
                                   memoryChanges: [0x0001: 0x42])
    }

    @Test mutating func ldHLIndirectFromC() async throws {
        try await self.testProgram(program: [0x71, 0x00],
                                   c: 0x42,
                                   h: 0x00,
                                   l: 0x01,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newC: .unchanged,
                                   newH: .unchanged,
                                   newL: .unchanged,
                                   memoryChanges: [0x0001: 0x42])
    }

    @Test mutating func ldHLIndirectFromD() async throws {
        try await self.testProgram(program: [0x72, 0x00],
                                   d: 0x42,
                                   h: 0x00,
                                   l: 0x01,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newD: .unchanged,
                                   newH: .unchanged,
                                   newL: .unchanged,
                                   memoryChanges: [0x0001: 0x42])
    }

    @Test mutating func ldHLIndirectFromE() async throws {
        try await self.testProgram(program: [0x73, 0x00],
                                   e: 0x42,
                                   h: 0x00,
                                   l: 0x01,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newE: .unchanged,
                                   newH: .unchanged,
                                   newL: .unchanged,
                                   memoryChanges: [0x0001: 0x42])
    }

    @Test mutating func ldHLIndirectFromH() async throws {
        try await self.testProgram(program: [0x74, 0x42],
                                   h: 0x00,
                                   l: 0x01,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newH: .unchanged,
                                   newL: .unchanged,
                                   memoryChanges: [0x0001: 0x00])
    }

    @Test mutating func ldHLIndirectFromL() async throws {
        try await self.testProgram(program: [0x75, 0x42],
                                   h: 0x00,
                                   l: 0x01,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newH: .unchanged,
                                   newL: .unchanged,
                                   memoryChanges: [0x0001: 0x01])
    }

    @Test mutating func addBToA() async throws {
        try await self.testProgram(program: [0x80],
                                   a: 0x21,
                                   f: 0x00,
                                   b: 0x21,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x42),
                                   newF: .unchanged,
                                   newB: .unchanged)
    }

    @Test mutating func addCToA() async throws {
        try await self.testProgram(program: [0x81],
                                   a: 0x21,
                                   f: 0x10,
                                   c: 0x21,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x42),
                                   newF: .newValue(0x00),
                                   newC: .unchanged)
    }

    @Test mutating func addDToA() async throws {
        try await self.testProgram(program: [0x82],
                                   a: 0x00,
                                   f: 0x00,
                                   d: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x00),
                                   newF: .newValue(RegisterBit.zero.value),
                                   newD: .unchanged)
    }

    @Test mutating func addEToA() async throws {
        try await self.testProgram(program: [0x83],
                                   a: 0x0F,
                                   f: 0x00,
                                   e: 0x01,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x10),
                                   newF: .newValue(RegisterBit.halfCarry.value),
                                   newE: .unchanged)
    }

    @Test mutating func addHToA() async throws {
        try await self.testProgram(program: [0x84],
                                   a: 0xF9,
                                   f: 0x00,
                                   h: 0x08,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x01),
                                   newF: .newValue(RegisterBit.halfCarry.value | RegisterBit.carry.value),
                                   newH: .unchanged)
    }

    @Test mutating func addLToA() async throws {
        try await self.testProgram(program: [0x85],
                                   a: 0xFF,
                                   f: 0x00,
                                   l: 0x01,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x00),
                                   newF: .newValue(RegisterBit.zero.value | RegisterBit.halfCarry.value | RegisterBit.carry.value),
                                   newL: .unchanged)
    }

    @Test mutating func addHLIndirectToA() async throws {
        try await self.testProgram(program: [0x86, 0x10],
                                   a: 0xF1,
                                   f: 0x00,
                                   h: 0x00,
                                   l: 0x01,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newA: .newValue(0x01),
                                   newF: .newValue(RegisterBit.carry.value),
                                   newH: .unchanged,
                                   newL: .unchanged)
    }

    @Test mutating func addAToA() async throws {
        try await self.testProgram(program: [0x87],
                                   a: 0x21,
                                   f: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x42),
                                   newF: .unchanged)
   }

    @Test mutating func adcBToA() async throws {
        try await self.testProgram(program: [0x88],
                                   a: 0x21,
                                   f: 0x00,
                                   b: 0x21,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x42),
                                   newF: .unchanged,
                                   newB: .unchanged)
    }

    @Test mutating func adcCToA() async throws {
        try await self.testProgram(program: [0x89],
                                   a: 0x00,
                                   f: 0x00,
                                   c: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .unchanged,
                                   newF: .newValue(RegisterBit.zero.value),
                                   newC: .unchanged)
    }

    @Test mutating func adcDToA() async throws {
        try await self.testProgram(program: [0x8A],
                                   a: 0x00,
                                   f: 0x10,
                                   d: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x01),
                                   newF: .newValue(0x00),
                                   newC: .unchanged)
    }

    @Test mutating func adcEToA() async throws {
        try await self.testProgram(program: [0x8B],
                                   a: 0x0E,
                                   f: 0x10,
                                   e: 0x01,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x10),
                                   newF: .newValue(RegisterBit.halfCarry.value),
                                   newE: .unchanged)
    }

    @Test mutating func adcHToA() async throws {
        try await self.testProgram(program: [0x8C],
                                   a: 0xF0,
                                   f: 0x10,
                                   h: 0x10,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x01),
                                   newF: .newValue(RegisterBit.carry.value),
                                   newH: .unchanged)
    }

    @Test mutating func adcLToA() async throws {
        try await self.testProgram(program: [0x8D],
                                   a: 0xFF,
                                   f: 0x10,
                                   l: 0xFF,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0xFF),
                                   newF: .newValue(RegisterBit.carry.value | RegisterBit.halfCarry.value),
                                   newL: .unchanged)
    }

    @Test mutating func adcHLIndirectToA() async throws {
        try await self.testProgram(program: [0x8E, 0x01],
                                   a: 0xFE,
                                   f: 0x10,
                                   h: 0x00,
                                   l: 0x01,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newA: .newValue(0x00),
                                   newF: .newValue(RegisterBit.zero.value | RegisterBit.carry.value | RegisterBit.halfCarry.value),
                                   newH: .unchanged,
                                   newL: .unchanged)
    }

    @Test mutating func adcAToA() async throws {
        try await self.testProgram(program: [0x8F],
                                   a: 0x21,
                                   f: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x42),
                                   newF: .unchanged)
    }

    @Test mutating func subBFromA() async throws {
        try await self.testProgram(program: [0x90],
                                   a: 0x63,
                                   f: 0x00,
                                   b: 0x21,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x42),
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value | RegisterBit.carry.value),
                                   newB: .unchanged)
    }

    @Test mutating func subCFromA() async throws {
        try await self.testProgram(program: [0x91],
                                   a: 0xE0,
                                   f: 0x00,
                                   c: 0xF0,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0xF0),
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value),
                                   newC: .unchanged)
    }

    @Test mutating func subDFromA() async throws {
        try await self.testProgram(program: [0x92],
                                   a: 0x10,
                                   f: 0x00,
                                   d: 0x01,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x0F),
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.carry.value),
                                   newD: .unchanged)
    }

    @Test mutating func subEFromA() async throws {
        try await self.testProgram(program: [0x93],
                                   a: 0x00,
                                   f: 0x00,
                                   e: 0x01,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0xFF),
                                   newF: .newValue(RegisterBit.subtraction.value),
                                   newE: .unchanged)
    }

    @Test mutating func subHFromA() async throws {
        try await self.testProgram(program: [0x94],
                                   a: 0x01,
                                   f: 0x00,
                                   h: 0x01,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x00),
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.zero.value | RegisterBit.halfCarry.value | RegisterBit.carry.value),
                                   newH: .unchanged)
    }

    @Test mutating func subLFromA() async throws {
        try await self.testProgram(program: [0x95],
                                   a: 0x63,
                                   f: 0x00,
                                   l: 0x21,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x42),
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value | RegisterBit.carry.value),
                                   newL: .unchanged)
    }

    @Test mutating func subHLIndirectFromA() async throws {
        try await self.testProgram(program: [0x96, 0x21],
                                   a: 0x63,
                                   f: 0x00,
                                   h: 0x00,
                                   l: 0x01,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newA: .newValue(0x42),
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value | RegisterBit.carry.value),
                                   newH: .unchanged,
                                   newL: .unchanged)
    }

    @Test mutating func subAFromA() async throws {
        try await self.testProgram(program: [0x97],
                                   a: 0x42,
                                   f: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x00),
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.zero.value | RegisterBit.halfCarry.value | RegisterBit.carry.value))
    }

    @Test mutating func sbcBFromA() async throws {
        try await self.testProgram(program: [0x98],
                                   a: 0x63,
                                   f: 0x00,
                                   b: 0x21,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x42),
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value | RegisterBit.carry.value),
                                   newB: .unchanged)
    }

    @Test mutating func sbcCFromA() async throws {
        try await self.testProgram(program: [0x99],
                                   a: 0xE0,
                                   f: 0x00,
                                   c: 0xF0,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0xF0),
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value),
                                   newC: .unchanged)
    }

    @Test mutating func sbcDFromA() async throws {
        try await self.testProgram(program: [0x9A],
                                   a: 0x10,
                                   f: 0x00,
                                   d: 0x01,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x0F),
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.carry.value),
                                   newD: .unchanged)
    }

    @Test mutating func sbcEFromA() async throws {
        try await self.testProgram(program: [0x9B],
                                   a: 0x00,
                                   f: 0x00,
                                   e: 0x01,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0xFF),
                                   newF: .newValue(RegisterBit.subtraction.value),
                                   newE: .unchanged)
    }

    @Test mutating func sbcHFromA() async throws {
        try await self.testProgram(program: [0x9C],
                                   a: 0x01,
                                   f: 0x00,
                                   h: 0x01,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x00),
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.zero.value | RegisterBit.halfCarry.value | RegisterBit.carry.value),
                                   newH: .unchanged)
    }

    @Test mutating func sbcLFromA() async throws {
        try await self.testProgram(program: [0x9D],
                                   a: 0x64,
                                   f: 0x10,
                                   l: 0x21,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x42),
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value | RegisterBit.carry.value),
                                   newL: .unchanged)
    }

    @Test mutating func sbcHLIndirectFromA() async throws {
        try await self.testProgram(program: [0x9E, 0x01],
                                   a: 0x01,
                                   f: 0x10,
                                   h: 0x00,
                                   l: 0x01,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newA: .newValue(0xFF),
                                   newF: .newValue(RegisterBit.subtraction.value),
                                   newH: .unchanged,
                                   newL: .unchanged)
    }

    @Test mutating func sbcAFromA() async throws {
        try await self.testProgram(program: [0x9F],
                                   a: 0x42,
                                   f: 0x10,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0xFF),
                                   newF: .newValue(RegisterBit.subtraction.value))
    }

    @Test mutating func andAWithB() async throws {
        try await self.testProgram(program: [0xA0],
                                   a: 0xFF,
                                   f: 0x00,
                                   b: 0xFF,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0xFF),
                                   newF: .newValue(RegisterBit.halfCarry.value),
                                   newB: .unchanged)
    }

    @Test mutating func andAWithC() async throws {
        try await self.testProgram(program: [0xA1],
                                   a: 0xFF,
                                   f: 0x00,
                                   c: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x00),
                                   newF: .newValue(RegisterBit.zero.value | RegisterBit.halfCarry.value),
                                   newB: .unchanged)
    }

    @Test mutating func andAWithD() async throws {
        try await self.testProgram(program: [0xA2],
                                   a: 0x55,
                                   f: 0x00,
                                   d: 0x5A,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x50),
                                   newF: .newValue(RegisterBit.halfCarry.value),
                                   newD: .unchanged)
    }

    @Test mutating func andAWithE() async throws {
        try await self.testProgram(program: [0xA3],
                                   a: 0x55,
                                   f: 0x00,
                                   e: 0xAA,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x00),
                                   newF: .newValue(RegisterBit.zero.value | RegisterBit.halfCarry.value),
                                   newE: .unchanged)
    }

    @Test mutating func andAWithH() async throws {
        try await self.testProgram(program: [0xA4],
                                   a: 0xE7,
                                   f: 0x00,
                                   h: 0x7E,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x66),
                                   newF: .newValue(RegisterBit.halfCarry.value),
                                   newH: .unchanged)
    }

    @Test mutating func andAWithL() async throws {
        try await self.testProgram(program: [0xA5],
                                   a: 0xC3,
                                   f: 0x00,
                                   l: 0x3C,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x00),
                                   newF: .newValue(RegisterBit.zero.value | RegisterBit.halfCarry.value),
                                   newL: .unchanged)
    }

    @Test mutating func andAFromHLIndirect() async throws {
        try await self.testProgram(program: [0xA6, 0xAA],
                                   a: 0x55,
                                   f: 0x00,
                                   h: 0x00,
                                   l: 0x01,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newA: .newValue(0x00),
                                   newF: .newValue(RegisterBit.zero.value | RegisterBit.halfCarry.value),
                                   newH: .unchanged,
                                   newL: .unchanged)
    }

    @Test mutating func andAWithA() async throws {
        try await self.testProgram(program: [0xA7],
                                   a: 0x42,
                                   f: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .unchanged,
                                   newF: .newValue(RegisterBit.halfCarry.value))
    }

    @Test mutating func andAWithImmediate() async throws {
        try await self.testProgram(program: [0xE6, 0x5A],
                                   a: 0xFF,
                                   f: 0x00,
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newA: .newValue(0x5A),
                                   newF: .newValue(RegisterBit.halfCarry.value))
    }

    @Test mutating func xorAWithB() async throws {
        try await self.testProgram(program: [0xA8],
                                   a: 0xFF,
                                   f: 0x00,
                                   b: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0xFF),
                                   newF: .unchanged,
                                   newB: .unchanged)
    }

    @Test mutating func xorAWithC() async throws {
        try await self.testProgram(program: [0xA9],
                                   a: 0xFF,
                                   f: 0x00,
                                   c: 0xFF,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x00),
                                   newF: .newValue(RegisterBit.zero.value),
                                   newC: .unchanged)
    }

    @Test mutating func xorAWithD() async throws {
        try await self.testProgram(program: [0xAA],
                                   a: 0x55,
                                   f: 0x00,
                                   d: 0xAA,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0xFF),
                                   newF: .unchanged,
                                   newD: .unchanged)
    }

    @Test mutating func xorAWithE() async throws {
        try await self.testProgram(program: [0xAB],
                                   a: 0xF0,
                                   f: 0x00,
                                   e: 0x0F,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0xFF),
                                   newF: .unchanged,
                                   newE: .unchanged)
    }

    @Test mutating func xorAWithH() async throws {
        try await self.testProgram(program: [0xAC],
                                   a: 0xE7,
                                   f: 0x00,
                                   h: 0xE7,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x00),
                                   newF: .newValue(RegisterBit.zero.value),
                                   newH: .unchanged)
    }

    @Test mutating func xorAWithL() async throws {
        try await self.testProgram(program: [0xAD],
                                   a: 0xC3,
                                   f: 0x00,
                                   l: 0x3C,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0xFF),
                                   newF: .unchanged,
                                   newL: .unchanged)
    }

    @Test mutating func xorAFromHLIndirect() async throws {
        try await self.testProgram(program: [0xAE, 0xAA],
                                   a: 0xAA,
                                   f: 0x00,
                                   h: 0x00,
                                   l: 0x01,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newA: .newValue(0x00),
                                   newF: .newValue(RegisterBit.zero.value),
                                   newH: .unchanged,
                                   newL: .unchanged)
    }

    @Test mutating func xorAWithA() async throws {
        try await self.testProgram(program: [0xAF],
                                   a: 0x42,
                                   f: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x00),
                                   newF: .newValue(RegisterBit.zero.value))
    }

    @Test mutating func xorAWithImmediate() async throws {
        try await self.testProgram(program: [0xEE, 0x5A],
                                   a: 0xA5,
                                   f: 0x00,
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newA: .newValue(0xFF),
                                   newF: .newValue(0x00))
    }

    @Test mutating func orAWithB() async throws {
        try await self.testProgram(program: [0xB0],
                                   a: 0x33,
                                   f: 0x00,
                                   b: 0xCC,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0xFF),
                                   newF: .unchanged,
                                   newB: .unchanged)
    }

    @Test mutating func orAWithC() async throws {
        try await self.testProgram(program: [0xB1],
                                   a: 0x00,
                                   f: 0x00,
                                   c: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x00),
                                   newF: .newValue(RegisterBit.zero.value),
                                   newC: .unchanged)
    }

    @Test mutating func orAWithD() async throws {
        try await self.testProgram(program: [0xB2],
                                   a: 0x80,
                                   f: 0x00,
                                   d: 0x01,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x81),
                                   newF: .unchanged,
                                   newD: .unchanged)
    }

    @Test mutating func orAWithE() async throws {
        try await self.testProgram(program: [0xB3],
                                   a: 0xE0,
                                   f: 0x00,
                                   e: 0x1F,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0xFF),
                                   newF: .unchanged,
                                   newE: .unchanged)
    }

    @Test mutating func orAWithH() async throws {
        try await self.testProgram(program: [0xB4],
                                   a: 0x00,
                                   f: 0x00,
                                   h: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0x00),
                                   newF: .newValue(RegisterBit.zero.value),
                                   newH: .unchanged)
    }

    @Test mutating func orAWithL() async throws {
        try await self.testProgram(program: [0xB5],
                                   a: 0xF0,
                                   f: 0x00,
                                   l: 0x0F,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .newValue(0xFF),
                                   newF: .unchanged,
                                   newL: .unchanged)
    }

    @Test mutating func orAFromHLIndirect() async throws {
        try await self.testProgram(program: [0xB6, 0xAA],
                                   a: 0x55,
                                   f: 0x00,
                                   h: 0x00,
                                   l: 0x01,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newA: .newValue(0xFF),
                                   newF: .unchanged,
                                   newH: .unchanged,
                                   newL: .unchanged)
    }

    @Test mutating func orAWithA() async throws {
        try await self.testProgram(program: [0xB7],
                                   a: 0x42,
                                   f: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .unchanged,
                                   newF: .unchanged)
    }

    @Test mutating func orAWithImmediate() async throws {
        try await self.testProgram(program: [0xF6, 0x0F],
                                   a: 0xF0,
                                   f: 0x00,
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newA: .newValue(0xFF),
                                   newF: .newValue(0x00))
    }

    @Test mutating func cpAWithB() async throws {
        try await self.testProgram(program: [0xB8],
                                   a: 0x42,
                                   f: 0x00,
                                   b: 0x41,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .unchanged,
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value | RegisterBit.carry.value),
                                   newB: .unchanged)
    }

    @Test mutating func cpAWithC() async throws {
        try await self.testProgram(program: [0xB9],
                                   a: 0x42,
                                   f: 0x00,
                                   c: 0x42,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .unchanged,
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.zero.value | RegisterBit.halfCarry.value | RegisterBit.carry.value),
                                   newC: .unchanged)
    }

    @Test mutating func cpAWithD() async throws {
        try await self.testProgram(program: [0xBA],
                                   a: 0x10,
                                   f: 0x00,
                                   d: 0x01,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .unchanged,
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.carry.value),
                                   newD: .unchanged)
    }

    @Test mutating func cpAWithE() async throws {
        try await self.testProgram(program: [0xBB],
                                   a: 0xE0,
                                   f: 0x00,
                                   e: 0xF0,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .unchanged,
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value),
                                   newE: .unchanged)
    }

    @Test mutating func cpAWithH() async throws {
        try await self.testProgram(program: [0xBC],
                                   a: 0x00,
                                   f: 0x00,
                                   h: 0xFF,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .unchanged,
                                   newF: .newValue(RegisterBit.subtraction.value),
                                   newH: .unchanged)
    }

    @Test mutating func cpAWithL() async throws {
        try await self.testProgram(program: [0xBD],
                                   a: 0x00,
                                   f: 0x00,
                                   l: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .unchanged,
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.zero.value | RegisterBit.halfCarry.value | RegisterBit.carry.value),
                                   newL: .unchanged)
    }

    @Test mutating func cpAFromHLIndirect() async throws {
        try await self.testProgram(program: [0xBE, 0xEF],
                                   a: 0xFE,
                                   f: 0x00,
                                   h: 0x00,
                                   l: 0x01,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newA: .unchanged,
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.carry.value),
                                   newH: .unchanged,
                                   newL: .unchanged)
    }

    @Test mutating func cpAWithA() async throws {
        try await self.testProgram(program: [0xBF],
                                   a: 0x42,
                                   f: 0x00,
                                   extraCycles: 1,
                                   newPC: 0x0001,
                                   newA: .unchanged,
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.zero.value | RegisterBit.halfCarry.value | RegisterBit.carry.value))
    }

    @Test mutating func cpAWithImmediate() async throws {
        try await self.testProgram(program: [0xFE, 0xFF],
                                   a: 0xFE,
                                   f: 0x00,
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newA: .unchanged,
                                   newF: .newValue(RegisterBit.subtraction.value))
    }

    @Test mutating func addImmediateToANoFlagsSet() async throws {
        try await self.testProgram(program: [0xC6, 0x21],
                                   a: 0x21,
                                   f: 0x00,
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newA: .newValue(0x42),
                                   newF: .unchanged)
    }

    @Test mutating func addImmediateToAZeroFlagButNoCarry() async throws {
        try await self.testProgram(program: [0xC6, 0x00],
                                   a: 0x00,
                                   f: 0x00,
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newA: .newValue(0x00),
                                   newF: .newValue(RegisterBit.zero.value))
    }

    @Test mutating func addImmediateToACarryFlagButNoZero() async throws {
        try await self.testProgram(program: [0xC6, 0xF0],
                                   a: 0xF0,
                                   f: 0x00,
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newA: .newValue(0xE0),
                                   newF: .newValue(RegisterBit.carry.value))
    }

    @Test mutating func addImmediateToABothCarryFlagsSet() async throws {
        try await self.testProgram(program: [0xC6, 0xFF],
                                   a: 0xFF,
                                   f: 0x00,
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newA: .newValue(0xFE),
                                   newF: .newValue(RegisterBit.halfCarry.value | RegisterBit.carry.value))
    }

    @Test mutating func addImmediateToAZeroAndBothCarryFlagsSet() async throws {
        try await self.testProgram(program: [0xC6, 0x01],
                                   a: 0xFF,
                                   f: 0x00,
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newA: .newValue(0x00),
                                   newF: .newValue(RegisterBit.zero.value | RegisterBit.halfCarry.value | RegisterBit.carry.value))
    }

    @Test mutating func adcImmediateToACarryFlagReset() async throws {
        try await self.testProgram(program: [0xCE, 0x20],
                                   a: 0x21,
                                   f: 0x10,
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newA: .newValue(0x42),
                                   newF: .newValue(0x00))
    }

    @Test mutating func adcImmediateToAOnlyHalfCarryFlagSet() async throws {
        try await self.testProgram(program: [0xCE, 0x01],
                                   a: 0x0E,
                                   f: 0x10,
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newA: .newValue(0x10),
                                   newF: .newValue(RegisterBit.halfCarry.value))
    }

    @Test mutating func adcImmediateToAOnlyCarryFlagSet() async throws {
        try await self.testProgram(program: [0xCE, 0xF0],
                                   a: 0xF0,
                                   f: 0x10,
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newA: .newValue(0xE1),
                                   newF: .newValue(RegisterBit.carry.value))
    }

    @Test mutating func adcImmediateToAZeroAndBothCarryFlagsSet() async throws {
        try await self.testProgram(program: [0xCE, 0x01],
                                   a: 0xFE,
                                   f: 0x10,
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newA: .newValue(0x00),
                                   newF: .newValue(RegisterBit.zero.value | RegisterBit.halfCarry.value | RegisterBit.carry.value))
    }

    @Test mutating func subImmediateFromABothCarriesSet() async throws {
        try await self.testProgram(program: [0xD6, 0x21],
                                   a: 0x63,
                                   f: 0x00,
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newA: .newValue(0x42),
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value | RegisterBit.carry.value))
    }

    @Test mutating func subImmediateFromAOnlyHalfCarry() async throws {
        try await self.testProgram(program: [0xD6, 0xF0],
                                   a: 0xE0,
                                   f: 0x00,
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newA: .newValue(0xF0),
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value))
    }

    @Test mutating func subImmediateFromAOnlyCarry() async throws {
        try await self.testProgram(program: [0xD6, 0x0F],
                                   a: 0x10,
                                   f: 0x00,
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newA: .newValue(0x01),
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.carry.value))
    }

    @Test mutating func subImmediateFromABothCarriesReset() async throws {
        try await self.testProgram(program: [0xD6, 0x01],
                                   a: 0x00,
                                   f: 0x00,
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newA: .newValue(0xFF),
                                   newF: .newValue(RegisterBit.subtraction.value))
    }

    @Test mutating func subImmediateFromAAllFlagsSet() async throws {
        try await self.testProgram(program: [0xD6, 0x42],
                                   a: 0x42,
                                   f: 0x00,
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newA: .newValue(0x00),
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value | RegisterBit.carry.value | RegisterBit.zero.value))
    }

    @Test mutating func sbcImmediateFromABothCarriesSet() async throws {
        try await self.testProgram(program: [0xDE, 0x20],
                                   a: 0x63,
                                   f: 0x10,
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newA: .newValue(0x42),
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value | RegisterBit.carry.value))
    }

    @Test mutating func sbcImmediateFromAOnlyHalfCarry() async throws {
        try await self.testProgram(program: [0xDE, 0xF0],
                                   a: 0xE1,
                                   f: 0x10,
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newA: .newValue(0xF0),
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value))
    }

    @Test mutating func sbcImmediateFromAOnlyCarry() async throws {
        try await self.testProgram(program: [0xDE, 0x00],
                                   a: 0x10,
                                   f: 0x10,
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newA: .newValue(0x0F),
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.carry.value))
    }

    @Test mutating func sbcImmediateFromABothCarriesReset() async throws {
        try await self.testProgram(program: [0xDE, 0x00],
                                   a: 0x00,
                                   f: 0x10,
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newA: .newValue(0xFF),
                                   newF: .newValue(RegisterBit.subtraction.value))
    }

    @Test mutating func sbcImmediateFromAAllFlagsSet() async throws {
        try await self.testProgram(program: [0xDE, 0x41],
                                   a: 0x42,
                                   f: 0x10,
                                   extraCycles: 2,
                                   newPC: 0x0002,
                                   newA: .newValue(0x00),
                                   newF: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value | RegisterBit.carry.value | RegisterBit.zero.value))
    }

    @Test mutating func retIfZeroReset() async throws {
        try await self.testProgram(program: [0xC0],
                                   stack: [0x12, 0x34],
                                   sp: 0xFFFD,
                                   f: 0x00,
                                   extraCycles: 5,
                                   newPC: 0x1234,
                                   newSP: .newValue(0xFFFF),
                                   newF: .unchanged)
    }

    @Test mutating func retIfZeroResetButZeroActuallySet() async throws {
        try await self.testProgram(program: [0xC0],
                                   stack: [0x12, 0x34],
                                   sp: 0xFFFD,
                                   f: 0x80,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newSP: .unchanged,
                                   newF: .unchanged)
    }

    @Test mutating func retIfZeroSet() async throws {
        try await self.testProgram(program: [0xC8],
                                   stack: [0x12, 0x34],
                                   sp: 0xFFFD,
                                   f: 0x80,
                                   extraCycles: 5,
                                   newPC: 0x1234,
                                   newSP: .newValue(0xFFFF),
                                   newF: .unchanged)
    }

    @Test mutating func retIfZeroSetButZeroActuallyReset() async throws {
        try await self.testProgram(program: [0xC8],
                                   stack: [0x12, 0x34],
                                   sp: 0xFFFD,
                                   f: 0x00,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newSP: .unchanged,
                                   newF: .unchanged)
    }

    @Test mutating func retIfCarryReset() async throws {
        try await self.testProgram(program: [0xD0],
                                   stack: [0x12, 0x34],
                                   sp: 0xFFFD,
                                   f: 0x00,
                                   extraCycles: 5,
                                   newPC: 0x1234,
                                   newSP: .newValue(0xFFFF),
                                   newF: .unchanged)
    }

    @Test mutating func retIfCarryResetButCarryActuallySet() async throws {
        try await self.testProgram(program: [0xD0],
                                   stack: [0x12, 0x34],
                                   sp: 0xFFFD,
                                   f: 0x10,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newSP: .unchanged,
                                   newF: .unchanged)
    }

    @Test mutating func retIfCarrySet() async throws {
        try await self.testProgram(program: [0xD8],
                                   stack: [0x12, 0x34],
                                   sp: 0xFFFD,
                                   f: 0x10,
                                   extraCycles: 5,
                                   newPC: 0x1234,
                                   newSP: .newValue(0xFFFF),
                                   newF: .unchanged)
    }

    @Test mutating func retIfCarrySetButCarryActuallyReset() async throws {
        try await self.testProgram(program: [0xD8],
                                   stack: [0x12, 0x34],
                                   sp: 0xFFFD,
                                   f: 0x00,
                                   extraCycles: 2,
                                   newPC: 0x0001,
                                   newSP: .unchanged,
                                   newF: .unchanged)
    }

    @Test mutating func ret() async throws {
        try await self.testProgram(program: [0xC9],
                                   stack: [0x12, 0x34],
                                   sp: 0xFFFD,
                                   extraCycles: 4,
                                   newPC: 0x1234,
                                   newSP: .newValue(0xFFFF),
                                   newF: .unchanged)
    }

    @Test mutating func retI() async throws {
        try await self.testProgram(program: [0xD9],
                                   stack: [0x12, 0x34],
                                   sp: 0xFFFD,
                                   interruptsEnabled: false,
                                   extraCycles: 4,
                                   newPC: 0x1234,
                                   newSP: .newValue(0xFFFF),
                                   newF: .unchanged,
                                   newInterruptsEnabled: .newValue(true))
    }

    mutating func testProgram(program: [UInt8],
                              stack: [UInt8] = [],
                              pc: UInt16 = 0x0000,
                              sp: UInt16 = 0xFFFF,
                              a: UInt8 = 0x00,
                              f: UInt8 = 0x00,
                              b: UInt8 = 0x00,
                              c: UInt8 = 0x00,
                              d: UInt8 = 0x00,
                              e: UInt8 = 0x00,
                              h: UInt8 = 0x00,
                              l: UInt8 = 0x00,
                              interruptsEnabled: Bool = false,
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
                              memoryChanges: [UInt16 : UInt8] = [:],
                              newInterruptsEnabled: FlagChange = .unchanged) async throws {
        self.cpu.loadProgram(program: program)
        self.cpu.loadStack(stack: stack)
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
        self.cpu.interruptsEnabled = interruptsEnabled

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
                 memoryChanges: memoryChanges,
                 newInterruptsEnabled: newInterruptsEnabled)
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
        memoryChanges: [UInt16 : UInt8] = [:],
        newInterruptsEnabled: FlagChange = .unchanged
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

        #expect(self.cpu.interruptsEnabled == newInterruptsEnabled.getValue(oldValue: oldCPU.interruptsEnabled))

        for address in self.cpu.memory.indices {
            if let newValue = memoryChanges[UInt16(address)] {
                #expect(self.cpu.memory[address] == newValue)
            } else {
                #expect(self.cpu.memory[address] == oldCPU.memory[address])
            }
        }
    }
}
