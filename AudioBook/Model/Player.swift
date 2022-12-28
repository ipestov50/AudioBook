//
//  Player.swift
//  AudioBook
//
//  Created by Ivan Pestov on 25.12.2022.
//

import Foundation
import Combine

struct Player: Equatable {
    
    var progress: Double
    var totalDuration: Double
    var chapterIndex: Int
    var rate: Float
    var isPlaying: Bool
    
    static var mock = Player(progress: 0.0, totalDuration: 0.0, chapterIndex: 0, rate: 0, isPlaying: false)
}
