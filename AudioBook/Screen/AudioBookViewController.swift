//
//  ViewController.swift
//  AudioBook
//
//  Created by Ivan Pestov on 07.12.2022.
//

import UIKit
import AVFoundation
import ComposableArchitecture
import Combine

class AudioBookViewController: UIViewController {
    
    @IBOutlet var bookImageView: UIImageView!
    @IBOutlet var keypointLabel: UILabel!
    @IBOutlet var chapterDescriptionLabel: UILabel!
    @IBOutlet var slider: UISlider!
    @IBOutlet var speedButton: UIButton!
    @IBOutlet var mediaButtonStackView: UIStackView!
    
    @IBOutlet var audioDurationLabel: UILabel!
    @IBOutlet var backwardEndButton: UIButton!
    @IBOutlet var goBackwardFiveButton: UIButton!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var goForwardTenButton: UIButton!
    @IBOutlet var forwardEndButton: UIButton!
    @IBOutlet var currentTimeLabel: UILabel!
    
    
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    fileprivate let seekDurationTen: Float64 = 10
    fileprivate let seekDurationFive: Float64 = 5
    var playerIndex = 0
    
    var audioBookService = AudioBookService()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupAVPlayer()
        setupUIButton()
        setupSlider()
        bookImageView.layer.cornerRadius = 8
        speedButton.layer.cornerRadius = 8
        playButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupAVPlayer() {
        let playerItem: AVPlayerItem = AVPlayerItem(url: URL(fileURLWithPath: Bundle.main.path(forResource: audioBookService.chapters[playerIndex].name, ofType: "mp3")!))
        player = AVPlayer(playerItem: playerItem)
        slider.minimumValue = 0
        let duration: CMTime = playerItem.asset.duration
        let seconds: Float64 = CMTimeGetSeconds(duration)
        audioDurationLabel.text = self.stringFromTimeInterval(interval: seconds)
        let currentDuration: CMTime = playerItem.currentTime()
        let currentSeconds: Float64 = CMTimeGetSeconds(currentDuration)
        currentTimeLabel.text = self.stringFromTimeInterval(interval: currentSeconds)
        slider.maximumValue = Float(seconds)
        slider.isContinuous = true
        player!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (CMTime) in
            if self.player!.currentItem?.status == .readyToPlay {
                let time: Float64 = CMTimeGetSeconds(self.player!.currentTime())
                self.slider.value = Float(time)
                self.currentTimeLabel.text = self.stringFromTimeInterval(interval: time)
            }
            let playbackLikelyToKeepUp = self.player?.currentItem?.isPlaybackLikelyToKeepUp
            if playbackLikelyToKeepUp == false {
                print("IsBuffering")
            } else {
                self.playButton.isHidden = false
            }
        }
    }
    
    @objc func finishedPlaying(_ myNotification: NSNotification) {
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
    
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
}

extension AudioBookViewController {
    func setupUIButton() {
        speedButton.layer.cornerRadius = 8
    }
    
    @IBAction func speedButtonTapped() {
        switch player!.rate {
        case 1..<2:
            player!.rate += 0.25
            speedButton.setTitle("Speed \(player!.rate)x", for: .normal)
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        case 2:
            player!.rate = 0.25
            speedButton.setTitle("Speed \(player!.rate)x", for: .normal)
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        default:
            
            player!.rate += 0.25
            speedButton.setTitle("Speed \(player!.rate)x", for: .normal)
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }
    
    @IBAction func forwardEndButtonTapped() {
        if playerIndex == 0 || playerIndex < 2 {
            playerIndex += 1
        }
        player = AVPlayer(url: URL(fileURLWithPath: Bundle.main.path(forResource: audioBookService.chapters[playerIndex].name, ofType: "mp3")!))
        keypointLabel.text = "KEY POINT \(playerIndex+1) OF 3"
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        let duration = player!.currentItem!.asset.duration
        let seconds: Float64 = CMTimeGetSeconds(duration)
        audioDurationLabel.text = self.stringFromTimeInterval(interval: seconds)
        slider.maximumValue = Float(seconds)
        slider.isContinuous = true
        player!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { [self] (CMTime) in
            if self.player!.currentItem?.status == .readyToPlay {
                let time: Float64 = CMTimeGetSeconds(self.player!.currentTime())
                self.slider.value = Float(time)
                self.currentTimeLabel.text = self.stringFromTimeInterval(interval: time)
            }
        }
        player!.play()
    }
    
    @IBAction func backwardEndButtonTapped() {
        if playerIndex != 0 || playerIndex > 0 {
            playerIndex -= 1
        }
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        
        player = AVPlayer(url: URL(fileURLWithPath: Bundle.main.path(forResource: audioBookService.chapters[playerIndex].name, ofType: "mp3")!))
        keypointLabel.text = "KEY POINT \(playerIndex+1) OF 3"
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        let duration = player!.currentItem!.asset.duration
        let seconds: Float64 = CMTimeGetSeconds(duration)
        audioDurationLabel.text = self.stringFromTimeInterval(interval: seconds)
        slider.maximumValue = Float(seconds)
        slider.isContinuous = true
        player!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { [self] (CMTime) in
            if self.player!.currentItem?.status == .readyToPlay {
                let time: Float64 = CMTimeGetSeconds(self.player!.currentTime())
                self.slider.value = Float(time)
                self.currentTimeLabel.text = self.stringFromTimeInterval(interval: time)
            }
        }
        player!.play()
    }
    
    @IBAction func seekBackWards(_ sender: AnyObject) {
        if player == nil { return }
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        let playerCurrentTime = CMTimeGetSeconds(player!.currentTime())
        var newTime = playerCurrentTime - seekDurationFive
        if newTime < 0 { newTime = 0 }
        player?.pause()
        let selectedTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        player?.seek(to: selectedTime)
        player?.play()
    }
    
    @IBAction func playButton(_ sender: AnyObject) {
        print("play Button")
        if player?.rate == 0 {
            player!.play()
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        } else {
            player!.pause()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    @IBAction func seekForward(_ sender: AnyObject) {
        if player == nil { return }
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        if let duration = player!.currentItem?.duration {
            let playerCurrentTime = CMTimeGetSeconds(player!.currentTime())
            let newTime = playerCurrentTime + seekDurationTen
            if newTime < CMTimeGetSeconds(duration)
            {
                let selectedTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
                player!.seek(to: selectedTime)
            }
            player?.pause()
            player?.play()
        }
    }
    
}

extension AudioBookViewController {
    
    @objc func sliderValueChanged(_ slider: UISlider) {
        let seconds : Int64 = Int64(slider.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        player!.seek(to: targetTime)
        if player!.rate == 0 {
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            player?.play()
        }
    }
    
    func setupSlider() {
        slider.setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(self.finishedPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
}
