//
//  AudioBookService.swift
//  AudioBook
//
//  Created by Ivan Pestov on 14.12.2022.
//

import Foundation
import AVFoundation

class AudioBookService {
    
    let seekDurationTen: Float64 = 10
    let seekDurationFive: Float64 = 5
    var playerIndex: Int
    
    let chapters: [AudioBookChapter]
    var player: AVPlayer
    var playerItem: AVPlayerItem
    let seconds: Float64
    var currentSeconds: Float64
    var time: Float64
    var timeObserver: Any?
    
    init?(chapters: [AudioBookChapter]) {
        self.chapters = chapters
        self.playerIndex = 0
        
        
        guard let url = Bundle.main.url(forResource: chapters[playerIndex].name, withExtension: "mp3") else {
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
    
    
    func playNext() {
        if playerIndex == 0 || playerIndex < 2 {
            playerIndex += 1
        }
        guard let url = Bundle.main.url(forResource: chapters[playerIndex].name, withExtension: "mp3") else {
            return
        }
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        player.play()
    }
    
    func playPrevious() {
        if playerIndex != 0 || playerIndex > 0 {
            playerIndex -= 1
        }
        guard let url = Bundle.main.url(forResource: chapters[playerIndex].name, withExtension: "mp3") else {
            return
        }
        
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        player.play()
    }
    
    func rewind() {
        let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
        var newTime = playerCurrentTime - seekDurationFive
        if newTime < 0 { newTime = 0 }
        player.pause()
        let selectedTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        player.seek(to: selectedTime)
        player.play()
    }
    
    func fastForward() {
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
    
    func timeObserve(closure: @escaping () -> ()) {
        let interval = CMTimeMakeWithSeconds(1, preferredTimescale: 1)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [self] (cmtime)  in
            if player.currentItem?.status == .readyToPlay {
                self.time = CMTimeGetSeconds(player.currentTime())
            } else if player.currentItem?.status == .unknown {
                removeTimeObserver()
            }
            closure()
        }
    }
    
    func removeTimeObserver() {
        DispatchQueue.main.async { [self] in
            guard let timeObserver = timeObserver else { return }
            player.removeTimeObserver(timeObserver)
        }
    }
}

