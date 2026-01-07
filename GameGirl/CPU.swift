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

    public var sp: Register16 = 0x0000
    public var pc: Register16 = 0x0000

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
            self.a = Register8(newValue.high)
            self.f = Register8(newValue.low)
        }
    }

    public var bc: Register16 {
        get {
            UInt16(self.b) << 8 | UInt16(self.c)
        }
        set {
            self.b = Register8(newValue.high)
            self.c = Register8(newValue.low)
        }
    }

    public var de: Register16 {
        get {
            UInt16(self.d) << 8 | UInt16(self.e)
        }
        set {
            self.d = Register8(newValue.high)
            self.e = Register8(newValue.low)
        }
    }

    public var hl: Register16 {
        get {
            UInt16(self.h) << 8 | UInt16(self.l)
        }
        set {
            self.h = Register8(newValue.high)
            self.l = Register8(newValue.low)
        }
    }
}

extension CPU {
    mutating func readProgramByte() -> UInt8 {
        // NOTA BENE: Perhaps later we can do some bounds checking
        let byte = self.readMemory(address: self.pc)
        self.pc += 1
        return byte
    }

    mutating func readProgramWord() -> UInt16 {
        let lowByte = self.readProgramByte()
        let highByte = self.readProgramByte()
        return UInt16(highByte) << 8 | UInt16(lowByte)
    }

    // ACHTUNG!!!!! This is a temporary measure for now until
    // we have a more robust understanding of memory and the bus.
    mutating func readMemory(address: UInt16) -> UInt8 {
        self.cycles += 1
        return self.program[Int(address)]
    }

    mutating func writeMemory(address: UInt16, byte: UInt8) {
        self.program[Int(address)] = byte
        self.cycles += 1
    }

    mutating func fetchOpcode() throws -> Opcode {
        let byte = readProgramByte()

        if let opcode = Opcode(rawValue: byte) {
            return opcode
        } else {
            throw CpuError.unimplementedOpcode(byte)
        }
    }

    mutating func execute(opcode: Opcode) {
        switch opcode {
        case .nop:
            self.nop()
        case .ldBCFromImmediate, .ldDEFromImmediate, .ldHLFromImmediate, .ldSPFromImmediate:
            self.load(target: Opcode.Register16Target(opcode: opcode)!)
        case .ldBCIndirectFromA, .ldDEIndirectFromA, .ldHLIndirectFromAAndIncrement, .ldHLIndirectFromAAndDecrement:
            self.loadMemory(target: Opcode.IndirectMemoryTarget(opcode: opcode)!)
        case .incBC, .incDE, .incHL, .incSP:
            self.incrementRegister(target: Opcode.Register16Target(opcode: opcode)!)
        case .incB, .incC, .incD, .incE, .incH, .incL, .incHLIndirect, .incA:
            self.incrementRegister(target: Opcode.Register8Target(opcode: opcode)!)
        case .decB, .decC, .decD, .decE, .decH, .decL, .decHLIndirect, .decA:
            self.decrementRegister(target: Opcode.Register8Target(opcode: opcode)!)
        case .ldImmediateIndirectFromSP:
            self.loadMemoryFromSP()
        case .addBCToHL, .addDEToHL, .addHLToHL, .addSPToHL:
            self.addToHL(from: Opcode.Register16Target(opcode: opcode)!)
        case .ldAFromBCIndirect, .ldAFromDEIndirect, .ldAFromHLIndirectAndIncrement, .ldAFromHLIndirectAndDecrement:
            self.loadAFromMemory(target: Opcode.IndirectMemoryTarget(opcode: opcode)!)
        case .decBC, .decDE, .decHL, .decSP:
            self.decrementRegister(target: Opcode.Register16Target(opcode: opcode)!)
        }
    }

    public mutating func executeInstruction() throws {
        let oldCycles = self.cycles
        let opcode = try self.fetchOpcode()
        self.execute(opcode: opcode)
        assert(self.cycles - oldCycles == opcode.cycles, "The cycle count for this instruction is off: \(opcode)")
    }

    mutating func nop() {
        // Nothing to see here!!!
    }

    mutating func load(target: Opcode.Register16Target) {
        let word = self.readProgramWord()

        switch target {
        case .bc:
            self.bc = word
        case .de:
            self.de = word
        case .hl:
            self.hl = word
        case .sp:
            self.sp = word
        }
    }

    mutating func loadMemory(target: Opcode.IndirectMemoryTarget) {
        switch target {
        case .bc:
            self.writeMemory(address: self.bc, byte: self.a)
        case .de:
            self.writeMemory(address: self.de, byte: self.a)
        case .hli:
            self.writeMemory(address: self.hl, byte: self.a)
            self.hl += 1
        case .hld:
            self.writeMemory(address: self.hl, byte: self.a)
            self.hl -= 1
        }
    }

