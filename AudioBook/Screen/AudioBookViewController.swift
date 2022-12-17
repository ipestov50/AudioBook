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
        playButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupDuration() {
        service.statePublisher.sink { [self] state in
            audioDurationLabel.text = "".stringFromTimeInterval(interval: state!.totalDuration)
            slider.minimumValue = 0
            slider.maximumValue = Float(state!.totalDuration)
            slider.value = Float(state!.progress)
            currentTimeLabel.text = "".stringFromTimeInterval(interval: state!.progress)
            slider.isContinuous = true
            currentTimeLabel.text = "".stringFromTimeInterval(interval: state!.progress)
        }.store(in: &subscriptions)
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        service.play()
        service.statePublisher.sink { [self] state in
            switch state?.isPlaying {
            case true:
                playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            default:
                playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            }
        }.store(in: &subscriptions)
    }
    
    @IBAction func speedButtonTapped() {
        service.setSpeed()
        service.statePublisher.sink { [self] state in
            speedButton.setTitle("Speed \(state!.rate)x", for: .normal)
            print(state?.rate)
        }.store(in: &subscriptions)
    }
    
    @IBAction func forwardEndButtonTapped() {
        service.playNext()
        service.statePublisher.sink { [self] state in
            keypointLabel.text = "KEY POINT \(state!.playerIndex+1) OF 3"
        }.store(in: &subscriptions)
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
        let seconds: Int64 = Int64(slider.value)
        let targetTime: CMTime = CMTimeMakeWithSeconds(Float64(seconds), preferredTimescale: 1)
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
