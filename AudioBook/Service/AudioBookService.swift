//
//  AudioBookService.swift
//  AudioBook
//
//  Created by Ivan Pestov on 14.12.2022.
//

import AVFoundation
import Combine
import ComposableArchitecture

class Service {
    
    var player: AVPlayer
    var urls: [URL]
    
    init?(urls: [URL]) {
        self.urls = urls
        
        guard let chapter = Bundle.main.url(forResource: URL.chapters[0], withExtension: "mp3") else { return nil }
        
        let playerItem = AVPlayerItem(url: chapter)
        
        self.player = AVPlayer(playerItem: playerItem)
    }
}
