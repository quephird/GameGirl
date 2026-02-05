//
//  FixedWidthInteger+extension.swift
//  GameGirl
//
//  Created by Danielle Kefford on 2/4/26.
//

extension FixedWidthInteger {
    func addingReportingOverflow(_ rhs: Self, carryValue: Self) -> (partialValue: Self, overflow: Bool) {
        let (tempResult, tempCarry) = self.addingReportingOverflow(rhs)
        let (tempResult2, tempCarry2) = tempResult.addingReportingOverflow(carryValue)

        return (tempResult2, tempCarry2 || tempCarry)
    }
}
