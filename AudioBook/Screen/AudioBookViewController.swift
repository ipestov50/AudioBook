//
//  ViewController.swift
//  AudioBook
//
//  Created by Ivan Pestov on 07.12.2022.
//

import UIKit

import ComposableArchitecture
import Combine

import UIKit
//import AVFoundation
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
    
    let string = [URL(string: "")!]
    
    private let stateSubject = CurrentValueSubject<PlayerState?, Never>(nil)
    
    var stateValue: PlayerState? {
        stateSubject.value
    }
    
    var service: AudioServiceProtocol = AudioService(urls: URL.urlChapter)!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        service.statePublisher.sink { state in
            slider.minimumValue = 0
            audioDurationLabel.text = "".stringFromTimeInterval(interval: service.stateValue?.duration)
            currentTimeLabel.text = "".stringFromTimeInterval(interval: service.statePublisher.currentSeconds)
            slider.maximumValue = Float(service.statePublisher.seconds)
            slider.isContinuous = true
            if service.statePublisher.player.currentItem?.status == .readyToPlay {
                let time: Float64 = service.stateValue?.progress
                self.slider.value = Float(time)
                self.currentTimeLabel.text = "".stringFromTimeInterval(interval: time)
            }
            
            let playbackLikelyToKeepUp = service.player.currentItem?.isPlaybackLikelyToKeepUp
            if playbackLikelyToKeepUp == false {
                print("IsBuffering")
            } else {
                self.playButton.isHidden = false
            }
        }
        .store(in: &stateSubject)
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        
        if service.player.rate == 0 {
            service.player.play()
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        } else {
            service.player.pause()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    @IBAction func speedButtonTapped() {
//        guard let audiobookService = audiobookService else { return }
        switch service.stateValue!.rate {
        case 1..<2:
            stateSubject.value?.rate += 0.25
            speedButton.setTitle("Speed \(stateSubject.value!.rate)x", for: .normal)
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        case 2:
            stateSubject.value?.rate = 0.25
            speedButton.setTitle("Speed \(stateSubject.value!.rate)x", for: .normal)
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        default:
            stateSubject.value?.rate += 0.25
            speedButton.setTitle("Speed \(stateSubject.value!.rate)x", for: .normal)
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }
    
    @IBAction func forwardEndButtonTapped() {
//        guard let audiobookService = audiobookService else { return }
        service.playNext()
        
        keypointLabel.text = "KEY POINT \(service.stateValue!.playerIndex+1) OF 3"
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        audioDurationLabel.text = "".stringFromTimeInterval(interval: TimeInterval(service.stateValue!.progress))
        slider.maximumValue = Float(service.stateValue!.duration)
        slider.isContinuous = true
        
        service.timeObserve { [self] in
            self.slider.value = Float(stateSubject.value!.time)
            self.currentTimeLabel.text = "".stringFromTimeInterval(interval: stateSubject.value!.time)
        }
    }
    
    @IBAction func backwardEndButtonTapped() {
//        guard let audiobookService = audiobookService else { return }
        service.playPrevious()
        
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        keypointLabel.text = "KEY POINT \(stateSubject.value!.playerIndex+1) OF 3"
//        let duration = audiobookService.player.currentItem!.asset.duration
//        let seconds: Float64 = CMTimeGetSeconds(duration)
//        audioDurationLabel.text = "".stringFromTimeInterval(interval: seconds)
//        slider.maximumValue = Float(seconds)
        slider.isContinuous = true
        
        service.timeObserve { [self] in
            self.slider.value = Float(stateSubject.value!.time)
//            self.currentTimeLabel.text = "".stringFromTimeInterval(interval: audiobookService.time)
        }
        service.removeTimeObserver()
        
    }
    
    @IBAction func seekBackWards(_ sender: AnyObject) {
        service.rewind()
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }
    
    @IBAction func seekForward(_ sender: AnyObject) {
        service.fastForward()
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }
    
    @objc func sliderValueChanged(_ slider: UISlider) {
//        guard let audiobookService = audiobookService else { return }
//        let seconds : Int64 = Int64(slider.value)
//        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
//        service.player.seek(to: targetTime)
        if service.player.rate == 0 {
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            service.player.play()
        }
    }
    
    @objc func finishedPlaying(_ myNotification: NSNotification) {
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
    
    func setupSlider() {
        slider.setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.finishedPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: service.playerItem)
    }
}
