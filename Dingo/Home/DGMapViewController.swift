//
//  DGMapViewController.swift
//  Dingo
//
//  Created by mugua on 2019/5/16.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class DGMapViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var mapView: MAMapView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var searchTextfield: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var city: String!
    
    var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, DGMapModel>>!
    var sections: Driver<[SectionModel<String, DGMapModel>]>!
    var vm: DGMapViewViewModel!
    
    var saveBlock: ((DGMapViewViewModel.LocationResul) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vm = DGMapViewViewModel(city: city)
        
        interactiveNavigationBarHidden = true
        setupUI()
        setupTaps()
        setupMap()
        setupRx()
    }
    
    func setupRx() {
        vm.touchLoctionObservable.map { $0?.name }.bind(to: searchTextfield.rx.text).disposed(by: rx.disposeBag)
        
        dataSource = RxTableViewSectionedReloadDataSource(configureCell: { (ds, tv, ip, item) -> UITableViewCell in
            let cell = tv.dequeueReusableCell(withIdentifier: "UITableViewCell", for: ip)
            cell.textLabel?.text = item.name
            return cell
        })
        
        sections = vm.models.asObservable().map({ (ms) -> [SectionModel<String, DGMapModel>] in
            return [SectionModel(model: "搜索结果", items: ms)]
        }).asDriver(onErrorJustReturn: [])
        
        sections.drive(tableView.rx.items(dataSource: dataSource)).disposed(by: rx.disposeBag)
        
        searchTextfield.rx.text.orEmpty.distinctUntilChanged(){ $0 }.throttle(.seconds(2), scheduler: MainScheduler.instance).bind(to: vm.searchTextObservable).disposed(by: rx.disposeBag)
        
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(DGMapModel.self)) { (a, b) -> (IndexPath, DGMapModel) in
            
            return (a, b)
            }.observeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] (tuple) in
                self?.searchTextfield.text = tuple.1.name
                let t = (tuple.1.location, tuple.1.name)
                self?.saveBlock?(t)
                
            }).disposed(by: rx.disposeBag)
    }
    
    func setupTaps() {
        backButton.rx.tap.subscribe(onNext: {[weak self] (_) in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: rx.disposeBag)
        
        saveButton.rx.tap.subscribe(onNext: {[weak self] (_) in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        searchTextfield.delegate = self
    }
    
    
    func setupMap() {
        
        mapView.delegate = vm
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
        mapView.isScrollEnabled = true
        
        let dot = MAUserLocationRepresentation()
        dot.locationDotBgColor = UIColor.white
        dot.locationDotFillColor = LaunchThemeManager.currentTheme().mainColor
        dot.lineWidth = 2
        mapView.update(dot)
        
        mapView.bringSubviewToFront(backButton)
        mapView.bringSubviewToFront(saveButton)
        mapView.bringSubviewToFront(searchTextfield)
    }
}


extension DGMapViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        mapView.sendSubviewToBack(tableView)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        mapView.bringSubviewToFront(tableView)
    }
}
