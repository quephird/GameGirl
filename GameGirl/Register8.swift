//
//  Register.swift
//  GameGirl
//
//  Created by Danielle Kefford on 6/10/25.
//

public typealias Register8 = UInt8

extension Register8 {
    subscript (_ flag: RegisterBit) -> Bool {
        get {
            (self & (1 << flag.bitIndex)) > 0
        }
        set {
            self &= ~(1 << flag.bitIndex)
            self |= (newValue ? 1 : 0) << flag.bitIndex
        }
    }
}
