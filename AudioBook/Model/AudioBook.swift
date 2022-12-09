//
//  AudioBook.swift
//  AudioBook
//
//  Created by Ivan Pestov on 08.12.2022.
//

import Foundation
import AVFoundation
import ComposableArchitecture

struct AudioBookChapter {
    var name: String
}

class AudioBookService {
    
    var chapters: [AudioBookChapter] = [
        AudioBookChapter(name: "firstChapter"),
        AudioBookChapter(name: "secondChapter"),
        AudioBookChapter(name: "thirdChapter")
    ]
}
