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

public protocol RequestTargetType:TargetType {
    var parames:[String : Any] { get }
}
