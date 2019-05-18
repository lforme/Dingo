//
//  MakeSoundViewController.swift
//  Dingo
//
//  Created by mugua on 2019/5/18.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import AVFoundation
import RxCocoa
import RxSwift
import Action
import PKHUD

class MakeSoundViewController: UITableViewController {
    
    enum MakeSoundType: Int {
        case fiveSecond = 0
        case tenSecond
        case fifteenSecond
    }
    
    var addType: AddAppletType!
    var type: MakeSoundType!
    let recordingSession = AVAudioSession.sharedInstance()
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var textfield: UITextField!
    let remarkObserver = BehaviorRelay<String?>(value: nil)
    let totalCount = BehaviorRelay<Int>(value: 0)
    var action: Action<String, Int>!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = LaunchThemeManager.currentTheme().textBlackColor
        setupUI()
        setupRecordingSession()
        setupRx()
        
    }
    
    func setupRx() {
        
        textfield.rx.text.orEmpty.distinctUntilChanged(){ $0 }.bind(to: remarkObserver).disposed(by: rx.disposeBag)
        
        let enbale = remarkObserver.map { $0.isNotNilNotEmpty }
        
        action = Action<String, Int>(enabledIf: enbale, workFactory: {[unowned self] (fileName) -> Observable<Int> in
            
            self.startRecording()
            return self.count(from: self.totalCount.value, to: 0, quickStart: false)
        })
        
        recordButton.rx.bind(to: action) {[unowned self] (_) -> String in
            
            return self.remarkObserver.value!
        }
        
        action.errors.actionErrorShiftError().bind(to: PKHUD.sharedHUD.rx.showError).disposed(by: rx.disposeBag)
        
        action.elements.map { (countDonw) -> String in
            return "正在录音...\n剩余\(String(countDonw))秒"
            }.bind(to: countDownLabel.rx.text).disposed(by: rx.disposeBag)
        
        action.completions.subscribe(onNext: {[unowned self] (_) in
            self.countDownLabel.text = "录制完成"
            self.finishRecording(success: true)
        }).disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        
        let disableColor = UIColor.white.withAlphaComponent(0.4)
        let buttonImage = UIImage(named: "record_mic_icon")
        recordButton.setImage(buttonImage, for: .normal)
        recordButton.setImage(buttonImage!.filled(withColor: disableColor), for: .disabled)
        playButton.isHidden = true
        
        guard let t = type else {
            return
        }
        switch t {
        case .fiveSecond:
            title = "录制5秒"
            totalCount.accept(5)
        case .tenSecond:
            title = "录制10秒"
            totalCount.accept(10)
        case .fifteenSecond:
            title = "录制15秒"
            totalCount.accept(15)
        }
    }
    
    func count(from: Int, to: Int, quickStart: Bool) -> Observable<Int> {
        let total = quickStart ? 0 : 1
        
        return Observable<Int>
            .timer(.seconds(total), period: .seconds(1), scheduler: MainScheduler.instance)
            .take(from - to + 1)
            .map { from - $0 }
    }
    
    
    @IBAction func playTap(_ sender: UIButton) {
        play()
    }
    
    
    func createdTaskSaveCloud() {
        guard let userId = AVUser.current()?.objectId, let name = AVUser.current()?.username else { return }
        
        let content = "自定义提醒铃声:\n\(self.remarkObserver.value!)"
        let task = TaskModel(userId: userId, name: name, usedCount: 0, icon: "make_noti_sound_icon", color: 1, repeat: false, taskType: self.addType.rawValue, remindDate: content, remindLocal: nil, id: nil, functionType: self.type.rawValue)
        task.saveToLeanCloud().subscribe().disposed(by: rx.disposeBag)
        NotificationCenter.default.post(name: .refreshState, object: nil)
    }
}

extension MakeSoundViewController {
    
    func setupRecordingSession() {
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            
            recordingSession.requestRecordPermission { (allowed) in
                if !allowed {
                    print("不同意访问麦克风")
                }
            }
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func startRecording() {
        let audioFilename = getFileURL(remarks: remarkObserver.value!)
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVLinearPCMBitDepthKey: 32,
            AVEncoderBitRateKey: 128000,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
        } catch let error {
            print(error.localizedDescription)
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        playButton.isHidden = !success
        if success {
            createdTaskSaveCloud()
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func getFileURL(remarks: String) -> URL {
        let path = getDocumentsDirectory().appendingPathComponent("\(remarks).m4a")
        return path as URL
    }
    
    func play() {
        var error: NSError?
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: getFileURL(remarks: self.remarkObserver.value!) as URL)
        } catch let error1 as NSError {
            error = error1
            audioPlayer = nil
        }
        if let err = error {
            print("AVAudioPlayer error: \(err.localizedDescription)")
        } else {
            audioPlayer.delegate = self 
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 10.0
            audioPlayer.play()
        }
    }
}


extension MakeSoundViewController: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        
    }
}


extension MakeSoundViewController: AVAudioPlayerDelegate {
    
}
