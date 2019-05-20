//
//  TaskDetailOfSoundController.swift
//  Dingo
//
//  Created by mugua on 2019/5/20.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import PKHUD

class TaskDetailOfSoundController: UITableViewController {
    
    var task: TaskModel!
    
    @IBOutlet weak var audioAnimationView: SpectrumView!
    @IBOutlet weak var audioRemarkName: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    var player: AudioSpectrumPlayer!
    
    override func viewWillAppear(_ animated: Bool) {
        LaunchThemeManager.changeStatusBarStyle(.lightContent)
        self.navigationController?.navigationBar.barTintColor = LaunchThemeManager.currentTheme().textBlackColor
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        LaunchThemeManager.changeStatusBarStyle(.default)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        player.stop()
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = LaunchThemeManager.currentTheme().textBlackColor
        tableView.tableFooterView = UIView(frame: .zero)
        
        bindData()
        setupPlayer()
        setupButtons()
    }
    
    func setupButtons() {
        let disableColor = UIColor.white.withAlphaComponent(0.2)
        pauseButton.setBackgroundImage(UIImage(named: "pause_icon")!.filled(withColor: disableColor), for: UIControl.State.disabled)
        playButton.setBackgroundImage(UIImage(named: "play_icon")!.filled(withColor: disableColor), for: UIControl.State.disabled)
        deleteButton.setBackgroundImage(UIImage(named: "delete_icon")!.filled(withColor: disableColor), for: UIControl.State.disabled)
    }
    
    func setupPlayer() {
        player = AudioSpectrumPlayer()
        player.delegate = self
    }
    
    func bindData() {
        guard let secondType = MakeSoundViewController.MakeSoundType(rawValue: task.functionType), let name = task.remindDate else { return }
        var secoundStr: String
        switch secondType {
        case .fiveSecond:
            secoundStr = "  (5秒)"
        case .tenSecond:
            secoundStr = "  (10秒)"
        case .fifteenSecond:
            secoundStr = "  (15秒)"
        }
        audioRemarkName.text = name + secoundStr
    }
    
    
    @IBAction func pasueTap(_ sender: UIButton) {
        player.stop()
    }
    
    @IBAction func playTap(_ sender: UIButton) {
        guard let fileName = task.remindDate else { return }
        player.play(withFileName: fileName)
        playButton.isEnabled = false
        deleteButton.isEnabled = false
    }
    
    @IBAction func deleteTap(_ sender: UIButton) {
        self.showActionSheet(title: nil, message: "确定要删除吗?", buttonTitles: ["删除", "取消"], highlightedButtonIndex: 1) {[weak self] (index) in
            if index == 0 {
                self?.deleteAction()
            }
        }
    }
    
    
    private func deleteAction() {
        AVQuery.doCloudQueryInBackground(withCQL: "delete from \(DatabaseKey.taskTable) where objectId='\(task.objcId!)'", callback: {[weak self] (_, error) in
            if let e = error {
                HUD.flash(.label(e.localizedDescription), delay: 2)
            } else {
                self?.deleteLocationSoundFile()
                
                self?.navigationController?.popViewController(animated: true)
                
                NotificationCenter.default.post(name: .refreshState, object: nil)
            }
        })
    }
    
    private func getFileURL(remarks: String) -> URL {
        let temp = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
        let path = temp[0].appendingPathComponent("\(remarks).m4a")
        return path as URL
    }
    
    private func deleteLocationSoundFile() {
        let fileManager = FileManager.default
        guard let name = task.remindDate else {
            return
        }
        let fileUrl = getFileURL(remarks: name)
        do {
            try fileManager.removeItem(at: fileUrl)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}


extension TaskDetailOfSoundController: AudioSpectrumPlayerDelegate {
    func player(_ playFinished: Bool) {
        DispatchQueue.main.async {[weak self] in
            self?.playButton.isEnabled = playFinished
            self?.deleteButton.isEnabled = playFinished
        }
    }
    
    func player(_ player: AudioSpectrumPlayer, didGenerateSpectrum spectra: [[Float]]) {
        
        DispatchQueue.main.async {[weak self] in
            self?.audioAnimationView.spectra = spectra
        }
    }
}
