//
//  HttpCommend.swift
//  DLDHttpClientFramework
//
//  Created by Frank liao on 2018/10/16.
//  Copyright © 2018年 Frank liao. All rights reserved.
//

import Foundation

// 日志开关
var isOpenConsoleOutput = true
// 服务器时间差
var diffientTimeInterval: TimeInterval = 0
// tag区分
var headerTagField = "Duliday-Cache-Tag"
// 强制更新跳转
var appstoreUrl = ""
// 强制更新code
var updateCode = 600

var reponseError:HttpReponseError? = nil

public class DLDHttpCommend {
    public class func setConsoleOutput(_ open: Bool) {
        isOpenConsoleOutput = open
    }
    
    public class func getDiffientTime() -> TimeInterval {
        return diffientTimeInterval
    }
    
    public class func setHeaderTag(_ tag: String) {
        headerTagField = tag
    }
    
    public class func setAppstoreUrl(_ url: String) {
        appstoreUrl = url
    }
    
    public class func setUpdateCode(_ code: Int) {
        updateCode = code
    }
    
    public class func setReponseError(response: @escaping HttpReponseError) {
        reponseError = response
    }
    
}
