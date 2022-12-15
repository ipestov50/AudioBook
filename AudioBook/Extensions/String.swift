//
//  String.swift
//  AudioBook
//
//  Created by Ivan Pestov on 14.12.2022.
//

import Foundation

extension String {
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
