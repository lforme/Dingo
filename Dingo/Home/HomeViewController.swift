//
//  HomeViewController.swift
//  Dingo
//
//  Created by mugua on 2019/5/8.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import IGListKit
import MJRefresh
import RxCocoa
import RxSwift

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
    var serverTaskData: [TaskModel] = []
    let notiHeaderData: [String] = ["提醒列表"]
    private var page = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "日常任务"
        LaunchThemeManager.changeStatusBarStyle(.default)
        setupCollectionView()
        fetchAllServer()
        
        NotificationCenter.default.rx.notification(.refreshState)
            .takeUntil(rx.deallocated)
            .observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (_) in
                self?.collectionView.mj_header.beginRefreshing()
            }).disposed(by: rx.disposeBag)
    }
    
    func fetchAllServer() {
        guard let userId = AVUser.current()?.objectId else {
            return
        }
        ServiceModel.fetchServerModels().drive(onNext: {[weak self] (models) in
            if let ms = models {
                self?.serverData = ms
                self?.adapter.reloadData(completion: nil)
            }
        }).disposed(by: rx.disposeBag)
        
        
        TaskModel.fetchServerModels(by: userId).drive(onNext: {[weak self] (models) in
            self?.serverTaskData = models
            self?.adapter.reloadData(completion: nil)
        }).disposed(by: rx.disposeBag)
        
    }
    
    func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.backgroundColor = UIColor.white
        adapter.collectionView = collectionView
        adapter.dataSource = self
        
        guard let userId = AVUser.current()?.objectId else {
            return
        }
        
        self.collectionView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[unowned self] in
            TaskModel.fetchServerModels(by: userId, page: 0).drive(onNext: {[weak self] (models) in
                self?.collectionView.mj_header.endRefreshing()
                self?.page = 0
                self?.serverTaskData = models
                self?.adapter.reloadData(completion: nil)
                
            }).disposed(by: self.rx.disposeBag)
        })
        
        self.collectionView.mj_footer = MJRefreshAutoNormalFooter.init(refreshingBlock: {
            self.page += 1
            TaskModel.fetchServerModels(by: userId, page: self.page).drive(onNext: {[weak self] (models) in
                self?.serverTaskData += models
                if models.count == 0 {
                    self?.collectionView.mj_footer.endRefreshingWithNoMoreData()
                } else {
                    self?.collectionView.mj_footer.endRefreshing()
                }
                self?.adapter.reloadData(completion: nil)
            }).disposed(by: self.rx.disposeBag)
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
}

extension HomeViewController: ListAdapterDataSource {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        let notiHeader = notiHeaderData as [ListDiffable]
        
        return serverData + notiHeader + serverTaskData
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        
        if object is ServiceModel {
            return SeverSectionController()
        }
        if object is String {
            return TaskHeaderSectionController()
        }
        if object is TaskModel {
            return TaskSectionController()
        }
        fatalError()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}
