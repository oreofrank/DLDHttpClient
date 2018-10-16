//
//  HttpRequestType.swift
//  Duliday
//
//  Created by Frank liao on 2018/6/20.
//  Copyright © 2018年 Duliday. All rights reserved.
//

import Foundation
import Moya
import RxSwift

/*
 扩展TargetType
 http缓存索引：链接加参数
*/
public protocol RequestTargetType:TargetType {
    var parames:[String : Any] { get }
}
