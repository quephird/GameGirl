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
                 programCounter: 0x0001)
    }

    @Test mutating func ldBc() async throws {
        self.cpu.setProgram(program: [0x01, 0x34, 0x12])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 3,
                 programCounter: 0x0003,
                 b: .newValue(0x12),
                 c: .newValue(0x34))
    }

    @Test mutating func ldDe() async throws {
        self.cpu.setProgram(program: [0x11, 0x34, 0x12])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 3,
                 programCounter: 0x0003,
                 d: .newValue(0x12),
                 e: .newValue(0x34))
    }

    @Test mutating func ldHl() async throws {
        self.cpu.setProgram(program: [0x21, 0x34, 0x12])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 3,
                 programCounter: 0x0003,
                 h: .newValue(0x12),
                 l: .newValue(0x34))
    }

    @Test mutating func ldSp() async throws {
        self.cpu.setProgram(program: [0x31, 0x34, 0x12])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 3,
                 programCounter: 0x0003,
                 stackPointer: .newValue(0x1234))
    }

    @Test mutating func ldBcMem() async throws {
        self.cpu.bc = 0x0003
        self.cpu.a = 0x42
        self.cpu.setProgram(program: [0x02, 0x00, 0x00, 0x00])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 2,
                 programCounter: 0x0001,
                 memoryChanges: [0x0003 : 0x42])
    }

    @Test mutating func ldDeMem() async throws {
        self.cpu.de = 0x0003
        self.cpu.a = 0x42
        self.cpu.setProgram(program: [0x12, 0x00, 0x00, 0x00])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 2,
                 programCounter: 0x0001,
                 memoryChanges: [0x0003 : 0x42])
    }


    @Test mutating func ldHlMemI() async throws {
        self.cpu.hl = 0x0003
        self.cpu.a = 0x42
        self.cpu.setProgram(program: [0x22, 0x00, 0x00, 0x00])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 2,
                 programCounter: 0x0001,
                 h: .unchanged,
                 l: .newValue(0x04),
                 memoryChanges: [0x0003 : 0x42])
    }

    @Test mutating func ldHlMemD() async throws {
        self.cpu.hl = 0x0003
        self.cpu.a = 0x42
        self.cpu.setProgram(program: [0x32, 0x00, 0x00, 0x00])
        let oldCPU = self.cpu

        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 2,
                 programCounter: 0x0001,
                 h: .unchanged,
                 l: .newValue(0x02),
                 memoryChanges: [0x0003 : 0x42])
    }

    func checkCPU(
        _ oldCPU: CPU,
        extraCycles: Int,
        programCounter: UInt16,
        stackPointer: RegisterPairChange = .unchanged,
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
        #expect(self.cpu.programCounter == programCounter)
        #expect(self.cpu.stackPointer == stackPointer.getValue(oldValue: oldCPU.stackPointer))
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
