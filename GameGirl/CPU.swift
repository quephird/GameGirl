//
//  CPU.swift
//  GameGirl
//
//  Created by Danielle Kefford on 6/10/25.
//

public struct CPU {
    public var a: Register8 = 0x00
    public var f: Register8 = 0x00
    public var b: Register8 = 0x00
    public var c: Register8 = 0x00
    public var d: Register8 = 0x00
    public var e: Register8 = 0x00
    public var h: Register8 = 0x00
    public var l: Register8 = 0x00

    public var stackPointer: Register16 = 0x0000
    public var programCounter: Register16 = 0x0000

    public var cycles: Int = 0

    public var program: [UInt8] = []
}

enum CpuError: Error {
    case unimplementedOpcode(UInt8)
}

extension CPU {
    public var af: Register16 {
        get {
            UInt16(self.a) << 8 | UInt16(self.f)
        }
        set {
            self.a = Register8(newValue >> 8)
            self.f = Register8(newValue & 0xFF)
        }
    }

    public var bc: Register16 {
        get {
            UInt16(self.b) << 8 | UInt16(self.c)
        }
        set {
            self.b = Register8(newValue >> 8)
            self.c = Register8(newValue & 0xFF)
        }
    }

    public var de: Register16 {
        get {
            UInt16(self.d) << 8 | UInt16(self.e)
        }
        set {
            self.d = Register8(newValue >> 8)
            self.e = Register8(newValue & 0xFF)
        }
    }

    public var hl: Register16 {
        get {
            UInt16(self.h) << 8 | UInt16(self.l)
        }
        set {
            self.h = Register8(newValue >> 8)
            self.l = Register8(newValue & 0xFF)
        }
    }
}

extension CPU {
    mutating func readProgramByte() -> UInt8 {
        // NOTA BENE: Perhaps later we can do some bounds checking
        let byte = self.program[Int(self.programCounter)]
        self.programCounter += 1
        return byte
    }

    mutating func readProgramWord() -> UInt16 {
        let lowByte = self.readProgramByte()
        let highByte = self.readProgramByte()
        return UInt16(highByte) << 8 | UInt16(lowByte)
    }

    mutating func fetchOpcode() throws -> Opcode {
        let byte = readProgramByte()

        if let opcode = Opcode(rawValue: byte) {
            return opcode
        } else {
            throw CpuError.unimplementedOpcode(byte)
        }
    }

    enum RegisterPairTarget: UInt8 {
        case bc = 0b00
        case de = 0b01
        case hl = 0b10
        case sp = 0b11

        init?(opcode: Opcode) {
            let rawValue = (opcode.rawValue & 0b0011_0000) >> 4
            self.init(rawValue: rawValue)
        }
    }

    mutating func execute(opcode: Opcode) {
        switch opcode {
        case .nop:
            self.nop()
        case .ldBc, .ldDe, .ldHl, .ldSp:
            self.load(target: RegisterPairTarget(opcode: opcode)!)
        }
    }

    public mutating func executeInstruction() throws {
        let opcode = try self.fetchOpcode()
        self.execute(opcode: opcode)
    }

    mutating func nop() {
        self.cycles += 1
    }

    mutating func load(target: RegisterPairTarget) {
        let word = self.readProgramWord()

        switch target {
        case .bc:
            self.bc = word
        case .de:
            self.de = word
        case .hl:
            self.hl = word
        case .sp:
            self.stackPointer = word
        }

        self.cycles += 3
    }
}
