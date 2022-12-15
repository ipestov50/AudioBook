//
//  AudioBookChapter.swift
//  AudioBook
//
//  Created by Ivan Pestov on 08.12.2022.
//

import Foundation
import AVFoundation

struct AudioBookChapter {
//    var name: String
    var url: URL
}

extension URL {
//    static var chapters: [AudioBookChapter] = [
//        AudioBookChapter(name: "firstChapter"),
//        AudioBookChapter(name: "secondChapter"),
//        AudioBookChapter(name: "thirdChapter")
//    ]
    
    static var urlChapter: [URL] = [
        URL(string: Bundle.main.path(forResource: "firstChapter", ofType: "mp3")!)!,
        URL(string: Bundle.main.path(forResource: "secondChapter", ofType: "mp3")!)!,
        URL(string: Bundle.main.path(forResource: "thirdChapter", ofType: "mp3")!)!,
    ]
}
