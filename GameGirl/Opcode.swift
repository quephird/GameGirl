//
//  Opcode.swift
//  GameGirl
//
//  Created by Danielle Kefford on 12/22/25.
//

enum Opcode: UInt8 {
    case nop = 0x00
    case ldBc = 0x01
    case ldDe = 0x11
    case ldHl = 0x21
    case ldSp = 0x31

}

extension Opcode {
    var bytes: Int {
        switch self {
        case .nop: 1
        case .ldBc, .ldDe, .ldHl, .ldSp: 3
        }
    }
}

extension Opcode {
    var cycles: Int {
        switch self {
        case .nop: 1
        case .ldBc, .ldDe, .ldHl, .ldSp: 3
        }
    }
}
