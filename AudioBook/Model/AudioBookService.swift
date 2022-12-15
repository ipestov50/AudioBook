//
//  AudioBookService.swift
//  AudioBook
//
//  Created by Ivan Pestov on 14.12.2022.
//

import Foundation
import AVFoundation
import Combine

struct PlayerState {
    var progress: Float
    var duration: Float
    var rate: Float
    var playerIndex: Int = 0
    var time: Float64
}

protocol AudioServiceProtocol {
    var stateValue: PlayerState? { get }
    var statePublisher: AnyPublisher<PlayerState?, Never> { get }
    var player: AVPlayer { get }
    
    func playNext()
    func playPrevious()
    func rewind()
    func fastForward()
    func timeObserve(closure: @escaping () -> ())
    func removeTimeObserver()
}

class AudioService: AudioServiceProtocol {
    
    let seekDurationTen: Float64 = 10
    let seekDurationFive: Float64 = 5
    let urls: [URL]
    var player: AVPlayer
    var playerItem: AVPlayerItem
//    let seconds: Float64
//    var currentSeconds: Float64
    var timeObserver: Any?
    
    private let stateSubject = CurrentValueSubject<PlayerState?, Never>(nil)
    
    var stateValue: PlayerState? {
        stateSubject.value
    }
    
    var statePublisher: AnyPublisher<PlayerState?, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    init?(urls: [URL]) {
        self.urls = urls
        
        let playerItem = AVPlayerItem(url: urls.first!)
        self.player = AVPlayer(playerItem: playerItem)
        self.playerItem = playerItem
        
//        let duration: CMTime = playerItem.asset.duration
//        self.seconds = CMTimeGetSeconds(duration)
//
//        let currentDuration = playerItem.currentTime()
//        self.currentSeconds = CMTimeGetSeconds(currentDuration)
        
//        self.time = CMTimeGetSeconds(self.player.currentTime())
        
        player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (CMTime) in
            
//            self.stateSubject.send(<#T##input: PlayerState?##PlayerState?#>)
        }
    }
    
    
    func playNext() {
        if stateSubject.value!.playerIndex != 0 || stateSubject.value!.playerIndex > 0 {
            stateSubject.value?.playerIndex -= 1
        }
        
        
        
        let playerItem = AVPlayerItem(url: URL.urlChapter[stateSubject.value!.playerIndex])
        player = AVPlayer(playerItem: playerItem)
        
        player.play()
    }
    
    func playPrevious() {
        if stateSubject.value!.playerIndex != 0 || stateSubject.value!.playerIndex > 0 {
            stateSubject.value?.playerIndex -= 1
        }
        
//        guard let url = URL(string: chapters[stateSubject.value!.playerIndex].name) else {
//            return
//        }
        
        let playerItem = AVPlayerItem(url: URL.urlChapter[stateSubject.value!.playerIndex])
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
                stateSubject.value?.time = CMTimeGetSeconds(player.currentTime())
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
