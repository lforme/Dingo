//
//  LocationTaskSettingController.swift
//  Dingo
//
//  Created by mugua on 2019/5/16.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import AMapSearchKit
import RxCocoa
import RxSwift
import PKHUD


class LocationTaskSettingController: UITableViewController {
    
    enum LocationType: Int {
        case enter = 0
        case exit
        case enterAndExit
    }
    
    var funcNameText: String?
    var funcDescribeText: String?
    var locationType: LocationType!
    
    @IBOutlet weak var funcationNameLabel: UILabel!
    @IBOutlet weak var functionDescrip: UILabel!
    @IBOutlet weak var topBgView: UIView!
    @IBOutlet weak var searchButton: UIControl!
    @IBOutlet weak var mapView: MAMapView!
    @IBOutlet weak var createdButton: UIButton!
    @IBOutlet weak var bottomBgView: UIView!
    @IBOutlet weak var searchResultLabel: UILabel!
    
    var vm: LocationTaskSettingViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let userId = AVUser.current()?.objectId else {
            DGNotiBanner.shareInstance.show(title: "用户登录失效", subtitle: nil, style: .warning, completion: nil)
            return
        }
        vm = LocationTaskSettingViewModel(userId: userId, type: locationType)
        title = "新任务"
        setupUI()
        setupLabel()
        setupMap()
        setupTaps()
        setupRx()
    }
    
    func setupRx() {
        vm.locationObservale.map { $0?.name }.bind(to: searchResultLabel.rx.text).disposed(by: rx.disposeBag)
        
        createdButton.rx.bind(to: vm.action) {[unowned self] (_) -> LocationTaskSettingViewModel.Inptu in
            return (self.vm.locationObservale.value!.location, self.vm.locationObservale.value!.name)
        }
        
        vm.action.elements.subscribe(onNext: {[unowned self] (_) in
            HUD.flash(.label("设置成功"), delay: 2)
            self.navigationController?.popToRootViewController(animated: true)
            NotificationCenter.default.post(name: .refreshState, object: nil)
        }).disposed(by: rx.disposeBag)
        
        vm.action.executing.asObservable().bind(to: PKHUD.sharedHUD.rx.animation).disposed(by: rx.disposeBag)
        vm.action.errors.actionErrorShiftError().bind(to: PKHUD.sharedHUD.rx.showError).disposed(by: rx.disposeBag)
    }
    
    func setupMap() {
        
        let url = Bundle.main.url(forResource: "style", withExtension: "data")
        let jsonData = try! Data(contentsOf: url!)
        let url2 = Bundle.main.url(forResource: "style_extra", withExtension: "data")
        let jsonData2 = try! Data(contentsOf: url2!)
        let options = MAMapCustomStyleOptions()
        options.styleData = jsonData
        options.styleExtraData = jsonData2
        mapView.setCustomMapStyleOptions(options)
        mapView.customMapStyleEnabled = true
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.desiredAccuracy = 1000
        mapView.zoomLevel = 14
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        mapView.isRotateCameraEnabled = false
        mapView.clipsToBounds = true
        mapView.layer.cornerRadius = 8
        mapView.layer.borderWidth = 3
        mapView.layer.borderColor = UIColor.white.cgColor
        let dot = MAUserLocationRepresentation()
        dot.locationDotBgColor = UIColor.white
        dot.locationDotFillColor = LaunchThemeManager.currentTheme().mainColor
        dot.lineWidth = 2
        mapView.update(dot)
        
        mapView.delegate = vm
    }
    
    func setupUI() {
        topBgView.roundCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 8)
        bottomBgView.roundCorners([.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 8)
        searchButton.clipsToBounds = true
        searchButton.layer.cornerRadius = 8
        
        let image = UIImage.from(color: createdButton.backgroundColor ?? UIColor.white)
        createdButton.dgSetBackgroundImage(image)
        createdButton.setupDgStyle()
    }
    
    func setupLabel() {
        funcationNameLabel.text = funcNameText
        functionDescrip.text = funcDescribeText
    }
    
    func setupTaps() {
        
        searchButton.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] (_) in
            guard let this = self else { return }
            let mapVC: DGMapViewController = ViewLoader.Storyboard.controller(from: "Home")
            
            if let c = this.vm.currentCity.value {
                mapVC.city = c
            }
            
            mapVC.saveBlock = { (tuple) in
                this.vm.locationObservale.accept(tuple)
            }
            
            this.navigationController?.pushViewController(mapVC, animated: true)
            
        }).disposed(by: rx.disposeBag)
    }
}

