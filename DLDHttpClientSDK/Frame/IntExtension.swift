//
//  IntExtension.swift
//  DLDHttpClientSDK
//
//  Created by Frank liao on 2018/8/22.
//  Copyright © 2018年 Frank liao. All rights reserved.
//

import Foundation

public extension Int {
    
    fileprivate var selfDate : Date {
        return Date(timeIntervalSince1970: TimeInterval(self))
    }
    
    func moyaTimeStr() -> String {
        let format = DateFormatter()
        format.dateFormat = "dd/MM/yyyy HH:mm:ss"
        return format.string(from: selfDate)
    }
    
    static var defaultValue: Int {
        return -101
    }
}
