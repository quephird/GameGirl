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
    subscript(_ index: Opcode.Register8Target) -> UInt8 {
        mutating get {
            switch index {
            case .b: return self.b
            case .c: return self.c
            case .d: return self.d
            case .e: return self.e
            case .h: return self.h
            case .l: return self.l
            case .hlIndirect: return self.readMemory(address: self.hl)
            case .a: return self.a
            }
        }
        set {
            switch index {
            case .b: self.b = newValue
            case .c: self.c = newValue
            case .d: self.d = newValue
            case .e: self.e = newValue
            case .h: self.h = newValue
            case .l: self.l = newValue
            case .hlIndirect: self.writeMemory(address: self.hl, byte: newValue)
            case .a: self.a = newValue
            }
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

    mutating func execute(opcode: Opcode) throws {
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
            self.incrementRegister(target: Opcode.Register8Target(atBit3Of: opcode)!)
        case .decB, .decC, .decD, .decE, .decH, .decL, .decHLIndirect, .decA:
            self.decrementRegister(target: Opcode.Register8Target(atBit3Of: opcode)!)
        case .ldBFromImmediate, .ldCFromImmediate, .ldDFromImmediate, .ldEFromImmediate, .ldHFromImmediate, .ldLFromImmediate, .ldHLIndirectFromImmediate, .ldAFromImmediate:
            self.load(target: Opcode.Register8Target(atBit3Of: opcode)!)
        case .rlca:
            self.rlca()
        case .rrca:
            self.rrca()
        case .rla:
            self.rla()
        case .rra:
            self.rra()
        case .daa:
            self.daa()
        case .cpl:
            self.cpl()
        case .scf:
            self.scf()
        case .ccf:
            self.ccf()
        case .ldImmediateIndirectFromSP:
            self.loadMemoryFromSP()
        case .addBCToHL, .addDEToHL, .addHLToHL, .addSPToHL:
            self.addToHL(from: Opcode.Register16Target(opcode: opcode)!)
        case .ldAFromBCIndirect, .ldAFromDEIndirect, .ldAFromHLIndirectAndIncrement, .ldAFromHLIndirectAndDecrement:
            self.loadAFromMemory(target: Opcode.IndirectMemoryTarget(opcode: opcode)!)
        case .decBC, .decDE, .decHL, .decSP:
            self.decrementRegister(target: Opcode.Register16Target(opcode: opcode)!)
        case .ldBFromB, .ldBFromC, .ldBFromD, .ldBFromE, .ldBFromH, .ldBFromL, .ldBFromHLIndirect,
                .ldCFromB, .ldCFromC, .ldCFromD, .ldCFromE, .ldCFromH, .ldCFromL, .ldCFromHLIndirect,
                .ldDFromB, .ldDFromC, .ldDFromD, .ldDFromE, .ldDFromH, .ldDFromL, .ldDFromHLIndirect,
                .ldEFromB, .ldEFromC, .ldEFromD, .ldEFromE, .ldEFromH, .ldEFromL, .ldEFromHLIndirect,
                .ldHFromB, .ldHFromC, .ldHFromD, .ldHFromE, .ldHFromH, .ldHFromL, .ldHFromHLIndirect,
                .ldLFromB, .ldLFromC, .ldLFromD, .ldLFromE, .ldLFromH, .ldLFromL, .ldLFromHLIndirect,
                .ldHLIndirectFromB, .ldHLIndirectFromC, .ldHLIndirectFromD,
                .ldHLIndirectFromE, .ldHLIndirectFromH, .ldHLIndirectFromL:
            try self.load(from: Opcode.Register8Target(atBit0Of: opcode)!,
                          to: Opcode.Register8Target(atBit3Of: opcode)!)
        case .addBToA, .addCToA, .addDToA, .addEToA, .addHToA, .addLToA, .addHLIndirectToA, .addAToA:
            self.addToA(from: Opcode.Register8Target(atBit0Of: opcode)!)
        case .adcBToA, .adcCToA, .adcDToA, .adcEToA, .adcHToA, .adcLToA, .adcHLIndirectToA, .adcAToA:
            self.adcToA(from: Opcode.Register8Target(atBit0Of: opcode)!)
        }
    }

    public mutating func executeInstruction() throws {
        let oldCycles = self.cycles
        let opcode = try self.fetchOpcode()
        try self.execute(opcode: opcode)
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

    mutating func load(target: Opcode.Register8Target) {
        let byte = self.readProgramByte()

        switch target {
        case .b:
            self.b = byte
        case .c:
            self.c = byte
        case .d:
            self.d = byte
        case .e:
            self.e = byte
        case .h:
            self.h = byte
        case .l:
            self.l = byte
        case .hlIndirect:
            self.writeMemory(address: self.hl, byte: byte)
        case .a:
            self.a = byte
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

    mutating func rlca() {
        self.f[.carry] = (self.a & 0x80) == 0x80
        self.a <<= 1
        self.f[.halfCarry] = false
        self.f[.subtraction] = false
        self.f[.zero] = self.a == 0
    }

    mutating func rrca() {
        self.f[.carry] = (self.a & 0x01) == 0x01
        self.a >>= 1
        self.f[.halfCarry] = false
        self.f[.subtraction] = false
        self.f[.zero] = self.a == 0
    }

    mutating func rla() {
        let oldCarry = self.f[.carry]
        self.f[.carry] = (self.a & 0x80) == 0x80
        self.a = (self.a << 1) | oldCarry.intValue
        self.f[.halfCarry] = false
        self.f[.subtraction] = false
        self.f[.zero] = self.a == 0
    }

    mutating func rra() {
        let oldCarry = self.f[.carry]
        self.f[.carry] = (self.a & 0x01) == 0x01
        self.a = (self.a >> 1) | (oldCarry.intValue << 7)
        self.f[.halfCarry] = false
        self.f[.subtraction] = false
        self.f[.zero] = self.a == 0
    }

    mutating func daa() {
        // NOTA BENE: Implementation adapted from this excellent blog post:
        //
        //    https://blog.ollien.com/posts/gb-daa/
        var offset: UInt8 = 0x00
        var newCarry = false

        if (!self.f[.subtraction] && (self.a & 0x0F) > 0x09) || self.f[.halfCarry] {
            offset += 0x06
        }

        if (!self.f[.subtraction] && self.a > 0x99) || self.f[.carry] {
            offset += 0x60
            newCarry = true
        }

        if self.f[.subtraction] {
            self.a &-= offset
        } else {
            self.a &+= offset
        }

        self.f[.halfCarry] = false
        self.f[.carry] = newCarry
        self.f[.zero] = self.a == 0
    }

    mutating func cpl() {
        self.a = ~self.a
        self.f[.halfCarry] = true
        self.f[.subtraction] = true
    }

    mutating func scf() {
        self.f[.carry] = true
    }

    mutating func ccf() {
        self.f[.carry] = !self.f[.carry]
    }

    mutating func incrementRegister(target: Opcode.Register8Target) {
        let oldRegister = self[target]

        let newRegister: Register8
        (newRegister, self.f[.carry]) = oldRegister.addingReportingOverflow(1)
        (_, self.f[.halfCarry]) = (oldRegister << 4).addingReportingOverflow(1 << 4)
        self.f[.zero] = newRegister == 0
        self.f[.subtraction] = false
        self[target] = newRegister

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
        let oldRegister = self[target]

        let newRegister = oldRegister &- 1
        // NOTA BENE: Per the GameBoy technical manual, we need to set the half carry
        // flag if there was _not_ a borrow.
        self.f[.halfCarry] = (((oldRegister & 0x0F) &- 0x01) & 0x10) != 0x10
        self.f[.zero] = newRegister == 0
        self.f[.subtraction] = true
        self[target] = newRegister
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

    mutating func load(from: Opcode.Register8Target, to: Opcode.Register8Target) throws {
        self[to] = self[from]
    }

    mutating func addToA(from: Opcode.Register8Target) {
        let oldA = self.a
        // NOTA BENE: We cache the value here once to avoid incurring extra cycles
        // for when we read from actual memory
        let fromValue = self[from]

        let newA: Register8
        (newA, self.f[.carry]) = self.a.addingReportingOverflow(fromValue)
        (_, self.f[.halfCarry]) = (oldA << 4).addingReportingOverflow(fromValue << 4)
        self.f[.zero] = newA == 0
        self.f[.subtraction] = false
        self.a = newA
    }

    // TODO: THink about a helper overload for addingReportingOverflow() that takes two args

    mutating func adcToA(from: Opcode.Register8Target) {
        let oldA = self.a
        let oldCarry = self.f[.carry]
        // NOTA BENE: We cache the value here once to avoid incurring extra cycles
        // for when we read from actual memory
        let fromValue = self[from]

        let newA: Register8
        (newA, self.f[.carry]) = self.a.addingReportingOverflow(fromValue, carryValue: oldCarry.intValue)
        (_, self.f[.halfCarry]) = (oldA << 4).addingReportingOverflow(fromValue << 4, carryValue: oldCarry.intValue << 4)
        self.f[.zero] = newA == 0
        self.f[.subtraction] = false
        self.a = newA
    }
}
