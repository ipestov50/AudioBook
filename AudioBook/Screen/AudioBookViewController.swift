//
//  ViewController.swift
//  AudioBook
//
//  Created by Ivan Pestov on 07.12.2022.
//

import UIKit
import ComposableArchitecture
import Combine
import CoreMedia

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

    
    var service: AudioServiceProtocol = AudioService(urls: URL.urlChapter)!
    var subscriptions = Set<AnyCancellable>()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupDuration()
        setupSlider()
        bookImageView.layer.cornerRadius = 8
        speedButton.layer.cornerRadius = 8
        
    }
    
    func setupDuration() {
        service.statePublisher.sink { [self] state in
            audioDurationLabel.text = "".stringFromTimeInterval(interval: state!.totalDuration)
            currentTimeLabel.text = "".stringFromTimeInterval(interval: state!.progress)
            slider.minimumValue = 0
            slider.maximumValue = Float(state!.totalDuration)
            slider.value = Float(state!.progress)
            slider.isContinuous = true
        }.store(in: &subscriptions)
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        service.play()
        switch service.stateValue!.isPlaying {
        case true:
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        default:
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    @IBAction func speedButtonTapped() {
        service.setSpeed()
        speedButton.setTitle("Speed \(service.stateValue!.rate)", for: .normal)
        
    }
    
    @IBAction func forwardEndButtonTapped() {
        service.playNext()
        service.statePublisher.sink { [self] state in
            keypointLabel.text = "KEY POINT \(state!.playerIndex+1) OF 3"
        }.store(in: &subscriptions)
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }
    
    @IBAction func backwardEndButtonTapped() {
        service.playPrevious()
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
        service.controlSliderValue {
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
        
        
//        let seconds: Int64 = Int64(slider.value)
//        let targetTime: CMTime = CMTimeMakeWithSeconds(Float64(seconds), preferredTimescale: 1)
//        service.player.seek(to: targetTime)
//        
//        if service.player.rate == 0 {
//            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
//            service.player.play()
//        }
    }
    
    @objc func finishedPlaying(_ myNotification: NSNotification) {
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
    
    func setupSlider() {
        slider.setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }
}
