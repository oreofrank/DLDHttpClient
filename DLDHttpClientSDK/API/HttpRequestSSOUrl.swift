//
//  HttpRequestSSOUrl.swift
//  Duliday
//
//  Created by Frank liao on 2018/8/1.
//  Copyright © 2018年 Duliday. All rights reserved.
//

import Foundation

// 域名 baseRequestSSOURL
public enum RequestSSOUrl:String {
    public typealias RawValue = String
    
    case urlSSO = "sso" // SSO域名
    case setPassword = "/api/auth/setPassword" // 设置密码(首次快捷登录时使用)
    case fastLogin = "/api/auth/fastLogin" // 快捷登录
    case getCheckCode = "/api/auth/verificationCode" // 获取验证码
    case login = "/api/auth/login" // 登录
    case logout = "/api/auth/logout" // 退出登录
    case updatePassword = "/api/auth/info/update" // 修改密码
    case forgetPassword = "/api/auth/info/reset" // 忘记密码

}
