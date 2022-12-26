//
//  Feature.swift
//  AudioBook
//
//  Created by Ivan Pestov on 26.12.2022.
//

import Foundation
import Combine
import ComposableArchitecture
import AVFoundation

struct Feature: ReducerProtocol {
    let service = Service(urls: URL.urlChapter)
    var progress = CurrentValueSubject<Double, Never>(0)
    
    struct State: Equatable {
        var player = Player.mock
    }
    
    enum Action: Equatable {
        case setupDuration
        case play
        case playNext
        case playPrevious
        case rewind
        case goForward
        case changeSpeed
    }
 
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .setupDuration:
            let total: CMTime = service!.player.currentItem!.asset.duration
            state.player.totalDuration = CMTimeGetSeconds(total)
            
            return .none
            
        case .play:
            state.player.isPlaying.toggle()
            
            switch state.player.isPlaying {
            case true:
                service!.player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main, using: { _ in
                    let time = service!.player.currentTime()
                    progress.send(CMTimeGetSeconds(time))
                })
                service!.player.play()
                
            default:
                service!.player.pause()
                
            }
            return .none
            
        case .playNext:
            if state.player.chapterIndex == 0 || state.player.chapterIndex < 2 {
                state.player.chapterIndex += 1
                trackPlayback(chapterIndex: state.player.chapterIndex, completion: {})
                let total: CMTime = service!.player.currentItem!.asset.duration
                state.player.totalDuration = CMTimeGetSeconds(total)
            }
            return .none
            
        case .playPrevious:
            if state.player.chapterIndex != 0 || state.player.chapterIndex > 0 {
                state.player.chapterIndex -= 1
                trackPlayback(chapterIndex: state.player.chapterIndex, completion: {})
                let total: CMTime = service!.player.currentItem!.asset.duration
                state.player.totalDuration = CMTimeGetSeconds(total)
            }
            return .none
            
        case .rewind:
            seekToSelectedTime(seconds: 5, operatorName: "-")
            return .none
            
        case .goForward:
            seekToSelectedTime(seconds: 10, operatorName: "+")
            return .none
            
        case .changeSpeed:
            switch service!.player.rate {
            case 0.25..<2:
                service!.player.rate += 0.25
                state.player.rate = service!.player.rate
            default:
                service!.player.rate = 0.25
                state.player.rate = service!.player.rate
            }
            return .none
        }
    }
    
    func trackPlayback(chapterIndex: Int, completion: @escaping () -> ()) {
        guard let service = service else { return }
        
        let chapter = URL.urlChapter[chapterIndex]
        
        let playerItem = AVPlayerItem(url: chapter)
        
        service.player = AVPlayer(playerItem: playerItem)
        
        let interval = CMTimeMakeWithSeconds(1, preferredTimescale: 1)
        
        service.player.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { _ in
            completion()
        })
        service.player.play()
        
    }
    
    func seekToSelectedTime(seconds: Double, operatorName: String) {
        let playerCurrentTime = CMTimeGetSeconds(service!.player.currentTime())
        var newTime: Double = 0.0
        switch (operatorName) {
        case "+":
            newTime = playerCurrentTime + seconds
        case "-":
            newTime = playerCurrentTime - seconds
        default:
            print("error")
        }
        let time: CMTime = CMTimeMakeWithSeconds(newTime, preferredTimescale: 1000)
        service!.player.seek(to: time)
        service!.player.play()
    }
}

