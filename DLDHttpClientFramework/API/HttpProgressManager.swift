//
//  HttpProgressManager.swift
//  Duliday
//  http 加载菊花
//  Created by liaohai on 2018/2/1.
//  Copyright © 2018年 Duliday. All rights reserved.
//

import Foundation

let HttpProgressErrorTag = false

class HttpProgressManager {
    
    static let httpProgressWindow = UIWindow.init(frame: UIScreen.main.bounds)
    
    static let hud = UIActivityIndicatorView(style:UIActivityIndicatorView.Style.gray)
    
    class func showProgressHUD(_ show:Bool, view:UIView? = nil) {
        guard show else {
            return
        }
        
        if let view = view {
            view.addSubview(hud)
            hud.center = view.center
            hud.startAnimating()
            hud.color = UIColor.colorWithHexCode(code: "ff473d")
        } else {
            let rootViewController = ProgressUIViewController()
            hud.center = rootViewController.view.center
            hud.startAnimating()
            hud.color = UIColor.colorWithHexCode(code: "ff473d")
            rootViewController.view.addSubview(hud)
            rootViewController.view.backgroundColor = UIColor.clear
            httpProgressWindow.backgroundColor = UIColor.clear
            httpProgressWindow.isHidden = false
            httpProgressWindow.rootViewController = rootViewController
            httpProgressWindow.makeKeyAndVisible()
        }
    }
    
    class func hiddenProcessHUD(_ show:Bool, view:UIView? = nil) {
        guard show else {
            return
        }
        if let _ = view {
            hud.removeFromSuperview()
        }else {
            hud.removeFromSuperview()
            httpProgressWindow.resignKey()
            httpProgressWindow.isHidden = true
        }
    }
    
}

class ProgressUIViewController:UIViewController {
    
    override var shouldAutorotate: Bool {
        return true
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIApplication.shared.statusBarOrientation
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

