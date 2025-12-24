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

struct OpcodeTests {
    var cpu = CPU()

    @Test mutating func nop() async throws {
        let oldCPU = self.cpu

        self.cpu.setProgram(program: [0x00])
        try self.cpu.executeInstruction()

        checkCPU(oldCPU,
                 extraCycles: 1,
                 programCounter: 0x01,
                 a: .unchanged,
                 f: .unchanged,
                 b: .unchanged,
                 c: .unchanged,
                 d: .unchanged,
                 e: .unchanged,
                 h: .unchanged,
                 l: .unchanged)
    }

    func checkCPU(
        _ oldCPU: CPU,
        extraCycles: Int,
        programCounter: UInt16,
        a: RegisterChange,
        f: RegisterChange,
        b: RegisterChange,
        c: RegisterChange,
        d: RegisterChange,
        e: RegisterChange,
        h: RegisterChange,
        l: RegisterChange
    ) {
        #expect(self.cpu.cycles == oldCPU.cycles + extraCycles)
        #expect(self.cpu.programCounter == programCounter)
        #expect(self.cpu.a == a.getValue(oldValue: oldCPU.a))
        #expect(self.cpu.f == f.getValue(oldValue: oldCPU.f))
        #expect(self.cpu.b == b.getValue(oldValue: oldCPU.b))
        #expect(self.cpu.c == c.getValue(oldValue: oldCPU.c))
        #expect(self.cpu.d == d.getValue(oldValue: oldCPU.d))
        #expect(self.cpu.e == e.getValue(oldValue: oldCPU.e))
        #expect(self.cpu.h == h.getValue(oldValue: oldCPU.h))
        #expect(self.cpu.l == l.getValue(oldValue: oldCPU.l))
    }
}
