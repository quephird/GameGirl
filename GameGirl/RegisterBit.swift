//
//  RegisterBit.swift
//  GameGirl
//
//  Created by Danielle Kefford on 6/12/25.
//

public enum RegisterBit {
    case carry
    case halfCarry
    case subtraction
    case zero

    var bitIndex: Int {
        switch self {
        case .carry:
            4
        case .halfCarry:
            5
        case .subtraction:
            6
        case .zero:
            7
        }
    }
}
