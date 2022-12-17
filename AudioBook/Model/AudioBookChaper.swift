//
//  AudioBookChapter.swift
//  AudioBook
//
//  Created by Ivan Pestov on 08.12.2022.
//

import Foundation
import AVFoundation

struct AudioBookChapter {
    var url: URL
}

extension URL {
    
    static var urlChapter: [URL] = [
        Bundle.main.url(forResource: "firstChapter", withExtension: "mp3")!,
        Bundle.main.url(forResource: "secondChapter", withExtension: "mp3")!,
        Bundle.main.url(forResource: "thirdChapter", withExtension: "mp3")!,
    ]
    
    static var chapters: [String] = [
        "firstChapter",
        "secondChapter",
        "thirdChapter"
    
    ]
}
