//
//  RegisterPair.swift
//  GameGirl
//
//  Created by Danielle Kefford on 6/10/25.
//

public typealias Register16 = UInt16

extension Register16 {
    public init(highByte: UInt8, lowByte: UInt8) {
        self = UInt16(highByte) << 8 | UInt16(lowByte)
    }

    var high: UInt8 {
        get { UInt8(self >> 8) }
        set { self = (self & 0xFF) | (UInt16(newValue) << 8) }
    }

    var low: UInt8 {
        get { UInt8(self & 0xFF) }
        set { self = (self & 0xFF00) | UInt16(newValue) }
    }
}
