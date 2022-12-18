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
    var progress: Double = 0.0
    var totalDuration: Double = 0.0
    var playerIndex: Int = 0
    var rate: Float = 0.0
    var isPlaying: Bool = false
}

protocol AudioServiceProtocol {
    var stateValue: PlayerState? { get }
    var statePublisher: AnyPublisher<PlayerState?, Never> { get }
    
    func playNext()
    func playPrevious()
    func rewind()
    func fastForward()
    func timeObserve()
    func removeTimeObserver()
    func setSpeed()
    func play()
    func controlSliderValue(closure: () -> ())
}

class AudioService: AudioServiceProtocol {
    let urls: [URL]
    var player: AVPlayer
    let seekDurationTen: Float64 = 10
    let seekDurationFive: Float64 = 5
    var timeObserver: Any?
    
    private let stateSubject = CurrentValueSubject<PlayerState?, Never>(nil)
    
//    let controlStatusChanged = PassthroughSubject<AVPlayer,Never>()
//    private var itemObservation: NSKeyValueObservation?
    
    var stateValue: PlayerState? {
        stateSubject.value
    }
    
    var statePublisher: AnyPublisher<PlayerState?, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    init?(urls: [URL]) {
        self.urls = urls
        
        self.stateSubject.value = PlayerState()
        
        guard let chapter = Bundle.main.url(forResource: URL.chapters[stateSubject.value!.playerIndex], withExtension: "mp3") else { return nil }
        
        let playerItem = AVPlayerItem(url: chapter)
        
        self.player = AVPlayer(playerItem: playerItem)
        
        let total: CMTime = player.currentItem!.asset.duration
        stateSubject.value?.totalDuration = CMTimeGetSeconds(total)
        
//        self.itemObservation = player.observe(\.rate, changeHandler: { player, change in
//
//            self.controlStatusChanged.send(player)
//        })
        player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: .main) { [self] (CMTime) in
            
            let currentTime: CMTime = playerItem.currentTime()
            stateSubject.value?.progress = CMTimeGetSeconds(currentTime)
            
            self.stateSubject.send(stateValue)
        }
    }
    
    func play() {
        stateSubject.value?.isPlaying.toggle()

        if stateSubject.value?.isPlaying == true {
            player.play()
        } else {
            player.pause()
        }
    }
    
    func playNext() {
        if stateSubject.value!.playerIndex == 0 || stateSubject.value!.playerIndex < 2 {
            stateSubject.value!.playerIndex += 1
        }
        timeObserve()
        player.play()
    }
    
    func playPrevious() {
        if stateSubject.value!.playerIndex != 0 || stateSubject.value!.playerIndex > 0 {
            stateSubject.value?.playerIndex -= 1   
        }
        timeObserve()
        player.play()
    }
    
    func rewind() {
        let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
        var newTime = playerCurrentTime - seekDurationFive
        if newTime < 0 { newTime = 0 }
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
            player.play()
        }
    }
    
    func setSpeed() {
        stateSubject.value?.rate = player.rate
        switch player.rate {
        case 1..<2:
            player.rate += 0.25
        case 2:
            player.rate = 0.25
        default:
            player.rate += 0.25
        }
    }
    
    func timeObserve() {
        guard let chapter = Bundle.main.url(forResource: URL.chapters[stateSubject.value!.playerIndex], withExtension: "mp3") else { return  }

        let playerItem = AVPlayerItem(url: chapter)

        player = AVPlayer(playerItem: playerItem)

        let interval = CMTimeMakeWithSeconds(1, preferredTimescale: 1)
        
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [self] (CMTime) in
            
            let currentTime: CMTime = player.currentTime()
            stateSubject.value?.progress = CMTimeGetSeconds(currentTime)
            let total: CMTime = player.currentItem!.asset.duration
            stateSubject.value?.totalDuration = CMTimeGetSeconds(total)
        }
    }
    
    func removeTimeObserver() {
        DispatchQueue.main.async { [self] in
            guard let timeObserver = timeObserver else { return }
            player.removeTimeObserver(timeObserver)
        }
    }
    
    @objc func controlSliderValue(closure: () -> ()) {
        let seconds: Int64 = Int64(stateSubject.value!.progress)
        let targetTime: CMTime = CMTimeMakeWithSeconds(Float64(seconds), preferredTimescale: 1)
//        let seconds: Int64 = Int64(slider.value)
//        let targetTime: CMTime = CMTimeMakeWithSeconds(Float64(seconds), preferredTimescale: 1)
        player.seek(to: targetTime)
        
        if player.rate == 0 {
//            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            player.play()
            closure()
        }
    }
}
