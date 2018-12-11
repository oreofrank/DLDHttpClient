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
            let statusBarOrientation = UIApplication.shared.statusBarOrientation
            if statusBarOrientation.isLandscape {
                let frame = httpProgressWindow.frame
                if frame.equalTo(UIScreen.main.bounds) {
                    httpProgressWindow.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.height, height: frame.size.width)
                }
            }
            httpProgressWindow.addSubview(hud)
            hud.center = httpProgressWindow.center
            hud.startAnimating()
            hud.color = UIColor.colorWithHexCode(code: "ff473d")
            httpProgressWindow.backgroundColor = UIColor.clear
            httpProgressWindow.isHidden = false
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

