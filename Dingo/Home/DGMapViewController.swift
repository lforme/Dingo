//
//  DGMapViewController.swift
//  Dingo
//
//  Created by mugua on 2019/5/16.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit

class DGMapViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var mapView: MAMapView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var searchTextfield: UITextField!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LaunchThemeManager.changeStatusBarStyle(.lightContent)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        LaunchThemeManager.changeStatusBarStyle(.default)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interactiveNavigationBarHidden = true
        setupUI()
        setupTaps()
        setupMap()
    }
    
    func setupTaps() {
        backButton.rx.tap.subscribe(onNext: {[weak self] (_) in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        mapView.bringSubviewToFront(backButton)
        mapView.bringSubviewToFront(saveButton)
        mapView.bringSubviewToFront(searchTextfield)
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
        mapView.isScrollEnabled = true
        let dot = MAUserLocationRepresentation()
        dot.locationDotBgColor = UIColor.white
        dot.locationDotFillColor = LaunchThemeManager.currentTheme().mainColor
        dot.lineWidth = 2
        mapView.update(dot)
    }
}


extension DGMapViewController: MAMapViewDelegate {
    
    func mapViewWillStartLoadingMap(_ mapView: MAMapView!) {
        
    }
    
    func mapView(_ mapView: MAMapView!, didAnnotationViewTapped view: MAAnnotationView!) {
        
    }
    
    func mapView(_ mapView: MAMapView!, didAnnotationViewCalloutTapped view: MAAnnotationView!) {
        
    }
    
    func mapView(_ mapView: MAMapView!, didTouchPois pois: [Any]!) {
        
    }
}
