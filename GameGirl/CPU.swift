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

    public var sp: Register16 = 0xFFFF
    public var pc: Register16 = 0x0000

    public var cycles: Int = 0

    public var memory: [UInt8] = Array(repeating: 0x00, count: 64*1024)

    public var interruptsEnabled: Bool = false
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

    subscript(_ index: Opcode.Register16Target) -> UInt16 {
        mutating get {
            switch index {
            case .bc: return self.bc
            case .de: return self.de
            case .hl: return self.hl
            case .sp: return self.sp
            }
        }
        set {
            switch index {
            case .bc: self.bc = newValue
            case .de: self.de = newValue
            case .hl: self.hl = newValue
            case .sp: self.sp = newValue
            }
        }
    }

    subscript(_ index: Opcode.IndirectMemoryTarget) -> UInt8 {
        mutating get {
            switch index {
            case .bc:
                return readMemory(address: self.bc)
            case .de:
                return readMemory(address: self.de)
            case .hli:
                defer {
                    self.hl += 1
                }
                return readMemory(address: self.hl)
            case .hld:
                defer {
                    self.hl -= 1
                }
                return readMemory(address: self.hl)
            }
        }
        set {
            switch index {
            case .bc:
                self.writeMemory(address: self.bc, byte: newValue)
            case .de:
                self.writeMemory(address: self.de, byte: newValue)
            case .hli:
                self.writeMemory(address: self.hl, byte: newValue)
                self.hl += 1
            case .hld:
                self.writeMemory(address: self.hl, byte: newValue)
                self.hl -= 1
            }
        }
    }
}

extension CPU {
    mutating func loadProgram(program: [UInt8]) {
        // NOTA BENE: We access memory directly here in order to initially load
        // the program in the context of initializing the CPU while running a unit test,
        // and so do not need to increment cycles as we would while executing a program.
        for (index, byte) in program.enumerated() {
            self.memory[index] = byte
        }
    }

    mutating func loadStack(stack: [UInt8]) {
        // NOTA BENE: We access memory directly here in order to initially load
        // the stack in the context of initializing the CPU while running a unit test,
        // and so do not need to increment cycles as we would while actually
        // popping and/or pushing during executing a program.
        for (index, byte) in stack.enumerated() {
            self.memory[0xFFFE - index] = byte
        }
    }

    mutating func readProgramByte() -> UInt8 {
        // NOTA BENE: Perhaps later we can do some bounds checking
        let byte = self.readMemory(address: self.pc)
        self.pc += 1
        return byte
    }

    mutating func readProgramWord() -> UInt16 {
        let lowByte = self.readProgramByte()
        let highByte = self.readProgramByte()
        return UInt16(highByte: highByte, lowByte: lowByte)
    }

    // ACHTUNG!!!!! This is a temporary measure for now until
    // we have a more robust understanding of memory and the bus.
    mutating func readMemory(address: UInt16) -> UInt8 {
        self.cycles += 1
        return self.memory[Int(address)]
    }

    mutating func writeMemory(address: UInt16, byte: UInt8) {
        self.memory[Int(address)] = byte
        self.cycles += 1
    }

    // NOTA BENE: The GameBoy is little-endian and so push and pop
    // operations behave as described in the answers in this thread:
    //
    //    https://www.reddit.com/r/EmuDev/comments/7an96f/gameboy_questions_about_handling_16bit_readwrite/
    mutating func popStackByte() -> UInt8 {
        let byte = self.readMemory(address: self.sp)
        self.sp += 1
        return byte
    }

    mutating func popStack() -> UInt16 {
        let lowByte = self.popStackByte()
        let highByte = self.popStackByte()
        return UInt16(highByte: highByte, lowByte: lowByte)
    }

    mutating func pushStackByte(byte: UInt8) {
        self.sp -= 1
        self.writeMemory(address: self.sp, byte: byte)
    }

