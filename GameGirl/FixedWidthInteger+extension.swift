//
//  FixedWidthInteger+extension.swift
//  GameGirl
//
//  Created by Danielle Kefford on 2/4/26.
//

extension FixedWidthInteger {
    func addingReportingCarries(_ rhs: Self, carry: Bool = false) -> (sum: Self, carry: Bool, halfCarry: Bool) {
        let (tempResult, tempCarry) = self.addingReportingOverflow(rhs)
        let (tempResult2, tempCarry2) = tempResult.addingReportingOverflow(Self(carry.intValue))

        let (tempResult3, tempHalfCarry) = (self << 4).addingReportingOverflow(rhs << 4)
        let (_, tempHalfCarry2) = (tempResult3).addingReportingOverflow(Self(carry.intValue << 4))

        return (tempResult2, tempCarry2 || tempCarry, tempHalfCarry || tempHalfCarry2)
    }
}
