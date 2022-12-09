//
//  TimeInterval.swift
//  AudioBook
//
//  Created by Ivan Pestov on 08.12.2022.
//

import Foundation

extension TimeInterval {
    var mmss: String {
        return self < 0 ? "00:00" : String(format:"%02d:%02d", Int((self/60.0).truncatingRemainder(dividingBy: 60)), Int(self .truncatingRemainder(dividingBy: 60)))
    }
}
