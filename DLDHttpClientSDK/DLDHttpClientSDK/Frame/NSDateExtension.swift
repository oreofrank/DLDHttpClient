//
//  NSDateExtension.swift
//  DLDHttpClientSDK
//
//  Created by Frank liao on 2018/8/22.
//  Copyright © 2018年 Frank liao. All rights reserved.
//

import Foundation

extension NSDate {
    
    class func timestamp(date: NSDate, timezone: NSTimeZone) -> String! {
        let interval = TimeInterval(timezone.secondsFromGMT(for: date as Date))
        let localeDate = date.addingTimeInterval(interval)
        let timestamp = NSString.localizedStringWithFormat("%ld", Int64(localeDate.timeIntervalSince1970))
        return String(timestamp)
    }
    
    class func currentTimestamp(
        timezone: NSTimeZone) -> String! {
        let date = NSDate()
        return timestamp(date: date, timezone: timezone)
    }
    
    class func currentLocalTimestamp() -> String! {
        let timezone = NSTimeZone.system
        return currentTimestamp(timezone: timezone as NSTimeZone)
    }
    
}
