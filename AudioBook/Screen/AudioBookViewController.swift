//
//  ViewController.swift
//  AudioBook
//
//  Created by Ivan Pestov on 07.12.2022.
//

import UIKit
import ComposableArchitecture
import Combine

class AudioBookViewController: UIViewController {
    // FIXME: - Если это убрать - не работает, как по другому сделать - ХЗ
    var viewStore: ViewStoreOf<Feature> = .init(.init(initialState: Feature.State(), reducer: Feature()))
    var subscriptions = Set<AnyCancellable>()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDuration()
        setupSlider()
        bookImageView.layer.cornerRadius = 8
        speedButton.layer.cornerRadius = 8

        // TODO: - Вообще ХЗ, правильно ли вешать слушателей в этом методе, можно попробовать в init()

        viewStore.publisher
            .map({ "\($0)" })
            .sink(receiveValue: { print("Receive value", $0) })
            .store(in: &subscriptions)

        viewStore.publisher
            .map { return String().stringFromTimeInterval(interval: $0.player.totalDuration) }
            .assign(to: \.text, on: audioDurationLabel)
            .store(in: &subscriptions)

        viewStore.publisher
            .map { return String().stringFromTimeInterval(interval: $0.player.progress) }
            .assign(to: \.text, on: currentTimeLabel)
            .store(in: &subscriptions)
    }
    
    func setupDuration() {
        viewStore.send(.setupDuration)

//        viewStore.publisher
//            .sink { [self] state in
//                audioDurationLabel.text = "".stringFromTimeInterval(interval: state.player.totalDuration)
//                currentTimeLabel.text = "".stringFromTimeInterval(interval: state.player.progress)
//                slider.minimumValue = 0
//                slider.maximumValue = Float(state.player.totalDuration)
//                slider.value = Float(state.player.progress)
//                slider.isContinuous = true
//            }.store(in: &subscriptions)
        
//        service.statePublisher.sink { [self] state in
//            audioDurationLabel.text = "".stringFromTimeInterval(interval: state!.totalDuration)
//            currentTimeLabel.text = "".stringFromTimeInterval(interval: state!.progress)
//            slider.minimumValue = 0
//            slider.maximumValue = Float(state!.totalDuration)
//            slider.value = Float(state!.progress)
//            slider.isContinuous = true
//        }.store(in: &subscriptions)
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        viewStore.send(.play)
        
        switch viewStore.player.isPlaying {
        case true:
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        default:
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
        
    }
    
    @IBAction func speedButtonTapped() {
        viewStore.send(.changeSpeed)
        
        speedButton.setTitle("Speed \(viewStore.player.rate)", for: .normal)
    }
    
    @IBAction func forwardEndButtonTapped() {
        viewStore.send(.playNext)
        
        keypointLabel.text = "KEY POINT \(viewStore.player.chapterIndex+1) OF 3"
        audioDurationLabel.text = "".stringFromTimeInterval(interval: viewStore.player.totalDuration)
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }
    
    @IBAction func backwardEndButtonTapped() {
        viewStore.send(.playPrevious)
        
        keypointLabel.text = "KEY POINT \(viewStore.player.chapterIndex+1) OF 3"
        audioDurationLabel.text = "".stringFromTimeInterval(interval: viewStore.player.totalDuration)
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        
    }
    
    @IBAction func seekBackWards(_ sender: AnyObject) {
        viewStore.send(.rewind)
        
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }
    
    @IBAction func seekForward(_ sender: AnyObject) {
        viewStore.send(.goForward)
        
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }
    
    @objc func sliderValueChanged(_ slider: UISlider) {
//        service.controlSliderValue {
//            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
//        }
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

