//
//  BaseModel.swift
//  DulidayB
//
//  Created by liaohai on 2018/3/22.
//  Copyright © 2018年 Duliday. All rights reserved.
//

import Foundation
import HandyJSON

public class BaseModel:HandyJSON {
    public var message:String! = String.defaultValue
    public var code:Int! = Int.defaultValue
    
    required public init() {
        
    }
}
