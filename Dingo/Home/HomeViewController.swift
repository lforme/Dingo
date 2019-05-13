//
//  HomeViewController.swift
//  Dingo
//
//  Created by mugua on 2019/5/8.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import IGListKit

class HomeViewController: UIViewController {
    
    let collectionView: ListCollectionView = {
        let layout = ListCollectionViewLayout(stickyHeaders: true, scrollDirection: .vertical, topContentInset: 0, stretchToEdge: false)
        let view = ListCollectionView(frame: .zero, listCollectionViewLayout: layout)
        return view
    }()
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    var serverData: [ServiceModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "日常任务"
        LaunchThemeManager.changeStatusBarStyle(.default)
        setupCollectionView()
        fetchAllServer()
    }
    
    func fetchAllServer() {
        ServiceModel.fetchServerModels().drive(onNext: {[weak self] (models) in
            if let ms = models {
                self?.serverData = ms
                self?.adapter.reloadData(completion: nil)
            }
        }).disposed(by: rx.disposeBag)
    }
    
    func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.backgroundColor = UIColor.white
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
}

extension HomeViewController: ListAdapterDataSource {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return serverData
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return SeverSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