    mutating func loadAFromMemory(target: Opcode.IndirectMemoryTarget) {
        switch target {
        case .bc:
            self.a = readMemory(address: self.bc)
        case .de:
            self.a = readMemory(address: self.de)
        case .hli:
            self.a = readMemory(address: self.hl)
            self.hl += 1
        case .hld:
            self.a = readMemory(address: self.hl)
            self.hl -= 1
        }
    }

    mutating func loadMemoryFromSP() {
        let address = self.readProgramWord()
        self.writeMemory(address: address, byte: self.sp.low)
        self.writeMemory(address: address+1, byte: self.sp.high)
    }

    mutating func incrementRegister(target: Opcode.Register16Target) {
        switch target {
        case .bc:
            self.bc &+= 1
        case .de:
            self.de &+= 1
        case .hl:
            self.hl &+= 1
        case .sp:
            self.sp &+= 1
        }

        // NOTA BENE: This set of instructions incurs an extra cycle
        self.cycles += 1
    }

    mutating func incrementRegister(target: Opcode.Register8Target) {
        switch target {
        case .b:
            self.incrementRegister8Impl(register: &self.b, flags: &self.f)
        case .c:
            self.incrementRegister8Impl(register: &self.c, flags: &self.f)
        case .d:
            self.incrementRegister8Impl(register: &self.d, flags: &self.f)
        case .e:
            self.incrementRegister8Impl(register: &self.e, flags: &self.f)
        case .h:
            self.incrementRegister8Impl(register: &self.h, flags: &self.f)
        case .l:
            self.incrementRegister8Impl(register: &self.l, flags: &self.f)
        case .hlIndirect:
            var newValue = self.readMemory(address: self.hl)
            self.incrementRegister8Impl(register: &newValue, flags: &self.f)
            self.writeMemory(address: self.hl, byte: newValue)
        case .a:
            self.incrementRegister8Impl(register: &self.a, flags: &self.f)
        }
    }

    func incrementRegister8Impl(register: inout Register8, flags: inout Register8) {
        let oldRegister = register

        (register, flags[.carry]) = register.addingReportingOverflow(1)
        (_, flags[.halfCarry]) = (oldRegister << 4).addingReportingOverflow(1 << 4)
        flags[.zero] = register == 0
        flags[.subtraction] = false
    }

    mutating func decrementRegister(target: Opcode.Register16Target) {
        switch target {
        case .bc:
            self.bc &-= 1
        case .de:
            self.de &-= 1
        case .hl:
            self.hl &-= 1
        case .sp:
            self.sp &-= 1
        }

        // NOTA BENE: This set of instructions incurs an extra cycle
        self.cycles += 1
    }

    mutating func decrementRegister(target: Opcode.Register8Target) {
        switch target {
        case .b:
            self.decrementRegister8Impl(register: &self.b, flags: &self.f)
        case .c:
            self.decrementRegister8Impl(register: &self.c, flags: &self.f)
        case .d:
            self.decrementRegister8Impl(register: &self.d, flags: &self.f)
        case .e:
            self.decrementRegister8Impl(register: &self.e, flags: &self.f)
        case .h:
            self.decrementRegister8Impl(register: &self.h, flags: &self.f)
        case .l:
            self.decrementRegister8Impl(register: &self.l, flags: &self.f)
        case .hlIndirect:
            var newValue = self.readMemory(address: self.hl)
            self.decrementRegister8Impl(register: &newValue, flags: &self.f)
            self.writeMemory(address: self.hl, byte: newValue)
        case .a:
            self.decrementRegister8Impl(register: &self.a, flags: &self.f)
        }
    }

    func decrementRegister8Impl(register: inout Register8, flags: inout Register8) {
        let oldRegister = register

        register &-= 1
        // NOTA BENE: Per the GameBoy technical manual, we need to set the half carry
        // flag if there was _not_ a borrow.
        flags[.halfCarry] = (((oldRegister & 0x0F) &- 0x01) & 0x10) != 0x10
        flags[.zero] = register == 0
        flags[.subtraction] = true
    }

    mutating func addToHL(from: Opcode.Register16Target) {
        let fromRegister = switch from {
        case .bc:
            self.bc
        case .de:
            self.de
        case .hl:
            self.hl
        case .sp:
            self.sp
        }

        (_, self.f[.halfCarry]) = ((self.hl & 0x0FFF) << 4).addingReportingOverflow((fromRegister & 0x0FFF) << 4)
        (self.hl, self.f[.carry]) = self.hl.addingReportingOverflow(fromRegister)
        self.f[.subtraction] = false

        // NOTA BENE: This set of instructions incurs an extra cycle
        self.cycles += 1
    }
}
