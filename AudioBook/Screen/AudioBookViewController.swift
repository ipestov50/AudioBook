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
    
    let audiobookService = AudioBookService(chapters: AudioBookChapter.chapters)
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupDuration()
        //        setupUIButton()
        setupSlider()
        bookImageView.layer.cornerRadius = 8
        speedButton.layer.cornerRadius = 8
        playButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupDuration() {
        guard let audiobookService = audiobookService else { return }
        slider.minimumValue = 0
        audioDurationLabel.text = "".stringFromTimeInterval(interval: audiobookService.seconds)
        currentTimeLabel.text = "".stringFromTimeInterval(interval: audiobookService.currentSeconds)
        slider.maximumValue = Float(audiobookService.seconds)
        slider.isContinuous = true
        
        audiobookService.player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (CMTime) in
            if audiobookService.player.currentItem?.status == .readyToPlay {
                let time: Float64 = CMTimeGetSeconds(audiobookService.player.currentTime())
                self.slider.value = Float(time)
                self.currentTimeLabel.text = "".stringFromTimeInterval(interval: time)
            }
            
            let playbackLikelyToKeepUp = audiobookService.player.currentItem?.isPlaybackLikelyToKeepUp
            if playbackLikelyToKeepUp == false {
                print("IsBuffering")
            } else {
                self.playButton.isHidden = false
            }
        }
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        guard let audiobookService = audiobookService else { return }
        if audiobookService.player.rate == 0 {
            audiobookService.player.play()
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        } else {
            audiobookService.player.pause()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    @IBAction func speedButtonTapped() {
        guard let audiobookService = audiobookService else { return }
        
        switch audiobookService.player.rate {
        case 1..<2:
            audiobookService.player.rate += 0.25
            speedButton.setTitle("Speed \(audiobookService.player.rate)x", for: .normal)
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        case 2:
            audiobookService.player.rate = 0.25
            speedButton.setTitle("Speed \(audiobookService.player.rate)x", for: .normal)
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        default:
            audiobookService.player.rate += 0.25
            speedButton.setTitle("Speed \(audiobookService.player.rate)x", for: .normal)
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }
    
    @IBAction func forwardEndButtonTapped() {
        guard let audiobookService = audiobookService else { return }
        audiobookService.playNext()
        keypointLabel.text = "KEY POINT \(audiobookService.playerIndex+1) OF 3"
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        let duration = audiobookService.player.currentItem!.asset.duration
        let seconds: Float64 = CMTimeGetSeconds(duration)
        audioDurationLabel.text = "".stringFromTimeInterval(interval: seconds)
        slider.maximumValue = Float(seconds)
        slider.isContinuous = true
        
        audiobookService.timeObserve {
            self.slider.value = Float(audiobookService.time)
            self.currentTimeLabel.text = "".stringFromTimeInterval(interval: audiobookService.time)
        }
    }
    
    @IBAction func backwardEndButtonTapped() {
        guard let audiobookService = audiobookService else { return }
        audiobookService.playPrevious()
        
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        keypointLabel.text = "KEY POINT \(audiobookService.playerIndex+1) OF 3"
        let duration = audiobookService.player.currentItem!.asset.duration
        let seconds: Float64 = CMTimeGetSeconds(duration)
        audioDurationLabel.text = "".stringFromTimeInterval(interval: seconds)
        slider.maximumValue = Float(seconds)
        slider.isContinuous = true
        
        audiobookService.timeObserve {
            self.slider.value = Float(audiobookService.time)
            self.currentTimeLabel.text = "".stringFromTimeInterval(interval: audiobookService.time)
        }
        audiobookService.removeTimeObserver()
        
    }
    
    @IBAction func seekBackWards(_ sender: AnyObject) {
        audiobookService?.rewind()
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }
    
    @IBAction func seekForward(_ sender: AnyObject) {
        audiobookService?.fastForward()
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }
    
    @objc func sliderValueChanged(_ slider: UISlider) {
        guard let audiobookService = audiobookService else { return }
        let seconds : Int64 = Int64(slider.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        audiobookService.player.seek(to: targetTime)
        if audiobookService.player.rate == 0 {
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            audiobookService.player.play()
        }
    }
    
    @objc func finishedPlaying(_ myNotification: NSNotification) {
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
    
    func setupSlider() {
        slider.setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(self.finishedPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: audiobookService?.playerItem)
    }
}

