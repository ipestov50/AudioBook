//
//  AudioBookChapter.swift
//  AudioBook
//
//  Created by Ivan Pestov on 08.12.2022.
//

import Foundation
import AVFoundation

struct AudioBookChapter {
    var name: String
}

extension AudioBookChapter {
    static var chapters: [AudioBookChapter] = [
        AudioBookChapter(name: "firstChapter"),
        AudioBookChapter(name: "secondChapter"),
        AudioBookChapter(name: "thirdChapter")
    ]
}
