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
        self.cpu.setProgram(program: [0x00])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 1,
                 pc: 0x0001)
    }

    @Test mutating func ldBCFromImmediate() async throws {
        self.cpu.setProgram(program: [0x01, 0x34, 0x12])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 3,
                 pc: 0x0003,
                 b: .newValue(0x12),
                 c: .newValue(0x34))
    }

    @Test mutating func ldDEFromImmediate() async throws {
        self.cpu.setProgram(program: [0x11, 0x34, 0x12])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 3,
                 pc: 0x0003,
                 d: .newValue(0x12),
                 e: .newValue(0x34))
    }

    @Test mutating func ldHLFromImmediate() async throws {
        self.cpu.setProgram(program: [0x21, 0x34, 0x12])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 3,
                 pc: 0x0003,
                 h: .newValue(0x12),
                 l: .newValue(0x34))
    }

    @Test mutating func ldSPFromImmediate() async throws {
        self.cpu.setProgram(program: [0x31, 0x34, 0x12])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 3,
                 pc: 0x0003,
                 sp: .newValue(0x1234))
    }

    @Test mutating func ldBFromImmediate() async throws {
        self.cpu.setProgram(program: [0x06, 0x42])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 2,
                 pc: 0x0002,
                 b: .newValue(0x42))
    }

    @Test mutating func ldCFromImmediate() async throws {
        self.cpu.setProgram(program: [0x0E, 0x42])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 2,
                 pc: 0x0002,
                 c: .newValue(0x42))
    }

    @Test mutating func ldDFromImmediate() async throws {
        self.cpu.setProgram(program: [0x16, 0x42])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 2,
                 pc: 0x0002,
                 d: .newValue(0x42))
    }

    @Test mutating func ldEFromImmediate() async throws {
        self.cpu.setProgram(program: [0x1E, 0x42])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 2,
                 pc: 0x0002,
                 e: .newValue(0x42))
    }

    @Test mutating func ldHFromImmediate() async throws {
        self.cpu.setProgram(program: [0x26, 0x42])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 2,
                 pc: 0x0002,
                 h: .newValue(0x42))
    }

    @Test mutating func ldLFromImmediate() async throws {
        self.cpu.setProgram(program: [0x2E, 0x42])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 2,
                 pc: 0x0002,
                 l: .newValue(0x42))
    }

    @Test mutating func ldHLIndirectFromImmediate() async throws {
        self.cpu.setProgram(program: [0x36, 0x42, 0x00])
        self.cpu.hl = 0x0002
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 3,
                 pc: 0x0002,
                 memoryChanges: [0x0002 : 0x42])
    }

    @Test mutating func ldAFromImmediate() async throws {
        self.cpu.setProgram(program: [0x3E, 0x42])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 2,
                 pc: 0x0002,
                 a: .newValue(0x42))
    }


    @Test mutating func ldBCIndirectFromA() async throws {
        self.cpu.bc = 0x0003
        self.cpu.a = 0x42
        self.cpu.setProgram(program: [0x02, 0x00, 0x00, 0x00])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 2,
                 pc: 0x0001,
                 memoryChanges: [0x0003 : 0x42])
    }

    @Test mutating func ldDEIndirectFromA() async throws {
        self.cpu.de = 0x0003
        self.cpu.a = 0x42
        self.cpu.setProgram(program: [0x12, 0x00, 0x00, 0x00])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 2,
                 pc: 0x0001,
                 memoryChanges: [0x0003 : 0x42])
    }


    @Test mutating func ldHLIndirectFromAAndIncrement() async throws {
        self.cpu.hl = 0x0003
        self.cpu.a = 0x42
        self.cpu.setProgram(program: [0x22, 0x00, 0x00, 0x00])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 2,
                 pc: 0x0001,
                 h: .unchanged,
                 l: .newValue(0x04),
                 memoryChanges: [0x0003 : 0x42])
    }

    @Test mutating func ldHLIndirectFromAAndDecrement() async throws {
        self.cpu.hl = 0x0003
        self.cpu.a = 0x42
        self.cpu.setProgram(program: [0x32, 0x00, 0x00, 0x00])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 2,
                 pc: 0x0001,
                 h: .unchanged,
                 l: .newValue(0x02),
                 memoryChanges: [0x0003 : 0x42])
    }

    @Test mutating func ldAFromBCIndirect() async throws {
        self.cpu.bc = 0x0003
        self.cpu.setProgram(program: [0x0A, 0x00, 0x00, 0x42])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 2,
                 pc: 0x0001,
                 a: .newValue(0x42))
    }

    @Test mutating func ldAFromDEIndirect() async throws {
        self.cpu.de = 0x0003
        self.cpu.setProgram(program: [0x1A, 0x00, 0x00, 0x42])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 2,
                 pc: 0x0001,
                 a: .newValue(0x42))
    }

    @Test mutating func ldAFromHLIndirectAndIncrement() async throws {
        self.cpu.hl = 0x0003
        self.cpu.setProgram(program: [0x2A, 0x00, 0x00, 0x42])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 2,
                 pc: 0x0001,
                 a: .newValue(0x42),
                 h: .unchanged,
                 l: .newValue(0x04))
    }

    @Test mutating func ldAFromHLIndirectAndDecrement() async throws {
        self.cpu.hl = 0x0003
        self.cpu.setProgram(program: [0x3A, 0x00, 0x00, 0x42])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 2,
                 pc: 0x0001,
                 a: .newValue(0x42),
                 h: .unchanged,
                 l: .newValue(0x02))
    }

    @Test mutating func ldImmediateIndirectFromSP() async throws {
        self.cpu.sp = 0x1234
        self.cpu.setProgram(program: [0x08, 0x03, 0x00, 0x00, 0x00])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 5,
                 pc: 0x0003,
                 memoryChanges: [
                    0x0003 : 0x34,
                    0x0004 : 0x12
                 ])
    }

    @Test mutating func incBC() async throws {
        self.cpu.bc = 0x1234
        self.cpu.setProgram(program: [0x03])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 2,
                 pc: 0x0001,
                 b: .unchanged,
                 c: .newValue(0x35))
    }

    @Test mutating func incDE() async throws {
        self.cpu.de = 0x1234
        self.cpu.setProgram(program: [0x13])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 2,
                 pc: 0x0001,
                 d: .unchanged,
                 e: .newValue(0x35))
    }

    @Test mutating func incHL() async throws {
        self.cpu.hl = 0xFFFF
        self.cpu.setProgram(program: [0x23])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 2,
                 pc: 0x0001,
                 h: .newValue(0x00),
                 l: .newValue(0x00))
    }

    @Test mutating func incSP() async throws {
        self.cpu.sp = 0x1234
        self.cpu.setProgram(program: [0x33])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 2,
                 pc: 0x0001,
                 sp: .newValue(0x1235))
    }

    @Test mutating func incB() async throws {
        self.cpu.b = 0x0F
        self.cpu.setProgram(program: [0x04])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 1,
                 pc: 0x0001,
                 f: .newValue(RegisterBit.halfCarry.value),
                 b: .newValue(0x10))
    }

    @Test mutating func incC() async throws {
        self.cpu.c = 0xFF
        self.cpu.setProgram(program: [0x0C])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 1,
                 pc: 0x0001,
                 f: .newValue(RegisterBit.zero.value | RegisterBit.carry.value | RegisterBit.halfCarry.value),
                 c: .newValue(0x00))
    }

    @Test mutating func incD() async throws {
        self.cpu.d = 0x41
        self.cpu.setProgram(program: [0x14])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 1,
                 pc: 0x0001,
                 f: .unchanged,
                 d: .newValue(0x42))
    }

    @Test mutating func incE() async throws {
        self.cpu.e = 0x41
        self.cpu.setProgram(program: [0x1C])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 1,
                 pc: 0x0001,
                 f: .unchanged,
                 e: .newValue(0x42))
    }

    @Test mutating func incH() async throws {
        self.cpu.h = 0x41
        self.cpu.setProgram(program: [0x24])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 1,
                 pc: 0x0001,
                 f: .unchanged,
                 h: .newValue(0x42))
    }

    @Test mutating func incL() async throws {
        self.cpu.l = 0x41
        self.cpu.setProgram(program: [0x2C])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 1,
                 pc: 0x0001,
                 f: .unchanged,
                 l: .newValue(0x42))
    }

    @Test mutating func incHLIndirect() async throws {
        self.cpu.hl = 0x0001
        self.cpu.setProgram(program: [0x34, 0xFF])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 3,
                 pc: 0x0001,
                 f: .newValue(RegisterBit.zero.value | RegisterBit.carry.value | RegisterBit.halfCarry.value),
                 memoryChanges: [0x0001: 0x00])
    }

    @Test mutating func incA() async throws {
        self.cpu.a = 0x41
        self.cpu.setProgram(program: [0x3C])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 1,
                 pc: 0x0001,
                 a: .newValue(0x42),
                 f: .unchanged)
    }

    @Test mutating func decBC() async throws {
        self.cpu.bc = 0x1234
        self.cpu.setProgram(program: [0x0B])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 2,
                 pc: 0x0001,
                 b: .unchanged,
                 c: .newValue(0x33))
    }

    @Test mutating func decDE() async throws {
        self.cpu.de = 0x1234
        self.cpu.setProgram(program: [0x1B])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 2,
                 pc: 0x0001,
                 d: .unchanged,
                 e: .newValue(0x33))
    }

    @Test mutating func decHL() async throws {
        self.cpu.hl = 0x0000
        self.cpu.setProgram(program: [0x2B])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 2,
                 pc: 0x0001,
                 h: .newValue(0xFF),
                 l: .newValue(0xFF))
    }

    @Test mutating func decSP() async throws {
        self.cpu.sp = 0x1234
        self.cpu.setProgram(program: [0x3B])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 2,
                 pc: 0x0001,
                 sp: .newValue(0x1233))
    }

    @Test mutating func decB() async throws {
        self.cpu.b = 0x0F
        self.cpu.setProgram(program: [0x05])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 1,
                 pc: 0x0001,
                 f: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value),
                 b: .newValue(0x0E))
    }

    @Test mutating func decC() async throws {
        self.cpu.c = 0x10
        self.cpu.setProgram(program: [0x0D])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 1,
                 pc: 0x0001,
                 f: .newValue(RegisterBit.subtraction.value),
                 c: .newValue(0x0F))
    }

    @Test mutating func decD() async throws {
        self.cpu.d = 0x01
        self.cpu.setProgram(program: [0x15])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 1,
                 pc: 0x0001,
                 f: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value | RegisterBit.zero.value),
                 d: .newValue(0x00))
    }

    @Test mutating func decE() async throws {
        self.cpu.e = 0x43
        self.cpu.setProgram(program: [0x1D])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 1,
                 pc: 0x0001,
                 f: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value),
                 e: .newValue(0x42))
    }

    @Test mutating func decH() async throws {
        self.cpu.h = 0x43
        self.cpu.setProgram(program: [0x25])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 1,
                 pc: 0x0001,
                 f: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value),
                 h: .newValue(0x42))
    }

    @Test mutating func decL() async throws {
        self.cpu.l = 0x43
        self.cpu.setProgram(program: [0x2D])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 1,
                 pc: 0x0001,
                 f: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value),
                 l: .newValue(0x42))
    }

    @Test mutating func decHLIndirect() async throws {
        self.cpu.hl = 0x0001
        self.cpu.setProgram(program: [0x35, 0x43])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 3,
                 pc: 0x0001,
                 f: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value),
                 memoryChanges: [0x0001: 0x42])
    }

    @Test mutating func decA() async throws {
        self.cpu.a = 0x43
        self.cpu.setProgram(program: [0x3D])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 1,
                 pc: 0x0001,
                 a: .newValue(0x42),
                 f: .newValue(RegisterBit.subtraction.value | RegisterBit.halfCarry.value))
    }

    @Test mutating func addBCToHL() async throws {
        self.cpu.bc = 0x0102
        self.cpu.hl = 0x0304
        self.cpu.setProgram(program: [0x09])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 2,
                 pc: 0x0001,
                 f: .unchanged,
                 h: .newValue(0x04),
                 l: .newValue(0x06))
    }

    @Test mutating func addDEToHL() async throws {
        self.cpu.de = 0x0F01
        self.cpu.hl = 0x0102
        self.cpu.setProgram(program: [0x19])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 2,
                 pc: 0x0001,
                 f: .newValue(RegisterBit.halfCarry.value),
                 h: .newValue(0x10),
                 l: .newValue(0x03))
    }

    @Test mutating func addHLToHL() async throws {
        self.cpu.hl = 0x7FFF
        self.cpu.setProgram(program: [0x29])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 2,
                 pc: 0x0001,
                 f: .newValue(RegisterBit.halfCarry.value),
                 h: .newValue(0xFF),
                 l: .newValue(0xFE))
    }

    @Test mutating func addSPToHL() async throws {
        self.cpu.sp = 0x0001
        self.cpu.hl = 0xFFFF
        self.cpu.setProgram(program: [0x39])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 2,
                 pc: 0x0001,
                 f: .newValue(RegisterBit.halfCarry.value | RegisterBit.carry.value),
                 h: .newValue(0x00),
                 l: .newValue(0x00))
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
