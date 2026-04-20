//
//  Bool+intValue.swift
//  GameGirl
//
//  Created by Danielle Kefford on 1/22/26.
//

public extension Bool {
    var intValue: UInt8 {
        self ? 1 : 0
    }
}
