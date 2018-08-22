//
//  BaseModel.swift
//  DulidayB
//
//  Created by liaohai on 2018/3/22.
//  Copyright © 2018年 Duliday. All rights reserved.
//

import Foundation
import HandyJSON

class BaseModel:HandyJSON {
	var message:String! = String.defaultValue
	var code:Int! = Int.defaultValue

	required init() {
		
	}
}
