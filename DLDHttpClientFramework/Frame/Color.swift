//
//  Color.swift
//  DLDHttpClientFramework
//
//  Created by Frank liao on 2018/6/27.
//  Copyright © 2018年 Frank liao. All rights reserved.
//

import Foundation

extension UIColor {
    
    class func colorWithCustom(r: CGFloat, g:CGFloat, b:CGFloat) -> UIColor {
        return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1)
    }
    
    class func randomColor() -> UIColor {
        let r = CGFloat(arc4random_uniform(256))
        let g = CGFloat(arc4random_uniform(256))
        let b = CGFloat(arc4random_uniform(256))
        return UIColor.colorWithCustom(r: r, g: g, b: b)
    }
    
    
    //UIColor中使用16进制选取颜色
    class  func colorWithHexCode(code: String) -> UIColor{
        
        var cString: String = code.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if cString.count < 6 {return UIColor.black}
        
        
        let fromIdx = cString.index(cString.startIndex, offsetBy: 2)
        let toIdx = cString.index(cString.startIndex, offsetBy: 1)
        
        if cString.hasPrefix("0X") {cString = String(cString.suffix(from: fromIdx))}
        if cString.hasPrefix("#") {cString = String(cString.suffix(from: toIdx))}
        if cString.count != 6 {return UIColor.black}
        
        var range: NSRange = NSMakeRange(0, 2)
        
        let rString = (cString as NSString).substring(with: range)
        range.location = 2
        let gString = (cString as NSString).substring(with: range)
        range.location = 4
        let bString = (cString as NSString).substring(with: range)
        
        var r: UInt32 = 0x0
        var g: UInt32 = 0x0
        var b: UInt32 = 0x0
        Scanner.init(string: rString).scanHexInt32(&r)
        Scanner.init(string: gString).scanHexInt32(&g)
        Scanner.init(string: bString).scanHexInt32(&b)
        
        return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: CGFloat(1))
        
    }
    
    
    
    func getImageByRect(rect:CGRect)->UIImage{//获取一张纯色的图片
        UIGraphicsBeginImageContext(rect.size)
        let context:CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(self.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
}
