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
    
    
    
    let seekDurationTen: Float64 = 10
    let seekDurationFive: Float64 = 5
    var playerIndex: Int = 0
    
    let chapters: [AudioBookChapter]
    var player: AVPlayer
    var playerItem: AVPlayerItem
    let seconds: Float64
    var currentSeconds: Float64
    var time: Float64
    
    init?(chapters: [AudioBookChapter]) {
        self.chapters = chapters
        
        guard let firstChapter = chapters.first else {
            return nil
        }
        
        guard let url = Bundle.main.url(forResource: firstChapter.name, withExtension: "mp3") else {
            return nil
        }
        
        let playerItem = AVPlayerItem(url: url)
        self.player = AVPlayer(playerItem: playerItem)
        self.playerItem = playerItem
        
        let duration: CMTime = playerItem.asset.duration
        self.seconds = CMTimeGetSeconds(duration)
        
        let currentDuration = playerItem.currentTime()
        self.currentSeconds = CMTimeGetSeconds(currentDuration)
        
        self.time = CMTimeGetSeconds(self.player.currentTime())
        
    }
    
    func setupforwardEndButton() {
        if playerIndex == 0 || playerIndex < 2 {
            playerIndex += 1
        }
        player = AVPlayer(url: URL(fileURLWithPath: Bundle.main.path(forResource: chapters[playerIndex].name, ofType: "mp3")!))
        player.play()
    }
    
    func setupbackwardEndButton() {
        if playerIndex != 0 || playerIndex > 0 {
            playerIndex -= 1
        }
        player = AVPlayer(url: URL(fileURLWithPath: Bundle.main.path(forResource: chapters[playerIndex].name, ofType: "mp3")!))
        player.play()
    }
    
    func setupSeekBackWardsButton() {
        let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
        var newTime = playerCurrentTime - seekDurationFive
        if newTime < 0 { newTime = 0 }
        player.pause()
        let selectedTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        player.seek(to: selectedTime)
        player.play()
    }
    
    func setupSeekForwarButton() {
        if let duration = player.currentItem?.duration {
            let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
            let newTime = playerCurrentTime + seekDurationTen
            if newTime < CMTimeGetSeconds(duration)
            {
                let selectedTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
                player.seek(to: selectedTime)
            }
            player.pause()
            player.play()
        }
    }
}

extension AudioBookChapter {
    static var chapters: [AudioBookChapter] = [
        AudioBookChapter(name: "firstChapter"),
        AudioBookChapter(name: "secondChapter"),
        AudioBookChapter(name: "thirdChapter")
    ]
}
