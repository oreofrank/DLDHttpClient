//
//  HttpProgressManager.swift
//  Duliday
//
//  Created by liaohai on 2018/2/1.
//  Copyright © 2018年 Duliday. All rights reserved.
//

import Foundation

let color_ff473d = UIColor.colorWithHexCode(code: "ff473d") //独立日红色

class HttpProgressManager {
	
	static let httpProgressWindow = UIWindow.init(frame: UIScreen.main.bounds)
	static let httpErrorProgressWindow = UIWindow.init(frame: UIScreen.main.bounds)
	
//    static let hud = MBProgressHUD()
//    static let hudError = MBProgressHUD()
	
	class func showProgressHUD(_ show:Bool, view:UIView? = nil) {
		guard show else {
			return
		}
//        hud.bezelView.color = UIColor.clear
//        hud.bezelView.style = .solidColor
//        hud.contentColor = color_ff473d
//
//        if let view = view {
//            view.addSubview(hud)
//            hud.show(animated: true)
//        } else {
//            httpProgressWindow.addSubview(hud)
//            hud.show(animated: true)
//            httpProgressWindow.backgroundColor = UIColor.clear
//            httpProgressWindow.isHidden = false
//            httpProgressWindow.makeKeyAndVisible()
//        }
	}
	
	class func hiddenProcessHUD(_ show:Bool, view:UIView? = nil) {
		guard show else {
			return
		}
//        if let _ = view {
//            hud.hide(animated: true)
//        }else {
//            hud.hide(animated: true)
//            httpProgressWindow.resignKey()
//            httpProgressWindow.isHidden = true
//        }
	}
	
    // interError:内部错误
    class func showErrorProgressHUD(code:Int, interError:Bool = false) {
//        #if DEBUG
//        hudError.mode = .text
//        if interError {
//            hudError.label.text = "业务异常 \(code)"
//        } else {
//            hudError.label.text = "服务器异常 \(code)"
//        }
//        hudError.label.textColor = UIColor.white
//        hudError.label.font = UIFont.systemFont(ofSize: 14)
//        
//        hudError.bezelView.backgroundColor = UIColor.black
//        hudError.bezelView.alpha = 0.2
//        
//        httpErrorProgressWindow.addSubview(hudError)
//        hudError.show(animated: true)
//        httpErrorProgressWindow.backgroundColor = UIColor.clear
//        httpErrorProgressWindow.isHidden = false
//        httpErrorProgressWindow.makeKeyAndVisible()
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//            // your code here
//            hudError.hide(animated: true)
//            httpErrorProgressWindow.resignKey()
//            httpErrorProgressWindow.isHidden = true
//        }
//        #endif
	}
	
}
