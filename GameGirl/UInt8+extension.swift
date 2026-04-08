//
//  FixedWidthInteger+extension.swift
//  GameGirl
//
//  Created by Danielle Kefford on 2/4/26.
//

extension UInt8 {
    func addingReportingCarries(_ rhs: Self, carry: Bool = false) -> (sum: Self, carry: Bool, halfCarry: Bool) {
        let (tempResult, tempCarry) = self.addingReportingOverflow(rhs)
        let (tempResult2, tempCarry2) = tempResult.addingReportingOverflow(Self(carry.intValue))

        let (tempResult3, tempHalfCarry) = (self << 4).addingReportingOverflow(rhs << 4)
        let (_, tempHalfCarry2) = (tempResult3).addingReportingOverflow(Self(carry.intValue << 4))

        return (tempResult2, tempCarry2 || tempCarry, tempHalfCarry || tempHalfCarry2)
    }

    func subtractingReportingCarries(_ rhs: Self, carry: Bool = false) -> (sum: Self, carry: Bool, halfCarry: Bool) {
        let (tempResult, tempCarry) = self.subtractingReportingOverflow(rhs)
        let (tempResult2, tempCarry2) = tempResult.subtractingReportingOverflow(Self(carry.intValue))

        // NOTA BENE: Per the GameBoy technical manual, we need to set the half carry
        // if there was _not_ a borrow, and similarly for the carry flag.
        let (tempResult3, tempHalfCarry) = (self << 4).subtractingReportingOverflow(rhs << 4)
        let (_, tempHalfCarry2) = tempResult3.subtractingReportingOverflow(Self(carry.intValue << 4))

        return (tempResult2, !(tempCarry2 || tempCarry), !(tempHalfCarry || tempHalfCarry2))
    }
}
