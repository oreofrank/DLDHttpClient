//
//  HttpCache.swift
//  Duliday
//
//  Created by liaohai on 2018/1/23.
//  Copyright © 2018年 Duliday. All rights reserved.
//

import Foundation

let UpdateWindow:UIWindow = UIWindow.init(frame: UIScreen.main.bounds)
let UpdateVC = ForceUpdateViewController()

class HttpQueryUnmind {
    
    class func commend(data: Any?) -> Bool {
        guard let dic = data as? NSDictionary  else {
            return false
        }
        if let statusCode = dic["code"] as? Int {
            // 强制更新
            if statusCode == updateCode {
                let message = dic["message"] as! String
                UpdateVC.view.backgroundColor = UIColor.clear
                UpdateVC.message = message
                UpdateWindow.rootViewController = UpdateVC
                UpdateWindow.makeKeyAndVisible()
                UpdateWindow.backgroundColor = UIColor.clear
                return true
            }
        }
        return false
    }
    
}

class ForceUpdateViewController:UIViewController {
    var message:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ForceUpdateViewController.applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.showAlertController()
    }
    
    @objc func applicationDidBecomeActive(_ application: UIApplication) {
        self.showAlertController()
    }
    
    func showAlertController() {
        let alertController = UIAlertController(title: "系统提示",
                                                message: message, preferredStyle: .alert)
        alertController.view.backgroundColor = UIColor.clear
        let okAction = UIAlertAction(title: "立即更新", style: .default, handler: {
            action in
            self.open(url: appstoreUrl)
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func open(url: String) {
        if let url = URL(string: url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]),
                                          completionHandler: {
                                            (success) in
                })
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