    mutating func pushStack(word: UInt16) {
        self.pushStackByte(byte: word.high)
        self.pushStackByte(byte: word.low)
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
            self.writeMemoryFromA(target: Opcode.IndirectMemoryTarget(opcode: opcode)!)
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
        case .jrImmediate:
            self.jrImmediate()
        case .jrImmediateIfZeroReset, .jrImmediateIfZeroSet, .jrImmediateIfCarryReset, .jrImmediateIfCarrySet:
            self.jrImmediate(condition: Opcode.JumpCondition(opcode: opcode)!)
        case .ldImmediateIndirectFromSP:
            self.loadMemoryFromSP()
        case .addBCToHL, .addDEToHL, .addHLToHL, .addSPToHL:
            self.addToHL(from: Opcode.Register16Target(opcode: opcode)!)
        case .ldAFromBCIndirect, .ldAFromDEIndirect, .ldAFromHLIndirectAndIncrement, .ldAFromHLIndirectAndDecrement:
            self.writeAFromMemory(target: Opcode.IndirectMemoryTarget(opcode: opcode)!)
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
        case .subBFromA, .subCFromA, .subDFromA, .subEFromA, .subHFromA, .subLFromA, .subHLIndirectFromA, .subAFromA:
            self.subFromA(from: Opcode.Register8Target(atBit0Of: opcode)!)
        case .sbcBFromA, .sbcCFromA, .sbcDFromA, .sbcEFromA, .sbcHFromA, .sbcLFromA, .sbcHLIndirectFromA, .sbcAFromA:
            self.sbcFromA(from: Opcode.Register8Target(atBit0Of: opcode)!)
        case .andAWithB, .andAWithC, .andAWithD, .andAWithE, .andAWithH, .andAWithL, .andAWithHLIndirect, .andAWithA:
            self.andA(with: Opcode.Register8Target(atBit0Of: opcode)!)
        case .xorAWithB, .xorAWithC, .xorAWithD, .xorAWithE, .xorAWithH, .xorAWithL, .xorAWithHLIndirect, .xorAWithA:
            self.xorA(with: Opcode.Register8Target(atBit0Of: opcode)!)
        case .orAWithB, .orAWithC, .orAWithD, .orAWithE, .orAWithH, .orAWithL, .orAWithHLIndirect, .orAWithA:
            self.orA(with: Opcode.Register8Target(atBit0Of: opcode)!)
        case .cpAWithB, .cpAWithC, .cpAWithD, .cpAWithE, .cpAWithH, .cpAWithL, .cpAWithHLIndirect, .cpAWithA:
            self.cpA(with: Opcode.Register8Target(atBit0Of: opcode)!)
        case .addImmediateToA:
            self.addImmediateToA()
        case .adcImmediateToA:
            self.adcImmediateToA()
        case .subImmediateFromA:
            self.subImmediateFromA()
        case .sbcImmediateFromA:
            self.sbcImmediateFromA()
        case .andImmediateWithA:
            self.andImmediateWithA()
        case .xorImmediateWithA:
            self.xorImmediateWithA()
        case .orImmediateWithA:
            self.orImmediateWithA()
        case .cpImmediateWithA:
            self.cpImmediateWithA()
        case .retIfZeroReset, .retIfZeroSet, .retIfCarryReset, .retIfCarrySet:
            self.ret(condition: Opcode.JumpCondition(opcode: opcode)!)
        case .ret:
            self.ret()
        case .retI:
            self.retI()
        case .jpImmediateIfZeroReset, .jpImmediateIfZeroSet, .jpImmediateIfCarryReset, .jpImmediateIfCarrySet:
            self.jpImmediate(condition: Opcode.JumpCondition(opcode: opcode)!)
        case .jpImmediate:
            self.jpImmediate()
        case .jpHL:
            self.jpHL()
        case .callImmediateIfZeroReset, .callImmediateIfZeroSet, .callImmediateIfCarryReset, .callImmediateIfCarrySet:
            self.callImmediate(condition: Opcode.JumpCondition(opcode: opcode)!)
        case .callImmediate:
            self.callImmediate()
        case .rst00, .rst08, .rst10, .rst18, .rst20, .rst28, .rst30, .rst38:
            self.restart(opcode: opcode)
        }
    }

    public mutating func executeInstruction() throws {
        let oldCycles = self.cycles
        let oldF = self.f

        let opcode = try self.fetchOpcode()
        try self.execute(opcode: opcode)

        assert(self.cycles - oldCycles == opcode.cycles(f: oldF), "The cycle count for this instruction is off: \(opcode)")
    }

    mutating func nop() {
        // Nothing to see here!!!
    }

    mutating func load(target: Opcode.Register16Target) {
        let word = self.readProgramWord()

        self[target] = word
    }

    mutating func load(target: Opcode.Register8Target) {
        let byte = self.readProgramByte()

        self[target] = byte
    }

    mutating func writeMemoryFromA(target: Opcode.IndirectMemoryTarget) {
        self[target] = self.a
    }

    mutating func writeAFromMemory(target: Opcode.IndirectMemoryTarget) {
        self.a = self[target]
    }

    mutating func loadMemoryFromSP() {
        let address = self.readProgramWord()
        self.writeMemory(address: address, byte: self.sp.low)
        self.writeMemory(address: address+1, byte: self.sp.high)
    }

    mutating func incrementRegister(target: Opcode.Register16Target) {
        self[target] &+= 1

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
        (newRegister, self.f[.carry], self.f[.halfCarry]) = oldRegister.addingReportingCarries(1)
        self.f[.zero] = newRegister == 0
        self.f[.subtraction] = false
        self[target] = newRegister

    }

    mutating func decrementRegister(target: Opcode.Register16Target) {
        self[target] &-= 1

        // NOTA BENE: This set of instructions incurs an extra cycle
        self.cycles += 1
    }

    mutating func decrementRegister(target: Opcode.Register8Target) {
        let oldValue = self[target]

        let newValue: Register8
        (newValue, self.f[.carry], self.f[.halfCarry]) = oldValue.subtractingReportingCarries(1)
        self.f[.zero] = newValue == 0
        self.f[.subtraction] = true
        self[target] = newValue
    }

    mutating func isSatisfied(condition: Opcode.JumpCondition) -> Bool {
        switch condition {
        case .carryReset:
            !self.f[.carry]
        case .carrySet:
            self.f[.carry]
        case .zeroReset:
            !self.f[.zero]
        case .zeroSet:
            self.f[.zero]
        }
    }

    mutating func jrImmediate() {
        self.jrImmediateImpl(conditionSatisfied: true)
    }

    mutating func jrImmediate(condition: Opcode.JumpCondition) {
        let conditionSatisfied = isSatisfied(condition: condition)

        self.jrImmediateImpl(conditionSatisfied: conditionSatisfied)
    }

    mutating func jrImmediateImpl(conditionSatisfied: Bool) {
        if conditionSatisfied {
            let jumpValue = UInt16(self.readProgramByte())

            self.pc &+= jumpValue
        } else {
            self.pc &+= 1
        }

        // NOTA BENE: This set of instructions incurs an extra cycle
        self.cycles += 1
    }

    mutating func jpImmediate(condition: Opcode.JumpCondition) {
        let conditionSatisfied = isSatisfied(condition: condition)

        self.jpImmediateImpl(conditionSatisfied: conditionSatisfied)
    }

    mutating func jpImmediate() {
        self.jpImmediateImpl(conditionSatisfied: true)
    }

    mutating func jpImmediateImpl(conditionSatisfied: Bool) {
        // ACHTUNG!!! The CPU actually reads the next two bytes
        // even if the condition is false, and thus regardless
        // consumes two more cycles! :O :O :O
        //
        //    https://gekkio.fi/files/gb-docs/gbctr.pdf
        let address = self.readProgramWord()

        if conditionSatisfied {
            self.pc = address

            self.cycles += 1
        }
    }

    mutating func jpHL() {
        let address = self.hl

        self.pc = address
    }

    mutating func callImmediate(condition: Opcode.JumpCondition) {
        let conditionSatisfied = isSatisfied(condition: condition)

        self.callImmediateImpl(conditionSatisfied: conditionSatisfied)
    }

    mutating func callImmediate() {
        self.callImmediateImpl(conditionSatisfied: true)
    }

    mutating func callImmediateImpl(conditionSatisfied: Bool) {
        // ACHTUNG!!! The CPU actually reads the next two bytes
        // even if the condition is false, and thus regardless
        // consumes two more cycles! :O :O :O
        //
        //    https://gekkio.fi/files/gb-docs/gbctr.pdf
        let address = self.readProgramWord()

        if conditionSatisfied {
            self.pushStack(word: self.pc)
            self.pc = address

            // NOTA BENE: The setting of the program counter incurs an extra cycle;
            // see the following page for details:
            //
            //    https://gist.github.com/SonoSooS/c0055300670d678b5ae8433e20bea595#call-a16
            self.cycles += 1
        }
    }

    mutating func addToHL(from: Opcode.Register16Target) {
        let fromValue = self[from]

        (_, self.f[.halfCarry]) = ((self.hl & 0x0FFF) << 4).addingReportingOverflow((fromValue & 0x0FFF) << 4)
        (self.hl, self.f[.carry]) = self.hl.addingReportingOverflow(fromValue)
        self.f[.subtraction] = false

        // NOTA BENE: This set of instructions incurs an extra cycle
        self.cycles += 1
    }

    mutating func load(from: Opcode.Register8Target, to: Opcode.Register8Target) throws {
        self[to] = self[from]
    }

    mutating func addToA(from: Opcode.Register8Target) {
        let fromValue = self[from]

        self.addToAImpl(value: fromValue, carry: false)
    }

    mutating func addImmediateToA() {
        let value = self.readProgramByte()

        self.addToAImpl(value: value, carry: false)
    }

    mutating func adcToA(from: Opcode.Register8Target) {
        let fromValue = self[from]

        self.addToAImpl(value: fromValue, carry: self.f[.carry])
    }

    mutating func adcImmediateToA() {
        let value = self.readProgramByte()

        self.addToAImpl(value: value, carry: self.f[.carry])
    }

    mutating func addToAImpl(value: UInt8, carry: Bool) {
        (self.a, self.f[.carry], self.f[.halfCarry]) = self.a.addingReportingCarries(value, carry: carry)
        self.f[.zero] = self.a == 0
        self.f[.subtraction] = false
    }

    mutating func subFromA(from: Opcode.Register8Target) {
        let fromValue = self[from]

        self.subFromAImpl(value: fromValue, carry: false)
    }

    mutating func subImmediateFromA() {
        let value = self.readProgramByte()

        self.subFromAImpl(value: value, carry: false)
    }

    mutating func sbcFromA(from: Opcode.Register8Target) {
        let fromValue = self[from]

        self.subFromAImpl(value: fromValue, carry: self.f[.carry])
    }

    mutating func sbcImmediateFromA() {
        let value = self.readProgramByte()

        self.subFromAImpl(value: value, carry: self.f[.carry])
    }

    mutating func subFromAImpl(value: UInt8, carry: Bool) {
        (self.a, self.f[.carry], self.f[.halfCarry]) = self.a.subtractingReportingCarries(value, carry: carry)
        self.f[.zero] = self.a == 0
        self.f[.subtraction] = true
    }

    mutating func andA(with: Opcode.Register8Target) {
        self.andAImpl(value: self[with])
    }

    mutating func andImmediateWithA() {
        let value = self.readProgramByte()

        self.andAImpl(value: value)
    }

    mutating func andAImpl(value: UInt8) {
        self.a &= value
        self.f[.zero] = self.a == 0
        self.f[.subtraction] = false
        self.f[.halfCarry] = true
        self.f[.carry] = false
    }

    mutating func xorA(with: Opcode.Register8Target) {
        self.xorAImpl(value: self[with])
    }

    mutating func xorImmediateWithA() {
        let value = self.readProgramByte()

        self.xorAImpl(value: value)
    }

    mutating func xorAImpl(value: UInt8) {
        self.a ^= value
        self.f[.zero] = self.a == 0
        self.f[.subtraction] = false
        self.f[.halfCarry] = false
        self.f[.carry] = false
    }

    mutating func orA(with: Opcode.Register8Target) {
        self.orAImpl(value: self[with])
    }

    mutating func orImmediateWithA() {
        let value = self.readProgramByte()

        self.orAImpl(value: value)
    }

    mutating func orAImpl(value: UInt8) {
        self.a |= value
        self.f[.zero] = self.a == 0
        self.f[.subtraction] = false
        self.f[.halfCarry] = false
        self.f[.carry] = false
    }

    mutating func cpA(with: Opcode.Register8Target) {
        self.cpAImpl(value: self[with])
    }

    mutating func cpImmediateWithA() {
        let value = self.readProgramByte()

        self.cpAImpl(value: value)
    }

    mutating func cpAImpl(value: UInt8) {
        self.f[.zero] = self.a == value
        self.f[.subtraction] = true
        (_, self.f[.carry], self.f[.halfCarry]) = self.a.subtractingReportingCarries(value)
    }

    mutating func ret(condition: Opcode.JumpCondition) {
        let conditionSatisfied: Bool = switch condition {
        case .carryReset:
            !self.f[.carry]
        case .carrySet:
            self.f[.carry]
        case .zeroReset:
            !self.f[.zero]
        case .zeroSet:
            self.f[.zero]
        }

        // NOTA BENE: The flag check above incurs an extra cycle;
        // see the following page for details:
        //
        //    https://gist.github.com/SonoSooS/c0055300670d678b5ae8433e20bea595#ret-cc
        self.cycles += 1

        self.retImpl(conditionSatisfied: conditionSatisfied)
    }

    mutating func ret() {
        self.retImpl(conditionSatisfied: true)
    }

    mutating func retI() {
        self.retImpl(conditionSatisfied: true, interruptsEnabled: true)
    }

    mutating func retImpl(conditionSatisfied: Bool, interruptsEnabled: Bool = false) {
        if conditionSatisfied {
            let address = self.popStack()
            self.pc = address
            self.interruptsEnabled = interruptsEnabled

            // NOTA BENE: The setting of the program counter incurs an extra cycle;
            // see the following page for details:
            //
            //    https://gist.github.com/SonoSooS/c0055300670d678b5ae8433e20bea595#ret-cc
            self.cycles += 1
        }
    }

    mutating func restart(opcode: Opcode) {
        let lowByte: UInt8 = opcode.rawValue & 0b0011_1000

        self.pushStack(word: self.pc)
        self.pc = Register16(highByte: 0x00, lowByte: lowByte)

        // NOTA BENE: The setting of the program counter incurs an extra cycle;
        // see the following page for details:
        //
        //    https://gist.github.com/SonoSooS/c0055300670d678b5ae8433e20bea595#rst-nn
        self.cycles += 1
    }
}
