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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "新任务"
        setupUI()
        setupLabel()
        setupMap()
        setupTaps()
    }
    
    func setupMap() {
        
        mapView.delegate = self
        let url = Bundle.main.url(forResource: "style", withExtension: "data")
        let jsonData = try! Data(contentsOf: url!)
        let url2 = Bundle.main.url(forResource: "style_extra", withExtension: "data")
        let jsonData2 = try! Data(contentsOf: url2!)
        let options = MAMapCustomStyleOptions()
        options.styleId = "7e391a8130f8226809032604ae64a687"
        options.styleData = jsonData
        options.styleExtraData = jsonData2
        mapView.setCustomMapStyleOptions(options)
        mapView.customMapStyleEnabled = true
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.desiredAccuracy = 1000
        mapView.zoomLevel = 14
        mapView.isScrollEnabled = false
        mapView.clipsToBounds = true
        mapView.layer.cornerRadius = 8
        mapView.layer.borderWidth = 3
        mapView.layer.borderColor = UIColor.white.cgColor
        let dot = MAUserLocationRepresentation()
        dot.locationDotBgColor = UIColor.white
        dot.locationDotFillColor = LaunchThemeManager.currentTheme().mainColor
        dot.lineWidth = 2
        mapView.update(dot)
    }
    
    func setupUI() {
        topBgView.roundCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 8)
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
            let mapVC: DGMapViewController = ViewLoader.Storyboard.controller(from: "Home")
            
            self?.navigationController?.pushViewController(mapVC, animated: true)
            
        }).disposed(by: rx.disposeBag)
    }
}

extension LocationTaskSettingController: MAMapViewDelegate {
    
}
