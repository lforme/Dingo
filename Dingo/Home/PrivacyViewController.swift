//
//  PrivacyViewController.swift
//  Dingo
//
//  Created by mugua on 2019/5/23.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import WebKit
import RxCocoa
import RxSwift

class PrivacyViewController: UIViewController {

    var privacyWeb: WKWebView!
    @IBOutlet weak var backButton: UIButton!
    let query = AVQuery(className: DatabaseKey.privacyTable)
    let live = LiveData(query: AVQuery(className: DatabaseKey.privacyTable))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupWebVeiw()
        queryData()
        
        live.liveDataHasChanged.observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (notification) in
            guard let block = notification else { return }
            let (_, object, _) = block
            guard let this = self else { return }
            
            guard let privacy = object as? AVObject, let isAlert = privacy.object(forKey: "isFirstShow") as? Bool, let isShowButton = privacy.object(forKey: "showIsBack") as? Bool else { return }
            
            if !isAlert {
                this.dismiss(animated: false, completion: nil)
            }
            
            this.backButton.isHidden = !isShowButton
            
        }).disposed(by: rx.disposeBag)
    }
    
    func setupWebVeiw() {
        let config = WKWebViewConfiguration()
        privacyWeb = WKWebView(frame: UIScreen.main.bounds, configuration: config)
        view.addSubview(privacyWeb)
        view.bringSubviewToFront(backButton)
    }
    
    func queryData() {

        query.findObjectsInBackground {[weak self] (objs, _) in
            guard let this = self, let objc = objs?.first as? AVObject, let showButton = objc.object(forKey: "showIsBack") as? Bool, let urlString = objc.object(forKey: "privacyWebSite") as? String else { return }
            let url = URL(string: urlString)
            this.backButton.isHidden = !showButton
            this.privacyWeb.load(URLRequest(url: url!))
        }
    }

    @IBAction func dismissTap(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
