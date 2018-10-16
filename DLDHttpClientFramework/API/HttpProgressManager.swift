//
//  HttpProgressManager.swift
//  Duliday
//
//  Created by liaohai on 2018/2/1.
//  Copyright © 2018年 Duliday. All rights reserved.
//

import Foundation

let HttpProgressErrorTag = false

class HttpProgressManager {
    
    static let httpProgressWindow = UIWindow.init(frame: UIScreen.main.bounds)
    static let httpErrorProgressWindow = UIWindow.init(frame: UIScreen.main.bounds)
    
    static let hud = UIActivityIndicatorView(activityIndicatorStyle:UIActivityIndicatorViewStyle.gray)
    
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
            hud.center = httpProgressWindow.center
            hud.startAnimating()
            hud.color = UIColor.colorWithHexCode(code: "ff473d")
            httpProgressWindow.addSubview(hud)
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
